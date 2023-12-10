import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Color purple = Color(0xFF6C5CE7);
  Color black = Color(0xFF191919);
  Color orange = Color(0xFFFF7B00);
  Color darkorange = Color.fromARGB(255, 153, 64, 1);
  TextEditingController msgInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: Container(
        child: Column(
          children: [
            Expanded(flex: 9, child: Container()),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                color: black,
                child: TextField(
                  cursorColor: Colors.white,
                  controller: msgInputController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: EdgeInsets.only(left: 15, right: 5),
                    suffixIcon: Container(
                      padding: EdgeInsets.only(left: 2, right: 2), // Ajusta el espacio del ícono aquí
                      decoration: BoxDecoration(
                        color: orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}