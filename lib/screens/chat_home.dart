import 'package:applogin/screens/chat_screen.dart';
import 'package:applogin/screens/chat_screen2.dart';
import 'package:applogin/screens/chat_screen3.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPrincipalScreen extends StatefulWidget {
  @override
  _ChatPrincipalScreenState createState() => _ChatPrincipalScreenState();
}

class _ChatPrincipalScreenState extends State<ChatPrincipalScreen> {
  List<String> eventNames = [];

  @override
  void initState() {
    super.initState();
    fetchEventNames();
  }

  Future<void> fetchEventNames() async {
    final response = await http.get(Uri.parse('http://localhost:9090/events'));

    if (response.statusCode == 200) {
      // Decodificar la respuesta JSON
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        // Extraer los nombres de los eventos
        eventNames = data.map((event) => event['eventName'].toString()).toList();
      });
    } else {
      // Si la solicitud falla, maneja el error según sea necesario
      print('Error al cargar los eventos: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Principal'),
      ),
      body: ListView.builder(
        itemCount: eventNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(eventNames[index]),
            onTap: () {
              // Al hacer clic en un evento, navega a la pantalla de chat correspondiente
              navigateToChatScreen(context, eventNames[index]);
            },
          );
        },
      ),
    );
  }

  void navigateToChatScreen(BuildContext context, String eventName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatName: eventName),
      ),
    );
  }
}