import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/cart_cubit.dart';
import 'package:user_market/bloc/voucher_cubit.dart';
import 'package:user_market/cart/product_in_cart.dart';
import 'package:user_market/cart/voucher_page.dart';
import 'package:user_market/entity/order.dart';
import 'package:user_market/entity/product.dart';
import 'package:user_market/entity/voucher.dart';
import 'package:user_market/service/entity/order_service.dart';
import 'package:user_market/service/entity/voucher_service.dart';
import 'package:user_market/util/cache.dart';
import 'package:user_market/util/const.dart';
import 'package:user_market/util/cost_util.dart';
import 'package:user_market/util/string_utils.dart';

class ListItemInCartWidget extends StatefulWidget {
  const ListItemInCartWidget({super.key});

  @override
  State<ListItemInCartWidget> createState() => _ListItemInCartWidgetState();
}

class _ListItemInCartWidgetState extends State<ListItemInCartWidget> {
  final _formKey = GlobalKey<FormState>();
  final _addressTEC = TextEditingController();
  final _phoneNumberTEC = TextEditingController();
  final _nodePhoneNumber = FocusNode();

  double _sum = 0.0;
  double _discount = 0.0;
  double _discountProduct = 0.0;

  Future<dynamic> _showInputAdressPhoneNumber(BuildContext context) {
    _addressTEC.text = Cache.user?.address ?? "";
    _phoneNumberTEC.text = Cache.user?.phoneNumber ?? "";
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(defPading),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Spacer(),
                  TextFormField(
                    autofocus: true,
                    controller: _addressTEC,
                    onEditingComplete: () => _nodePhoneNumber.requestFocus(),
                    keyboardType: TextInputType.streetAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your address";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        label: const Text("Address*"),
                        suffixIcon: IconButton(
                            onPressed: () => _addressTEC.text = "",
                            icon: const Icon(Icons.clear_rounded))),
                  ),
                  TextFormField(
                    focusNode: _nodePhoneNumber,
                    controller: _phoneNumberTEC,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your phone number";
                      }
                      if (value.length < 10) {
                        return "Phone number leasts 10 letters";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        label: const Text("Phone number*"),
                        suffixIcon: IconButton(
                            onPressed: () => _phoneNumberTEC.text = "",
                            icon: const Icon(Icons.clear_rounded))),
                  ),
                  const SizedBox(height: defPading),
                  FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context);
                          _buyAll();
                        }
                      },
                      child: const Text("Submit")),
                  const Spacer(),
                ],
              )),
        ),
      ),
    );
  }

  void _buyAll() {
    Map<String, Map<String, int>> map = {};
    context.read<CartCubit>().state.forEach((key, value) {
      double actPrice = getActuallyCost(value.$1);
      map.addAll({
        key: {actPrice.toString(): value.$2}
      });
    });

    OrderService.instance
        .add(Order()
          ..products = map
          ..status = 1
          ..phoneNumber = _phoneNumberTEC.text
          ..address = _addressTEC.text
          ..vouchers = context
              .read<VoucherCubit>()
              .currentState()
              .values
              .map((e) => e.id!)
              .toList())
        .then((_) {
      context.read<VoucherCubit>().currentState().values.forEach((element) {
        VoucherService.instance
            .decreaseCount(element)
            .then((_) => context.read<VoucherCubit>().remove(element));
      });

      OrderService.instance
          .update(Order()
            ..id = Cache.cartId
            ..userId = Cache.userId
            ..products = {}
            ..vouchers = [])
          .then((_) {
        Navigator.pop(context);
      });
    });
  }

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
        height: 132,
        child: Padding(
          padding: const EdgeInsets.all(defPading),
          child: Column(children: [
            SizedBox(
              height: 40,
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                      child: BlocBuilder<VoucherCubit, Map<String, Voucher>>(
                    builder: (_, state) {
                      if (state.values.isNotEmpty) {
                        return Text(
                          "Code: ${state.values.first.name}",
                          textAlign: TextAlign.center,
                        );
                      }
                      return const Text("Please add code");
                    },
                  )),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const VoucherPage(),
                            ));
                      },
                      child: const Text("Add Voucher"),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: BlocBuilder<VoucherCubit, Map<String, Voucher>>(
                          builder: (_, vstate) {
                        return BlocBuilder<CartCubit,
                            Map<String, (Product, int)>>(
                          builder: (_, state) {
                            _discount = 0;
                            _sum = 0;
                            _discountProduct = 0.0;

                            for (var element in state.values) {
                              _discountProduct +=
                                  getActuallyCost(element.$1) * element.$2;
                              _sum += (element.$1.price ?? 0) * element.$2;
                            }

                            if (context
                                .read<VoucherCubit>()
                                .currentState()
                                .values
                                .isNotEmpty) {
                              final voucher = context
                                  .read<VoucherCubit>()
                                  .currentState()
                                  .values
                                  .first;
                              if (voucher.percent != null &&
                                  voucher.percent! > 0) {
                                _discount =
                                    _discountProduct * (voucher.percent! / 100);
                                if (voucher.maxValue != null &&
                                    voucher.maxValue! > 0.0) {
                                  _discount =
                                      _discount.clamp(0, voucher.maxValue!);
                                }
                              } else {
                                _discount = (voucher.maxValue ?? 0)
                                    .clamp(0, _discountProduct);
                              }
                            }
                            debugPrint("$_discount $_discountProduct $_sum");
                            if (_discount != 0.0 || _discountProduct != _sum) {
                              return RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: formatCurrency(_sum),
                                      style: TextStyle(
                                        color: Theme.of(context).disabledColor,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          "\n${formatCurrency(_sum - _discount - (_sum - _discountProduct))}",
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Text(formatCurrency(_sum));
                          },
                        );
                      }),
                    ),
                  ),
                  Expanded(
                      child: FilledButton(
                    onPressed: context.read<CartCubit>().state.isEmpty
                        ? null
                        : () => _showInputAdressPhoneNumber(context),
                    child: const Text("Buy all!"),
                  ))
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressTEC.dispose();
    _phoneNumberTEC.dispose();
    _nodePhoneNumber.dispose();
    super.dispose();
  }
}
