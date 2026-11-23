import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../models/cliente.dart';
import '../../providers/cliente_provider.dart';
import '../../widgets/etiqueta_perfil.dart';
import 'tela_cliente_form.dart';

class TelaClientes extends StatelessWidget {
  const TelaClientes({super.key});

  void _abrirCliente(BuildContext context, [Cliente? cliente]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TelaClienteForm(cliente: cliente)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Novo cliente',
        onPressed: () => _abrirCliente(context),
        child: const Icon(Icons.person_add_alt),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por nome ou telefone',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: provider.buscar,
            ),
          ),
          Expanded(child: _lista(context, provider)),
        ],
      ),
    );
  }

  Widget _lista(BuildContext context, ClienteProvider provider) {
    if (provider.carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.clientes.isEmpty) {
      return const Center(child: Text('Nenhum cliente encontrado'));
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: provider.clientes.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, indice) {
        final cliente = provider.clientes[indice];
        final perfil = provider.perfis[cliente.id];
        return ListTile(
          leading: CircleAvatar(child: Text(cliente.nome[0].toUpperCase())),
          title: Text(cliente.nome),
          subtitle: cliente.telefone == null ? null : Text(cliente.telefone!),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (perfil != null) EtiquetaPerfil(perfil: perfil),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () => _abrirCliente(context, cliente),
        );
      },
    );
  }
}
