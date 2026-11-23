import 'package:material_ui/material_ui.dart';

import '../relatorios/tela_relatorios.dart';
import 'dados_exemplo.dart';
import 'tela_minha_vitrine.dart';
import 'tela_sobre.dart';

class TelaMais extends StatelessWidget {
  const TelaMais({super.key});

  void _abrir(BuildContext context, Widget tela) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => tela));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mais')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: const Text('Relatórios'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(context, const TelaRelatorios()),
          ),
          ListTile(
            leading: const Icon(Icons.storefront_outlined),
            title: const Text('Minha vitrine digital'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(context, const TelaMinhaVitrine()),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre o app'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(context, const TelaSobre()),
          ),
          ListTile(
            leading: const Icon(Icons.dataset_outlined),
            title: const Text('Carregar dados de exemplo'),
            subtitle: const Text('Somente com o app vazio'),
            onTap: () => carregarDadosExemplo(context),
          ),
        ],
      ),
    );
  }
}
