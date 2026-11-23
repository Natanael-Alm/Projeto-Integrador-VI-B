import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../models/cliente.dart';
import '../../models/item_pedido.dart';
import '../../models/pedido.dart';
import '../../models/produto.dart';
import '../../providers/catalogo_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/pedido_provider.dart';
import '../../repositories/regra_negocio_exception.dart';
import '../../utils/formatadores.dart';
import '../../widgets/linha_valor.dart';

class TelaNovoPedido extends StatefulWidget {
  const TelaNovoPedido({super.key});

  @override
  State<TelaNovoPedido> createState() => _TelaNovoPedidoState();
}

class _TelaNovoPedidoState extends State<TelaNovoPedido> {
  final _formulario = GlobalKey<FormState>();
  final _desconto = TextEditingController();
  late final Future<List<Cliente>> _clientes = context
      .read<ClienteProvider>()
      .todos();

  final List<ItemPedido> _itens = [];
  int? _clienteId;
  FormaPagamento _formaPagamento = FormaPagamento.pix;
  bool _pago = false;

  int get _subtotal => somarItens(_itens);
  int get _descontoCentavos => textoParaCentavos(_desconto.text) ?? 0;

  @override
  void dispose() {
    _desconto.dispose();
    super.dispose();
  }

  Future<void> _adicionarProduto() async {
    final produtos = await context.read<CatalogoProvider>().produtosAtivos();
    if (!mounted) return;

    final disponiveis = produtos.where((produto) => produto.estoque > 0);
    final escolhido = await showModalBottomSheet<Produto>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Escolha o produto')),
            if (disponiveis.isEmpty)
              const ListTile(title: Text('Nenhum produto com estoque')),
            for (final produto in disponiveis)
              ListTile(
                title: Text(produto.nome),
                subtitle: Text(
                  '${formatarMoeda(produto.precoCentavos)} · estoque: ${produto.estoque}',
                ),
                onTap: () => Navigator.pop(context, produto),
              ),
          ],
        ),
      ),
    );
    if (escolhido == null) return;

    final indice = _itens.indexWhere((item) => item.produtoId == escolhido.id);
    setState(() {
      if (indice >= 0) {
        _alterarQuantidade(indice, 1);
      } else {
        _itens.add(
          ItemPedido(
            produtoId: escolhido.id!,
            produtoNome: escolhido.nome,
            quantidade: 1,
            precoUnitCentavos: escolhido.precoCentavos,
          ),
        );
      }
    });
  }

  void _alterarQuantidade(int indice, int diferenca) {
    final item = _itens[indice];
    final quantidade = item.quantidade + diferenca;

    if (quantidade <= 0) {
      _itens.removeAt(indice);
    } else {
      _itens[indice] = item.copyWith(quantidade: quantidade);
    }
  }

  Future<void> _salvar() async {
    if (!_formulario.currentState!.validate()) return;

    final mensageiro = ScaffoldMessenger.of(context);
    final catalogo = context.read<CatalogoProvider>();
    try {
      await context.read<PedidoProvider>().registrar(
        clienteId: _clienteId,
        itens: _itens,
        descontoCentavos: _descontoCentavos,
        formaPagamento: _formaPagamento,
        pago: _pago,
      );
      await catalogo.carregar();
      mensageiro.showSnackBar(
        const SnackBar(content: Text('Pedido registrado')),
      );
      if (mounted) Navigator.pop(context);
    } on RegraNegocioException catch (erro) {
      mensageiro.showSnackBar(SnackBar(content: Text(erro.mensagem)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo pedido')),
      body: Form(
        key: _formulario,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FutureBuilder(
              future: _clientes,
              builder: (context, snapshot) => DropdownButtonFormField<int?>(
                initialValue: _clienteId,
                decoration: const InputDecoration(labelText: 'Cliente'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Sem cliente'),
                  ),
                  for (final cliente in snapshot.data ?? <Cliente>[])
                    DropdownMenuItem(
                      value: cliente.id,
                      child: Text(cliente.nome),
                    ),
                ],
                onChanged: (valor) => setState(() => _clienteId = valor),
              ),
            ),
            const SizedBox(height: 16),
            Text('Itens', style: textos.titleMedium),
            if (_itens.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Nenhum produto adicionado'),
              ),
            for (final (indice, item) in _itens.indexed)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.produtoNome),
                subtitle: Text(
                  '${formatarMoeda(item.precoUnitCentavos)} cada · '
                  '${formatarMoeda(item.subtotalCentavos)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Diminuir',
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () =>
                          setState(() => _alterarQuantidade(indice, -1)),
                    ),
                    Text('${item.quantidade}', style: textos.titleMedium),
                    IconButton(
                      tooltip: 'Aumentar',
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () =>
                          setState(() => _alterarQuantidade(indice, 1)),
                    ),
                  ],
                ),
              ),
            OutlinedButton.icon(
              onPressed: _adicionarProduto,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar produto'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _desconto,
              decoration: const InputDecoration(
                labelText: 'Desconto',
                prefixText: r'R$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => setState(() {}),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) return null;
                final centavos = textoParaCentavos(valor);
                if (centavos == null) return 'Desconto inválido';
                if (centavos > _subtotal) {
                  return 'Maior que o valor dos produtos';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<FormaPagamento>(
              initialValue: _formaPagamento,
              decoration: const InputDecoration(
                labelText: 'Forma de pagamento',
              ),
              items: [
                for (final forma in FormaPagamento.values)
                  DropdownMenuItem(value: forma, child: Text(forma.rotulo)),
              ],
              onChanged: (valor) => setState(() => _formaPagamento = valor!),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Já está pago'),
              value: _pago,
              onChanged: (valor) => setState(() => _pago = valor),
            ),
            const Divider(height: 32),
            LinhaValor(rotulo: 'Subtotal', centavos: _subtotal),
            LinhaValor(rotulo: 'Desconto', centavos: -_descontoCentavos),
            LinhaValor(
              rotulo: 'Total',
              centavos: _subtotal - _descontoCentavos,
              destaque: true,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _salvar,
              child: const Text('Registrar pedido'),
            ),
          ],
        ),
      ),
    );
  }
}
