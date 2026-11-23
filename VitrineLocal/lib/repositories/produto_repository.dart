import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/produto.dart';

class ProdutoRepository {
  final _helper = DatabaseHelper.instance;

  Future<List<Produto>> listar({
    String busca = '',
    int? categoriaId,
    bool somenteAtivos = false,
  }) async {
    final filtros = <String>[];
    final argumentos = <Object>[];

    if (busca.trim().isNotEmpty) {
      filtros.add('nome LIKE ?');
      argumentos.add('%${busca.trim()}%');
    }
    if (categoriaId != null) {
      filtros.add('categoria_id = ?');
      argumentos.add(categoriaId);
    }
    if (somenteAtivos) filtros.add('ativo = 1');

    final db = await _helper.database;
    final linhas = await db.query(
      'produto',
      where: filtros.isEmpty ? null : filtros.join(' AND '),
      whereArgs: argumentos,
      orderBy: 'nome COLLATE NOCASE',
    );
    return linhas.map(Produto.fromMap).toList();
  }

  Future<int> salvar(Produto produto) async {
    final db = await _helper.database;
    if (produto.id == null) return db.insert('produto', produto.toMap());

    await db.update(
      'produto',
      produto.toMap(),
      where: 'id = ?',
      whereArgs: [produto.id],
    );
    return produto.id!;
  }

  Future<void> alterarAtivo(int id, bool ativo) async {
    final db = await _helper.database;
    await db.update(
      'produto',
      {'ativo': ativo ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// RN06: produto que já aparece em pedidos é apenas desativado.
  /// Retorna `true` se o produto foi excluído e `false` se foi desativado.
  Future<bool> excluir(int id) async {
    final db = await _helper.database;
    final vendas = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM item_pedido WHERE produto_id = ?',
      [id],
    ));

    if (vendas != null && vendas > 0) {
      await alterarAtivo(id, false);
      return false;
    }

    await db.delete('produto', where: 'id = ?', whereArgs: [id]);
    return true;
  }
}
