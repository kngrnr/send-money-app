import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_money_app/src/core/di/locator.dart';
import 'package:send_money_app/src/core/routing/app_router.dart';
import 'package:send_money_app/src/presentation/cubit/auth/auth_cubit.dart';

void main() {
  // Setup dependency injection with injectable
  configureDependencies();

  runApp(const SendMoneyApp());
}

class SendMoneyApp extends StatelessWidget {
  const SendMoneyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<AuthCubit>(),
      child: MaterialApp.router(
        title: 'Send Money App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(116, 236, 166, 1)),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}