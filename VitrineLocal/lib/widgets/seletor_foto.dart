import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../utils/imagens.dart';

class SeletorFoto extends StatelessWidget {
  const SeletorFoto({
    super.key,
    required this.caminho,
    required this.aoAlterar,
    this.icone = Icons.add_a_photo_outlined,
  });

  final String? caminho;
  final ValueChanged<String> aoAlterar;
  final IconData icone;

  Future<void> _escolher(BuildContext context) async {
    final origem = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Câmera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (origem == null) return;

    final foto = await ImagePicker().pickImage(
      source: origem,
      maxWidth: 1080,
      imageQuality: 85,
    );
    if (foto != null) aoAlterar(await salvarFoto(foto));
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _escolher(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 180,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: cores.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: caminho == null
            ? Icon(icone, size: 48, color: cores.onSurfaceVariant)
            : Image.file(File(caminho!), fit: BoxFit.cover),
      ),
    );
  }
}
