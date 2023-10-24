import 'package:cloud_firestore/cloud_firestore.dart';
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
  late DocumentReference<Map<String, dynamic>> _stream;

  @override
  void initState() {
    debugPrint("Cart: initState");
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      OrderService.instance.getCartChanges().then((s) {
        _stream = s;
        _stream.snapshots().listen((event) {
          if (event.data() != null) {
            Map<String, int> products = {};

            // Map<ProductId, Map<price.toString(), quantity>>
            final map = event.data()!["products"];
            map?.forEach((key, value) {
              debugPrint("key: $key value: $value");
              products.addAll({key: value.values.first});
            });

            if (products.isEmpty) {
              context.read<CartCubit>().replaceCurrentState({});
            } else {
              Map<String, (Product, int)> map = {};
              products.forEach((key, value) {
                ProductService.instance.getById(key).then((pro) {
                  if (pro != null) {
                    map.addAll({pro.id!: (pro, value)});
                    context.read<CartCubit>().replaceCurrentState(map);
                  }
                });
              });
            }
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.height,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: LayoutBuilder(builder: (context, constraints) {
          return BlocBuilder<CartCubit, Map<String, (Product, int)>>(
              builder: (_, state) {
            return Row(
              children: [
                SizedBox(
                    width: constraints.maxWidth - widget.height,
                    height: widget.height,
                    child: ListView.separated(
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
                    )),
                SizedBox(
                  height: widget.height,
                  width: widget.height,
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
                        size: widget.height / 2,
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
    debugPrint("Cart: dispose");
    _stream.snapshots().listen((event) {}).cancel();
    super.dispose();
  }
}
