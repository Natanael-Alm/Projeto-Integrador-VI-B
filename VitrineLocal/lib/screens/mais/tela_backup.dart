import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/catalogo_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/empresa_provider.dart';
import '../../providers/painel_provider.dart';
import '../../providers/pedido_provider.dart';
import '../../repositories/backup_repository.dart';
import '../../utils/formatadores.dart';

enum _Acao { restaurar, compartilhar, excluir }

class TelaBackup extends StatefulWidget {
  const TelaBackup({super.key});

  @override
  State<TelaBackup> createState() => _TelaBackupState();
}

class _TelaBackupState extends State<TelaBackup> {
  final _repositorio = BackupRepository();
  late Future<List<File>> _backups = _repositorio.listar();

  void _atualizarLista() {
    setState(() => _backups = _repositorio.listar());
  }

  Future<void> _fazerBackup() async {
    final mensageiro = ScaffoldMessenger.of(context);
    await _repositorio.criar();
    _atualizarLista();
    mensageiro.showSnackBar(const SnackBar(content: Text('Backup criado')));
  }

  Future<void> _executar(_Acao acao, File backup) async {
    switch (acao) {
      case _Acao.restaurar:
        await _restaurar(backup);
      case _Acao.compartilhar:
        await SharePlus.instance.share(
          ShareParams(files: [XFile(backup.path)], subject: 'Backup Vitrine'),
        );
      case _Acao.excluir:
        await _repositorio.excluir(backup);
        _atualizarLista();
    }
  }

  Future<void> _restaurar(File backup) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar backup?'),
        content: Text(
          'Os dados atuais serão substituídos pelos do backup de '
          '${formatarDataHora(backup.lastModifiedSync())}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    final mensageiro = ScaffoldMessenger.of(context);
    final provedores = [
      context.read<CatalogoProvider>().carregar,
      context.read<ClienteProvider>().carregar,
      context.read<PedidoProvider>().carregar,
      context.read<EmpresaProvider>().carregar,
      context.read<PainelProvider>().carregar,
    ];

    await _repositorio.restaurar(backup);
    await Future.wait([for (final recarregar in provedores) recarregar()]);
    mensageiro.showSnackBar(const SnackBar(content: Text('Backup restaurado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup e restauração')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'O backup guarda uma cópia de todos os dados do app '
            '(produtos, clientes, pedidos e configurações). '
            'Use "Compartilhar" para enviar a cópia para o Drive ou WhatsApp.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _fazerBackup,
            icon: const Icon(Icons.backup_outlined),
            label: const Text('Fazer backup agora'),
          ),
          const SizedBox(height: 24),
          Text(
            'Backups salvos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          FutureBuilder(
            future: _backups,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final backups = snapshot.data!;
              if (backups.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Nenhum backup feito ainda'),
                );
              }

              return Column(
                children: [
                  for (final backup in backups)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.storage_outlined),
                      title: Text(formatarDataHora(backup.lastModifiedSync())),
                      subtitle: Text(
                        '${(backup.lengthSync() / 1024).ceil()} KB',
                      ),
                      trailing: PopupMenuButton<_Acao>(
                        onSelected: (acao) => _executar(acao, backup),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: _Acao.restaurar,
                            child: Text('Restaurar'),
                          ),
                          PopupMenuItem(
                            value: _Acao.compartilhar,
                            child: Text('Compartilhar'),
                          ),
                          PopupMenuItem(
                            value: _Acao.excluir,
                            child: Text('Excluir'),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
