import 'package:material_ui/material_ui.dart';

import '../models/relatorio.dart';

class EtiquetaPerfil extends StatelessWidget {
  const EtiquetaPerfil({super.key, required this.perfil});

  final PerfilCliente perfil;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final cor = switch (perfil) {
      PerfilCliente.novo => cores.primary,
      PerfilCliente.fiel => Colors.green.shade700,
      PerfilCliente.regular => cores.outline,
      PerfilCliente.emRisco => Colors.orange.shade800,
      PerfilCliente.inativo => cores.error,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: cor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        perfil.etiqueta,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cor),
      ),
    );
  }
}
