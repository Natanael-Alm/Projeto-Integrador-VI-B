import 'package:material_ui/material_ui.dart';

import 'screens/catalogo/tela_catalogo.dart';
import 'screens/clientes/tela_clientes.dart';
import 'screens/mais/tela_mais.dart';
import 'screens/pedidos/tela_pedidos.dart';
import 'screens/tela_em_breve.dart';

const _corPrincipal = Color(0xFF374151);

class VitrineApp extends StatelessWidget {
  const VitrineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vitrine',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _corPrincipal),
        appBarTheme: const AppBarTheme(
          backgroundColor: _corPrincipal,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const TelaPrincipal(),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _abaAtual = 1;

  static const _telas = [
    TelaEmBreve(titulo: 'Vitrine', icone: Icons.dashboard_outlined),
    TelaCatalogo(),
    TelaPedidos(),
    TelaClientes(),
    TelaMais(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _abaAtual, children: _telas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _abaAtual,
        onDestinationSelected: (indice) => setState(() => _abaAtual = indice),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'Catálogo'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Pedidos'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'Clientes'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'Mais'),
        ],
      ),
    );
  }
}
