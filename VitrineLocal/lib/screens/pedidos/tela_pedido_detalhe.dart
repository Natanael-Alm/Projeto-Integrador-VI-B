import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../models/item_pedido.dart';
import '../../models/pedido.dart';
import '../../providers/catalogo_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/pedido_provider.dart';
import '../../utils/formatadores.dart';
import '../../widgets/cartao_pedido.dart';
import '../../widgets/linha_valor.dart';

class TelaPedidoDetalhe extends StatefulWidget {
  const TelaPedidoDetalhe({super.key, required this.pedido});

  final Pedido pedido;

  @override
  State<TelaPedidoDetalhe> createState() => _TelaPedidoDetalheState();
}

class _TelaPedidoDetalheState extends State<TelaPedidoDetalhe> {
  late final Future<List<ItemPedido>> _itens = context
      .read<PedidoProvider>()
      .listarItens(widget.pedido.id!);

  Future<void> _marcarComoPago() async {
    final mensageiro = ScaffoldMessenger.of(context);
    await context.read<PedidoProvider>().marcarComoPago(widget.pedido.id!);

    mensageiro.showSnackBar(
      const SnackBar(content: Text('Pedido marcado como pago')),
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _cancelar() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar pedido?'),
        content: const Text('O estoque dos produtos será devolvido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancelar pedido'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    final mensageiro = ScaffoldMessenger.of(context);
    final catalogo = context.read<CatalogoProvider>();
    final clientes = context.read<ClienteProvider>();
    await context.read<PedidoProvider>().cancelar(widget.pedido.id!);
    await catalogo.carregar();
    await clientes.carregar();

    mensageiro.showSnackBar(const SnackBar(content: Text('Pedido cancelado')));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final pedido = widget.pedido;
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Pedido #${pedido.id}')),
      body: FutureBuilder(
        future: _itens,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final itens = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                pedido.status.rotulo,
                style: textos.titleLarge?.copyWith(
                  color: corDoStatus(context, pedido.status),
                ),
              ),
              Text('Cliente: ${pedido.clienteNome ?? 'Sem cliente'}'),
              Text('Data: ${formatarDataHora(pedido.dataPedido)}'),
              Text('Pagamento: ${pedido.formaPagamento?.rotulo ?? '-'}'),
              const Divider(height: 32),
              Text('Itens', style: textos.titleMedium),
              for (final item in itens)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${item.quantidade}x ${item.produtoNome}'),
                  subtitle: Text(
                    '${formatarMoeda(item.precoUnitCentavos)} cada',
                  ),
                  trailing: Text(formatarMoeda(item.subtotalCentavos)),
                ),
              const Divider(height: 32),
              LinhaValor(rotulo: 'Subtotal', centavos: somarItens(itens)),
              LinhaValor(
                rotulo: 'Desconto',
                centavos: -pedido.descontoCentavos,
              ),
              LinhaValor(
                rotulo: 'Total',
                centavos: pedido.totalCentavos,
                destaque: true,
              ),
              const SizedBox(height: 24),
              if (pedido.status == StatusPedido.aberto)
                FilledButton(
                  onPressed: _marcarComoPago,
                  child: const Text('Marcar como pago'),
                ),
              if (pedido.status != StatusPedido.cancelado)
                TextButton(
                  onPressed: _cancelar,
                  child: const Text('Cancelar pedido'),
                ),
            ],
          );
        },
      ),
    );
  }
}
