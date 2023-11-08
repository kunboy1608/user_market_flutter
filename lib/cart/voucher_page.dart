import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/voucher_cubit.dart';
import 'package:user_market/cart/voucher_card.dart';
import 'package:user_market/entity/voucher.dart';
import 'package:user_market/service/entity/voucher_service.dart';
import 'package:user_market/util/const.dart';

class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  final _codeTEC = TextEditingController();

  Widget _appliedVoucherWidget(BuildContext context) {
    if (context.read<VoucherCubit>().state.isNotEmpty) {
      return VoucherCard(
        voucher: context.read<VoucherCubit>().state.values.first,
        isSelected: true,
      );
    }
    return Text(
      "No apllied voucher",
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  void _check() {
    if (_codeTEC.text.isNotEmpty) {
      VoucherService.instance.getById(_codeTEC.text).then((voucher) {
        if (voucher != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Success"),
            ),
          );
          setState(() {
            context.read<VoucherCubit>().replaceState({});
            context.read<VoucherCubit>().addOrUpdateIfExist(voucher);
          });
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Wrong code, or used, expried"),
            ),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter code"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoucherCubit, Map<String, Voucher>>(
        builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Add vouchers"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(defPading),
            child: Column(children: [
              TextField(
                controller: _codeTEC,
                onEditingComplete: _check,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(defRadius))),
                    hintText: "Enter you private code",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: _check,
                    )),
              ),
              Container(
                  padding: const EdgeInsets.all(defPading),
                  color: Theme.of(context).colorScheme.background,
                  child: Row(
                    children: [
                      const Spacer(),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: defPading),
                        decoration: BoxDecoration(
                            color: Theme.of(context).highlightColor,
                            borderRadius: BorderRadius.circular(defRadius)),
                        child: Text(
                          "Applied voucher",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const Spacer()
                    ],
                  )),
              _appliedVoucherWidget(context),
              Container(
                  padding: const EdgeInsets.all(defPading),
                  color: Theme.of(context).colorScheme.background,
                  child: Row(
                    children: [
                      const Spacer(),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: defPading),
                        decoration: BoxDecoration(
                            color: Theme.of(context).highlightColor,
                            borderRadius: BorderRadius.circular(defRadius)),
                        child: Text("Voucher today",
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      const Spacer()
                    ],
                  )),
              FutureBuilder(
                future: VoucherService.instance.get(),
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (_, index) =>
                            VoucherCard(voucher: snapshot.data![index]),
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: defPading),
                        itemCount: snapshot.data!.length);
                  }
                  return Container();
                },
              ),
            ]),
          ),
        ),
      );
    });
  }
}
