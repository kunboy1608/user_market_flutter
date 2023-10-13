import 'package:flutter/material.dart';
import 'package:user_market/home/cart.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key, required this.isHidden});

  final bool isHidden;

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    double height = 60;
    return AnimatedContainer(
      height: widget.isHidden ? 0 : height,
      duration: const Duration(seconds: 1),
      child: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {},
          child: isExpanded
              ? Container()
              : Cart(
                  height: height,
                ),
        ),
      ),
    );
  }
}
