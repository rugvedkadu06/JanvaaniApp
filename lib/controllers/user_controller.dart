// lib/controllers/user_controller.dart
import 'package:get/get.dart';
import '../models/user_profile.dart';

class UserController extends GetxController {
  var user = UserProfile(name: 'Guest', email: '', phone: '', uniqueId: '').obs;
  void loadUserFromJson(Map<String, dynamic> userData) => user.value = UserProfile.fromJson(userData);
  void clearUser() => user.value = UserProfile(name: 'Guest', email: '', phone: '', uniqueId: '');
}


