import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/pedido.dart';
import '../models/produto.dart';
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

  Future<List<ClienteComPerfil>> perfisDeClientes() async {
    final hoje = DateTime.now();
    final db = await _helper.database;
    final linhas = await db.rawQuery(
      '''
      SELECT c.nome,
             MIN(p.data_pedido) AS primeira_compra,
             MAX(p.data_pedido) AS ultima_compra,
             SUM(CASE WHEN p.data_pedido >= ? THEN 1 ELSE 0 END) AS pedidos_90_dias
      FROM cliente c
      LEFT JOIN pedido p ON p.cliente_id = c.id AND p.status != ?
      GROUP BY c.id
      ORDER BY c.nome COLLATE NOCASE
      ''',
      [
        _inicio(DateTime(hoje.year, hoje.month, hoje.day - 90)),
        StatusPedido.cancelado.valor,
      ],
    );

    return [for (final linha in linhas) _classificar(linha, hoje)];
  }

  // RN07: classificação por recência e frequência de compra.
  ClienteComPerfil _classificar(Map<String, Object?> linha, DateTime hoje) {
    final nome = linha['nome'] as String;
    final ultimaCompra = linha['ultima_compra'] as String?;
    if (ultimaCompra == null) {
      return ClienteComPerfil(nome: nome, perfil: PerfilCliente.inativo);
    }

    final primeiraCompra = linha['primeira_compra'] as String;
    final diasPrimeira = hoje.difference(DateTime.parse(primeiraCompra)).inDays;
    final diasUltima = hoje.difference(DateTime.parse(ultimaCompra)).inDays;
    final pedidos90Dias = linha['pedidos_90_dias'] as int;

    final PerfilCliente perfil;
    if (diasPrimeira <= 30) {
      perfil = PerfilCliente.novo;
    } else if (pedidos90Dias >= 3) {
      perfil = PerfilCliente.fiel;
    } else if (diasUltima < 60) {
      perfil = PerfilCliente.regular;
    } else if (diasUltima <= 120) {
      perfil = PerfilCliente.emRisco;
    } else {
      perfil = PerfilCliente.inativo;
    }

    return ClienteComPerfil(
      nome: nome,
      perfil: perfil,
      diasDesdeUltimaCompra: diasUltima,
    );
  }

  Future<List<Produto>> estoqueBaixo(int limite) async {
    final db = await _helper.database;
    final linhas = await db.query(
      'produto',
      where: 'ativo = 1 AND estoque <= ?',
      whereArgs: [limite],
      orderBy: 'estoque, nome COLLATE NOCASE',
    );
    return linhas.map(Produto.fromMap).toList();
  }

  Future<EfeitoDivulgacao> efeitoDivulgacao(DateTime de, DateTime ate) async {
    final db = await _helper.database;
    final linhas = await db.rawQuery(
      '''
      SELECT d.id, COUNT(p.id) AS pedidos
      FROM divulgacao d
      LEFT JOIN pedido p
        ON p.status = ?
       AND p.data_pedido >= d.data_envio
       AND p.data_pedido < strftime('%Y-%m-%dT%H:%M:%S', d.data_envio, '+3 days')
      WHERE d.data_envio >= ? AND d.data_envio < ?
      GROUP BY d.id
      ''',
      [StatusPedido.pago.valor, _inicio(de), _fimExclusivo(ate)],
    );

    final compartilhamentos = linhas.length;
    final pedidosDepois = linhas.fold(
      0,
      (soma, linha) => soma + (linha['pedidos'] as int),
    );
    final diasNoPeriodo = ate.difference(de).inDays + 1;
    final resumoDoPeriodo = await resumo(de, ate);

    return EfeitoDivulgacao(
      compartilhamentos: compartilhamentos,
      pedidosPorDiaDepois: compartilhamentos == 0
          ? 0
          : pedidosDepois / (compartilhamentos * 3),
      pedidosPorDiaGeral: resumoDoPeriodo.pedidos / diasNoPeriodo,
    );
  }
}
