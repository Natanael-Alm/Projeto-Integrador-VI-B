import 'package:flutter/foundation.dart';

import '../models/empresa.dart';
import '../repositories/empresa_repository.dart';

class EmpresaProvider extends ChangeNotifier {
  EmpresaProvider([EmpresaRepository? repositorio])
      : _repositorio = repositorio ?? EmpresaRepository();

  final EmpresaRepository _repositorio;

  Empresa? empresa;

  Future<void> carregar() async {
    empresa = await _repositorio.buscar();
    notifyListeners();
  }

  Future<void> salvar(Empresa dados) async {
    await _repositorio.salvar(dados);
    empresa = dados;
    notifyListeners();
  }
}
