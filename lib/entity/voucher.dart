import 'package:user_market/entity/entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Voucher extends Entity {
  String? code;
  double? percent;
  double? maxValue;
  Timestamp? startDate;
  Timestamp? endDate;
  int? count;
  bool isPublic = true;

  Voucher();
  Voucher.fromMap(Map<String, dynamic> map) {
    code = map["code"];
    percent = map["percent"];
    maxValue = map["max_value"];
    startDate = map["start_date"];
    endDate = map["end_date"];
    count = map["count"];
    isPublic = map["is_public"] ?? true;
    uploadDate = map["upload_date"];
    lastUpdatedDate = map["last_update_date"];
    id = map["id"];
  }

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'code': code,
        'percent': percent,
        'max_value': maxValue,
        'start_date': startDate,
        'end_date': endDate,
        'count': count,
        'is_public': isPublic,
      });
  }
}
