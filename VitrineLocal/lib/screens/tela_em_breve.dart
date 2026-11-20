import 'package:material_ui/material_ui.dart';

class TelaEmBreve extends StatelessWidget {
  const TelaEmBreve({super.key, required this.titulo, required this.icone});

  final String titulo;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            const Text('Disponível na próxima etapa do projeto'),
          ],
        ),
      ),
    );
  }
}
