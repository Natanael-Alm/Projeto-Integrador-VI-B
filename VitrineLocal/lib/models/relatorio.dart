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

class BarraDoGrafico {
  const BarraDoGrafico(this.rotulo, this.centavos);

  final String rotulo;
  final int centavos;
}

class ItemCurvaAbc {
  const ItemCurvaAbc({
    required this.produto,
    required this.percentual,
    required this.classe,
  });

  final ProdutoVendido produto;
  final double percentual;
  final String classe;
}

enum PerfilCliente {
  novo('Novos', 'Novo', 'Primeira compra há 30 dias ou menos'),
  fiel('Fiéis', 'Fiel', '3 ou mais pedidos nos últimos 90 dias'),
  regular('Regulares', 'Regular', 'Compraram nos últimos 60 dias'),
  emRisco('Em risco', 'Em risco', 'Última compra entre 60 e 120 dias atrás'),
  inativo(
    'Inativos',
    'Inativo',
    'Última compra há mais de 120 dias ou nenhuma',
  );

  const PerfilCliente(this.rotulo, this.etiqueta, this.regra);

  final String rotulo;
  final String etiqueta;
  final String regra;
}

class ClienteComPerfil {
  const ClienteComPerfil({
    required this.clienteId,
    required this.nome,
    required this.perfil,
    this.diasDesdeUltimaCompra,
  });

  final int clienteId;
  final String nome;
  final PerfilCliente perfil;
  final int? diasDesdeUltimaCompra;
}

class EfeitoDivulgacao {
  const EfeitoDivulgacao({
    required this.compartilhamentos,
    required this.pedidosPorDiaDepois,
    required this.pedidosPorDiaGeral,
  });

  final int compartilhamentos;
  final double pedidosPorDiaDepois;
  final double pedidosPorDiaGeral;
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
