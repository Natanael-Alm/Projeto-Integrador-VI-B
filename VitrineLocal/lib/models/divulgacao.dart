enum Canal {
  whatsapp('WHATSAPP', 'WhatsApp'),
  instagram('INSTAGRAM', 'Instagram'),
  outro('OUTRO', 'Outro');

  const Canal(this.valor, this.rotulo);

  final String valor;
  final String rotulo;

  static Canal deValor(String valor) =>
      Canal.values.firstWhere((canal) => canal.valor == valor);
}

class Divulgacao {
  const Divulgacao({
    this.id,
    required this.canal,
    required this.dataEnvio,
    required this.qtdProdutos,
    this.observacao,
  });

  final int? id;
  final Canal canal;
  final DateTime dataEnvio;
  final int qtdProdutos;
  final String? observacao;

  factory Divulgacao.fromMap(Map<String, Object?> map) => Divulgacao(
        id: map['id'] as int,
        canal: Canal.deValor(map['canal'] as String),
        dataEnvio: DateTime.parse(map['data_envio'] as String),
        qtdProdutos: map['qtd_produtos'] as int,
        observacao: map['observacao'] as String?,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'canal': canal.valor,
        'data_envio': dataEnvio.toIso8601String(),
        'qtd_produtos': qtdProdutos,
        'observacao': observacao,
      };
}
