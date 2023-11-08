import 'package:flutter/cupertino.dart';
import 'package:user_market/cart/order_details.dart';
import 'package:user_market/entity/order.dart';
import 'package:user_market/service/entity/order_service.dart';
import 'package:user_market/service/entity/voucher_service.dart';
import 'package:user_market/util/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:user_market/util/widget_util.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});
  final Order order;

  Widget _summaryWidget(BuildContext context) {
    double sum = 0.0;
    double discount = 0.0;

    order.products?.forEach(
      (key, value) {
        sum += double.parse(value.keys.first) * value.values.first;
      },
    );

    if (order.vouchers != null && order.vouchers!.isNotEmpty) {
      return FutureBuilder(
          future: VoucherService.instance.getById(order.vouchers!.first),
          builder: (context, snapshot) {
            final voucher = snapshot.data;
            if (voucher != null) {
              if (voucher.percent != null || voucher.percent! > 0) {
                discount = sum * (voucher.percent! / 100);
                if (voucher.maxValue != null) {
                  discount = discount.clamp(0, voucher.maxValue!);
                }
              } else {
                discount = (voucher.maxValue ?? 0).clamp(0, sum);
              }
            }
            return ListTile(
              isThreeLine: true,
              subtitle: Text(
                  "Subtotal: ${formatCurrency(sum)}\nDiscount: ${formatCurrency(discount)} \nAmount: ${formatCurrency(sum - discount)}"),
              trailing: 1 == order.status
                  ? IconButton(
                      onPressed: () => _cancel(context),
                      icon: const Icon(Icons.clear_rounded))
                  : 3 == order.status
                      ? IconButton(
                          onPressed: _update,
                          icon: const Icon(Icons.check_rounded))
                      : null,
            );
          });
    }

    return ListTile(
      isThreeLine: true,
      subtitle: Text(
          "Subtotal: ${formatCurrency(sum)}\nDiscount: ${formatCurrency(discount)} \nAmount: ${formatCurrency(sum - discount)}"),
      trailing: 1 == order.status
          ? IconButton(
              onPressed: () => _cancel(context),
              icon: const Icon(Icons.clear_rounded))
          : 3 == order.status
              ? IconButton(
                  onPressed: _update, icon: const Icon(Icons.check_rounded))
              : null,
    );
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
      child: Card(child: _summaryWidget(context)),
    );
  }
}
