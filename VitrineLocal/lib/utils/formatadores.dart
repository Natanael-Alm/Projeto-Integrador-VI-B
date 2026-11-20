import 'package:intl/intl.dart';

final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
final _data = DateFormat('dd/MM/yyyy', 'pt_BR');

String formatarMoeda(int centavos) => _moeda.format(centavos / 100);

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
