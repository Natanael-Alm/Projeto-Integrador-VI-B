class ItemPedido {
  const ItemPedido({
    required this.produtoId,
    required this.produtoNome,
    required this.quantidade,
    required this.precoUnitCentavos,
  });

  final int produtoId;
  final String produtoNome;
  final int quantidade;
  final int precoUnitCentavos;

  int get subtotalCentavos => quantidade * precoUnitCentavos;

  factory ItemPedido.fromMap(Map<String, Object?> map) => ItemPedido(
    produtoId: map['produto_id'] as int,
    produtoNome: map['produto_nome'] as String,
    quantidade: map['quantidade'] as int,
    precoUnitCentavos: map['preco_unit_centavos'] as int,
  );

  Map<String, Object?> toMap(int pedidoId) => {
    'pedido_id': pedidoId,
    'produto_id': produtoId,
    'quantidade': quantidade,
    'preco_unit_centavos': precoUnitCentavos,
  };

  ItemPedido copyWith({int? quantidade}) => ItemPedido(
    produtoId: produtoId,
    produtoNome: produtoNome,
    quantidade: quantidade ?? this.quantidade,
    precoUnitCentavos: precoUnitCentavos,
  );
}

int somarItens(List<ItemPedido> itens) =>
    itens.fold(0, (soma, item) => soma + item.subtotalCentavos);
