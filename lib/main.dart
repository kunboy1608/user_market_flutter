import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/auth/login.dart';
import 'package:user_market/bloc/cart_cubit.dart';
import 'package:user_market/bloc/order_cubit.dart';
import 'package:user_market/bloc/product_cubit.dart';
import 'package:user_market/bloc/voucher_cubit.dart';

void main() {
  runApp(MultiBlocProvider(providers: [
    BlocProvider(
      create: (context) => ProductCubit({}),
    ),
    BlocProvider(
      create: (context) => CartCubit({}),
    ),
    BlocProvider(
      create: (context) => OrderCubit({}),
    ),
    BlocProvider(
      create: (context) => VoucherCubit({}),
    ),
  ], child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.light,
              seedColor: const Color.fromARGB(255, 6, 183, 215)),
          useMaterial3: true),
      darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color.fromARGB(255, 203, 118, 120)),
          useMaterial3: true),
      home: const Login(),
    );
  }
}
