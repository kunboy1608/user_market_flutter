import 'dart:async';

import 'package:user_market/entity/banner.dart';
import 'package:user_market/service/entity/entity_service.dart';
import 'package:user_market/service/google/firestore_service.dart';
import 'package:user_market/service/image_service.dart';

class BannerService extends EntityService<Banner> {
  static final BannerService _instance = BannerService._();
  static BannerService get instance => _instance;
  BannerService._();

  @override
  String collectionName = "banners";

  @override
  Future<List<Banner>?> get() async {
    List<Banner> list = await FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).get().then((event) {
              return event.docs.map((doc) {
                return Banner.fromMap(doc.data())..id = doc.id;
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
  Future<Banner?> getById(String id) {
    return FirestoreService.instance
        .getFireStore()
        .then((fs) => fs.collection(collectionName).doc(id).get().then((value) {
              if (value.data() != null) {
                if (value.data()!['img_url'] != null ||
                    value.data()!['img_url'].isNotEmpty) {
                  return ImageService.instance
                      .getActuallyLink(value.data()!['img_url'])
                      .then((link) {
                    return Banner.fromMap(value.data()!)
                      ..actuallyLink = link
                      ..id = id;
                  });
                } else {
                  return Banner.fromMap(value.data()!)..id = id;
                }
              }
              return null;
            }));
  }
}
