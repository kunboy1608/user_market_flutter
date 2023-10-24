import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/order_cubit.dart';
import 'package:user_market/entity/order.dart';

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
    return BlocBuilder<OrderCubit, Map<int, Map<String, Order>>>(
        builder: (context, state) {
      return ListView.builder(
        itemCount: state[widget.status]?.length ?? 0,
        itemBuilder: (context, index) {
          if (state[widget.status] != null &&
              state[widget.status]!.isNotEmpty) {
            return Text(
                state[widget.status]?.values.elementAt(index).id ?? "null");
          } else {
            return Container();
          }
        },
      );
    });
  }
}
