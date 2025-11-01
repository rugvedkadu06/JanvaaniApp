// lib/controllers/localization_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LocalizationController extends GetxController {
  void changeLocale(String langCode, String countryCode) {
    Get.updateLocale(Locale(langCode, countryCode));
  }
}


