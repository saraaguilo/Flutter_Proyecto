import 'package:applogin/app_navigation.dart';
import 'package:applogin/routes.dart';

import 'package:applogin/screens/home_screen.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //return MaterialApp.router(
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: RoutesClass.getSignin(),
      getPages: [
        ...RoutesClass.routes,
        ...RoutesClass.eventsPages
      ],
      //unknownRoute: RoutesClass.unknownRoute,
      //routerConfig: AppNavigation.router,
      debugShowCheckedModeBanner: false, // Remove the debug banner

      //eliminar el home si usamos las rutas
      //home: const SignInScreen(),
    );
  }
}
