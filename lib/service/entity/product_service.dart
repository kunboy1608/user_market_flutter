import 'dart:async';

import 'package:user_market/entity/product.dart';
import 'package:user_market/service/entity/entity_service.dart';
import 'package:user_market/service/google/firestore_service.dart';
import 'package:user_market/service/image_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_market/util/cost_util.dart';

class ProductService extends EntityService<Product> {
  static final ProductService _instance = ProductService._();
  static ProductService get instance => _instance;
  ProductService._();

  DocumentSnapshot? _lastDocument;

  @override
  String collectionName = "products";

  @override
  Future<DocumentReference<Map<String, dynamic>>> add(Product e) async {
    return FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).add(e.toMap()
          ..remove("id")
          ..remove("actually_link")));
  }

  @override
  Future<List<Product>?> get() async {
    List<Product> list = await FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).get().then((event) {
              return event.docs.map((doc) {
                return Product.fromMap(doc.data())..id = doc.id;
              }).toList();
            }));

    for (int i = 0; i < list.length; i++) {
      if (list[i].imgUrl != null) {
        list[i].actuallyLink =
            await ImageService.instance.getActuallyLink(list[i].imgUrl!);
      }
    }

    return list;
  }

  Future<List<Product>?> searchByName(String key) async {
    List<Product> list = await FirestoreService.instance.getFireStore().then(
        (fs) => fs
            .collection(collectionName)
            .where("name",
                whereIn: [key, key.toLowerCase(), key.toUpperCase()])
            .get()
            .then((event) {
              return event.docs.map((doc) {
                return Product.fromMap(doc.data())..id = doc.id;
              }).toList();
            }));

    for (int i = 0; i < list.length; i++) {
      if (list[i].imgUrl != null) {
        list[i].actuallyLink =
            await ImageService.instance.getActuallyLink(list[i].imgUrl!);
      }
    }

    return list;
  }

  @override
  Future<void> update(Product e) {
    return FirestoreService.instance.getFireStore().then((fs) {
      return fs.collection(collectionName).doc(e.id).update(e.toMap()
        ..remove("id")
        ..remove("actually_link"));
    });
  }

  @override
  Future<Product?> getById(String id) {
    return FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).doc(id).get().then((value) {
              if (value.data() != null) {
                if (value.data()!['img_url'] != null ||
                    value.data()!['img_url'].isNotEmpty) {
                  return ImageService.instance
                      .getActuallyLink(value.data()!['img_url'])
                      .then((link) {
                    return Product.fromMap(value.data()!)
                      ..actuallyLink = link
                      ..id = id;
                  });
                } else {
                  return Product.fromMap(value.data()!)..id = id;
                }
              }
              return null;
            }));
  }

  Future<List<Product>?> getBestSellers() async {
    List<Product> list = await FirestoreService.instance.getFireStore().then(
        (fs) => fs
            .collection(collectionName)
            .limit(5)
            .orderBy('quantity_sold', descending: true)
            .get()
            .then((event) => event.docs
                .map((doc) => Product.fromMap(doc.data())..id = doc.id)
                .where((element) =>
                    element.quantitySold != null && element.quantitySold! > 0)
                .toList()));

    for (int i = 0; i < list.length; i++) {
      if (list[i].imgUrl != null) {
        list[i].actuallyLink =
            await ImageService.instance.getActuallyLink(list[i].imgUrl!);
      }
    }

    return list.isEmpty ? null : list;
  }

  Future<List<Product>?> getFlashSale() async {
    await Future.delayed(const Duration(seconds: 5));
    List<Product> list = await FirestoreService.instance.getFireStore().then(
        (fs) => fs
                .collection(collectionName)
                .where('discount_price', isNotEqualTo: null)
                .orderBy('discount_price')
                .get()
                .then((event) {
              return event.docs.map((doc) {
                return Product.fromMap(doc.data())..id = doc.id;
              }).toList();
            }));

    int i = 0;
    while (i < list.length) {
      if (getActuallyCost(list[i]) != list[i].price) {
        if (list[i].imgUrl != null) {
          list[i].actuallyLink =
              await ImageService.instance.getActuallyLink(list[i].imgUrl!);
        }
        i++;
      } else {
        list.removeAt(i);
      }
    }

    return list.isEmpty ? null : list;
  }

  Future<List<Product>> lazyLoad() async {
    late List<Product> list;
    if (_lastDocument != null) {
      list = await FirestoreService.instance.getFireStore().then((fs) => fs
              .collection(collectionName)
              .limit(5)
              .startAfterDocument(_lastDocument!)
              .get()
              .then((event) {
            if (event.docs.isNotEmpty) {
              _lastDocument = event.docs.last;
            }
            return event.docs.map((doc) {
              return Product.fromMap(doc.data())..id = doc.id;
            }).toList();
          }));
    } else {
      list = await FirestoreService.instance.getFireStore().then(
          (fs) => fs.collection(collectionName).limit(5).get().then((event) {
                if (event.docs.isNotEmpty) {
                  _lastDocument = event.docs.last;
                }

                return event.docs.map((doc) {
                  return Product.fromMap(doc.data())..id = doc.id;
                }).toList();
              }));
    }

    for (int i = 0; i < list.length; i++) {
      if (list[i].imgUrl != null) {
        list[i].actuallyLink =
            await ImageService.instance.getActuallyLink(list[i].imgUrl!);
      }
    }

    return list;
  }
}
