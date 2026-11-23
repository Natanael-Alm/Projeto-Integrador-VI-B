import 'package:flutter/foundation.dart';

import '../models/item_pedido.dart';
import '../models/pedido.dart';
import '../repositories/pedido_repository.dart';

class PedidoProvider extends ChangeNotifier {
  final _repositorio = PedidoRepository();

  List<Pedido> pedidos = [];
  StatusPedido? status;
  DateTime? de;
  DateTime? ate;
  bool carregando = true;

  Future<void> carregar() async {
    pedidos = await _repositorio.listar(status: status, de: de, ate: ate);
    carregando = false;
    notifyListeners();
  }

  Future<void> filtrarStatus(StatusPedido? novoStatus) async {
    status = novoStatus;
    await carregar();
  }

  Future<void> filtrarPeriodo(DateTime? inicio, DateTime? fim) async {
    de = inicio;
    ate = fim;
    await carregar();
  }

  Future<List<ItemPedido>> listarItens(int pedidoId) =>
      _repositorio.listarItens(pedidoId);

  Future<List<Pedido>> historicoDoCliente(int clienteId) =>
      _repositorio.listar(clienteId: clienteId);

  Future<void> registrar({
    int? clienteId,
    required List<ItemPedido> itens,
    required int descontoCentavos,
    FormaPagamento? formaPagamento,
    required bool pago,
  }) async {
    await _repositorio.registrar(
      clienteId: clienteId,
      itens: itens,
      descontoCentavos: descontoCentavos,
      formaPagamento: formaPagamento,
      pago: pago,
    );
    await carregar();
  }

  Future<void> marcarComoPago(int pedidoId) async {
    await _repositorio.marcarComoPago(pedidoId);
    await carregar();
  }

  Future<void> cancelar(int pedidoId) async {
    await _repositorio.cancelar(pedidoId);
    await carregar();
  }
}
