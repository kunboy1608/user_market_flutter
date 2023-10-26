import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/product_cubit.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/home/product/product_card.dart';
import 'package:user_market/util/const.dart';

class BestSellersWidget extends StatelessWidget {
  const BestSellersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return BlocBuilder<ProductCubit, Map<String, Product>>(
        builder: (_, state) {
          final bestSellers = context.read<ProductCubit>().getBestSeller();
          return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: bestSellers.length,
          itemBuilder: (_, index) => SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxHeight * 0.9,
            child: ProductCard(
              pro: bestSellers.elementAt(index),
              additionTag: "_bestSellers",
            ),
          ),
          separatorBuilder: (_, __) => const SizedBox(
            width: defPading,
          ),
        );}
      );
    });
  }
}
