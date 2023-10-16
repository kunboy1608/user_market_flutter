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

  bool? _isSortedByCategory;
  int _filterCategory = 0;

  Map<String, Product>? _holdCurrentState;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();

    FirestoreService.instance
        .listenChanges(Product.collectionName, _streamController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _streamController.stream.listen((event) {
        _isSortedByCategory = null;
        if (_holdCurrentState == null) {
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
        } else {
          if (event.$2.categoryId == _filterCategory) {
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
          }
          switch (event.$1) {
            case DocumentChangeType.added:
            case DocumentChangeType.modified:
              _holdCurrentState!.addAll({event.$2.id!: event.$2});
              break;
            case DocumentChangeType.removed:
              // Support remove useless img on Firestorage
              FirestorageService.instance.delete(event.$2.imgUrl ?? "");
              _holdCurrentState!.remove(event.$2.id!);
              break;
            default:
          }
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
                      // _holdCurrentState!.clear();
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
            child: BlocBuilder<ProductCubit, Map<String, Product>>(
              builder: (context, state) => GridView.builder(
                controller: _controller,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: defPading,
                    mainAxisSpacing: defPading,
                    childAspectRatio: 0.9),
                itemBuilder: (_, index) => ProductCard(
                  pro: state.values.elementAt(index),
                ),
                itemCount: state.values.length,
              ),
            )),
        bottomNavigationBar: const CartBottom(
          isHidden: false,
        ));
  }
}
