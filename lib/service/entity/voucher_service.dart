import 'dart:async';

import 'package:user_market/entity/voucher.dart';
import 'package:user_market/service/entity/entity_service.dart';
import 'package:user_market/service/google/firestore_service.dart';

class VoucherService extends EntityService<Voucher> {
  static final VoucherService _instance = VoucherService._();
  static VoucherService get instance => _instance;
  VoucherService._();

  @override
  String collectionName = "vouchers";

  @override
  Future<List<Voucher>?> get() {
    return FirestoreService.instance.getFireStore().then((fs) => fs
        .collection(collectionName)
        .where('is_public', isEqualTo: true)
        .where('count', isGreaterThan: 0)
        .get()
        .then((event) => event.docs
            .map((doc) => Voucher.fromMap(doc.data())..id = doc.id)
            .toList()));
  }

  @override
  Future<Voucher?> getById(String id) {
    return FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).doc(id).get().then((value) {
              if (value.data() != null && (value.data()!['count'] ?? 0) > 0) {
                return Voucher.fromMap(value.data()!)..id = id;
              }
              return null;
            }));
  }

  Future<void> decreaseCount(Voucher v) async {
    update(Voucher.fromMap(
        v.toMap()..addAll({'count': v.count == null ? 0 : v.count! - 1})));
  }
}
