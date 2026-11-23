import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'esquema.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async => _db ??= await _abrir();

  Future<Database> _abrir() async {
    return openDatabase(
      join(await getDatabasesPath(), 'vitrine.db'),
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
