import 'package:flutter/material.dart';
import 'package:user_market/cart/product_in_order.dart';
import 'package:user_market/entity/order.dart';
import 'package:user_market/service/entity/voucher_service.dart';
import 'package:user_market/util/string_utils.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key, required this.order});
  final Order order;

  @override
  State<OrderDetails> createState() => _OrderEditorState();
}

class _OrderEditorState extends State<OrderDetails> {
  Widget _summaryWidget(BuildContext context) {
    double sum = 0.0;
    double discount = 0.0;

    widget.order.products?.forEach(
      (key, value) {
        sum += double.parse(value.keys.first) * value.values.first;
      },
    );

    if (widget.order.vouchers != null && widget.order.vouchers!.isNotEmpty) {
      return FutureBuilder(
          future: VoucherService.instance.getById(widget.order.vouchers!.first),
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
            );
          });
    }

    return ListTile(
      isThreeLine: true,
      subtitle: Text(
          "Subtotal: ${formatCurrency(sum)}\nDiscount: ${formatCurrency(discount)} \nAmount: ${formatCurrency(sum - discount)}"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order details"),
      ),
      body: ListView.builder(
        itemCount: widget.order.products?.length ?? 0,
        itemBuilder: (context, index) {
          return ProductInOrder(
            productId: widget.order.products!.keys.elementAt(index),
            quantity:
                widget.order.products!.values.elementAt(index).values.first,
            price: double.parse(
                widget.order.products!.values.elementAt(index).keys.first),
          );
        },
      ),
      bottomNavigationBar: _summaryWidget(context),
    );
  }
}
