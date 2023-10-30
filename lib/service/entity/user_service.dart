import 'dart:async';

import 'package:user_market/entity/user.dart';
import 'package:user_market/service/entity/entity_service.dart';
import 'package:user_market/service/google/firestore_service.dart';
import 'package:user_market/util/cache.dart';

class UserService extends EntityService<User> {
  static final UserService _instance = UserService._();
  static UserService get instance => _instance;
  UserService._();

  @override
  String collectionName = "users";

  @override
  Future<List<User>?> get() {
    return FirestoreService.instance.getFireStore().then((fs) => fs
            .collection(collectionName)
            .where('user_id', isEqualTo: Cache.userId)
            .limit(1)
            .get()
            .then((event) {
          if (event.docs.isEmpty) {
            return null;
          }
          return event.docs
              .map((doc) => User.fromMap(doc.data())..id = doc.id)
              .toList();
        }));
  }

  @override
  Future<User?> getById(String id) {
    throw UnimplementedError();
  }
}
