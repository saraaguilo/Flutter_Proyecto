import 'dart:convert';
import 'package:applogin/config.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';


Future<List<Message>> getMessagesByUser(String idUser) async {
  try {
    final response = await http.get(Uri.parse('$uri/messages/user/$idUser'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Message.fromJson(item)).toList();
    } else {
      print('Error al cargar mensajes. Código de estado: ${response.statusCode}');
      
      return [];
    }
  } catch (error) {
    print('Error de red al cargar eventos: $error');
    
    return [];
  }
}