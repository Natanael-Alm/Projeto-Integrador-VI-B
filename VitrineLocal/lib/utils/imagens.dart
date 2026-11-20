import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> salvarFoto(XFile foto) async {
  final documentos = await getApplicationDocumentsDirectory();
  final pasta = Directory(join(documentos.path, 'fotos'));
  await pasta.create(recursive: true);

  final nome = '${DateTime.now().millisecondsSinceEpoch}${extension(foto.path)}';
  final destino = join(pasta.path, nome);
  await foto.saveTo(destino);
  return destino;
}

Future<void> excluirFoto(String? caminho) async {
  if (caminho == null) return;
  final arquivo = File(caminho);
  if (await arquivo.exists()) await arquivo.delete();
}
