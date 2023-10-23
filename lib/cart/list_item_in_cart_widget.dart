import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/cart_cubit.dart';
import 'package:user_market/cart/product_in_cart.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/util/const.dart';
import 'package:user_market/util/string_utils.dart';

class ListItemInCartWidget extends StatefulWidget {
  const ListItemInCartWidget({super.key});

  @override
  State<ListItemInCartWidget> createState() => _ListItemInCartWidgetState();
}

class _ListItemInCartWidgetState extends State<ListItemInCartWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(     
      body: BlocBuilder<CartCubit, Map<String, (Product, int)>>(
          builder: (context, state) => ListView.separated(
              itemBuilder: (context, index) => ProductInCart(
                  product: state.values.elementAt(index).$1,
                  quantity: state.values.elementAt(index).$2),
              separatorBuilder: (context, index) => const SizedBox(
                    height: defPading,
                  ),
              itemCount: state.values.length)),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: BlocBuilder<CartCubit, Map<String, (Product, int)>>(
                  builder: (_, state) {
                    double sum = 0.0;
                    for (var element in state.values) {
                      sum += (element.$1.price ?? 0) * element.$2;
                    }
                    return Text("Total: ${formatCurrency(sum)}");
                  },
                ),
              ),
            ),
            Expanded(
                child: FilledButton(
              onPressed: () {},
              child: const Text("Buy!"),
            ))
          ],
        ),
      ),
    );
  }
}