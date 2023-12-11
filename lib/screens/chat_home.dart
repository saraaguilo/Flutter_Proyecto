import 'package:applogin/screens/chat_screen.dart';
import 'package:applogin/screens/chat_screen2.dart';
import 'package:applogin/screens/chat_screen3.dart';
import 'package:flutter/material.dart';

class ChatPrincipalScreen extends StatelessWidget {
  final List<String> conciertos = ['Concierto Pop', 'Concierto Pop 2', 'Concierto Pop 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Principal'),
      ),
      body: ListView.builder(
        itemCount: conciertos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(conciertos[index]),
            onTap: () {
              // Al hacer clic en un concierto, navega a la pantalla de chat correspondiente
              navigateToChatScreen(context, conciertos[index]);
            },
          );
        },
      ),
    );
  }

  void navigateToChatScreen(BuildContext context, String chatName) {
  if (chatName == 'Concierto Pop') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatName: chatName),
      ),
    );
  } else if (chatName == 'Concierto Pop 2') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen2(chatName: chatName),
      ),
    );
  } else if (chatName == 'Concierto Pop 3') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen3(chatName: chatName),
      ),
    );
  }
}
}

