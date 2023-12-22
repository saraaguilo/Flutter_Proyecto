import 'dart:convert';
import 'package:applogin/reusable_/reusable_widget.dart';
import 'package:applogin/screens/home_screen.dart';
import 'package:applogin/screens/profile_edit.dart';
import 'package:applogin/screens/signin_screen.dart';
import 'package:applogin/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:applogin/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:applogin/config.dart';
import 'package:http/http.dart' as http;

Future<void> deleteUser(idUser, token) async {
  try {
    final response = await http.delete(
      Uri.parse('$uri/users/$idUser'),
      headers: {'x-access-token': token},
    );

    if (response.statusCode == 200) {
      print('Usuario eliminado. Código de estado: ${response.statusCode}');
    } else {
      print(
          'Error al cargar eventos. Código de estado: ${response.statusCode}');
    }
  } catch (error) {
    print('Error de red al cargar eventos: $error');
  }
}
