class ResumoVendas {
  const ResumoVendas({
    required this.faturamentoCentavos,
    required this.pedidos,
    required this.novosClientes,
  });

  final int faturamentoCentavos;
  final int pedidos;
  final int novosClientes;

  int get ticketMedioCentavos =>
      pedidos == 0 ? 0 : faturamentoCentavos ~/ pedidos;
}

class VendaDoDia {
  const VendaDoDia(this.dia, this.centavos);

  final DateTime dia;
  final int centavos;
}

class ProdutoVendido {
  const ProdutoVendido({
    required this.nome,
    required this.quantidade,
    required this.receitaCentavos,
  });

  final String nome;
  final int quantidade;
  final int receitaCentavos;
}
