import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/home/cart_bottom.dart';
import 'package:user_market/home/product_card.dart';
import 'package:user_market/util/const.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<Product> _products;
  // bool _hideCart = false;
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _products = List.generate(50, (index) {
      Product p = Product();
      p.id = index.toString();
      p.name = "Product $index";
      p.categoryId = Random().nextInt(4);
      p.date = Timestamp.now();
      p.price = Random().nextDouble();
      p.actuallyLink = "assets/img/background_login.png";
      return p;
    }).toList();
    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("App bar"),
          actions: const [
            Icon(
              CupertinoIcons.profile_circled,
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defPading / 2),
          child: GridView.builder(
            controller: _controller,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: defPading,
                mainAxisSpacing: defPading,
                childAspectRatio: 0.9),
            itemBuilder: (_, index) => ProductCard(              
              pro: _products[index],
            ),
            itemCount: _products.length,
          ),
        ),
        bottomNavigationBar: const CartBottom(
          isHidden: false,
        ));
  }
}
