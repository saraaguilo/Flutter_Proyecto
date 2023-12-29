import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:applogin/controller/profile_controller.dart';
import 'package:applogin/screens/signin_screen.dart';

void main() {
  // Inicializa ProfileController utilizando Get.put
  Get.put(ProfileController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SignInScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
