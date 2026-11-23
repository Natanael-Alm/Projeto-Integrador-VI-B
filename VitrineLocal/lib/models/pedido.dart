enum StatusPedido {
  aberto('ABERTO', 'Aberto'),
  pago('PAGO', 'Pago'),
  cancelado('CANCELADO', 'Cancelado');

  const StatusPedido(this.valor, this.rotulo);

  final String valor;
  final String rotulo;

  static StatusPedido deValor(String valor) =>
      StatusPedido.values.firstWhere((status) => status.valor == valor);
}

enum FormaPagamento {
  pix('PIX', 'Pix'),
  dinheiro('DINHEIRO', 'Dinheiro'),
  cartao('CARTAO', 'Cartão'),
  outro('OUTRO', 'Outro');

  const FormaPagamento(this.valor, this.rotulo);

  final String valor;
  final String rotulo;

  static FormaPagamento deValor(String valor) =>
      FormaPagamento.values.firstWhere((forma) => forma.valor == valor);
}

class Pedido {
  const Pedido({
    this.id,
    this.clienteId,
    this.clienteNome,
    required this.dataPedido,
    required this.status,
    this.formaPagamento,
    this.descontoCentavos = 0,
    required this.totalCentavos,
  });

  final int? id;
  final int? clienteId;
  final String? clienteNome;
  final DateTime dataPedido;
  final StatusPedido status;
  final FormaPagamento? formaPagamento;
  final int descontoCentavos;
  final int totalCentavos;

  factory Pedido.fromMap(Map<String, Object?> map) => Pedido(
    id: map['id'] as int,
    clienteId: map['cliente_id'] as int?,
    clienteNome: map['cliente_nome'] as String?,
    dataPedido: DateTime.parse(map['data_pedido'] as String),
    status: StatusPedido.deValor(map['status'] as String),
    formaPagamento: map['forma_pagamento'] == null
        ? null
        : FormaPagamento.deValor(map['forma_pagamento'] as String),
    descontoCentavos: map['desconto_centavos'] as int,
    totalCentavos: map['total_centavos'] as int,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'cliente_id': clienteId,
    'data_pedido': dataPedido.toIso8601String(),
    'status': status.valor,
    'forma_pagamento': formaPagamento?.valor,
    'desconto_centavos': descontoCentavos,
    'total_centavos': totalCentavos,
  };
}
