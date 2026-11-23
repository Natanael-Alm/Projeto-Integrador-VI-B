import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../database/database_helper.dart';

class BackupRepository {
  final _helper = DatabaseHelper.instance;

  Future<Directory> _pasta() async {
    final documentos = await getApplicationDocumentsDirectory();
    final pasta = Directory(join(documentos.path, 'backups'));
    await pasta.create(recursive: true);
    return pasta;
  }

  Future<List<File>> listar() async {
    final pasta = await _pasta();
    final backups = pasta
        .listSync()
        .whereType<File>()
        .where((arquivo) => arquivo.path.endsWith('.db'))
        .toList();
    backups.sort((a, b) => b.path.compareTo(a.path));
    return backups;
  }

  Future<File> criar() async {
    final pasta = await _pasta();
    final data = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());

    // O banco é fechado para a cópia sair completa; ele reabre sozinho no próximo uso.
    await _helper.fechar();
    final banco = File(await _helper.caminho());
    return banco.copy(join(pasta.path, 'vitrine_$data.db'));
  }

  Future<void> restaurar(File backup) async {
    await _helper.fechar();
    await backup.copy(await _helper.caminho());
  }

  Future<void> excluir(File backup) => backup.delete();
}
