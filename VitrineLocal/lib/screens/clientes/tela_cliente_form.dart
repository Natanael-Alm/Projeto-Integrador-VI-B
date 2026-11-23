import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/cliente.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/pedido_provider.dart';
import 'tela_historico_cliente.dart';

final _formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class TelaClienteForm extends StatefulWidget {
  const TelaClienteForm({super.key, this.cliente});

  final Cliente? cliente;

  @override
  State<TelaClienteForm> createState() => _TelaClienteFormState();
}

class _TelaClienteFormState extends State<TelaClienteForm> {
  final _formulario = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.cliente?.nome);
  late final _telefone = TextEditingController(text: widget.cliente?.telefone);
  late final _email = TextEditingController(text: widget.cliente?.email);
  late final _observacoes = TextEditingController(
    text: widget.cliente?.observacoes,
  );

  bool get _editando => widget.cliente != null;

  @override
  void dispose() {
    for (final campo in [_nome, _telefone, _email, _observacoes]) {
      campo.dispose();
    }
    super.dispose();
  }

  String? _opcional(TextEditingController campo) {
    final texto = campo.text.trim();
    return texto.isEmpty ? null : texto;
  }

  Future<void> _salvar() async {
    if (!_formulario.currentState!.validate()) return;

    final cliente = Cliente(
      id: widget.cliente?.id,
      nome: _nome.text.trim(),
      telefone: _opcional(_telefone),
      email: _opcional(_email),
      observacoes: _opcional(_observacoes),
      criadoEm: widget.cliente?.criadoEm ?? DateTime.now(),
    );

    final mensageiro = ScaffoldMessenger.of(context);
    final pedidos = context.read<PedidoProvider>();
    try {
      await context.read<ClienteProvider>().salvar(cliente);
      await pedidos.carregar();
      if (mounted) Navigator.pop(context);
    } on DatabaseException catch (erro) {
      if (!erro.isUniqueConstraintError()) rethrow;
      mensageiro.showSnackBar(
        const SnackBar(content: Text('Já existe um cliente com esse telefone')),
      );
    }
  }

  Future<void> _excluir() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir cliente?'),
        content: const Text('Os pedidos dele continuam salvos, sem cliente.'),
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

    final pedidos = context.read<PedidoProvider>();
    await context.read<ClienteProvider>().excluir(widget.cliente!.id!);
    await pedidos.carregar();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar cliente' : 'Novo cliente'),
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
            TextFormField(
              controller: _nome,
              decoration: const InputDecoration(labelText: 'Nome'),
              textCapitalization: TextCapitalization.words,
              validator: (valor) => valor == null || valor.trim().isEmpty
                  ? 'Informe o nome'
                  : null,
            ),
            TextFormField(
              controller: _telefone,
              decoration: const InputDecoration(labelText: 'Telefone'),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'E-mail (opcional)'),
              keyboardType: TextInputType.emailAddress,
              validator: (valor) {
                final texto = valor?.trim() ?? '';
                return texto.isEmpty || _formatoEmail.hasMatch(texto)
                    ? null
                    : 'E-mail inválido';
              },
            ),
            TextFormField(
              controller: _observacoes,
              decoration: const InputDecoration(labelText: 'Observações'),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _salvar, child: const Text('Salvar')),
            if (_editando) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TelaHistoricoCliente(cliente: widget.cliente!),
                  ),
                ),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Histórico de compras'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
