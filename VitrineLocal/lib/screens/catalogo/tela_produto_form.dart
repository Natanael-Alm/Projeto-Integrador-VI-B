import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../models/produto.dart';
import '../../providers/catalogo_provider.dart';
import '../../utils/formatadores.dart';
import '../../utils/imagens.dart';
import '../../widgets/seletor_foto.dart';

class TelaProdutoForm extends StatefulWidget {
  const TelaProdutoForm({super.key, this.produto});

  final Produto? produto;

  @override
  State<TelaProdutoForm> createState() => _TelaProdutoFormState();
}

class _TelaProdutoFormState extends State<TelaProdutoForm> {
  final _formulario = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.produto?.nome);
  late final _descricao = TextEditingController(text: widget.produto?.descricao);
  late final _preco = TextEditingController(
    text: widget.produto == null
        ? ''
        : centavosParaTexto(widget.produto!.precoCentavos),
  );
  late final _estoque = TextEditingController(
    text: widget.produto?.estoque.toString() ?? '0',
  );
  late int? _categoriaId = widget.produto?.categoriaId;
  late final String? _fotoOriginal = widget.produto?.fotoPath;
  late String? _fotoPath = _fotoOriginal;
  late bool _ativo = widget.produto?.ativo ?? true;
  bool _salvo = false;

  bool get _editando => widget.produto != null;

  @override
  void dispose() {
    if (!_salvo && _fotoPath != _fotoOriginal) excluirFoto(_fotoPath);
    _nome.dispose();
    _descricao.dispose();
    _preco.dispose();
    _estoque.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formulario.currentState!.validate()) return;

    final descricao = _descricao.text.trim();
    final produto = Produto(
      id: widget.produto?.id,
      categoriaId: _categoriaId,
      nome: _nome.text.trim(),
      descricao: descricao.isEmpty ? null : descricao,
      precoCentavos: textoParaCentavos(_preco.text)!,
      estoque: int.parse(_estoque.text),
      fotoPath: _fotoPath,
      ativo: _ativo,
      criadoEm: widget.produto?.criadoEm ?? DateTime.now(),
    );

    await context.read<CatalogoProvider>().salvarProduto(produto);
    _salvo = true;
    if (_fotoPath != _fotoOriginal) await excluirFoto(_fotoOriginal);
    if (mounted) Navigator.pop(context);
  }

  void _trocarFoto(String caminho) {
    if (_fotoPath != _fotoOriginal) excluirFoto(_fotoPath);
    setState(() => _fotoPath = caminho);
  }

  Future<void> _excluir() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir produto?'),
        content: Text(widget.produto!.nome),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    final mensageiro = ScaffoldMessenger.of(context);
    final excluido =
        await context.read<CatalogoProvider>().excluirProduto(widget.produto!);

    mensageiro.showSnackBar(SnackBar(
      content: Text(excluido
          ? 'Produto excluído'
          : 'O produto já tem vendas, então foi desativado em vez de excluído'),
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categorias = context.watch<CatalogoProvider>().categorias;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar produto' : 'Novo produto'),
        actions: [
          if (_editando)
            IconButton(
              tooltip: 'Excluir',
              icon: const Icon(Icons.delete_outline),
              onPressed: _excluir,
            ),
        ],
      ),
      body: Form(
        key: _formulario,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SeletorFoto(
              caminho: _fotoPath,
              aoAlterar: _trocarFoto,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nome,
              decoration: const InputDecoration(labelText: 'Nome'),
              textCapitalization: TextCapitalization.sentences,
              validator: (valor) =>
                  valor == null || valor.trim().isEmpty ? 'Informe o nome' : null,
            ),
            TextFormField(
              controller: _descricao,
              decoration: const InputDecoration(labelText: 'Descrição'),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              minLines: 1,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _preco,
                    decoration: const InputDecoration(
                      labelText: 'Preço',
                      prefixText: r'R$ ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (valor) => textoParaCentavos(valor ?? '') == null
                        ? 'Preço inválido'
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _estoque,
                    decoration: const InputDecoration(labelText: 'Estoque'),
                    keyboardType: TextInputType.number,
                    validator: (valor) {
                      final numero = int.tryParse(valor ?? '');
                      return numero == null || numero < 0
                          ? 'Estoque inválido'
                          : null;
                    },
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<int?>(
              initialValue: _categoriaId,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Sem categoria')),
                for (final categoria in categorias)
                  DropdownMenuItem(
                    value: categoria.id,
                    child: Text(categoria.nome),
                  ),
              ],
              onChanged: (valor) => setState(() => _categoriaId = valor),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Visível no catálogo'),
              value: _ativo,
              onChanged: (valor) => setState(() => _ativo = valor),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _salvar, child: const Text('Salvar')),
          ],
        ),
      ),
    );
  }
}
