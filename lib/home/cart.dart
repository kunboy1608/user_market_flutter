import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/cart_cubit.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/home/cart_item.dart';
import 'package:user_market/util/const.dart';

class Cart extends StatefulWidget {
  const Cart({super.key, required this.height});
  final double height;

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
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
                onPressed: () {},
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
}
