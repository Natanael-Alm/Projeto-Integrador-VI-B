import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/pedido.dart';
import '../models/relatorio.dart';

class RelatorioRepository {
  final _helper = DatabaseHelper.instance;

  String _inicio(DateTime dia) =>
      DateTime(dia.year, dia.month, dia.day).toIso8601String();

  String _fimExclusivo(DateTime dia) =>
      DateTime(dia.year, dia.month, dia.day + 1).toIso8601String();

  Future<ResumoVendas> resumo(DateTime de, DateTime ate) async {
    final db = await _helper.database;
    final vendas = (await db.rawQuery(
      '''
      SELECT COALESCE(SUM(total_centavos), 0) AS faturamento,
             COUNT(*) AS pedidos
      FROM pedido
      WHERE status = ? AND data_pedido >= ? AND data_pedido < ?
      ''',
      [StatusPedido.pago.valor, _inicio(de), _fimExclusivo(ate)],
    )).first;

    final novosClientes = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM cliente WHERE criado_em >= ? AND criado_em < ?',
        [_inicio(de), _fimExclusivo(ate)],
      ),
    );

    return ResumoVendas(
      faturamentoCentavos: vendas['faturamento'] as int,
      pedidos: vendas['pedidos'] as int,
      novosClientes: novosClientes ?? 0,
    );
  }

  Future<List<VendaDoDia>> vendasPorDia(DateTime de, DateTime ate) async {
    final db = await _helper.database;
    final linhas = await db.rawQuery(
      '''
      SELECT substr(data_pedido, 1, 10) AS dia,
             SUM(total_centavos) AS total
      FROM pedido
      WHERE status = ? AND data_pedido >= ? AND data_pedido < ?
      GROUP BY dia
      ''',
      [StatusPedido.pago.valor, _inicio(de), _fimExclusivo(ate)],
    );
    final totalPorDia = {
      for (final linha in linhas) linha['dia'] as String: linha['total'] as int,
    };

    // Dias sem venda também entram na lista, com zero.
    final dias = <VendaDoDia>[];
    for (
      var dia = DateTime(de.year, de.month, de.day);
      !dia.isAfter(ate);
      dia = DateTime(dia.year, dia.month, dia.day + 1)
    ) {
      final chave = dia.toIso8601String().substring(0, 10);
      dias.add(VendaDoDia(dia, totalPorDia[chave] ?? 0));
    }
    return dias;
  }

  Future<List<ProdutoVendido>> maisVendidos(
    DateTime de,
    DateTime ate, {
    int? limite,
  }) async {
    final db = await _helper.database;
    final linhas = await db.rawQuery(
      '''
      SELECT pr.nome,
             SUM(i.quantidade) AS quantidade,
             SUM(i.quantidade * i.preco_unit_centavos) AS receita
      FROM item_pedido i
      JOIN pedido p ON p.id = i.pedido_id
      JOIN produto pr ON pr.id = i.produto_id
      WHERE p.status = ? AND p.data_pedido >= ? AND p.data_pedido < ?
      GROUP BY pr.id
      ORDER BY receita DESC
      LIMIT ?
      ''',
      [StatusPedido.pago.valor, _inicio(de), _fimExclusivo(ate), limite ?? -1],
    );

    return [
      for (final linha in linhas)
        ProdutoVendido(
          nome: linha['nome'] as String,
          quantidade: linha['quantidade'] as int,
          receitaCentavos: linha['receita'] as int,
        ),
    ];
  }
}
