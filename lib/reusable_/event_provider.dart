import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:applogin/models/event.dart';
import 'package:applogin/config.dart';

class EventProvider extends ChangeNotifier {
  List<Event> _events = [];
  bool _initialized = false;

  List<Event> get events => _events;
  Future<bool> get initialized async => _initialized;

  // Función para cargar eventos
  Future<void> getEvents() async {
    try {
      final response = await http.get(Uri.parse('$uri/events'));

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        // Verificar si la respuesta es un JSON válido
        if (data is List) {
          _events = data.map((item) => Event.fromJson(item)).toList();
          _initialized = true;
          notifyListeners();
          if (kDebugMode) {
            print('Número de eventos cargados: ${_events.length}');
          }
        } else {
          // Manejar el caso donde la respuesta no es un JSON válido
          if (kDebugMode) {
            print('Error: La respuesta del servidor no es un JSON válido.');
          }
        }
      } else {
        if (kDebugMode) {
          print(
              'Error al cargar eventos. Código de estado: ${response.statusCode}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error de red al cargar eventos: $error');
      }
    }
  }
}
