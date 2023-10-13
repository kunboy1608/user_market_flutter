import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/entity/product.dart';

class CartCubit extends Cubit<Map<String, (Product, int)>> {
  CartCubit(super.initialState) : super();
  void setOrReplace(Product p, int quantity) {
    if (p.id == null) {
      return;
    }
    state[p.id!] = (p, quantity);
    emit(Map.of(state));
  }

  void changeQuantity(Product p, int quantity) {
    if (p.id == null) {
      return;
    }
    final pq = state[p.id!];

    if (pq == null) {
      return;
    }

    if (quantity + pq.$2 == 0) {
      state.remove(p.id!);
    } else {
      state[p.id!] = (p, pq.$2 + quantity);
    }

    emit(Map.of(state));
  }

  void increase(Product p) => changeQuantity(p, 1);
  void decrease(Product p) => changeQuantity(p, -1);
}
