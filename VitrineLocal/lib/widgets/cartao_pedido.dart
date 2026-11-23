import 'package:material_ui/material_ui.dart';

import '../models/pedido.dart';
import '../utils/formatadores.dart';

Color corDoStatus(BuildContext context, StatusPedido status) {
  final cores = Theme.of(context).colorScheme;
  return switch (status) {
    StatusPedido.aberto => cores.tertiary,
    StatusPedido.pago => Colors.green.shade700,
    StatusPedido.cancelado => cores.error,
  };
}

class CartaoPedido extends StatelessWidget {
  const CartaoPedido({super.key, required this.pedido, this.aoTocar});

  final Pedido pedido;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return ListTile(
      title: Text(
        'Pedido #${pedido.id} · ${pedido.clienteNome ?? 'Sem cliente'}',
      ),
      subtitle: Text(formatarDataHora(pedido.dataPedido)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatarMoeda(pedido.totalCentavos),
            style: textos.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            pedido.status.rotulo,
            style: textos.bodySmall?.copyWith(
              color: corDoStatus(context, pedido.status),
            ),
          ),
        ],
      ),
      onTap: aoTocar,
    );
  }
}
