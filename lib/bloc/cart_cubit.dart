import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/entity/product.dart';

class CartCubit extends Cubit<Map<String, (Product, int)>> {
  CartCubit(super.initialState) : super();

  void replaceCurrentState(Map<String, (Product, int)> newState) {
    _sortByName(newState);    
  }

  void _sortByName(Map<String, (Product, int)> m) {
    List<String> sortedKeys = m.keys.toList(growable: false)
      ..sort(
        (a, b) {
          if (m[a]?.$1.name == null) {
            return -1;
          } else {
            if (m[b]?.$1.name == null) {
              return m[a]!.$1.name!.compareTo("");
            } else {
              return m[a]!.$1.name!.compareTo(m[b]!.$1.name!);
            }
          }
        },
      );

    LinkedHashMap<String, (Product, int)> sortedMap =
        LinkedHashMap.fromIterable(sortedKeys,
            key: (k) => k, value: (k) => m[k]!);

    emit(sortedMap);
  }

  void setOrReplace(Product p, int quantity) {
    if (p.id == null) {
      return;
    }
    final oldQuantity = state[p.id!]?.$2;
    state[p.id!] = (p, oldQuantity ?? quantity);
    emit(Map.of(state));
  }

  void changeQuantity(Product p, int quantity) {
    if (p.id == null) {
      return;
    }
    final pq = state[p.id!];

    if (pq == null) {
      return setOrReplace(p, 1);
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
