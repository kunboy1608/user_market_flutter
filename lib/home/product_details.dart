import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/cart_cubit.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/util/const.dart';
import 'package:user_market/util/string_utils.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key, required this.pro, this.isFromCart = false});
  final Product pro;
  final bool isFromCart;

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  String _tag = "";

  @override
  void initState() {
    super.initState();
    _tag = widget.pro.id ?? "";
    if (widget.isFromCart) {
      _tag += "_cartItem";
    }
  }

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
              child: Center(
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
      bottomNavigationBar: widget.isFromCart
          ? null
          : ElevatedButton(
              onPressed: () {
                context.read<CartCubit>().setOrReplace(widget.pro, 1);
                context.read<CartCubit>().setOrReplace(widget.pro, 1);
                setState(() {
                  _tag = "${widget.pro.id ?? ""}_cartItem";
                });
                Navigator.pop(context);
              },
              child: const Text("Add to cart"),
            ),
    );
  }
}
