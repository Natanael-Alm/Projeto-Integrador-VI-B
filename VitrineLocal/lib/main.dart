import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/catalogo_provider.dart';
import 'providers/cliente_provider.dart';
import 'providers/empresa_provider.dart';
import 'providers/pedido_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'pt_BR';
  await initializeDateFormatting('pt_BR');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CatalogoProvider()..carregar()),
        ChangeNotifierProvider(create: (_) => EmpresaProvider()..carregar()),
        ChangeNotifierProvider(create: (_) => ClienteProvider()..carregar()),
        ChangeNotifierProvider(create: (_) => PedidoProvider()..carregar()),
      ],
      child: const VitrineApp(),
    ),
  );
}
