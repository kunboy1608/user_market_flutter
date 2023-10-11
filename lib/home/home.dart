import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/home/product_card.dart';
import 'package:user_market/util/const.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<Product> _products;

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
      return p;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App bar"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defPading / 2),
        child: GridView.builder(
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
    );
  }
}
