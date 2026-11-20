import 'dart:io';

import 'package:material_ui/material_ui.dart';

import '../models/produto.dart';
import '../utils/formatadores.dart';

class CartaoProduto extends StatelessWidget {
  const CartaoProduto({super.key, required this.produto, this.aoTocar});

  final Produto produto;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Opacity(
      opacity: produto.ativo ? 1 : 0.5,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: produto.fotoPath == null
                    ? ColoredBox(
                        color: cores.surfaceContainerHighest,
                        child: Icon(Icons.image_outlined,
                            size: 40, color: cores.onSurfaceVariant),
                      )
                    : Image.file(File(produto.fotoPath!), fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textos.titleSmall,
                    ),
                    Text(
                      formatarMoeda(produto.precoCentavos),
                      style: textos.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      produto.ativo ? 'Estoque: ${produto.estoque}' : 'Oculto',
                      style: textos.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
