import 'package:flutter/material.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/util/const.dart';
import 'package:user_market/util/string_utils.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key, required this.pro});
  final Product pro;

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App bar"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Hero(
                tag: widget.pro.id ?? "",
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(defRadius),
                    bottomRight: Radius.circular(defRadius),
                  ),
                  child: Image.asset(
                    "assets/img/background_login.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(defPading),
              child: Column(
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
            )
          ],
        ),
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () {},
        child: const Text("Add to cart"),
      ),
    );
  }
}
