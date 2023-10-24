import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/product_cubit.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/home/product/product_card.dart';
import 'package:user_market/util/const.dart';

class HotSaleWidget extends StatelessWidget {
  const HotSaleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return BlocBuilder<ProductCubit, Map<String, Product>>(
        builder: (context, state) => ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: state.values.length,
          itemBuilder: (_, index) => SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxHeight * 0.9,
            child: ProductCard(
              pro: state.values.elementAt(index),
            ),
          ),
          separatorBuilder: (_, __) => const SizedBox(
            width: defPading,
          ),
        ),
      );
    });
  }
}
