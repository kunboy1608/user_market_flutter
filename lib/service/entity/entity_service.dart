import 'dart:async';

import 'package:user_market/entity/entity.dart';
import 'package:user_market/service/google/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class EntityService<T extends Entity> {
  abstract String collectionName;

  Future<List<T>?> get();
  void listenChanges(StreamController<(DocumentChangeType, T)> controller);

  Future<DocumentReference<Map<String, dynamic>>> add(T e) {
    return FirestoreService.instance.getFireStore().then(
        (fs) => fs.collection(collectionName).add(e.toMap()..remove("id")));
  }

  Future<T?> getById(String id);

  Future<void> update(T e) {
    return FirestoreService.instance.getFireStore().then((fs) {
      return fs
          .collection(collectionName)
          .doc(e.id)
          .update(e.toMap()..remove("id"));
    });
  }

  Future<void> delete(String id) {
    return FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).doc(id).delete());
  }
}
