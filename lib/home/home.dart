import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/auth/change_password.dart';
import 'package:user_market/auth/login.dart';
import 'package:user_market/bloc/cart_cubit.dart';
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
import 'package:user_market/service/google/firebase_service.dart';
import 'package:user_market/service/google/firestorage_service.dart';
import 'package:user_market/user/user_infor_editor.dart';
import 'package:user_market/util/cache.dart';
import 'package:user_market/util/const.dart';
import 'package:user_market/util/spm.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _streamOrder;

  late ScrollController _controller;

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
      OrderService.instance.getSnapshot().then((value) {
        _streamOrder = value.listen((event) {
          for (var element in event.docChanges) {
            Order p = Order.fromMap(element.doc.data()!)..id = element.doc.id;
            switch (element.type) {
              case DocumentChangeType.added:
              case DocumentChangeType.modified:
                context.read<OrderCubit>().addOrUpdateIfExist(p);
                break;
              case DocumentChangeType.removed:
                context.read<OrderCubit>().remove(p);
                break;
              default:
            }
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                _scaffoldKey.currentState!.openDrawer();
              },
              icon: const Icon(CupertinoIcons.profile_circled)),
          title: Text(
            Cache.user?.fullName ?? "",
            overflow: TextOverflow.ellipsis,
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
                const SizedBox(height: defPading),
                ClipRRect(
                    borderRadius: BorderRadius.circular(defRadius),
                    child: const SizedBox(
                        height: 210, child: FlashSaleWidget())),
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
        drawer: NavigationDrawer(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
              child: Text(
                Cache.user?.fullName ?? "",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const Divider(),
            GestureDetector(
              onTap: () {
                context.read<CartCubit>().replaceCurrentState({});
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const UserInforEditor(),
                    ));
              },
              child: const ListTile(
                leading: Icon(CupertinoIcons.profile_circled),
                title: Text("Edit information"),
              ),
            ),
            GestureDetector(
              onTap: () {
                context.read<CartCubit>().replaceCurrentState({});
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const ChangePassword(),
                    ));
              },
              child: const ListTile(
                leading: Icon(Icons.security_rounded),
                title: Text("Change password"),
              ),
            ),
            const SizedBox(height: defPading),
            GestureDetector(
              onTap: () {
                context.read<CartCubit>().replaceCurrentState({});
                Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const Login(),
                    ));
              },
              child: const ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text("Log out"),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const CartBottom(
          isHidden: false,
        ));
  }

  @override
  void dispose() {
    debugPrint("Home: dispose");
    _streamOrder.cancel();
    _controller.dispose();
    Cache.user = null;
    Cache.userId = "";
    Cache.cartId = "";
    SPM.clearAllReference();
    FirestorageService.instance.dispose();
    FirestorageService.instance.dispose();
    FirebaseService.instance.initialAuth().then((value) {
      value?.signOut();
    });
    super.dispose();
  }
}
