import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/cart_cubit.dart';
import 'package:user_market/cart/cart_page.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/home/cart_item.dart';
import 'package:user_market/service/entity/order_service.dart';
import 'package:user_market/service/entity/product_service.dart';
import 'package:user_market/util/const.dart';

class CartBottom extends StatefulWidget {
  const CartBottom({super.key, required this.isHidden});

  final bool isHidden;

  @override
  State<CartBottom> createState() => _CartBottomState();
}

class _CartBottomState extends State<CartBottom> {
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> _streamCart;
  final double _height = 60.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      OrderService.instance.getSnapshotCart().then((value) {
        _streamCart = value.listen((event) {
          Map<String, int> products = {};

          // Map<ProductId, Map<price.toString(), quantity>>
          final map = event.data()!["products"];
          map?.forEach((key, value) {
            products.addAll({key: value.values.first});
          });

          Map<String, (Product, int)> m = {};
          products.forEach((key, value) {
            ProductService.instance.getById(key).then((pro) {
              if (pro != null) {
                m.addAll({pro.id!: (pro, value)});
                context.read<CartCubit>().replaceCurrentState(m);
              }
            });
          });
          context.read<CartCubit>().replaceCurrentState(m);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: _height + defPading,
        padding: const EdgeInsets.all(defPading / 2),
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: LayoutBuilder(builder: (context, constraints) {
          return BlocBuilder<CartCubit, Map<String, (Product, int)>>(
              builder: (_, state) {
            return Row(
              children: [
                SizedBox(
                    width: constraints.maxWidth - _height,
                    height: _height,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, index) {
                        return CartItem(
                            product: state.values.elementAt(index).$1,
                            size: _height);
                      },
                      itemCount: state.values.length,
                      separatorBuilder: (_, __) => const SizedBox(
                        width: defPading,
                      ),
                    )),
                SizedBox(
                  height: _height,
                  width: _height,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            reverseTransitionDuration:
                                const Duration(milliseconds: 500),
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
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
                    icon: Badge(
                      label: Text(state.length.toString()),
                      child: Icon(
                        CupertinoIcons.cart,
                        size: _height / 2,
                      ),
                    ),
                  ),
                )
              ],
            );
          });
        }));
  }

  @override
  void dispose() {
    debugPrint("Cart Bottom: dispose");
    _streamCart.cancel();
    super.dispose();
  }
}
