import 'package:applogin/theme/dark_theme.dart';
import 'package:applogin/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:applogin/controller/profile_controller.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:applogin/theme/darkModeProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


void main() async {
  // Inicializa ProfileController utilizando Get.put
  Get.put(ProfileController());
  WidgetsFlutterBinding.ensureInitialized();

  // Espera a que Firebase.initializeApp() se complete
  await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "AIzaSyAtHrrHPxwhPKQsaMadeXwf2Vz-rxiKXUQ",
    authDomain: "fir-c14b5.firebaseapp.com",
    projectId: "fir-c14b5",
    storageBucket: "fir-c14b5.appspot.com",
    messagingSenderId: "627441200007",
    appId: "1:627441200007:web:af58934c506c4a02dd4122"
  ),
);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Flutter Demo',

      /*
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      */
    
      theme: ThemeData(
        // Tema claro por defecto
        brightness: Brightness.light,
        // Aquí puedes personalizar otros atributos del tema claro si es necesario
      ),
      darkTheme: ThemeData.dark().copyWith(
        // Personaliza los atributos del tema oscuro según sea necesario
      ),
      
      home: const SignInScreen(),
      
      debugShowCheckedModeBanner: false,
    );
  }
}