import 'package:applogin/controller/chat_controller.dart';
import 'package:applogin/model/message.dart';
import 'package:applogin/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:applogin/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final String chatName;

  const ChatScreen({required this.chatName, Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Color black = Color(0xFF191919);
  Color orange = Color(0xFFFF7B00);
  TextEditingController msgInputController = TextEditingController();
  late IO.Socket socket;
  ChatController chatController = ChatController();
  late String miUsuario; // Variable para almacenar el nombre de usuario
  late String username;
  late String miUsuario2;

  @override
  void initState() {
    super.initState();
    setUpSocket();
  }

  Future<void> setUpSocket() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      miUsuario = prefs.getString('userName') ?? "Usuario Desconocido";
      print('Nombre de usuario almacenado: $miUsuario');

      // Envía el nombre de usuario al servidor cuando se establece la conexión
      var usernameData = {
        "username": miUsuario,
      };
      socket.emit('username', usernameData);
    } catch (error) {
      print(
          'Error al obtener el nombre de usuario desde SharedPreferences: $error');
    }

    socket = IO.io(
      '$uri',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();
    socket.emit('join-room', widget.chatName);

    setUpSocketListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Chat Room: ${widget.chatName}",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            leaveRoom();
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Connected Users: ${chatController.connectedUser}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: Obx(
                () => ListView.builder(
                  itemCount: chatController.chatMessages.length,
                  itemBuilder: (context, index) {
                    var currentItem = chatController.chatMessages[index];
                    return MessageItem(
                      sentByMe: currentItem.sentByMe == socket.id,
                      message: currentItem.message,
                      sentByUserName: miUsuario,
                      username: miUsuario,
                    );
                  },
                ),
              ),
            ),
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
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {
                          sendMessage(msgInputController.text);
                          msgInputController.text = "";
                        },
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

  void sendMessage(String text) {
    // Mantén el nombre de usuario actualizado al enviar un mensaje
    var messageJson = {
      "message": text,
      "sentByMe": socket.id,
      "room": widget.chatName,
      "username": miUsuario,
    };
    // Envía el mensaje al servidor
    socket.emit('message', messageJson);
    var username = messageJson['username'];
    print('El valor de username es: $username');
  }

  void setUpSocketListener() {
    socket.on('message-receive', (msg) {
      chatController.chatMessages.add(Message.fromJson(msg));
    });

    socket.on('connected-user', (count) {
      chatController.updateConnectedUser(count, socket.id!);
    });

    socket.on('user-left', (count) {
      chatController.updateConnectedUser(count, socket.id!);
    });

    socket.on('username-receive', (data) {
      var receivedUsername = data['username'];
      print('Nombre de usuario recibido: $receivedUsername');
    });
  }

  void leaveRoom() {
    socket.emit('leave-room', widget.chatName);
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({
    Key? key,
    required this.sentByMe,
    required this.message,
    required this.sentByUserName,
    required this.username,
  }) : super(key: key);

  final bool sentByMe;
  final String message;
  final String sentByUserName;
  final String username;

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'sentByMe': sentByMe,
      'username': username,
      'sentByUserName': sentByUserName,
    };
  }

  @override
  Widget build(BuildContext context) {
    Color orange = Color(0xFFFF7B00);
    Color white = Colors.white;

    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: sentByMe ? orange : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              sentByMe ? "Me: $message" : "$username: $message",
              style: TextStyle(
                color: sentByMe ? white : orange,
                fontSize: 18,
              ),
            ),
            SizedBox(width: 20),
            Text(
              "${DateFormat('h:mm a').format(DateTime.now())}",
              style: TextStyle(
                color: (sentByMe ? white : orange).withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}