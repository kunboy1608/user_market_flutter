import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/cart_cubit.dart';
import 'package:user_market/bloc/voucher_cubit.dart';
import 'package:user_market/entity/order.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/service/entity/order_service.dart';
import 'package:user_market/util/cache.dart';
import 'package:user_market/util/const.dart';
import 'package:user_market/util/string_utils.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key, required this.pro, this.additionTag = ""});
  final Product pro;
  final String additionTag;

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  String _tag = "";

  @override
  void initState() {
    super.initState();
    _tag = "${widget.pro.id ?? ""}${widget.additionTag}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App bar"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defPading),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Hero(
                  tag: _tag,
                  child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(defRadius),
                        bottomRight: Radius.circular(defRadius),
                      ),
                      child: widget.pro.actuallyLink != null &&
                              widget.pro.actuallyLink!.isNotEmpty
                          ? SizedBox(
                              child: FadeInImage(                                
                                placeholder:
                                    const AssetImage('assets/img/loading.gif'),
                                image:
                                    FileImage(File(widget.pro.actuallyLink!)),
                              ),
                            )
                          : const Icon(Icons.add_rounded)),
                ),
              ),
              const SizedBox(height: defPading),
              Row(
                children: [
                  Text(
                    widget.pro.name ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Text(
                    formatCurrency(widget.pro.price),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  )
                ],
              ),
              Text("Category: ${widget.pro.categoryId?.toString() ?? ""}",
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(widget.pro.description ?? ""),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FilledButton(
        onPressed: () {
          context.read<CartCubit>().changeQuantity(widget.pro, 1);
          setState(() {
            _tag = "${widget.pro.id ?? ""}_cartItem";
          });

          Map<String, Map<String, int>> map = {};

          final m = Map.of(context.read<CartCubit>().state);

          m.forEach((key, value) {
            map.addAll({
              key: {value.$1.price.toString(): value.$2}
            });
          });

          Navigator.pop(context);
          List<String> vouchers = [];
          if (context.read<VoucherCubit>().currentState().values.isNotEmpty) {
            vouchers.add(
                context.read<VoucherCubit>().currentState().values.first.id ??
                    "");
          }

          OrderService.instance.update(Order()
            ..id = Cache.cartId
            ..userId = Cache.userId
            ..products = map
            ..vouchers = vouchers);
        },
        child: const Text("Add to cart"),
      ),
    );
  }
}
