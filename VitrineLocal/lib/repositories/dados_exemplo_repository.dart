import 'dart:math';

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/categoria.dart';
import '../models/cliente.dart';
import '../models/divulgacao.dart';
import '../models/empresa.dart';
import '../models/item_pedido.dart';
import '../models/pedido.dart';
import '../models/produto.dart';

class _ProdutoExemplo {
  const _ProdutoExemplo(
    this.nome,
    this.categoria,
    this.precoCentavos,
    this.estoque,
    this.popularidade,
  );

  final String nome;
  final String categoria;
  final int precoCentavos;
  final int estoque;
  final int popularidade;
}

class _ClienteExemplo {
  const _ClienteExemplo(
    this.nome,
    this.telefone,
    this.pedidos,
    this.primeiraCompraDias,
    this.ultimaCompraDias,
  );

  final String nome;
  final String telefone;
  final int pedidos;
  final int primeiraCompraDias;
  final int ultimaCompraDias;
}

const _produtos = [
  _ProdutoExemplo('Brigadeiro', 'Doces', 250, 40, 10),
  _ProdutoExemplo('Bolo de pote', 'Doces', 1200, 8, 6),
  _ProdutoExemplo('Torta de limão (fatia)', 'Doces', 900, 3, 3),
  _ProdutoExemplo('Brownie', 'Doces', 700, 15, 4),
  _ProdutoExemplo('Pudim', 'Doces', 1500, 2, 1),
  _ProdutoExemplo('Coxinha', 'Salgados', 600, 30, 9),
  _ProdutoExemplo('Empada', 'Salgados', 650, 12, 5),
  _ProdutoExemplo('Pão de queijo (6 un.)', 'Salgados', 1000, 4, 3),
  _ProdutoExemplo('Esfiha', 'Salgados', 550, 20, 2),
  _ProdutoExemplo('Quiche', 'Salgados', 1400, 1, 1),
  _ProdutoExemplo('Suco natural', 'Bebidas', 800, 25, 4),
  _ProdutoExemplo('Café', 'Bebidas', 400, 50, 3),
  _ProdutoExemplo('Refrigerante lata', 'Bebidas', 600, 6, 2),
];

const _clientes = [
  _ClienteExemplo('Ana Souza', '54991110001', 12, 150, 2),
  _ClienteExemplo('Bruno Lima', '54991110002', 9, 120, 5),
  _ClienteExemplo('Carla Mendes', '54991110003', 8, 90, 1),
  _ClienteExemplo('Diego Rocha', '54991110004', 6, 80, 3),
  _ClienteExemplo('Elisa Martins', '54991110005', 2, 20, 3),
  _ClienteExemplo('Felipe Costa', '54991110006', 1, 10, 10),
  _ClienteExemplo('Gabriela Alves', '54991110007', 2, 28, 6),
  _ClienteExemplo('Henrique Dias', '54991110008', 4, 160, 75),
  _ClienteExemplo('Isabela Nunes', '54991110009', 3, 140, 90),
  _ClienteExemplo('João Pereira', '54991110010', 2, 110, 65),
  _ClienteExemplo('Karina Torres', '54991110011', 3, 175, 130),
  _ClienteExemplo('Lucas Ferreira', '54991110012', 1, 160, 160),
  _ClienteExemplo('Mariana Silva', '54991110013', 0, 200, 200),
  _ClienteExemplo('Nicolas Ribeiro', '54991110014', 0, 45, 45),
];

const _diasDeHistorico = 150;

class DadosExemploRepository {
  final _helper = DatabaseHelper.instance;
  final _sorteio = Random(42);

