import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_market/auth/login.dart';
import 'package:user_market/bloc/cart_cubit.dart';
import 'package:user_market/bloc/order_cubit.dart';
import 'package:user_market/bloc/product_cubit.dart';
import 'package:user_market/bloc/voucher_cubit.dart';
import 'package:user_market/home/home.dart';
import 'package:user_market/service/entity/user_service.dart';
import 'package:user_market/service/google/firebase_service.dart';
import 'package:user_market/util/cache.dart';
import 'package:user_market/util/spm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final username = await SPM.get(SPK.username);
  final password = await SPM.get(SPK.password);

  bool isAutoLoginSuccess = false;

  if (username != null && password != null) {
    final userCredential =
        await FirebaseService.instance.signInWithEmail(username, password);
    if (userCredential != null) {
      Cache.userCredential = userCredential;
      isAutoLoginSuccess = true;
      Cache.userId = userCredential.user?.uid ?? "";
      final u = await UserService.instance.get();
      if (u != null && u.isNotEmpty) {
        Cache.user = u.first;
      }
    }
  }

  runApp(MultiBlocProvider(
      providers: [
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
      ],
      child: MainApp(
        child: isAutoLoginSuccess ? const Home() : const Login(),
      )));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      theme: ThemeData(
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.light,
              seedColor: const Color.fromARGB(255, 119, 139, 162)),
          useMaterial3: true),
      darkTheme: ThemeData(
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color.fromARGB(255, 119, 139, 162)),
          useMaterial3: true),
      home: child,
    );
  }
}
