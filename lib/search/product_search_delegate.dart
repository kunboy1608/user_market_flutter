import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/product_cubit.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/home/product_card.dart';
import 'package:user_market/util/const.dart';

class ProductSearchDelegate extends SearchDelegate<String?> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return query.isEmpty
        ? []
        : [
            IconButton(
                onPressed: () {
                  query = "";
                },
                icon: const Icon(Icons.clear))
          ];
  }

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back));

  @override
  Widget buildResults(BuildContext context) {
    return BlocBuilder<ProductCubit, Map<String, Product>>(
        builder: (context, state) {
      final currentValues = context.read<ProductCubit>().currentState().values;
      List<Product> listResult = [];

      for (final element in currentValues) {
        if (element.name != null &&
            element.name!
                .trim()
                .toLowerCase()
                .contains(query.trim().toLowerCase())) {
          listResult.add(element);
        }
      }
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: defPading,
            mainAxisSpacing: defPading,
            childAspectRatio: 0.9),
        itemBuilder: (_, index) => ProductCard(
          pro: listResult.elementAt(index),
        ),
        itemCount: listResult.length,
      );
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
