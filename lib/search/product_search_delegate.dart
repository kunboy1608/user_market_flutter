import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/product_cubit.dart';
import 'package:user_market/home/product/product_card.dart';
import 'package:user_market/service/entity/product_service.dart';
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
    return FutureBuilder(
        future: ProductService.instance.searchByName(query),
        builder: (ctx, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                ctx.read<ProductCubit>().addOrUpdateIfExistAll(snapshot.data!);
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          (MediaQuery.of(context).size.width ~/ 200),
                      crossAxisSpacing: defPading,
                      mainAxisSpacing: defPading,
                      childAspectRatio: 0.9),
                  itemBuilder: (_, index) => ProductCard(
                    pro: snapshot.data!.elementAt(index),
                  ),
                  itemCount: snapshot.data?.length ?? 0,
                );
              } else {
                return const Center(child: Text("Not found"));
              }

            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
