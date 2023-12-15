import 'dart:html';
import 'package:applogin/screens/home_screen.dart';
import 'package:applogin/screens/events.dart';
import 'package:applogin/screens/home_screen.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:applogin/models/user.dart';
import 'package:applogin/config.dart';
import 'dart:convert';
import 'package:applogin/screens/mapa.dart';

/*
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case '/signup':
        // Validation of correct data type
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => SignUpScreen(),
          );
        }
        // If args is not of the correct type, return an error page.
        // You can also throw an exception while in development.
        return _errorRoute();
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
*/
