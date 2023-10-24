import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/order_cubit.dart';
import 'package:user_market/cart/order_card.dart';
import 'package:user_market/entity/order.dart';
import 'package:user_market/util/const.dart';

class ListOrdersWidget extends StatefulWidget {
  const ListOrdersWidget({super.key, required this.status})
      : assert(status >= 1 && status <= 6);
  final int status;

  @override
  State<ListOrdersWidget> createState() => _ListOrdersWidgetState();
}

class _ListOrdersWidgetState extends State<ListOrdersWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, Map<String, Order>>(
        builder: (context, state) {
      final list = context.read<OrderCubit>().getOrdersByStatus(widget.status);
      return ListView.separated(
          itemBuilder: (context, index) => OrderCard(order: list[index]),
          separatorBuilder: (context, index) => const SizedBox(
                height: defPading,
              ),
          itemCount: list.length);
    });
  }
}
