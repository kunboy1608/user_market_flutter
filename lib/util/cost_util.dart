import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_market/entity/product.dart';

double getActuallyCost(Product p) {
  double actPrice = 0.0;

  // check flash sale
  if (p.discountPrice != null &&
      (p.startDiscountDate != null || p.endDiscountDate != null)) {
    final now = Timestamp.now();
    if ((p.startDiscountDate == null ||
            now.compareTo(p.startDiscountDate!) > 0) &&
        (p.endDiscountDate == null || now.compareTo(p.endDiscountDate!) < 0)) {
      actPrice = p.discountPrice!;
    } else {
      actPrice = p.price!;
    }
  } else {
    actPrice = p.price!;
  }
  return actPrice;
}
