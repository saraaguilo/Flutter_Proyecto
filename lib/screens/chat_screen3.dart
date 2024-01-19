import 'package:applogin/controller/chat_controller.dart';
import 'package:applogin/controller/chat_controller3.dart';
import 'package:applogin/model/message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:applogin/config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ChatScreen3 extends StatefulWidget {
  final String chatName;
  const ChatScreen3({required this.chatName, Key? key}) : super(key: key);

  @override
  _ChatScreenState3 createState() => _ChatScreenState3();
}

class _ChatScreenState3 extends State<ChatScreen3> {
  Color purple = Color(0xFF6C5CE7);
  Color black = Color(0xFF191919);
  Color orange = Color(0xFFFF7B00);
  Color darkorange = Color.fromARGB(255, 153, 64, 1);
  TextEditingController msgInputController = TextEditingController();
  late IO.Socket socket;
  ChatController3 chatController3 = ChatController3();
@override
  void initState(){
    socket = IO.io(
        '$uri',
        IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build());
    socket.connect();
    setUpSocketListener3();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: Container(
        child: Column(
          children: [
            Expanded(
            child: Obx( 
          () => Container(padding: EdgeInsets.all(10),child: Text("${AppLocalizations.of(context)!.connectedUser}: ${chatController3.connectedUser}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.0, ),
            ),
            )),
            ),
            Expanded(
              flex: 9,
              child: Obx(
                ()=> ListView.builder(
                  itemCount: chatController3.chatMessages.length,
                  itemBuilder: (context, index) {
                    var currentItem = chatController3.chatMessages[index];
                    return MessageItem(
                      sentByMe: currentItem.sentByMe == socket.id,
                      message: currentItem.message,
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
    var messageJson = {"message": text, "sentByMe": socket.id};
    socket.emit('message', messageJson);
    chatController3.chatMessages.add(Message.fromJson(messageJson));
  }
  
  void setUpSocketListener3() {
    socket.on('message-receive', (msg){
      print(msg);
      chatController3.chatMessages.add(Message.fromJson(msg));
    });
    socket.on('connected-user ', (msg){
      print(msg);
      chatController3.connectedUser.value = msg;
    });
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({Key? key, required this.sentByMe, required this.message}) : super(key: key);
  final bool sentByMe;
  final String message;

  @override
  Widget build(BuildContext context) {
    Color black = Color(0xFF191919);
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
              message,
              style: TextStyle(
                color: sentByMe ? white : orange,
                fontSize: 18,
              ),
            ),
            SizedBox(width: 5),
            Text(
              "1:10 AM",
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