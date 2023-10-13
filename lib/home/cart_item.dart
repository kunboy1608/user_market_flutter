import 'package:flutter/cupertino.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/home/product_details.dart';

class CartItem extends StatelessWidget {
  const CartItem({super.key, required this.product, required this.size});
  final Product product;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (_) => ProductDetails(
                        pro: product,
                        isFromCart: true,
                      )));
        },
        child: Hero(
          tag: "${product.id}_cartItem",
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(180)),
            child: Image.asset(
              'assets/img/background_login.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
