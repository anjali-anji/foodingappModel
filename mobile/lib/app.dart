import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'constants/app_strings.dart';
import 'constants/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/foods_provider.dart';
import 'providers/orders_provider.dart';
import 'utils/screen_utils.dart';
import 'views/auth/auth_gate.dart';

class FoodingApp extends StatelessWidget {
  const FoodingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..restoreSession()),
        ChangeNotifierProvider(create: (_) => CartProvider()..restore()),
        ChangeNotifierProvider(create: (_) => FoodsProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(
          ScreenUtils.designWidth,
          ScreenUtils.designHeight,
        ),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: child,
          );
        },
        child: const AuthGate(),
      ),
    );
  }
}
