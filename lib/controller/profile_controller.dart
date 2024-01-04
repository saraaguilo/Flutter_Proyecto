import 'package:get/get.dart';

class ProfileController extends GetxController {
  var userName = "".obs;

  static ProfileController get to => Get.find();

  // Método para actualizar el nombre de usuario
  void updateUserName(String newUserName) {
    userName.value = newUserName;
  }
}