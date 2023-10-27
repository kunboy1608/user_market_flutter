import 'package:flutter/cupertino.dart';
import 'package:user_market/cart/order_details.dart';
import 'package:user_market/entity/order.dart';
import 'package:user_market/service/entity/order_service.dart';
import 'package:user_market/util/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:user_market/util/widget_util.dart';

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

  void _cancel(BuildContext context) {
    WidgetUtil.showYesNoDialog(context, "Are you sure cancel this order?")
        .then((value) {
      if (value != null && value == true) {
        OrderService.instance.cancel(order);
      }
    });
  }

  void _update() {
    OrderService.instance.delivered(order);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => OrderDetails(order: order),
            ));
      },
      child: Card(
        child: ListTile(
          title: Text(
            "User: ${order.userId}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          isThreeLine: true,
          subtitle: Text(
              "Total: ${formatCurrency(_sum())}\nCreated date: ${order.uploadDate?.toDate().toString() ?? ""}"),
          trailing: 1 == order.status
              ? IconButton(
                  onPressed: () => _cancel(context),
                  icon: const Icon(Icons.clear_rounded))
              : 3 == order.status
                  ? IconButton(
                      onPressed: _update, icon: const Icon(Icons.check_rounded))
                  : null,
        ),
      ),
    );
  }
}
