import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/home/product/product_details.dart';
import 'package:user_market/util/const.dart';
import 'package:user_market/util/string_utils.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.pro});

  final Product pro;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (_) => ProductDetails(
                        pro: pro,
                      )));
        },
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(defRadius / 2)),
          child: Container(
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  // TODO: Please reverted it 
                  // tag: pro.id ?? "",
                  tag: UniqueKey(),
                  child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight * 0.6,
                      child: pro.actuallyLink != null &&
                              pro.actuallyLink!.isNotEmpty
                          ? FadeInImage(
                              placeholder:
                                  const AssetImage('assets/img/loading.gif'),
                              image: FileImage(File(pro.actuallyLink!)),
                            )
                          : Icon(
                              Icons.add_rounded,
                              size: constraints.maxHeight * 0.3,
                            )),
                ),
                Padding(
                  padding: const EdgeInsets.all(defPading),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pro.name ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text("Category: ${pro.categoryId?.toString() ?? ""}",
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text("Price: ${formatCurrency(pro.price)}",
                          maxLines: 1, overflow: TextOverflow.ellipsis)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
