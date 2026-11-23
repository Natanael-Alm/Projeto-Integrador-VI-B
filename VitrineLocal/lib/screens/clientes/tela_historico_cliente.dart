import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../models/cliente.dart';
import '../../models/pedido.dart';
import '../../providers/pedido_provider.dart';
import '../../widgets/cartao_pedido.dart';
import '../pedidos/tela_pedido_detalhe.dart';

class TelaHistoricoCliente extends StatefulWidget {
  const TelaHistoricoCliente({super.key, required this.cliente});

  final Cliente cliente;

  @override
  State<TelaHistoricoCliente> createState() => _TelaHistoricoClienteState();
}

class _TelaHistoricoClienteState extends State<TelaHistoricoCliente> {
  late Future<List<Pedido>> _pedidos = _buscar();

  Future<List<Pedido>> _buscar() =>
      context.read<PedidoProvider>().historicoDoCliente(widget.cliente.id!);

  Future<void> _abrirPedido(Pedido pedido) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TelaPedidoDetalhe(pedido: pedido)),
    );
    setState(() => _pedidos = _buscar());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cliente.nome)),
      body: FutureBuilder(
        future: _pedidos,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final pedidos = snapshot.data!;
          if (pedidos.isEmpty) {
            return const Center(child: Text('Nenhuma compra registrada'));
          }

          return ListView.separated(
            itemCount: pedidos.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, indice) => CartaoPedido(
              pedido: pedidos[indice],
              aoTocar: () => _abrirPedido(pedidos[indice]),
            ),
          );
        },
      ),
    );
  }
}
