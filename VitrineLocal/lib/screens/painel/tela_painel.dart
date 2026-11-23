import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../providers/empresa_provider.dart';
import '../../providers/painel_provider.dart';
import '../../utils/formatadores.dart';
import '../../widgets/cartao_indicador.dart';
import '../../widgets/grafico_barras.dart';
import '../relatorios/tela_relatorios.dart';

class TelaPainel extends StatelessWidget {
  const TelaPainel({super.key});

  @override
  Widget build(BuildContext context) {
    final painel = context.watch<PainelProvider>();
    final empresa = context.watch<EmpresaProvider>().empresa;
    final textos = Theme.of(context).textTheme;
    final resumo = painel.resumoDoMes;

    return Scaffold(
      appBar: AppBar(title: Text(empresa?.nome ?? 'Vitrine')),
      body: painel.carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: painel.carregar,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Resumo de ${formatarMesAno(DateTime.now())}',
                    style: textos.titleMedium,
                  ),
                  const SizedBox(height: 8),
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
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CartaoIndicador(
                          icone: Icons.sell_outlined,
                          titulo: 'Ticket médio',
                          valor: formatarMoeda(resumo.ticketMedioCentavos),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CartaoIndicador(
                          icone: Icons.person_add_alt,
                          titulo: 'Novos clientes',
                          valor: '${resumo.novosClientes}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vendas dos últimos 7 dias',
                            style: textos.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          GraficoBarras(
                            rotulos: [
                              for (final venda in painel.ultimos7Dias)
                                formatarDiaDaSemana(venda.dia),
                            ],
                            valoresCentavos: [
                              for (final venda in painel.ultimos7Dias)
                                venda.centavos,
                            ],
                          ),
                          const Divider(height: 32),
                          _Tendencia(
                            mediaCentavos: painel.mediaDiariaCentavos,
                            variacao: painel.variacaoPercentual,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Mais vendidos do mês', style: textos.titleMedium),
                  if (painel.maisVendidos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Nenhuma venda paga neste mês'),
                    ),
                  for (final (posicao, produto) in painel.maisVendidos.indexed)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text('${posicao + 1}º')),
                      title: Text(produto.nome),
                      subtitle: Text('${produto.quantidade} unidades'),
                      trailing: Text(formatarMoeda(produto.receitaCentavos)),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TelaRelatorios()),
                    ),
                    icon: const Icon(Icons.bar_chart_outlined),
                    label: const Text('Ver relatórios'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Tendencia extends StatelessWidget {
  const _Tendencia({required this.mediaCentavos, required this.variacao});

  final int mediaCentavos;
  final double? variacao;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final subiu = (variacao ?? 0) >= 0;

    final icone = variacao == null
        ? Icons.trending_flat
        : subiu
        ? Icons.trending_up
        : Icons.trending_down;
    final cor = variacao == null
        ? cores.outline
        : subiu
        ? Colors.green.shade700
        : cores.error;

    return Row(
      children: [
        Icon(icone, color: cor, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Média diária: ${formatarMoeda(mediaCentavos)}'),
              if (variacao != null)
                Text(
                  '${subiu ? '+' : '-'}${variacao!.abs().toStringAsFixed(0)}% '
                  'em relação aos 7 dias anteriores',
                  style: TextStyle(color: cor),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
