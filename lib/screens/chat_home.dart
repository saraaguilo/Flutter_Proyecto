import 'package:applogin/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:applogin/config.dart';
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
    final response = await http.get(Uri.parse('$uri/events'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        eventNames =
            data.map((event) => event['eventName'].toString()).toList();
      });
    } else {
      print('Error al cargar los eventos: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Home'),
        backgroundColor: Color(0xFFFF7B00), // Color naranja personalizado
      ),
      body: ListView.builder(
        itemCount: eventNames.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(0), // Margen ajustado a cero
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(0), // Margen interno ajustado a cero
              title: Align(
                alignment: Alignment.centerLeft, // Alinear al centro izquierda
                child: Text(
                  eventNames[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Color(0xFF191919), // Color de texto personalizado
                  ),
                ),
              ),
              
              onTap: () {
                navigateToChatScreen(context, eventNames[index]);
              },
            ),
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
