import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/cart_cubit.dart';
import 'package:user_market/entity/order.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/home/product/product_details.dart';
import 'package:user_market/service/entity/order_service.dart';
import 'package:user_market/util/cache.dart';
import 'package:user_market/util/const.dart';
import 'package:user_market/util/string_utils.dart';
import 'package:user_market/util/widget_util.dart';

class ProductInCart extends StatefulWidget {
  const ProductInCart(
      {super.key, required this.product, required this.quantity});
  final Product product;
  final int quantity;

  @override
  State<ProductInCart> createState() => _ProductInCartState();
}

class _ProductInCartState extends State<ProductInCart> {
  Widget _getPriceWidget() {
    final now = Timestamp.now();
    if (widget.product.discountPrice != null &&
        (widget.product.startDiscountDate != null ||
            widget.product.endDiscountDate != null) &&
        (widget.product.startDiscountDate == null ||
            now.compareTo(widget.product.startDiscountDate!) > 0) &&
        (widget.product.endDiscountDate == null ||
            now.compareTo(widget.product.endDiscountDate!) < 0)) {
      return RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: formatCurrency(widget.product.price),
              style: TextStyle(
                color: Theme.of(context).disabledColor,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            TextSpan(
              text: " ${formatCurrency(widget.product.discountPrice)}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }
    return Text("${formatCurrency(widget.product.price)} ",
        maxLines: 1, overflow: TextOverflow.ellipsis);
  }

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
                        additionTag: "_cartItem",
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
                _getPriceWidget(),
                const SizedBox(height: defPading),
                SizedBox(
                  height: 30,
                  width: constraints.maxWidth - 160.0 - defPading,
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (widget.quantity == 1) {
                            WidgetUtil.showYesNoDialog(
                                    context, "Are sure remove this product?")
                                .then((confirm) {
                              if (confirm != null && confirm) {
                                context
                                    .read<CartCubit>()
                                    .decrease(widget.product);
                              }
                            });
                          } else {
                            context.read<CartCubit>().decrease(widget.product);
                            Map<String, Map<String, int>> map = {};
                            context
                                .read<CartCubit>()
                                .state
                                .forEach((key, value) {
                              map.addAll({
                                key: {value.$1.price.toString(): value.$2}
                              });
                            });

                            OrderService.instance.update(Order()
                              ..id = Cache.cartId
                              ..products = map
                              ..status = 0
                              ..vouchers = []);
                          }
                        },
                        child: const Icon(Icons.remove),
                      ),
                      Card(child: Text(widget.quantity.toString())),
                      ElevatedButton(
                        onPressed: () {
                          context.read<CartCubit>().increase(widget.product);
                          Map<String, Map<String, int>> map = {};
                          context.read<CartCubit>().state.forEach((key, value) {
                            map.addAll({
                              key: {value.$1.price.toString(): value.$2}
                            });
                          });

                          OrderService.instance.update(Order()
                            ..id = Cache.cartId
                            ..products = map
                            ..status = 0
                            ..vouchers = []);
                        },
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
