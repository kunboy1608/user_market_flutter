import 'package:flutter/material.dart';
import 'package:user_market/home/cart.dart';

class CartBottom extends StatefulWidget {
  const CartBottom({super.key, required this.isHidden});

  final bool isHidden;

  @override
  State<CartBottom> createState() => _CartBottomState();
}

class _CartBottomState extends State<CartBottom> {
  @override
  Widget build(BuildContext context) {
    double height = 60;
    return AnimatedContainer(
      height: widget.isHidden ? 0 : height,
      duration: const Duration(seconds: 1),
      child: SingleChildScrollView(
        child: Cart(
          height: height,
        ),
      ),
    );
  }
}
