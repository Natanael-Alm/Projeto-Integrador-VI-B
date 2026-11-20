import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/empresa.dart';

class EmpresaRepository {
  EmpresaRepository([DatabaseHelper? helper])
      : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  Future<Empresa?> buscar() async {
    final db = await _helper.database;
    final linhas = await db.query('empresa', where: 'id = 1');
    return linhas.isEmpty ? null : Empresa.fromMap(linhas.first);
  }

  Future<void> salvar(Empresa empresa) async {
    final db = await _helper.database;
    await db.insert(
      'empresa',
      empresa.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
