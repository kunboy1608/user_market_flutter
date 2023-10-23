import 'package:flutter/material.dart';

class ListOrdersWidget extends StatefulWidget {
  const ListOrdersWidget({super.key, required this.status})
      : assert(status >= 0 && status <= 6);
  final int status;

  @override
  State<ListOrdersWidget> createState() => _ListOrdersWidgetState();
}

class _ListOrdersWidgetState extends State<ListOrdersWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 50,
      itemBuilder: (context, index) {
        // return OrderCard(
        //     order: Order()
        //       ..status = widget.status
        //       ..products = [
        //         ("", 0.0, 1),
        //         // ("", 0.0, 2),
        //         // ("", 0.0, 3),
        //         // ("", 0.0, 4),
        //         // ("", 0.0, 5),
        //         // ("", 0.0, 6)
        //       ]);
        return Container();
      },
    );
  }
}
