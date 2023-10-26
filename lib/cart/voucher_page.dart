import 'package:flutter/material.dart';
import 'package:user_market/cart/voucher_card.dart';
import 'package:user_market/service/entity/voucher_service.dart';
import 'package:user_market/util/const.dart';

class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("add vouchers"),
      ),
      body: FutureBuilder(
        future: VoucherService.instance.get(),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
                itemBuilder: (_, index) =>
                    VoucherCard(voucher: snapshot.data![index]),
                separatorBuilder: (_, index) =>
                    const SizedBox(height: defPading),
                itemCount: snapshot.data!.length);
          }
          return Container();
        },
      ),
    );
  }
}
