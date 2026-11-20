import '../database/database_helper.dart';
import '../models/categoria.dart';

class CategoriaRepository {
  CategoriaRepository([DatabaseHelper? helper])
      : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  Future<List<Categoria>> listar() async {
    final db = await _helper.database;
    final linhas = await db.query('categoria', orderBy: 'nome COLLATE NOCASE');
    return linhas.map(Categoria.fromMap).toList();
  }

  Future<int> salvar(Categoria categoria) async {
    final db = await _helper.database;
    if (categoria.id == null) return db.insert('categoria', categoria.toMap());

    await db.update(
      'categoria',
      categoria.toMap(),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
    return categoria.id!;
  }

  Future<void> excluir(int id) async {
    final db = await _helper.database;
    await db.delete('categoria', where: 'id = ?', whereArgs: [id]);
  }
}
