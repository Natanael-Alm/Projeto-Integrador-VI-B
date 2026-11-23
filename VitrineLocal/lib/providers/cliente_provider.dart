import 'package:flutter/foundation.dart';

import '../models/cliente.dart';
import '../repositories/cliente_repository.dart';

class ClienteProvider extends ChangeNotifier {
  final _repositorio = ClienteRepository();

  List<Cliente> clientes = [];
  String busca = '';
  bool carregando = true;

  Future<void> carregar() async {
    clientes = await _repositorio.listar(busca: busca);
    carregando = false;
    notifyListeners();
  }

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
