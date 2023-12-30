import 'package:applogin/model/message.dart';
import 'package:applogin/models/user.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  var chatMessages = <Message>[].obs;
  var connectedUser = 0.obs;
  var chatUsernames = <User>[].obs;

  void updateConnectedUser(int count, String myId) {
    // Resta 1 para excluir al usuario actual (tú mismo)
    connectedUser.value = count - 1;
  }
}