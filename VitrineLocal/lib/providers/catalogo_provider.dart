import 'package:flutter/foundation.dart';

import '../models/categoria.dart';
import '../models/divulgacao.dart';
import '../models/produto.dart';
import '../repositories/categoria_repository.dart';
import '../repositories/divulgacao_repository.dart';
import '../repositories/produto_repository.dart';
import '../utils/imagens.dart';

class CatalogoProvider extends ChangeNotifier {
  CatalogoProvider({
    ProdutoRepository? produtos,
    CategoriaRepository? categorias,
    DivulgacaoRepository? divulgacoes,
  })  : _produtoRepo = produtos ?? ProdutoRepository(),
        _categoriaRepo = categorias ?? CategoriaRepository(),
        _divulgacaoRepo = divulgacoes ?? DivulgacaoRepository();

  final ProdutoRepository _produtoRepo;
  final CategoriaRepository _categoriaRepo;
  final DivulgacaoRepository _divulgacaoRepo;

  List<Produto> produtos = [];
  List<Categoria> categorias = [];
  String busca = '';
  int? categoriaSelecionada;
  bool carregando = true;

  List<Categoria> get categoriasAtivas =>
      categorias.where((categoria) => categoria.ativa).toList();

  String? nomeDaCategoria(int? id) {
    for (final categoria in categorias) {
      if (categoria.id == id) return categoria.nome;
    }
    return null;
  }

  Future<void> carregar() async {
    categorias = await _categoriaRepo.listar();
    await _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    produtos = await _produtoRepo.listar(
      busca: busca,
      categoriaId: categoriaSelecionada,
    );
    carregando = false;
    notifyListeners();
  }

  Future<void> buscar(String texto) async {
    busca = texto;
    await _carregarProdutos();
  }

  Future<void> selecionarCategoria(int? id) async {
    categoriaSelecionada = id;
    await _carregarProdutos();
  }

  Future<void> salvarProduto(Produto produto) async {
    await _produtoRepo.salvar(produto);
    await _carregarProdutos();
  }

  Future<void> alterarAtivo(Produto produto, bool ativo) async {
    await _produtoRepo.alterarAtivo(produto.id!, ativo);
    await _carregarProdutos();
  }

  Future<bool> excluirProduto(Produto produto) async {
    final excluido = await _produtoRepo.excluir(produto.id!);
    if (excluido) await excluirFoto(produto.fotoPath);
    await _carregarProdutos();
    return excluido;
  }

  Future<void> salvarCategoria(Categoria categoria) async {
    await _categoriaRepo.salvar(categoria);
    await carregar();
  }

  Future<void> excluirCategoria(int id) async {
    await _categoriaRepo.excluir(id);
    if (categoriaSelecionada == id) categoriaSelecionada = null;
    await carregar();
  }

  Future<List<Produto>> produtosParaCompartilhar() =>
      _produtoRepo.listar(somenteAtivos: true);

  Future<void> registrarDivulgacao(Canal canal, int qtdProdutos) =>
      _divulgacaoRepo.registrar(Divulgacao(
        canal: canal,
        dataEnvio: DateTime.now(),
        qtdProdutos: qtdProdutos,
      ));
}
