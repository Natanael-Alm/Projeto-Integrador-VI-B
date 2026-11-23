class RegraNegocioException implements Exception {
  const RegraNegocioException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}
