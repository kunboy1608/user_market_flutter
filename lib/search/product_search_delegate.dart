import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/product_cubit.dart';
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
    return BlocBuilder(builder: (context, state) {
      final listResult =
          context.read<ProductCubit>().currentState().values.map((e) {
        if (e.name != null && e.name!.contains(query)) {
          return e;
        }
        return null;
      }).toList();

      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: defPading,
            mainAxisSpacing: defPading,
            childAspectRatio: 0.9),
        itemBuilder: (_, index) => ProductCard(
          pro: listResult.elementAt(index)!,
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
