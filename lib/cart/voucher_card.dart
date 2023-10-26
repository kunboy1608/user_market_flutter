import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/voucher_cubit.dart';
import 'package:user_market/entity/voucher.dart';
import 'package:flutter/material.dart';

class VoucherCard extends StatelessWidget {
  const VoucherCard({super.key, required this.voucher});
  final Voucher voucher;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<VoucherCubit>().replaceState({});
        context.read<VoucherCubit>().addOrUpdateIfExist(voucher);
        Navigator.pop(context);
      },
      child: Card(
        child: Column(
          children: [
            Text("Code: ${voucher.code}"),
            Text("Max: ${voucher.maxValue}"),
            Text("Percent: ${voucher.percent}"),
            Text("Start: ${voucher.startDate ?? "null"}"),
            Text("End: ${voucher.endDate ?? "null"}"),
          ],
        ),
      ),
    );
  }
}
