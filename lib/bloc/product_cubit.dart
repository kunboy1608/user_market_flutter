import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_market/bloc/entity_cubit.dart';
import 'package:user_market/entity/product.dart';

class ProductCubit extends EntityCubit<Product> {
  ProductCubit(super.initialState);

  @override
  void replaceState(Map<String, Product> map) {
    state.clear();
    state.addAll(map);
    sortByName();
  }

  void sortByCategory() {
    List<String> sortedKeys = state.keys.toList(growable: false)
      ..sort(
        (a, b) {
          if (state[a]!.categoryId == null) {
            return -1;
          } else {
            if (state[b]!.categoryId == null) {
              return state[a]!.categoryId!;
            } else {
              return state[a]!.categoryId!.compareTo(state[b]!.categoryId!);
            }
          }
        },
      );

    LinkedHashMap<String, Product> sortedMap = LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => state[k]!);

    emit(sortedMap);
  }

  void sortByName() {
    List<String> sortedKeys = state.keys.toList(growable: false)
      ..sort(
        (a, b) {
          if (state[a]!.name == null) {
            return -1;
          } else {
            if (state[b]!.name == null) {
              return state[a]!.name!.compareTo("");
            } else {
              return state[a]!.name!.compareTo(state[b]!.name!);
            }
          }
        },
      );

    LinkedHashMap<String, Product> sortedMap = LinkedHashMap.fromIterable(
        sortedKeys,
        key: (k) => k,
        value: (k) => state[k]!);

    emit(sortedMap);
  }

  List<Product> getFlashSale() {
    List<Product> products = [];
    for (var element in state.values) {
      if (element.discountPrice != null &&
          (element.startDiscountDate != null ||
              element.endDiscountDate != null)) {
        if (element.discountPrice != null &&
            (element.startDiscountDate != null ||
                element.endDiscountDate != null)) {
          final now = Timestamp.now();
          if ((element.startDiscountDate == null ||
                  now.compareTo(element.startDiscountDate!) > 0) &&
              (element.endDiscountDate == null ||
                  now.compareTo(element.endDiscountDate!) < 0)) {
            products.add(element);
          }
        }
      }
    }

    return products;
  }

  List<Product> getBestSeller() {
    List<Product> allProducts = state.values.toList(growable: false);
    allProducts.sort(
      (a, b) {
        if (a.quantitySold == null) {
          if (b.quantitySold == null) {
            return 0;
          } else {
            return -1;
          }
        } else {
          if (b.quantitySold == null) {
            return 1;
          } else {
            return a.quantitySold!.compareTo(b.quantitySold!);
          }
        }
      },
    );
    final sortedAllProducts =
        allProducts.where((element) => element.quantitySold != null).toList();

    return sortedAllProducts
        .getRange(0, 9.clamp(0, sortedAllProducts.length))
        .toList();
  }
}
