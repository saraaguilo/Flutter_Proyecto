import 'package:applogin/routes.dart';
import 'package:get/get.dart';

class NavBarController extends GetxController {
  var tabIndex = 0;
  void changeTabIndex(int index) {
    tabIndex = index;
    update();
  }
/*
   RxString currentRoute = '/'.obs;

  void goToNamed(String route) {
    //Get.toNamed(route);
    //currentRoute.value = route;

    currentRoute.value = route;
    Get.offNamed(route);
  } */
}
