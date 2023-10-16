import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';
import 'package:user_market/service/firestorage_service.dart';

class ImageService {
  static ImageService? _instance;

  ImageService._();
  static final Lock _lock = Lock();

  static ImageService get instance {
    if (_instance == null) {
      _lock.synchronized(() {
        _instance ??= ImageService._();
      });
    }
    return _instance!;
  }

  Future<String?> getActuallyLink(String imgUrl) async {
    String fileName = imgUrl.substring(imgUrl.indexOf("/") + 1);
    return getTemporaryDirectory().then(
        (direc) => File("${direc.path}/$fileName").exists().then((exists) {
              if (exists) {
                return FirestorageService.instance
                    .getMd5Hash(imgUrl)
                    .then((md5code) {
                  if (md5code == null) {
                    return null;
                  }
                  return File("${direc.path}/$fileName")
                      .readAsBytes()
                      .then((uint8list) {
                    if (md5.convert(uint8list).toString() == md5code) {
                      return "${direc.path}/$fileName";
                    }
                    return FirestorageService.instance
                        .getLinkDownload(imgUrl)
                        .then((link) {
                      if (link != null) {
                        return Dio()
                            .download(link, "${direc.path}/$fileName")
                            .then((_) => "${direc.path}/$fileName");
                      }
                      return null;
                    });
                  });
                });
              } else {
                return FirestorageService.instance
                    .getLinkDownload(imgUrl)
                    .then((link) {
                  if (link != null) {
                    return Dio()
                        .download(link, "${direc.path}/$fileName")
                        .then((_) => "${direc.path}/$fileName");
                  }
                  return null;
                });
              }
            }));
  }
}
