import 'dart:convert';
import 'package:applogin/config.dart';
import 'package:http/http.dart' as http;
import '../models/event.dart';


Future<List<Event>> getEventsByUser(String idUser) async {
  try {
    final response = await http.get(Uri.parse('$uri/events/user/$idUser'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Event.fromJson(item)).toList();
    } else {
      print('Error al cargar eventos. Código de estado: ${response.statusCode}');
      // Puedes lanzar una excepción aquí si lo consideras apropiado
      return [];
    }
  } catch (error) {
    print('Error de red al cargar eventos: $error');
    // Puedes lanzar una excepción aquí si lo consideras apropiado
    return [];
  }
}