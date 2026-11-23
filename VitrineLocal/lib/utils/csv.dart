String montarCsv(List<List<Object?>> linhas) =>
    linhas.map((linha) => linha.map(_celula).join(';')).join('\r\n');

String _celula(Object? valor) {
  final texto = valor?.toString() ?? '';
  if (!texto.contains(RegExp(r'[;"\n]'))) return texto;
  return '"${texto.replaceAll('"', '""')}"';
}
