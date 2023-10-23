import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/cart_cubit.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/home/product/product_details.dart';
import 'package:user_market/util/const.dart';
import 'package:user_market/util/string_utils.dart';

class ProductInCart extends StatefulWidget {
  const ProductInCart(
      {super.key, required this.product, required this.quantity});
  final Product product;
  final int quantity;

  @override
  State<ProductInCart> createState() => _ProductInCartState();
}

class _ProductInCartState extends State<ProductInCart> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetails(
                        pro: widget.product,
                        isFromCart: true,
                      ),
                    ));
              },
              child: Hero(
                  tag: "${widget.product.id ?? ""}_cartItem",
                  child: SizedBox(
                    height: 160.0,
                    width: 160.0,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(defRadius),
                        child: widget.product.actuallyLink != null &&
                                widget.product.actuallyLink!.isNotEmpty
                            ? FadeInImage(
                                placeholder:
                                    const AssetImage('assets/img/loading.gif'),
                                image: FileImage(
                                    File(widget.product.actuallyLink!)),
                              )
                            : const Icon(
                                Icons.add_rounded,
                                size: 160.0,
                              )),
                  )),
            ),
            const SizedBox(width: defPading),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name ?? "",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: defPading),
                Text(
                  "Price: ${formatCurrency(widget.product.price)}",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: defPading),
                SizedBox(
                  height: 30,
                  width: constraints.maxWidth - 160.0 - defPading,
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            context.read<CartCubit>().decrease(widget.product),
                        child: const Icon(Icons.remove),
                      ),
                      Card(child: Text(widget.quantity.toString())),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<CartCubit>().increase(widget.product),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
