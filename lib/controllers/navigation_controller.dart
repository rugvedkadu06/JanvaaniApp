// lib/controllers/navigation_controller.dart
import 'package:get/get.dart';

class NavigationController extends GetxController {
  var selectedIndex = 0.obs;
  void setIndex(int index) => selectedIndex.value = index;
}


