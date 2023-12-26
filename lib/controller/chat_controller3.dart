import 'package:applogin/model/message.dart';
import 'package:get/get.dart';

class ChatController3 extends GetxController{
  var chatMessages = <Message>[].obs;
  var connectedUser = 0.obs;
}