import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/bloc/voucher_cubit.dart';
import 'package:user_market/entity/voucher.dart';

class VoucherCard extends StatelessWidget {
  const VoucherCard(
      {super.key, required this.voucher, this.isSelected = false});
  final Voucher voucher;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<VoucherCubit>().replaceState({});
        context.read<VoucherCubit>().addOrUpdateIfExist(voucher);
        Navigator.pop(context);
      },
      child: Card(
        child: ListTile(
          leading: const Icon(CupertinoIcons.ticket, size: 60),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Code: ${voucher.name}"),
              Text("Max: ${voucher.maxValue}"),
              Text("Percent: ${voucher.percent}"),
              Text("Start: ${voucher.startDate?.toDate().toString() ?? "Now"}"),
              Text(
                  "End: ${voucher.endDate?.toDate().toString() ?? "Unilimted"}"),
            ],
          ),
          trailing: isSelected
              ? IconButton(
                  onPressed: () {
                    context.read<VoucherCubit>().remove(voucher);
                  },
                  icon: const Icon(Icons.clear_rounded))
              : null,
        ),
      ),
    );
  }
}
