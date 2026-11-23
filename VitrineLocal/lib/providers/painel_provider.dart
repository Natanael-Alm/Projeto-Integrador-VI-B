import 'package:flutter/foundation.dart';

import '../models/relatorio.dart';
import '../repositories/relatorio_repository.dart';

class PainelProvider extends ChangeNotifier {
  final _repositorio = RelatorioRepository();

  ResumoVendas resumoDoMes = const ResumoVendas(
    faturamentoCentavos: 0,
    pedidos: 0,
    novosClientes: 0,
  );
  List<VendaDoDia> ultimos7Dias = [];
  int mediaDiariaCentavos = 0;
  double? variacaoPercentual;
  List<ProdutoVendido> maisVendidos = [];
  bool carregando = true;

  Future<void> carregar() async {
    final hoje = DateTime.now();
    final inicioDoMes = DateTime(hoje.year, hoje.month);
    final ultimos14Dias = await _repositorio.vendasPorDia(
      DateTime(hoje.year, hoje.month, hoje.day - 13),
      hoje,
    );

    final semanaAnterior = ultimos14Dias.take(7);
    ultimos7Dias = ultimos14Dias.skip(7).toList();

    // RF17: média móvel de 7 dias comparada com a dos 7 dias anteriores.
    mediaDiariaCentavos = _media(ultimos7Dias);
    final mediaAnterior = _media(semanaAnterior);
    variacaoPercentual = mediaAnterior == 0
        ? null
        : (mediaDiariaCentavos - mediaAnterior) / mediaAnterior * 100;

    resumoDoMes = await _repositorio.resumo(inicioDoMes, hoje);
    maisVendidos = await _repositorio.maisVendidos(
      inicioDoMes,
      hoje,
      limite: 3,
    );
    carregando = false;
    notifyListeners();
  }

  int _media(Iterable<VendaDoDia> dias) =>
      dias.fold(0, (soma, dia) => soma + dia.centavos) ~/ dias.length;
}
