import 'package:user_market/entity/order.dart';
import 'package:user_market/service/entity/order_service.dart';
import 'package:user_market/util/string_utils.dart';
import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});
  final Order order;

  double _sum() {
    double sum = 0.0;

    order.products?.forEach((key, value) {
      sum += double.parse(value.keys.first) * value.values.first;
    });

    return sum;
  }

  void _cancel() {
    OrderService.instance.cancel(order);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          "User: ${order.userId}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        subtitle: Text(
            "Total: ${formatCurrency(_sum())}\nCreated date: ${order.uploadDate}"),
        trailing: order.status == 1
            ? IconButton(
                onPressed: _cancel, icon: const Icon(Icons.clear_rounded))
            : null,
      ),
    );
  }
}
