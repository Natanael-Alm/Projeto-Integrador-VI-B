import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/categoria.dart';
import '../../providers/catalogo_provider.dart';

class TelaCategorias extends StatelessWidget {
  const TelaCategorias({super.key});

  Future<void> _editar(BuildContext context, [Categoria? categoria]) async {
    final catalogo = context.read<CatalogoProvider>();
    final mensageiro = ScaffoldMessenger.of(context);

    final resultado = await showDialog<_ResultadoDialogo>(
      context: context,
      builder: (_) => _DialogoCategoria(categoria: categoria),
    );
    if (resultado == null) return;

    try {
      if (resultado.excluir) {
        await catalogo.excluirCategoria(categoria!.id!);
      } else {
        await catalogo.salvarCategoria(resultado.categoria!);
      }
    } on DatabaseException catch (erro) {
      if (!erro.isUniqueConstraintError()) rethrow;
      mensageiro.showSnackBar(const SnackBar(
        content: Text('Já existe uma categoria com esse nome'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorias = context.watch<CatalogoProvider>().categorias;

    return Scaffold(
      appBar: AppBar(title: const Text('Categorias')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova categoria',
        onPressed: () => _editar(context),
        child: const Icon(Icons.add),
      ),
      body: categorias.isEmpty
          ? const Center(child: Text('Nenhuma categoria cadastrada'))
          : ListView.separated(
              itemCount: categorias.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, indice) {
                final categoria = categorias[indice];
                return ListTile(
                  title: Text(categoria.nome),
                  subtitle: categoria.descricao == null
                      ? null
                      : Text(categoria.descricao!),
                  trailing: categoria.ativa ? null : const Text('Inativa'),
                  onTap: () => _editar(context, categoria),
                );
              },
            ),
    );
  }
}

class _ResultadoDialogo {
  const _ResultadoDialogo.salvar(Categoria this.categoria) : excluir = false;
  const _ResultadoDialogo.excluir()
      : categoria = null,
        excluir = true;

  final Categoria? categoria;
  final bool excluir;
}

class _DialogoCategoria extends StatefulWidget {
  const _DialogoCategoria({this.categoria});

  final Categoria? categoria;

  @override
  State<_DialogoCategoria> createState() => _DialogoCategoriaState();
}

class _DialogoCategoriaState extends State<_DialogoCategoria> {
  final _formulario = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.categoria?.nome);
  late final _descricao =
      TextEditingController(text: widget.categoria?.descricao);
  late bool _ativa = widget.categoria?.ativa ?? true;

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formulario.currentState!.validate()) return;

    final descricao = _descricao.text.trim();
    Navigator.pop(
      context,
      _ResultadoDialogo.salvar(Categoria(
        id: widget.categoria?.id,
        nome: _nome.text.trim(),
        descricao: descricao.isEmpty ? null : descricao,
        ativa: _ativa,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.categoria == null ? 'Nova categoria' : 'Editar categoria'),
      content: Form(
        key: _formulario,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nome,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nome'),
              textCapitalization: TextCapitalization.sentences,
              validator: (valor) =>
                  valor == null || valor.trim().isEmpty ? 'Informe o nome' : null,
            ),
            TextFormField(
              controller: _descricao,
              decoration: const InputDecoration(labelText: 'Descrição'),
              textCapitalization: TextCapitalization.sentences,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ativa'),
              value: _ativa,
              onChanged: (valor) => setState(() => _ativa = valor),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.categoria != null)
          TextButton(
            onPressed: () =>
                Navigator.pop(context, const _ResultadoDialogo.excluir()),
            child: const Text('Excluir'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _salvar, child: const Text('Salvar')),
      ],
    );
  }
}
