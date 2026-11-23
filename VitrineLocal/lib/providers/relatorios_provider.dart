import 'package:flutter/foundation.dart';

import '../models/produto.dart';
import '../models/relatorio.dart';
import '../repositories/relatorio_repository.dart';
import '../utils/csv.dart';
import '../utils/formatadores.dart';

const limiteEstoqueBaixo = 5;

enum PeriodoRelatorio {
  dias30('30 dias', 'por dia'),
  dias90('90 dias', 'por semana'),
  meses6('6 meses', 'por mês');

  const PeriodoRelatorio(this.rotulo, this.agrupamento);

  final String rotulo;
  final String agrupamento;
}

class RelatoriosProvider extends ChangeNotifier {
  final _repositorio = RelatorioRepository();

  PeriodoRelatorio periodo = PeriodoRelatorio.dias30;
  ResumoVendas resumo = const ResumoVendas(
    faturamentoCentavos: 0,
    pedidos: 0,
    novosClientes: 0,
  );
  List<BarraDoGrafico> vendas = [];
  List<ItemCurvaAbc> curvaAbc = [];
  List<ClienteComPerfil> clientes = [];
  List<Produto> estoqueBaixo = [];
  EfeitoDivulgacao? divulgacao;
  bool carregando = true;

  DateTime get inicio {
    final hoje = DateTime.now();
    return switch (periodo) {
      PeriodoRelatorio.dias30 => DateTime(hoje.year, hoje.month, hoje.day - 29),
      PeriodoRelatorio.dias90 => DateTime(hoje.year, hoje.month, hoje.day - 89),
      PeriodoRelatorio.meses6 => DateTime(hoje.year, hoje.month - 5),
    };
  }

  Future<void> mudarPeriodo(PeriodoRelatorio novoPeriodo) async {
    periodo = novoPeriodo;
    await carregar();
  }

  Future<void> carregar() async {
    final hoje = DateTime.now();
    final de = inicio;

    resumo = await _repositorio.resumo(de, hoje);
    vendas = _agruparVendas(await _repositorio.vendasPorDia(de, hoje), de);
    curvaAbc = _montarCurvaAbc(await _repositorio.maisVendidos(de, hoje));
    clientes = await _repositorio.perfisDeClientes();
    estoqueBaixo = await _repositorio.estoqueBaixo(limiteEstoqueBaixo);
    divulgacao = await _repositorio.efeitoDivulgacao(de, hoje);

    carregando = false;
    notifyListeners();
  }

  List<ClienteComPerfil> clientesDoPerfil(PerfilCliente perfil) =>
      clientes.where((cliente) => cliente.perfil == perfil).toList();

  List<BarraDoGrafico> _agruparVendas(List<VendaDoDia> dias, DateTime de) {
    return switch (periodo) {
      PeriodoRelatorio.dias30 => _agrupar(dias, (dia) => dia, formatarDiaMes),
      PeriodoRelatorio.dias90 => _agrupar(
        dias,
        (dia) => dia.difference(de).inDays ~/ 7,
        formatarDiaMes,
      ),
      PeriodoRelatorio.meses6 => _agrupar(
        dias,
        (dia) => '${dia.year}-${dia.month}',
        formatarMesCurto,
      ),
    };
  }

  List<BarraDoGrafico> _agrupar(
    List<VendaDoDia> dias,
    Object Function(DateTime dia) chaveDoGrupo,
    String Function(DateTime inicioDoGrupo) rotulo,
  ) {
    final grupos = <Object, List<VendaDoDia>>{};
    for (final venda in dias) {
      grupos.putIfAbsent(chaveDoGrupo(venda.dia), () => []).add(venda);
    }

    return [
      for (final grupo in grupos.values)
        BarraDoGrafico(
          rotulo(grupo.first.dia),
          grupo.fold(0, (soma, venda) => soma + venda.centavos),
        ),
    ];
  }

  // Curva ABC: A até 80% da receita acumulada, B até 95%, C o restante.
  List<ItemCurvaAbc> _montarCurvaAbc(List<ProdutoVendido> produtos) {
    final receitaTotal = produtos.fold(
      0,
      (soma, produto) => soma + produto.receitaCentavos,
    );
    final itens = <ItemCurvaAbc>[];
    var acumulado = 0.0;

    for (final produto in produtos) {
      final percentual = produto.receitaCentavos / receitaTotal * 100;
      final classe = acumulado < 80
          ? 'A'
          : acumulado < 95
          ? 'B'
          : 'C';
      itens.add(
        ItemCurvaAbc(produto: produto, percentual: percentual, classe: classe),
      );
      acumulado += percentual;
    }
    return itens;
  }

  String gerarCsv() {
    final hoje = DateTime.now();
    return montarCsv([
      ['Relatório Vitrine'],
      [
        'Período',
        '${formatarData(inicio)} a ${formatarData(hoje)} (${periodo.rotulo})',
      ],
      [],
      ['Resumo'],
      ['Faturamento (R\$)', centavosParaTexto(resumo.faturamentoCentavos)],
      ['Pedidos pagos', resumo.pedidos],
      ['Ticket médio (R\$)', centavosParaTexto(resumo.ticketMedioCentavos)],
      ['Novos clientes', resumo.novosClientes],
      [],
      ['Vendas ${periodo.agrupamento}'],
      ['Início', 'Valor (R\$)'],
      for (final barra in vendas)
        [barra.rotulo, centavosParaTexto(barra.centavos)],
      [],
      ['Curva ABC'],
      ['Classe', 'Produto', 'Quantidade', 'Receita (R\$)', '% da receita'],
      for (final item in curvaAbc)
        [
          item.classe,
          item.produto.nome,
          item.produto.quantidade,
          centavosParaTexto(item.produto.receitaCentavos),
          formatarDecimal(item.percentual),
        ],
      [],
      ['Clientes por perfil'],
      ['Cliente', 'Perfil', 'Dias desde a última compra'],
      for (final cliente in clientes)
        [cliente.nome, cliente.perfil.rotulo, cliente.diasDesdeUltimaCompra],
      [],
      ['Estoque baixo (até $limiteEstoqueBaixo unidades)'],
      ['Produto', 'Estoque'],
      for (final produto in estoqueBaixo) [produto.nome, produto.estoque],
      [],
      ['Divulgação'],
      ['Compartilhamentos', divulgacao?.compartilhamentos],
      [
        'Pedidos por dia nos 3 dias seguintes',
        formatarDecimal(divulgacao?.pedidosPorDiaDepois ?? 0),
      ],
      [
        'Pedidos por dia no período',
        formatarDecimal(divulgacao?.pedidosPorDiaGeral ?? 0),
      ],
    ]);
  }
}
