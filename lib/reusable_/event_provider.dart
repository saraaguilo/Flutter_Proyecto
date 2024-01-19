import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:applogin/models/event.dart';
import 'package:applogin/config.dart';

class EventProvider extends ChangeNotifier {
  List<Event> _events = [];
  bool _isLoading = false;
  bool _initialized = false;
  List<Event> _suggestions = [];

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  Future<bool> get initialized async => _initialized;
  List<Event> get suggestions => _suggestions;

  Future<void> getEvents() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(Uri.parse('$uri/events'));

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        if (data is List) {
          _events = data.map((item) => Event.fromJson(item)).toList();
          _initialized = true;
          _suggestions =
              _events; // Inicializar sugerencias con todos los eventos
          notifyListeners();
          if (kDebugMode) {
            print('Número de eventos cargados: ${_events.length}');
          }
        } else {
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Event?> searchEventByName(String eventName) async {
    try {
      print('buscas este evento${eventName}');
      final response = await http.get(Uri.parse('$uri/events'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final List<Event> matchingEvents = data
            .map((item) => Event.fromJson(item))
            .where((event) =>
                event.eventName.toLowerCase() == eventName.toLowerCase())
            .toList();
        print('${matchingEvents}');
        if (matchingEvents.isNotEmpty) {
          return matchingEvents.first;
        } else {
          if (kDebugMode) {
            print('${matchingEvents}');
            print('No se encontraron eventos con el eventName especificado.');
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          print(
              'Error al cargar eventos. Código de estado: ${response.statusCode}');
        }
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error de red al cargar eventos: $error');
      }
      return null;
    }
  }

  void onQueryChanged(String query) {
    // Filtrar eventos según la consulta
    _suggestions = _events
        .where((event) =>
            event.eventName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void clear() {
    // Limpiar sugerencias y mostrar todos los eventos
    _suggestions = _events;
    notifyListeners();
  }
}
