import 'dart:convert';
import 'package:applogin/models/event.dart';
import 'package:applogin/config.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BuscadorScreenController {
  List<Event> events = [];


  Future<void> getEvents() async {
    try {
      final response = await http.get(Uri.parse('$uri/events'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        events = data.map((item) => Event.fromJson(item)).toList();
      } else {
        print(
            'Error al cargar eventos. Código de estado: ${response.statusCode}');
      }
    } catch (error) {
      print('Error de red al cargar eventos: $error');
    }
  }
}

