import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vitrine/database/database_helper.dart';
import 'package:vitrine/models/categoria.dart';
import 'package:vitrine/models/produto.dart';
import 'package:vitrine/repositories/categoria_repository.dart';
import 'package:vitrine/repositories/produto_repository.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseHelper helper;
  late ProdutoRepository produtos;
  late CategoriaRepository categorias;

  setUp(() {
    helper = DatabaseHelper.emMemoria();
    produtos = ProdutoRepository(helper);
    categorias = CategoriaRepository(helper);
  });

  tearDown(() => helper.fechar());

  Produto novoProduto(String nome, {int? categoriaId, bool ativo = true}) =>
      Produto(
        nome: nome,
        categoriaId: categoriaId,
        precoCentavos: 1000,
        estoque: 5,
        ativo: ativo,
        criadoEm: DateTime(2026, 11, 20),
      );

  test('insere e lista produtos em ordem alfabética', () async {
    await produtos.salvar(novoProduto('Bolo'));
    await produtos.salvar(novoProduto('açaí'));

    final lista = await produtos.listar();

    expect(lista.map((p) => p.nome), ['açaí', 'Bolo']);
    expect(lista.first.precoCentavos, 1000);
  });

  test('busca por nome, categoria e somente ativos', () async {
    final doces = await categorias.salvar(const Categoria(nome: 'Doces'));
    await produtos.salvar(novoProduto('Brigadeiro', categoriaId: doces));
    await produtos.salvar(novoProduto('Beijinho', categoriaId: doces, ativo: false));
    await produtos.salvar(novoProduto('Coxinha'));

    expect((await produtos.listar(busca: 'briga')).single.nome, 'Brigadeiro');
    expect(await produtos.listar(categoriaId: doces), hasLength(2));
    expect(await produtos.listar(somenteAtivos: true), hasLength(2));
  });

  test('exclui produto que nunca foi vendido', () async {
    final id = await produtos.salvar(novoProduto('Bolo'));

    expect(await produtos.excluir(id), isTrue);
    expect(await produtos.listar(), isEmpty);
  });

  test('RN06: produto já vendido é desativado em vez de excluído', () async {
    final id = await produtos.salvar(novoProduto('Bolo'));
    final db = await helper.database;
    final pedidoId = await db.insert('pedido', {
      'data_pedido': '2026-11-20T10:00:00',
      'status': 'PAGO',
      'total_centavos': 1000,
    });
    await db.insert('item_pedido', {
      'pedido_id': pedidoId,
      'produto_id': id,
      'quantidade': 1,
      'preco_unit_centavos': 1000,
    });

    expect(await produtos.excluir(id), isFalse);

    final produto = (await produtos.listar()).single;
    expect(produto.ativo, isFalse);
  });

  test('excluir categoria deixa o produto sem categoria', () async {
    final doces = await categorias.salvar(const Categoria(nome: 'Doces'));
    await produtos.salvar(novoProduto('Brigadeiro', categoriaId: doces));

    await categorias.excluir(doces);

    expect((await produtos.listar()).single.categoriaId, isNull);
  });

  test('não permite categorias com o mesmo nome', () async {
    await categorias.salvar(const Categoria(nome: 'Doces'));

    expect(
      () => categorias.salvar(const Categoria(nome: 'Doces')),
      throwsA(isA<DatabaseException>()),
    );
  });
}
