import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../models/pedido.dart';
import '../../providers/pedido_provider.dart';
import '../../utils/formatadores.dart';
import '../../widgets/cartao_pedido.dart';
import 'tela_novo_pedido.dart';
import 'tela_pedido_detalhe.dart';

class TelaPedidos extends StatelessWidget {
  const TelaPedidos({super.key});

  void _abrir(BuildContext context, Widget tela) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => tela));
  }

  Future<void> _escolherPeriodo(BuildContext context) async {
    final provider = context.read<PedidoProvider>();
    final hoje = DateTime.now();

    final periodo = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: hoje,
      initialDateRange: provider.de == null
          ? null
          : DateTimeRange(start: provider.de!, end: provider.ate!),
    );
    if (periodo == null) return;

    await provider.filtrarPeriodo(periodo.start, periodo.end);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PedidoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        actions: [
          IconButton(
            tooltip: 'Filtrar por período',
            icon: const Icon(Icons.date_range),
            onPressed: () => _escolherPeriodo(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo pedido',
        onPressed: () => _abrir(context, const TelaNovoPedido()),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              children: [
                _filtroStatus(provider, null, 'Todos'),
                for (final status in StatusPedido.values)
                  _filtroStatus(provider, status, status.rotulo),
              ],
            ),
          ),
          if (provider.de != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InputChip(
                  avatar: const Icon(Icons.date_range),
                  label: Text(
                    '${formatarData(provider.de!)} a ${formatarData(provider.ate!)}',
                  ),
                  onDeleted: () => provider.filtrarPeriodo(null, null),
                ),
              ),
            ),
          Expanded(child: _lista(context, provider)),
        ],
      ),
    );
  }

  Widget _filtroStatus(
    PedidoProvider provider,
    StatusPedido? status,
    String rotulo,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(rotulo),
        selected: provider.status == status,
        onSelected: (_) => provider.filtrarStatus(status),
      ),
    );
  }

  Widget _lista(BuildContext context, PedidoProvider provider) {
    if (provider.carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.pedidos.isEmpty) {
      return const Center(child: Text('Nenhum pedido encontrado'));
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: provider.pedidos.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, indice) {
        final pedido = provider.pedidos[indice];
        return CartaoPedido(
          pedido: pedido,
          aoTocar: () => _abrir(context, TelaPedidoDetalhe(pedido: pedido)),
        );
      },
    );
  }
}
