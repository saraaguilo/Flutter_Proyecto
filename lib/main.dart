import 'package:applogin/screens/signin_screen.dart';
import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:flutter/material.dart';
import 'package:applogin/screens/profile.dart';
import 'package:applogin/theme/dark_theme.dart';
import 'package:applogin/theme/light_theme.dart';
import 'package:get/get.dart';
import 'package:applogin/models/language.dart';
import 'package:applogin/models/language_constants.dart';
import 'package:applogin/controller/profile_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:applogin/theme/darkModeProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart' as provider;
import 'package:applogin/reusable_/event_provider.dart';



void main() async {
  // Inicializa ProfileController utilizando Get.put
  Get.put(ProfileController());
  WidgetsFlutterBinding.ensureInitialized();

// Inicializar geocodificación
  //await initGeocoding();
  // Espera a que Firebase.initializeApp() se complete
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyAtHrrHPxwhPKQsaMadeXwf2Vz-rxiKXUQ",
        authDomain: "fir-c14b5.firebaseapp.com",
        projectId: "fir-c14b5",
        storageBucket: "fir-c14b5.appspot.com",
        messagingSenderId: "627441200007",
        appId: "1:627441200007:web:af58934c506c4a02dd4122"),
  );

runApp(
    provider.ChangeNotifierProvider(
      create: (context) => EventProvider(),
      child: const MyApp(),
    ),
  );
}
 

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}
class _MyAppState extends State<MyApp> {
  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) => {setLocale(locale)});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
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
      //darkTheme: ThemeData.dark().copyWith(
          // Personaliza los atributos del tema oscuro según sea necesario
      //    ),

      home: const SignInScreen(),

      //home: const ProfileScreen(), //CAMBIAR

      debugShowCheckedModeBanner: false,
    );
  }
}
