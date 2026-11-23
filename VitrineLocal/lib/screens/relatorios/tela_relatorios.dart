import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/relatorio.dart';
import '../../providers/relatorios_provider.dart';
import '../../utils/formatadores.dart';
import '../../widgets/cartao_indicador.dart';
import '../../widgets/grafico_barras.dart';

class TelaRelatorios extends StatefulWidget {
  const TelaRelatorios({super.key});

  @override
  State<TelaRelatorios> createState() => _TelaRelatoriosState();
}

class _TelaRelatoriosState extends State<TelaRelatorios> {
  @override
  void initState() {
    super.initState();
    context.read<RelatoriosProvider>().carregar();
  }

  Future<void> _exportarCsv() async {
    final csv = context.read<RelatoriosProvider>().gerarCsv();
    final pasta = await getTemporaryDirectory();
    final arquivo = File(join(pasta.path, 'relatorio_vitrine.csv'));

    // O ﻿ no início faz o Excel reconhecer os acentos.
    await arquivo.writeAsString('﻿$csv');
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(arquivo.path, mimeType: 'text/csv')],
        subject: 'Relatório Vitrine',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final relatorios = context.watch<RelatoriosProvider>();
    final textos = Theme.of(context).textTheme;
    final resumo = relatorios.resumo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        actions: [
          IconButton(
            tooltip: 'Exportar CSV',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: relatorios.carregando ? null : _exportarCsv,
          ),
        ],
      ),
      body: relatorios.carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SegmentedButton<PeriodoRelatorio>(
                  segments: [
                    for (final periodo in PeriodoRelatorio.values)
                      ButtonSegment(
                        value: periodo,
                        label: Text(periodo.rotulo),
                      ),
                  ],
                  selected: {relatorios.periodo},
                  onSelectionChanged: (escolha) =>
                      relatorios.mudarPeriodo(escolha.first),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CartaoIndicador(
                        icone: Icons.payments_outlined,
                        titulo: 'Faturamento',
                        valor: formatarMoeda(resumo.faturamentoCentavos),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CartaoIndicador(
                        icone: Icons.receipt_long_outlined,
                        titulo: 'Pedidos pagos',
                        valor: '${resumo.pedidos}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CartaoIndicador(
                        icone: Icons.sell_outlined,
                        titulo: 'Ticket médio',
                        valor: formatarMoeda(resumo.ticketMedioCentavos),
                      ),
                    ),
                  ],
                ),
                _Secao(
                  titulo: 'Vendas ${relatorios.periodo.agrupamento}',
                  children: [
                    GraficoBarras(
                      rotulos: [
                        for (final barra in relatorios.vendas) barra.rotulo,
                      ],
                      valoresCentavos: [
                        for (final barra in relatorios.vendas) barra.centavos,
                      ],
                      mostrarValores: relatorios.vendas.length <= 7,
                    ),
                  ],
                ),
                _Secao(
                  titulo: 'Curva ABC dos produtos',
                  subtitulo:
                      'A: até 80% da receita · B: até 95% · C: o restante',
                  children: [
                    if (relatorios.curvaAbc.isEmpty)
                      const Text('Nenhuma venda paga no período'),
                    for (final item in relatorios.curvaAbc)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(child: Text(item.classe)),
                        title: Text(item.produto.nome),
                        subtitle: Text(
                          '${item.produto.quantidade} un. · '
                          '${formatarDecimal(item.percentual)}% da receita',
                        ),
                        trailing: Text(
                          formatarMoeda(item.produto.receitaCentavos),
                        ),
                      ),
                  ],
                ),
                _Secao(
                  titulo: 'Clientes por perfil',
                  children: [
                    for (final perfil in PerfilCliente.values)
                      _GrupoDeClientes(
                        perfil: perfil,
                        clientes: relatorios.clientesDoPerfil(perfil),
                      ),
                  ],
                ),
                _Secao(
                  titulo: 'Estoque baixo',
                  subtitulo:
                      'Produtos ativos com até $limiteEstoqueBaixo '
                      'unidades',
                  children: [
                    if (relatorios.estoqueBaixo.isEmpty)
                      const Text('Nenhum produto com estoque baixo'),
                    for (final produto in relatorios.estoqueBaixo)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.warning_amber_outlined),
                        title: Text(produto.nome),
                        trailing: Text(
                          '${produto.estoque} un.',
                          style: textos.titleMedium,
                        ),
                      ),
                  ],
                ),
                _Secao(
                  titulo: 'Efeito da divulgação',
                  subtitulo:
                      'Pedidos nos 3 dias seguintes a cada compartilhamento '
                      'do catálogo, comparados à média do período',
                  children: [
                    _EfeitoDaDivulgacao(efeito: relatorios.divulgacao!),
                  ],
                ),
              ],
            ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({required this.titulo, this.subtitulo, required this.children});

  final String titulo;
  final String? subtitulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: textos.titleMedium),
            if (subtitulo != null) Text(subtitulo!, style: textos.bodySmall),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _GrupoDeClientes extends StatelessWidget {
  const _GrupoDeClientes({required this.perfil, required this.clientes});

  final PerfilCliente perfil;
  final List<ClienteComPerfil> clientes;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text('${perfil.rotulo} (${clientes.length})'),
      subtitle: Text(perfil.regra),
      children: [
        for (final cliente in clientes)
          ListTile(
            dense: true,
            title: Text(cliente.nome),
            trailing: Text(
              cliente.diasDesdeUltimaCompra == null
                  ? 'Nunca comprou'
                  : 'Há ${cliente.diasDesdeUltimaCompra} dias',
            ),
          ),
      ],
    );
  }
}

class _EfeitoDaDivulgacao extends StatelessWidget {
  const _EfeitoDaDivulgacao({required this.efeito});

  final EfeitoDivulgacao efeito;

  @override
  Widget build(BuildContext context) {
    if (efeito.compartilhamentos == 0) {
      return const Text('Nenhum compartilhamento do catálogo no período');
    }

    final melhorou = efeito.pedidosPorDiaDepois >= efeito.pedidosPorDiaGeral;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${efeito.compartilhamentos} compartilhamentos no período'),
        Text(
          'Depois de divulgar: '
          '${formatarDecimal(efeito.pedidosPorDiaDepois)} pedidos por dia',
        ),
        Text(
          'Média do período: '
          '${formatarDecimal(efeito.pedidosPorDiaGeral)} pedidos por dia',
        ),
        const SizedBox(height: 8),
        Text(
          melhorou
              ? 'As vendas aumentam depois de divulgar o catálogo.'
              : 'A divulgação não aumentou as vendas neste período.',
          style: TextStyle(
            color: melhorou
                ? Colors.green.shade700
                : Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }
}
