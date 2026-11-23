import '../database/database_helper.dart';
import '../models/divulgacao.dart';

class DivulgacaoRepository {
  final _helper = DatabaseHelper.instance;

  Future<int> registrar(Divulgacao divulgacao) async {
    final db = await _helper.database;
    return db.insert('divulgacao', divulgacao.toMap());
  }

  Future<List<Divulgacao>> listar() async {
    final db = await _helper.database;
    final linhas = await db.query('divulgacao', orderBy: 'data_envio DESC');
    return linhas.map(Divulgacao.fromMap).toList();
  }
}
