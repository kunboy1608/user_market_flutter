import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/product_cubit.dart';
import 'package:user_market/home/product/product_card.dart';
import 'package:user_market/service/entity/product_service.dart';
import 'package:user_market/util/const.dart';
import 'package:user_market/util/widget_util.dart';

class FlashSaleWidget extends StatelessWidget {
  const FlashSaleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return FutureBuilder(
          future: ProductService.instance.getFlashSale(),
          builder: (ctx, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return ListView.separated(
                  itemCount: 5,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => SizedBox(
                    height: constraints.maxHeight,
                    width: constraints.maxHeight * 0.9,
                    child: WidgetUtil.skeletonProductCard(),
                  ),
                  separatorBuilder: (_, __) => const SizedBox(width: defPading),
                );
              case ConnectionState.done:
                if (snapshot.hasData) {
                  ctx
                      .read<ProductCubit>()
                      .addOrUpdateIfExistAll(snapshot.data!);
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) => SizedBox(
                      height: constraints.maxHeight,
                      width: constraints.maxHeight * 0.9,
                      child: ProductCard(
                        pro: snapshot.data!.elementAt(index),
                        additionTag: "_flashSale",
                      ),
                    ),
                    separatorBuilder: (_, __) => const SizedBox(
                      width: defPading,
                    ),
                  );
                }
                return const Center(
                  child: Text(
                      "Sorry!! There are no products on sale at this time"),
                );

              default:
                return Container();
            }
          });
    });
  }
}
