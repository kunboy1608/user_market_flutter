import 'dart:async';

import 'package:synchronized/synchronized.dart';
import 'package:user_market/entity/order.dart';
import 'package:user_market/service/entity/entity_service.dart';
import 'package:user_market/service/google/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:user_market/util/cache.dart';

class OrderService extends EntityService<Order> {
  static OrderService? _instance;
  static final Lock _lock = Lock();

  static OrderService get instance {
    if (_instance == null) {
      _lock.synchronized(() {
        _instance ??= OrderService._();
      });
    }
    return _instance!;
  }

  OrderService._() {
    collectionName = "users/${Cache.userId}/orders";
  }

  @override
  late String collectionName;

  @override
  Future<DocumentReference<Map<String, dynamic>>> add(Order e) async {
    return FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).add(e.toMap()
          ..remove("id")
          ..addAll({'user_id': Cache.userId})));
  }

  @override
  Future<List<Order>?> get() async {
    List<Order> list = [];
    for (int i = 0; i < 7; i++) {
      FirestoreService.instance
          .getFireStore()
          .then((fs) => fs.collection(collectionName).get().then((event) {
                list.addAll(event.docs.map((doc) {
                  return Order.fromMap(doc.data())..id = doc.id;
                }));
              }));
    }
    return list;
  }

  Future<void> forwardStep(Order e) async {
    if (e.status == null) {
      return;
    }
    e.status = (e.status! + 1).clamp(1, 4);
    return update(e);
  }

  Future<void> cancel(Order e) async {
    if (e.status == null) {
      return;
    }
    e.status = 5;

    return update(e);
  }

  Future<void> refund(Order e) async {
    if (e.status == null) {
      return;
    }
    e.status = 6;

    return update(e);
  }

  /// Without cart changes
  @override
  void listenChanges(StreamController<(DocumentChangeType, Order)> controller) {
    // FirestoreService.instance.getFireStore().then((fs) => fs
    //         .collection(collectionName)
    //         .where('status', isGreaterThan: 0)
    //         .snapshots()
    //         .listen((event) {
    //       for (var element in event.docChanges) {
    //         Order p = Order.fromMap(element.doc.data()!)..id = element.doc.id;
    //         controller.sink.add((element.type, p));
    //       }
    //     }));
  }

  Future<Query<Map<String, dynamic>>> getInputChanges() async {
    return FirestoreService.instance.getFireStore().then((fs) =>
        fs.collection(collectionName).where('status', isGreaterThan: 0));
  }

  Future<DocumentReference<Map<String, dynamic>>> getCartChanges() {
    return FirestoreService.instance
        .getFireStore()
        .then((fs) => fs
                .collection(collectionName)
                .limit(1)
                .where('status', isEqualTo: '0')
                .get()
                .then((event) {
              if (event.docs.isNotEmpty && event.docs.first.exists) {
                Cache.cartId = event.docs.first.id;
                return event.docs.first.id;
              } else {
                return add(Order()).then((value) {
                  Cache.cartId = value.id;
                  return value.id;
                });
              }
            }))
        .then((id) => FirestoreService.instance
            .getFireStore()
            .then((fs) => fs.collection(collectionName).doc(id.toString())));
  }

  void listenCartChanges(StreamController<Map<String, int>> controller) {
    FirestoreService.instance
        .getFireStore()
        .then((fs) => fs
                .collection(collectionName)
                .limit(1)
                .where('status', isEqualTo: '0')
                .get()
                .then((event) {
              if (event.docs.isNotEmpty && event.docs.first.exists) {
                Cache.cartId = event.docs.first.id;
                return event.docs.first.id;
              } else {
                return add(Order()).then((value) {
                  Cache.cartId = value.id;
                  return value.id;
                });
              }
            }))
        .then((id) {
      FirestoreService.instance.getFireStore().then((fs) => fs
              .collection(collectionName)
              .doc(id.toString())
              .snapshots()
              .listen((event) {
            if (event.data() != null) {
              Map<String, int> products = {};

              // Map<ProductId, Map<price.toString(), quantity>>
              final map = event.data()!["products"];
              map?.forEach((key, value) {                
                products.addAll({key: value.values.first});
              });

              controller.sink.add(products);
            }
          }));
    });
  }

  @override
  Future<Order?> getById(String id) {
    return FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).doc(id).get().then((value) {
              if (value.data() != null) {
                return Order.fromMap(value.data()!)..id = id;
              }
              return null;
            }));
  }
}
