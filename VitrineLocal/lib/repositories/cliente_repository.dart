import '../database/database_helper.dart';
import '../models/cliente.dart';

class ClienteRepository {
  final _helper = DatabaseHelper.instance;

  Future<List<Cliente>> listar({String busca = ''}) async {
    final texto = busca.trim();
    final db = await _helper.database;
    final linhas = await db.query(
      'cliente',
      where: texto.isEmpty ? null : 'nome LIKE ? OR telefone LIKE ?',
      whereArgs: texto.isEmpty ? null : ['%$texto%', '%$texto%'],
      orderBy: 'nome COLLATE NOCASE',
    );
    return linhas.map(Cliente.fromMap).toList();
  }

  Future<int> salvar(Cliente cliente) async {
    final db = await _helper.database;
    if (cliente.id == null) return db.insert('cliente', cliente.toMap());

    await db.update(
      'cliente',
      cliente.toMap(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
    return cliente.id!;
  }

  Future<void> excluir(int id) async {
    final db = await _helper.database;
    await db.delete('cliente', where: 'id = ?', whereArgs: [id]);
  }
}
