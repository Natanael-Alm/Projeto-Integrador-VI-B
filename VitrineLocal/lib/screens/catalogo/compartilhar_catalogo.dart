import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/divulgacao.dart';
import '../../providers/catalogo_provider.dart';
import '../../providers/empresa_provider.dart';
import '../../utils/texto_catalogo.dart';

const _limiteDeFotos = 10;

Future<void> compartilharCatalogo(BuildContext context) async {
  final catalogo = context.read<CatalogoProvider>();
  final empresa = context.read<EmpresaProvider>().empresa;
  final mensageiro = ScaffoldMessenger.of(context);

  final canal = await showModalBottomSheet<Canal>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(title: Text('Compartilhar catálogo por')),
          for (final canal in Canal.values)
            ListTile(
              leading: const Icon(Icons.send_outlined),
              title: Text(canal.rotulo),
              onTap: () => Navigator.pop(context, canal),
            ),
        ],
      ),
    ),
  );
  if (canal == null) return;

  final produtos = await catalogo.produtosParaCompartilhar();
  if (produtos.isEmpty) {
    mensageiro.showSnackBar(
      const SnackBar(content: Text('Nenhum produto ativo para compartilhar')),
    );
    return;
  }

  final fotos = produtos
      .map((produto) => produto.fotoPath)
      .whereType<String>()
      .where((caminho) => File(caminho).existsSync())
      .take(_limiteDeFotos)
      .map(XFile.new)
      .toList();

  final resultado = await SharePlus.instance.share(ShareParams(
    text: montarTextoCatalogo(empresa, produtos),
    files: fotos.isEmpty ? null : fotos,
  ));

  if (resultado.status != ShareResultStatus.dismissed) {
    await catalogo.registrarDivulgacao(canal, produtos.length);
  }
}
