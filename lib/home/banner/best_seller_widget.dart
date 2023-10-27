import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/product_cubit.dart';
import 'package:user_market/home/product/product_card.dart';
import 'package:user_market/service/entity/product_service.dart';
import 'package:user_market/util/const.dart';

class BestSellersWidget extends StatelessWidget {
  const BestSellersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return FutureBuilder(
        future: ProductService.instance.getBestSellers(),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            ctx.read<ProductCubit>().addOrUpdateIfExistAll(snapshot.data!);
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (ctx, index) => SizedBox(
                height: constraints.maxHeight,
                width: constraints.maxHeight * 0.9,
                child: ProductCard(
                  pro: snapshot.data!.elementAt(index),
                  additionTag: "_bestSellers",
                ),
              ),
              separatorBuilder: (_, __) => const SizedBox(
                width: defPading,
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
    });
  }
}
