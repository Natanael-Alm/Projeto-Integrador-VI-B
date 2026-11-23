import 'package:flutter/foundation.dart';

import '../models/cliente.dart';
import '../models/relatorio.dart';
import '../repositories/cliente_repository.dart';
import '../repositories/relatorio_repository.dart';

class ClienteProvider extends ChangeNotifier {
  final _repositorio = ClienteRepository();
  final _relatorioRepo = RelatorioRepository();

  List<Cliente> clientes = [];
  Map<int, PerfilCliente> perfis = {};
  String busca = '';
  bool carregando = true;
  int _ultimaConsulta = 0;

  Future<void> carregar() async {
    final consulta = ++_ultimaConsulta;
    final resultado = await _repositorio.listar(busca: busca);
    final classificados = await _relatorioRepo.perfisDeClientes();
    if (consulta != _ultimaConsulta) return;

    clientes = resultado;
    perfis = {
      for (final cliente in classificados) cliente.clienteId: cliente.perfil,
    };
    carregando = false;
    notifyListeners();
  }

  Future<List<Cliente>> todos() => _repositorio.listar();

  Future<void> buscar(String texto) async {
    busca = texto;
    await carregar();
  }

  Future<void> salvar(Cliente cliente) async {
    await _repositorio.salvar(cliente);
    await carregar();
  }

  Future<void> excluir(int id) async {
    await _repositorio.excluir(id);
    await carregar();
  }
}
