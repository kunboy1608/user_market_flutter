import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/order_cubit.dart';
import 'package:user_market/cart/list_item_in_cart_widget.dart';
import 'package:user_market/cart/list_orders_widget.dart';
import 'package:user_market/entity/order.dart';
import 'package:user_market/service/entity/order_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<Tab> _tabs;
  late List<Widget> _tabViews;

  @override
  void initState() {
    super.initState();
    debugPrint("Cart Page: init state");
    _tabs = const [
      Tab(text: "Cart"),
      Tab(text: "Waitting to confirm"),
      Tab(text: "Waiting to delivery man take product"),
      Tab(text: "Delivering"),
      Tab(text: "Delivered"),
      Tab(text: "Cancelled"),
      Tab(text: "Refund"),
    ];

    _tabViews = const [
      ListItemInCartWidget(),
      ListOrdersWidget(status: 1),
      ListOrdersWidget(status: 2),
      ListOrdersWidget(status: 3),
      ListOrdersWidget(status: 4),
      ListOrdersWidget(status: 5),
      ListOrdersWidget(status: 6),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<OrderCubit>().replaceState({});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
          appBar: AppBar(
              title: const Text("Cart"),
              bottom: TabBar(isScrollable: true, tabs: _tabs)),
          body: FutureBuilder(
              future: OrderService.instance.getInputChanges(),
              builder: (_, s) {
                if (!s.hasData) {
                  return Container();
                }
                return StreamBuilder(
                    stream: s.data!.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        for (var element in snapshot.data!.docChanges) {
                          Order o = Order.fromMap(element.doc.data()!)
                            ..id = element.doc.id;
                          switch (element.type) {
                            case DocumentChangeType.added:
                            case DocumentChangeType.modified:
                              context.read<OrderCubit>().addOrUpdateIfExist(o);
                              break;
                            case DocumentChangeType.removed:
                              context.read<OrderCubit>().remove(o);
                              break;
                            default:
                          }
                        }
                      }
                      return TabBarView(
                        children: _tabViews,
                      );
                    });
              })),
    );
  }

  @override
  void dispose() {
    // _streamController.close();
    debugPrint("Cart Page: dispose");
    super.dispose();
  }
}
