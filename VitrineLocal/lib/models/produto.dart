class Produto {
  const Produto({
    this.id,
    this.categoriaId,
    required this.nome,
    this.descricao,
    required this.precoCentavos,
    this.estoque = 0,
    this.fotoPath,
    this.ativo = true,
    required this.criadoEm,
  });

  final int? id;
  final int? categoriaId;
  final String nome;
  final String? descricao;
  final int precoCentavos;
  final int estoque;
  final String? fotoPath;
  final bool ativo;
  final DateTime criadoEm;

  factory Produto.fromMap(Map<String, Object?> map) => Produto(
        id: map['id'] as int,
        categoriaId: map['categoria_id'] as int?,
        nome: map['nome'] as String,
        descricao: map['descricao'] as String?,
        precoCentavos: map['preco_centavos'] as int,
        estoque: map['estoque'] as int,
        fotoPath: map['foto_path'] as String?,
        ativo: map['ativo'] == 1,
        criadoEm: DateTime.parse(map['criado_em'] as String),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'categoria_id': categoriaId,
        'nome': nome,
        'descricao': descricao,
        'preco_centavos': precoCentavos,
        'estoque': estoque,
        'foto_path': fotoPath,
        'ativo': ativo ? 1 : 0,
        'criado_em': criadoEm.toIso8601String(),
      };

  Produto copyWith({bool? ativo}) => Produto(
        id: id,
        categoriaId: categoriaId,
        nome: nome,
        descricao: descricao,
        precoCentavos: precoCentavos,
        estoque: estoque,
        fotoPath: fotoPath,
        ativo: ativo ?? this.ativo,
        criadoEm: criadoEm,
      );
}
