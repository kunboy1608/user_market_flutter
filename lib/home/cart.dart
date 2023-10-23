import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/cart_cubit.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/home/cart_item.dart';
import 'package:user_market/cart/cart_page.dart';
import 'package:user_market/service/entity/order_service.dart';
import 'package:user_market/service/entity/product_service.dart';
import 'package:user_market/util/const.dart';

class Cart extends StatefulWidget {
  const Cart({super.key, required this.height});
  final double height;

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  late StreamController<Map<String, int>> _streamController;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<Map<String, int>>();

    OrderService.instance.listenCartChanges(_streamController);
    _streamController.stream.listen(
      (event) {
        if (event.isEmpty) {
          context.read<CartCubit>().replaceCurrentState({});
        } else {
          Map<String, (Product, int)> map = {};
          event.forEach((key, value) {
            ProductService.instance.getById(key).then((pro) {
              if (pro != null) {
                map.addAll({pro.id!: (pro, value)});
                context.read<CartCubit>().replaceCurrentState(map);
              }
            });
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: LayoutBuilder(builder: (context, constraints) {
        return Row(
          children: [
            SizedBox(
                width: constraints.maxWidth - widget.height,
                height: widget.height,
                child: BlocBuilder<CartCubit, Map<String, (Product, int)>>(
                  builder: (_, state) {
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, index) {
                        return CartItem(
                            product: state.values.elementAt(index).$1,
                            size: widget.height);
                      },
                      itemCount: state.values.length,
                      separatorBuilder: (_, __) => const SizedBox(
                        width: defPading,
                      ),
                    );
                  },
                )),
            SizedBox(
              height: widget.height,
              width: widget.height,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 500),
                        reverseTransitionDuration:
                            const Duration(milliseconds: 500),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          var begin = const Offset(0.0, 1.0);
                          var end = Offset.zero;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: Curves.ease));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: const CartPage(),
                          );
                        },
                      ));
                },
                icon: Icon(
                  CupertinoIcons.cart,
                  size: widget.height / 2,
                ),
              ),
            )
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}
