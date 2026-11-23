import '../database/database_helper.dart';
import '../models/item_pedido.dart';
import '../models/pedido.dart';
import 'regra_negocio_exception.dart';

class PedidoRepository {
  final _helper = DatabaseHelper.instance;

  Future<List<Pedido>> listar({
    StatusPedido? status,
    DateTime? de,
    DateTime? ate,
    int? clienteId,
  }) async {
    final filtros = <String>[];
    final argumentos = <Object>[];

    if (status != null) {
      filtros.add('p.status = ?');
      argumentos.add(status.valor);
    }
    if (de != null) {
      filtros.add('p.data_pedido >= ?');
      argumentos.add(DateTime(de.year, de.month, de.day).toIso8601String());
    }
    if (ate != null) {
      filtros.add('p.data_pedido < ?');
      argumentos.add(
        DateTime(ate.year, ate.month, ate.day + 1).toIso8601String(),
      );
    }
    if (clienteId != null) {
      filtros.add('p.cliente_id = ?');
      argumentos.add(clienteId);
    }

    final where = filtros.isEmpty ? '' : 'WHERE ${filtros.join(' AND ')}';
    final db = await _helper.database;
    final linhas = await db.rawQuery('''
      SELECT p.*, c.nome AS cliente_nome
      FROM pedido p
      LEFT JOIN cliente c ON c.id = p.cliente_id
      $where
      ORDER BY p.data_pedido DESC
    ''', argumentos);
    return linhas.map(Pedido.fromMap).toList();
  }

  Future<List<ItemPedido>> listarItens(int pedidoId) async {
    final db = await _helper.database;
    final linhas = await db.rawQuery(
      '''
      SELECT i.*, pr.nome AS produto_nome
      FROM item_pedido i
      JOIN produto pr ON pr.id = i.produto_id
      WHERE i.pedido_id = ?
      ORDER BY pr.nome COLLATE NOCASE
    ''',
      [pedidoId],
    );
    return linhas.map(ItemPedido.fromMap).toList();
  }

  Future<int> registrar({
    int? clienteId,
    required List<ItemPedido> itens,
    int descontoCentavos = 0,
    FormaPagamento? formaPagamento,
    bool pago = false,
  }) async {
    if (itens.isEmpty) {
      throw const RegraNegocioException('Adicione pelo menos um produto');
    }

    final db = await _helper.database;
    return db.transaction((txn) async {
      final itensConferidos = <ItemPedido>[];

      for (final item in itens) {
        final linhas = await txn.query(
          'produto',
          columns: ['nome', 'preco_centavos', 'estoque'],
          where: 'id = ?',
          whereArgs: [item.produtoId],
        );
        if (linhas.isEmpty) {
          throw RegraNegocioException('${item.produtoNome} não existe mais');
        }

        final produto = linhas.first;
        final nome = produto['nome'] as String;
        final estoque = produto['estoque'] as int;

        if (item.quantidade <= 0) {
          throw RegraNegocioException('Quantidade inválida para $nome');
        }
        if (item.quantidade > estoque) {
          throw RegraNegocioException(
            'Estoque insuficiente de $nome (restam $estoque)',
          );
        }

        itensConferidos.add(
          ItemPedido(
            produtoId: item.produtoId,
            produtoNome: nome,
            quantidade: item.quantidade,
            precoUnitCentavos: produto['preco_centavos'] as int,
          ),
        );
      }

      final subtotal = somarItens(itensConferidos);
      if (descontoCentavos < 0 || descontoCentavos > subtotal) {
        throw const RegraNegocioException(
          'O desconto não pode ser maior que o valor dos produtos',
        );
      }

      final pedidoId = await txn.insert(
        'pedido',
        Pedido(
          clienteId: clienteId,
          dataPedido: DateTime.now(),
          status: pago ? StatusPedido.pago : StatusPedido.aberto,
          formaPagamento: formaPagamento,
          descontoCentavos: descontoCentavos,
          totalCentavos: subtotal - descontoCentavos,
        ).toMap(),
      );

      for (final item in itensConferidos) {
        await txn.insert('item_pedido', item.toMap(pedidoId));
        await txn.rawUpdate(
          'UPDATE produto SET estoque = estoque - ? WHERE id = ?',
          [item.quantidade, item.produtoId],
        );
      }

      return pedidoId;
    });
  }

  Future<void> marcarComoPago(int pedidoId) async {
    final db = await _helper.database;
    await db.update(
      'pedido',
      {'status': StatusPedido.pago.valor},
      where: 'id = ? AND status = ?',
      whereArgs: [pedidoId, StatusPedido.aberto.valor],
    );
  }

  Future<void> cancelar(int pedidoId) async {
    final db = await _helper.database;
    await db.transaction((txn) async {
      final alterados = await txn.update(
        'pedido',
        {'status': StatusPedido.cancelado.valor},
        where: 'id = ? AND status != ?',
        whereArgs: [pedidoId, StatusPedido.cancelado.valor],
      );
      if (alterados == 0) return;

      final itens = await txn.query(
        'item_pedido',
        where: 'pedido_id = ?',
        whereArgs: [pedidoId],
      );
      for (final item in itens) {
        await txn.rawUpdate(
          'UPDATE produto SET estoque = estoque + ? WHERE id = ?',
          [item['quantidade'], item['produto_id']],
        );
      }
    });
  }
}
