import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'esquema.dart';

class DatabaseHelper {
  DatabaseHelper._(this._caminho);

  static final instance = DatabaseHelper._('vitrine.db');

  factory DatabaseHelper.emMemoria() => DatabaseHelper._(inMemoryDatabasePath);

  final String _caminho;
  Database? _db;

  Future<Database> get database async => _db ??= await _abrir();

  Future<Database> _abrir() async {
    final caminho = _caminho == inMemoryDatabasePath
        ? _caminho
        : join(await getDatabasesPath(), _caminho);

    return openDatabase(
      caminho,
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

  Future<void> fechar() async {
    await _db?.close();
    _db = null;
  }
}