  Future<bool> bancoVazio() async {
    final db = await _helper.database;
    final total = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT (SELECT COUNT(*) FROM produto) + (SELECT COUNT(*) FROM cliente)',
      ),
    );
    return total == 0;
  }

  Future<void> carregar() async {
    final db = await _helper.database;
    final hoje = DateTime.now();

    await db.transaction((txn) async {
      await txn.insert(
        'empresa',
        const Empresa(
          nome: 'Doces & Salgados da Vila',
          slogan: 'Feito em casa, todo dia',
          whatsapp: '54999990000',
          instagram: 'docesdavila',
          horarioAtendimento: 'Seg a sáb, 8h às 19h',
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      final categorias = <String, int>{};
      for (final nome in {for (final p in _produtos) p.categoria}) {
        categorias[nome] = await txn.insert(
          'categoria',
          Categoria(nome: nome).toMap(),
        );
      }

      final produtoIds = <int>[];
      for (final produto in _produtos) {
        produtoIds.add(
          await txn.insert(
            'produto',
            Produto(
              categoriaId: categorias[produto.categoria],
              nome: produto.nome,
              precoCentavos: produto.precoCentavos,
              estoque: produto.estoque,
              criadoEm: hoje.subtract(const Duration(days: _diasDeHistorico)),
            ).toMap(),
          ),
        );
      }

      final compras = <(DateTime, int?)>[];
      for (final cliente in _clientes) {
        final clienteId = await txn.insert(
          'cliente',
          Cliente(
            nome: cliente.nome,
            telefone: cliente.telefone,
            criadoEm: _diasAtras(hoje, cliente.primeiraCompraDias),
          ).toMap(),
        );
        for (var i = 0; i < cliente.pedidos; i++) {
          final intervalo =
              cliente.primeiraCompraDias - cliente.ultimaCompraDias;
          final dias = cliente.pedidos == 1
              ? cliente.ultimaCompraDias
              : cliente.primeiraCompraDias -
                    intervalo * i ~/ (cliente.pedidos - 1);
          compras.add((_diasAtras(hoje, dias), clienteId));
        }
      }

      for (var dias = _diasDeHistorico; dias >= 0; dias--) {
        final vendasDoDia = _sorteio.nextInt(3) + (dias < 30 ? 1 : 0);
        for (var i = 0; i < vendasDoDia; i++) {
          compras.add((_diasAtras(hoje, dias), null));
        }
      }

      for (final (data, clienteId) in compras) {
        await _inserirPedido(txn, data, clienteId, produtoIds, hoje);
      }

      for (var dias = _diasDeHistorico; dias > 0; dias -= 12) {
        await txn.insert(
          'divulgacao',
          Divulgacao(
            canal: dias % 24 == 0 ? Canal.instagram : Canal.whatsapp,
            dataEnvio: _diasAtras(hoje, dias),
            qtdProdutos: _produtos.length,
          ).toMap(),
        );
      }
    });
  }

  DateTime _diasAtras(DateTime hoje, int dias) {
    final dia = DateTime(hoje.year, hoje.month, hoje.day - dias);
    final momento = dia.add(Duration(hours: 8 + _sorteio.nextInt(11)));
    return momento.isAfter(hoje) ? hoje : momento;
  }

  Future<void> _inserirPedido(
    Transaction txn,
    DateTime data,
    int? clienteId,
    List<int> produtoIds,
    DateTime hoje,
  ) async {
    final itens = <ItemPedido>[];
    final quantidadeDeProdutos = 1 + _sorteio.nextInt(3);

    while (itens.length < quantidadeDeProdutos) {
      final indice = _sortearProduto();
      if (itens.any((item) => item.produtoId == produtoIds[indice])) continue;

      itens.add(
        ItemPedido(
          produtoId: produtoIds[indice],
          produtoNome: _produtos[indice].nome,
          quantidade: 1 + _sorteio.nextInt(4),
          precoUnitCentavos: _produtos[indice].precoCentavos,
        ),
      );
    }

    final subtotal = somarItens(itens);
    final desconto = _sorteio.nextInt(10) == 0 ? subtotal ~/ 10 : 0;
    final recente = hoje.difference(data).inDays < 3;
    final sorteioStatus = _sorteio.nextInt(20);
    final status = sorteioStatus == 0
        ? StatusPedido.cancelado
        : recente && sorteioStatus < 8
        ? StatusPedido.aberto
        : StatusPedido.pago;

    final pedidoId = await txn.insert(
      'pedido',
      Pedido(
        clienteId: clienteId,
        dataPedido: data,
        status: status,
        formaPagamento: FormaPagamento
            .values[_sorteio.nextInt(FormaPagamento.values.length)],
        descontoCentavos: desconto,
        totalCentavos: subtotal - desconto,
      ).toMap(),
    );

    for (final item in itens) {
      await txn.insert('item_pedido', item.toMap(pedidoId));
    }
  }

  int _sortearProduto() {
    final total = _produtos.fold(0, (soma, p) => soma + p.popularidade);
    var alvo = _sorteio.nextInt(total);
    for (var i = 0; i < _produtos.length; i++) {
      alvo -= _produtos[i].popularidade;
      if (alvo < 0) return i;
    }
    return 0;
  }
}
