import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../providers/catalogo_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/empresa_provider.dart';
import '../../providers/pedido_provider.dart';
import '../../repositories/dados_exemplo_repository.dart';

Future<void> carregarDadosExemplo(BuildContext context) async {
  final mensageiro = ScaffoldMessenger.of(context);
  final catalogo = context.read<CatalogoProvider>();
  final clientes = context.read<ClienteProvider>();
  final pedidos = context.read<PedidoProvider>();
  final empresa = context.read<EmpresaProvider>();
  final repositorio = DadosExemploRepository();

  if (!await repositorio.bancoVazio()) {
    mensageiro.showSnackBar(
      const SnackBar(
        content: Text(
          'Os dados de exemplo só podem ser carregados com o app vazio',
        ),
      ),
    );
    return;
  }
  if (!context.mounted) return;

  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Carregar dados de exemplo?'),
      content: const Text(
        'Serão criados produtos, clientes e cerca de 5 meses de pedidos '
        'fictícios para testar o painel e os relatórios.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Carregar'),
        ),
      ],
    ),
  );
  if (confirmado != true) return;

  await repositorio.carregar();
  await Future.wait([
    catalogo.carregar(),
    clientes.carregar(),
    pedidos.carregar(),
    empresa.carregar(),
  ]);
  mensageiro.showSnackBar(
    const SnackBar(content: Text('Dados de exemplo carregados')),
  );
}
