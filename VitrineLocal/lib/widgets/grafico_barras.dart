import 'package:material_ui/material_ui.dart';

import '../utils/formatadores.dart';

class GraficoBarras extends StatelessWidget {
  const GraficoBarras({
    super.key,
    required this.rotulos,
    required this.valoresCentavos,
    this.mostrarValores = true,
    this.altura = 180,
  });

  final List<String> rotulos;
  final List<int> valoresCentavos;
  final bool mostrarValores;
  final double altura;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final maior = valoresCentavos.fold(0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: altura,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < valoresCentavos.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  children: [
                    if (mostrarValores)
                      FittedBox(
                        child: Text(
                          formatarMoedaCurta(valoresCentavos[i]),
                          style: textos.labelSmall,
                        ),
                      ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: maior == 0
                              ? 0
                              : valoresCentavos[i] / maior,
                          child: Container(
                            decoration: BoxDecoration(
                              color: cores.primary,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      child: Text(rotulos[i], style: textos.labelSmall),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
