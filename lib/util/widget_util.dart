import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/home/product/product_card.dart';
import 'package:user_market/util/const.dart';

class WidgetUtil {
  static Future<dynamic> showLoadingDialog(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => WillPopScope(
            child: const Center(
              child: CircularProgressIndicator(),
            ),
            onWillPop: () async => false));
  }

  static Future<bool?> showYesNoDialog(BuildContext context, String message) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(defPading * 3),
            child: Column(
              children: [
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                ),
                const SizedBox(height: defPading),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text("Yes")),
                    const SizedBox(width: defPading),
                    FilledButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text("No")),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Skeletonizer skeletonProductCard() {
    return Skeletonizer(
      enabled: true,
      child: ProductCard(
        pro: Product()
          ..price = 10000
          ..name = "HoangDP's product"
          ..provider = "HoangDP"
          ..quantitySold = 100,
        additionTag: Random().nextDouble().toString(),
      ),
    );
  }
}
