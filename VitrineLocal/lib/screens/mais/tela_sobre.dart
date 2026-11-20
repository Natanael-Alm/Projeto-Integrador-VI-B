import 'package:material_ui/material_ui.dart';

const _integrantes = [
  'Erick Alves Kolhrausch',
  'Natanael Almeida de Jesus',
];

class TelaSobre extends StatelessWidget {
  const TelaSobre({super.key});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o app')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: cores.primaryContainer,
            child: Icon(Icons.storefront, size: 48, color: cores.primary),
          ),
          const SizedBox(height: 16),
          Text('Vitrine', textAlign: TextAlign.center, style: textos.headlineMedium),
          Text('Versão 1.0.0', textAlign: TextAlign.center, style: textos.bodyMedium),
          const SizedBox(height: 16),
          Text('Projeto Integrador VI-B',
              textAlign: TextAlign.center, style: textos.titleMedium),
          Text('Análise e Desenvolvimento de Sistemas',
              textAlign: TextAlign.center, style: textos.bodyMedium),
          const SizedBox(height: 32),
          Text('Integrantes do grupo', style: textos.titleMedium),
          const SizedBox(height: 8),
          for (final nome in _integrantes)
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(nome),
              ),
            ),
        ],
      ),
    );
  }
}
