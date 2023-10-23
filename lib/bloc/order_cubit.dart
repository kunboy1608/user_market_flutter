import 'package:user_market/entity/order.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderCubit extends Cubit<Map<int, Map<String, Order>>> {
  OrderCubit(super.initialState);

  void replaceState(Map<int, Map<String, Order>> map) {
    state.addAll(Map.of(map));
  }

  void addOrUpdateIfExist(Order o) {
    if (o.status == null || o.id == null) {
      return;
    }

    if (state[o.status!] == null) {
      state[o.status!] = {o.id!: o};
    } else {
      state[o.status!]!.addAll({o.id!: o});
    }

    emit(Map.of(state));
  }

  void addOrUpdateIfExistAll(List<Order> orders) {
    for (var o in orders) {
      addOrUpdateIfExist(o);
    }
  }

  void remove(Order o) {
    if (o.status == null || o.id == null || state[o.status] == null) {
      return;
    }

    state[o.status]?.remove(o.id);

    if (state[o.status]!.isEmpty) {
      state.remove(o.status);
    }

    emit(Map.of(state));
  }

  void removeAll(List<Order> list) {
    for (var o in list) {
      remove(o);
    }
  }

  Map<int, Map<String, Order>> currentState() => state;
}
