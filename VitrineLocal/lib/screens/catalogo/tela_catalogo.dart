import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../models/produto.dart';
import '../../providers/catalogo_provider.dart';
import '../../widgets/cartao_produto.dart';
import '../mais/dados_exemplo.dart';
import 'compartilhar_catalogo.dart';
import 'tela_categorias.dart';
import 'tela_produto_form.dart';

class TelaCatalogo extends StatelessWidget {
  const TelaCatalogo({super.key});

  void _abrirProduto(BuildContext context, [Produto? produto]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TelaProdutoForm(produto: produto)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogo = context.watch<CatalogoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          IconButton(
            tooltip: 'Categorias',
            icon: const Icon(Icons.category_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TelaCategorias()),
            ),
          ),
          IconButton(
            tooltip: 'Compartilhar catálogo',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => compartilharCatalogo(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo produto',
        onPressed: () => _abrirProduto(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar produto',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: catalogo.buscar,
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FiltroCategoria(
                  rotulo: 'Todas',
                  selecionado: catalogo.categoriaSelecionada == null,
                  aoSelecionar: () => catalogo.selecionarCategoria(null),
                ),
                for (final categoria in catalogo.categoriasAtivas)
                  _FiltroCategoria(
                    rotulo: categoria.nome,
                    selecionado: catalogo.categoriaSelecionada == categoria.id,
                    aoSelecionar: () =>
                        catalogo.selecionarCategoria(categoria.id),
                  ),
              ],
            ),
          ),
          Expanded(child: _listaDeProdutos(context, catalogo)),
        ],
      ),
    );
  }

  Widget _listaDeProdutos(BuildContext context, CatalogoProvider catalogo) {
    if (catalogo.carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (catalogo.produtos.isEmpty) {
      final catalogoVazio =
          catalogo.busca.isEmpty && catalogo.categoriaSelecionada == null;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nenhum produto encontrado'),
            if (catalogoVazio)
              TextButton(
                onPressed: () => carregarDadosExemplo(context),
                child: const Text('Carregar dados de exemplo'),
              ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        childAspectRatio: 0.72,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: catalogo.produtos.length,
      itemBuilder: (context, indice) {
        final produto = catalogo.produtos[indice];
        return CartaoProduto(
          produto: produto,
          aoTocar: () => _abrirProduto(context, produto),
        );
      },
    );
  }
}

class _FiltroCategoria extends StatelessWidget {
  const _FiltroCategoria({
    required this.rotulo,
    required this.selecionado,
    required this.aoSelecionar,
  });

  final String rotulo;
  final bool selecionado;
  final VoidCallback aoSelecionar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(rotulo),
        selected: selecionado,
        onSelected: (_) => aoSelecionar(),
      ),
    );
  }
}
