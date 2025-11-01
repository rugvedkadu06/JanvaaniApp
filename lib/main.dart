// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'utils/app_translations.dart';
import 'api/api_service.dart';
import 'api/ai_analysis_service.dart';
import 'controllers/localization_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/issue_controller.dart';
import 'controllers/reward_controller.dart';
import 'controllers/navigation_controller.dart';
import 'screens/onboarding/registration_screen.dart';
import 'screens/onboarding/otp_verification_screen.dart';
import 'screens/onboarding/face_verification_screen.dart';
import 'main_layout.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Error initializing cameras: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(ApiService()); Get.put(AiAnalysisService()); Get.put(LocalizationController()); Get.put(UserController()); Get.put(IssueController()); Get.put(RewardController()); Get.put(NavigationController());
    return GetMaterialApp(
      title: 'Janvaani',
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF007BFF),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'SF Pro Text',
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0, centerTitle: true, titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
        cardTheme: CardThemeData(color: Colors.white, elevation: 0, shadowColor: Colors.black.withOpacity(0.02), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007BFF), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24), textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
        chipTheme: ChipThemeData(backgroundColor: Colors.grey.shade100, selectedColor: const Color(0xFF007BFF), labelStyle: const TextStyle(color: Colors.black87), secondaryLabelStyle: const TextStyle(color: Colors.white), padding: const EdgeInsets.symmetric(horizontal: 12)),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const RegistrationScreen()),
        GetPage(name: '/otp', page: () => const OtpVerificationScreen()),
        GetPage(name: '/verify-face', page: () => FaceVerificationScreen(cameras: cameras)),
        GetPage(name: '/home', page: () => MainLayout()),
      ],
    );
  }
}


