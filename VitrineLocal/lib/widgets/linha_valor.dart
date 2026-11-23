import 'package:material_ui/material_ui.dart';

import '../utils/formatadores.dart';

class LinhaValor extends StatelessWidget {
  const LinhaValor({
    super.key,
    required this.rotulo,
    required this.centavos,
    this.destaque = false,
  });

  final String rotulo;
  final int centavos;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final estilo = destaque ? textos.titleMedium : textos.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(rotulo, style: estilo),
          const Spacer(),
          Text(formatarMoeda(centavos), style: estilo),
        ],
      ),
    );
  }
}
