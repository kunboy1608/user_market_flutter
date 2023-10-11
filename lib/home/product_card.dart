import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/home/product_details.dart';
import 'package:user_market/util/const.dart';
import 'package:user_market/util/string_utils.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.pro});

  final Product pro;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) => ProductDetails(
                      pro: widget.pro,
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
                  tag: widget.pro.id ?? "",
                  child: Image.asset("assets/img/background_login.png")),
              Padding(
                padding: const EdgeInsets.all(defPading),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pro.name ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(widget.pro.categoryId?.toString() ?? "",
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text("Price: ${formatCurrency(widget.pro.price)}",
                        maxLines: 2, overflow: TextOverflow.ellipsis)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
