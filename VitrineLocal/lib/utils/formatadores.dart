import 'package:intl/intl.dart';

final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
final _moedaCurta = NumberFormat.compactCurrency(locale: 'pt_BR', symbol: r'R$');
final _data = DateFormat('dd/MM/yyyy', 'pt_BR');
final _dataHora = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR');
final _diaDaSemana = DateFormat('E', 'pt_BR');
final _mesAno = DateFormat("MMMM 'de' y", 'pt_BR');
final _diaMes = DateFormat('dd/MM', 'pt_BR');
final _mesCurto = DateFormat('MMM', 'pt_BR');
final _decimal = NumberFormat('0.0', 'pt_BR');

String formatarMoeda(int centavos) => _moeda.format(centavos / 100);

String formatarMoedaCurta(int centavos) => _moedaCurta.format(centavos / 100);

String centavosParaTexto(int centavos) =>
    (centavos / 100).toStringAsFixed(2).replaceAll('.', ',');

int? textoParaCentavos(String texto) {
  var limpo = texto.replaceAll(RegExp(r'[^\d,.]'), '');
  if (RegExp(r'^\d+\.\d{1,2}$').hasMatch(limpo)) {
    limpo = limpo.replaceAll('.', ',');
  }
  limpo = limpo.replaceAll('.', '');

  final partes = limpo.split(',');
  if (limpo.isEmpty || partes.length > 2 || partes[0].isEmpty) return null;

  final reais = int.parse(partes[0]);
  final decimais = partes.length == 2 ? partes[1].padRight(2, '0') : '00';
  if (decimais.length > 2) return null;

  return reais * 100 + int.parse(decimais);
}

String formatarData(DateTime data) => _data.format(data);

String formatarDataHora(DateTime data) => _dataHora.format(data);

String formatarDiaDaSemana(DateTime data) => _diaDaSemana.format(data);

String formatarMesAno(DateTime data) => _mesAno.format(data);

String formatarDiaMes(DateTime data) => _diaMes.format(data);

String formatarMesCurto(DateTime data) => _mesCurto.format(data);

String formatarDecimal(double valor) => _decimal.format(valor);
