import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/order_cubit.dart';
import 'package:user_market/bloc/product_cubit.dart';
import 'package:user_market/entity/order.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/home/banner/banner_widget.dart';
import 'package:user_market/home/banner/flash_sale_widget.dart';
import 'package:user_market/home/banner/best_seller_widget.dart';
import 'package:user_market/home/cart_bottom.dart';
import 'package:user_market/home/product/product_card.dart';
import 'package:user_market/search/product_search_delegate.dart';
import 'package:user_market/service/entity/order_service.dart';
import 'package:user_market/service/entity/product_service.dart';
import 'package:user_market/util/cache.dart';
import 'package:user_market/util/const.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late ScrollController _controller;
  final _streamOrdersController =
      StreamController<(DocumentChangeType, Order)>();

  bool? _isSortedByCategory;
  int _filterCategory = 0;

  Map<String, Product>? _holdCurrentState;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();

    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        ProductService.instance.lazyLoad().then((value) {
          context.read<ProductCubit>().addOrUpdateIfExistAll(value);
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get orders
      OrderService.instance.listenChanges(_streamOrdersController);
      _streamOrdersController.stream.listen((event) {
        switch (event.$1) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:
            context.read<OrderCubit>().addOrUpdateIfExist(event.$2);
            break;
          case DocumentChangeType.removed:
            // Support remove useless img on Firestorage
            context.read<OrderCubit>().remove(event.$2);
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
          title: Row(
            children: [
              const Icon(CupertinoIcons.profile_circled),
              Text(
                Cache.userId.substring(0, 15),
                overflow: TextOverflow.ellipsis,
              )
            ],
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
                )),
            PopupMenuButton<int>(
              icon: const Icon(Icons.filter_alt_rounded),
              onSelected: (value) {
                if (value != _filterCategory) {
                  _filterCategory = value;
                  switch (_filterCategory) {
                    case 0:
                      if (_holdCurrentState != null) {
                        context
                            .read<ProductCubit>()
                            .replaceState(_holdCurrentState!);
                      }
                      _holdCurrentState = null;
                      break;

                    default:
                      _holdCurrentState ??=
                          Map.of(context.read<ProductCubit>().currentState());
                      Map<String, Product> mapFilter = {};
                      _holdCurrentState!.forEach((key, value) {
                        if (value.categoryId == _filterCategory) {
                          mapFilter.addAll({key: value});
                        }
                      });
                      context.read<ProductCubit>().replaceState(mapFilter);
                      break;
                  }
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text('Remove filter'),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text('Category 1'),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text('Category 2'),
                ),
                const PopupMenuItem<int>(
                  value: 3,
                  child: Text('Category 3'),
                ),
              ],
            ),
            PopupMenuButton<bool>(
              icon: const Icon(Icons.sort),
              onSelected: (value) {
                if (value != _isSortedByCategory) {
                  _isSortedByCategory = value;
                  if (_isSortedByCategory!) {
                    context.read<ProductCubit>().sortByCategory();
                  } else {
                    context.read<ProductCubit>().sortByName();
                  }
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<bool>>[
                const PopupMenuItem<bool>(
                  value: false,
                  child: Text('Order by Product\'s name'),
                ),
                const PopupMenuItem<bool>(
                  value: true,
                  child: Text('Order by Product\'s category'),
                ),
              ],
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defPading / 2),
          child: SingleChildScrollView(
            controller: _controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(defRadius),
                    child: SizedBox(
                        height: MediaQuery.of(context).size.width * 9 / 16,
                        child: const BannerWidget())),
                const SizedBox(height: defPading),
                Text(
                  "Flash sale",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                ClipRRect(
                    borderRadius: BorderRadius.circular(defRadius),
                    child:
                        const SizedBox(height: 210, child: FlashSaleWidget())),
                const SizedBox(height: defPading),
                Text(
                  "Best sellers",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: defPading),
                ClipRRect(
                    borderRadius: BorderRadius.circular(defRadius),
                    child: const SizedBox(
                        height: 210, child: BestSellersWidget())),
                const SizedBox(height: defPading),
                Text(
                  "Daily discover",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                BlocBuilder<ProductCubit, Map<String, Product>>(
                  builder: (context, state) => GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            (MediaQuery.of(context).size.width ~/ 200),
                        crossAxisSpacing: defPading,
                        mainAxisSpacing: defPading,
                        childAspectRatio: 0.9),
                    itemBuilder: (_, index) =>
                        ProductCard(pro: state.values.elementAt(index)),
                    itemCount: state.values.length,
                  ),
                ),
                const SizedBox(height: defPading),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const CartBottom(
          isHidden: false,
        ));
  }
}
