import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/product_cubit.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/home/product/product_card.dart';
import 'package:user_market/util/const.dart';

class FlashSaleWidget extends StatelessWidget {
  const FlashSaleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return BlocBuilder<ProductCubit, Map<String, Product>>(
          builder: (_, state) {
        final listFlashSale = context.read<ProductCubit>().getFlashSale();
        if (listFlashSale.isEmpty) {
          return const Text(
              "Sorry!! There are no products on sale at this time");
        }
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: listFlashSale.length,
          itemBuilder: (_, index) => SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxHeight * 0.9,
            child: ProductCard(
              pro: listFlashSale.elementAt(index),
              additionTag: "_flashSale",
            ),
          ),
          separatorBuilder: (_, __) => const SizedBox(
            width: defPading,
          ),
        );
      });
    });
  }
}
