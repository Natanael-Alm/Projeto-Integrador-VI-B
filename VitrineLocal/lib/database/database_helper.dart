import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'esquema.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async => _db ??= await _abrir();

  Future<String> caminho() async =>
      join(await getDatabasesPath(), 'vitrine.db');

  Future<void> fechar() async {
    await _db?.close();
    _db = null;
  }

  Future<Database> _abrir() async {
    return openDatabase(
      await caminho(),
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        final lote = db.batch();
        for (final comando in comandosCriacao) {
          lote.execute(comando);
        }
        await lote.commit(noResult: true);
      },
    );
  }
}
