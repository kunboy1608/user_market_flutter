import 'dart:async';

import 'package:user_market/entity/product.dart';
import 'package:user_market/service/entity/entity_service.dart';
import 'package:user_market/service/google/firestore_service.dart';
import 'package:user_market/service/image_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService extends EntityService<Product> {
  static final ProductService _instance = ProductService._();
  static ProductService get instance => _instance;
  ProductService._();

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

  @override
  void listenChanges(
      StreamController<(DocumentChangeType, Product)> controller) {
    FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).snapshots().listen((event) {
              for (var element in event.docChanges) {
                Product p = Product.fromMap(element.doc.data()!)
                  ..id = element.doc.id;
                // Get actually link
                if (p.imgUrl != null &&
                    element.type != DocumentChangeType.removed) {
                  ImageService.instance
                      .getActuallyLink(p.imgUrl!)
                      .then((value) {
                    p.actuallyLink = value;
                    controller.sink.add((element.type, p));
                  });
                } else {
                  controller.sink.add((element.type, p));
                }
              }
            }));
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
}