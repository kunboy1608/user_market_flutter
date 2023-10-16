import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/product_cubit.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/home/cart_bottom.dart';
import 'package:user_market/home/product_card.dart';
import 'package:user_market/search/product_search_delegate.dart';
import 'package:user_market/service/firestorage_service.dart';
import 'package:user_market/service/firestore_service.dart';
import 'package:user_market/util/const.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // bool _hideCart = false;
  late ScrollController _controller;
  final _streamController = StreamController<(DocumentChangeType, Product)>();
  // ignore: unused_field
  bool? _isSortedByCategory;

  Future<Map<String, Product>?> _loadData() async {
    return FirestoreService.instance.get(Product.collectionName).then((list) {
      Map<String, Product> map = {};
      list?.forEach((element) {
        final p = element as Product;
        map[p.id ?? ""] = p;
      });
      context.read<ProductCubit>().replaceState(map);
      return map;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();

    FirestoreService.instance
        .listenChanges(Product.collectionName, _streamController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _streamController.stream.listen((event) {
        _isSortedByCategory = null;
        switch (event.$1) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            context.read<ProductCubit>().addOrUpdateIfExist(event.$2);
            break;
          case DocumentChangeType.removed:
            // Support remove useless img on Firestorage
            FirestorageService.instance.delete(event.$2.imgUrl ?? "");
            context.read<ProductCubit>().remove(event.$2);
            break;
          default:
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () {},
            child: const Row(
              children: [Icon(CupertinoIcons.profile_circled), Text("User")],
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(
                      context: context,
                      useRootNavigator: true,
                      delegate: ProductSearchDelegate());
                },
                icon: const Icon(
                  CupertinoIcons.search,
                ))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defPading / 2),
          child: FutureBuilder(
              future: _loadData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return BlocBuilder<ProductCubit, Map<String, Product>>(
                    builder: (context, state) => GridView.builder(
                      controller: _controller,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: defPading,
                              mainAxisSpacing: defPading,
                              childAspectRatio: 0.9),
                      itemBuilder: (_, index) => ProductCard(
                        pro: state.values.elementAt(index),
                      ),
                      itemCount: state.values.length,
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ),
        bottomNavigationBar: const CartBottom(
          isHidden: false,
        ));
  }
}
