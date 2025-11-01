// lib/screens/onboarding/registration_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../api/api_service.dart';
// Note: flutter_local_notifications and main.dart imports removed as they are no longer needed for a Toast/Snackbar.

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  // --- Professional Color Palette ---
  static final Color primaryBlue = Colors.blue.shade800;
  static final Color secondaryGrey = Colors.blueGrey.shade600;
  static final Color lightGrey = Colors.grey.shade100;

  // --- Trusted/Standard Dialogue for Account Existence ---
  void _showExistingAccountDialog() {
    HapticFeedback.lightImpact();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'loginPromptTitle'.tr,
          style: TextStyle(
              color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Text(
          "If you already have an account, please proceed to the login screen to access your services and issue history.",
          style: TextStyle(color: secondaryGrey, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr, style: TextStyle(color: secondaryGrey)),
          ),
          TextButton(
            // Action: Navigate to Login Screen
            onPressed: () {
              Get.back(); // Close dialog
              Get.offNamed('/login'); // Assuming '/login' is the route
            },
            child: Text(
              'goToLogin'.tr.toUpperCase(),
              style: TextStyle(
                  color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // --- API Call and Response Handling Function (UPDATED for Snackbar) ---
  Future<void> handleRegistration(
      TextEditingController nameCtrl,
      TextEditingController emailCtrl,
      TextEditingController phoneCtrl,
      GlobalKey<FormState> formKey,
      ApiService apiService,
      RxBool isLoading) async {

    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    const String staticOtp = "124590"; // Define the static OTP value

    try {
      final result = await apiService.sendOtp(
        nameCtrl.text,
        emailCtrl.text,
        phoneCtrl.text,
      );

      // Function to show the success Snackbar/Toast
      void showOtpSuccessToast(String otp) {
        Get.snackbar(
          'OTP Sent',
          'Your OTP is: $otp. Please enter to verify',
          backgroundColor: primaryBlue, // Use primary color for success
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP, // Toast-like position
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        );
      }

      if (result is bool && result == true) {
        // Case 1: API call succeeded (email might have been sent)
        showOtpSuccessToast(staticOtp);
        Get.toNamed('/otp', arguments: emailCtrl.text);

      } else if (result is String) {
        final errorMessage = result as String;

        if (errorMessage.contains("User with this email already exists.")) {
          // Specific error: User exists -> show login dialog
          _showExistingAccountDialog();
        } else if (errorMessage.contains("use static OTP") || errorMessage.contains("successfully registered")) {
          // Case 2: API failed to send email but user registered/can use static OTP
          showOtpSuccessToast(staticOtp);
          Get.toNamed('/otp', arguments: emailCtrl.text);
        } else {
          // Generic unrecoverable errors
          Get.snackbar(
            'Registration Error',
            errorMessage,
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        // Case 3: API call failed and returned 'false' or another unexpected value
        Get.snackbar(
          'Registration Error',
          'Failed to send OTP. Please try again.',
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Handle unhandled exceptions (e.g., network error, server down)
      Get.snackbar(
        'Network Error',
        'Could not reach the server. Please check your connection.',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    // Controllers and Keys
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final apiService = Get.find<ApiService>();
    var isLoading = false.obs;

    return Scaffold(
      backgroundColor: lightGrey, // Light, professional background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Trustworthy Header (Logo & Mission) ---
                Image.asset(
                  'assets/logo.png',
                  height: 80,
                  color: primaryBlue,
                ),
                const SizedBox(height: 16),
                Text(
                  'Report Resolve Improve'.tr.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: secondaryGrey,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 40),

                // --- Form Container (Elevated Card) ---
                Form(
                  key: formKey,
                  child: Container(
                    padding: const EdgeInsets.all(30.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.1),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Citizen Account'.tr,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Verify Identity For Reporting'.tr,
                          style: TextStyle(color: secondaryGrey, fontSize: 15),
                        ),
                        const SizedBox(height: 30),

                        // --- Text Fields ---
                        _ProfessionalTextField(
                            controller: nameCtrl,
                            label: 'fullName'.tr,
                            icon: Icons.person_outline,
                            validator: (v) => v!.isEmpty ? 'fullNameRequired'.tr : null),
                        const SizedBox(height: 20),
                        _ProfessionalTextField(
                            controller: emailCtrl,
                            label: 'emailAddress'.tr,
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => !GetUtils.isEmail(v!)
                                ? 'validEmailRequired'.tr
                                : null),
                        const SizedBox(height: 20),
                        _ProfessionalTextField(
                            controller: phoneCtrl,
                            label: 'phoneNumber'.tr,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (v) => v!.isEmpty ? 'phoneNumberRequired'.tr : null),
                        const SizedBox(height: 40),

                        // --- Primary Action Button (Trusted) ---
                        Obx(() => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isLoading.value
                                ? null
                                : () => handleRegistration(
                                nameCtrl, emailCtrl, phoneCtrl, formKey, apiService, isLoading),

                            icon: isLoading.value
                                ? const SizedBox.shrink()
                                : const Icon(Icons.send_rounded, size: 20),
                            label: isLoading.value
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                                : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Text('Send OTP'.tr.toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8)),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 5,
                            ),
                          ),
                        )),
                        const SizedBox(height: 20),

                        // --- Secondary Action (Login Prompt) ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already Have Account'.tr, style: TextStyle(color: secondaryGrey)),
                            TextButton(
                              onPressed: _showExistingAccountDialog,
                              child: Text(
                                'Login'.tr,
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Custom Text Field Widget for a Professional Look ---
class _ProfessionalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _ProfessionalTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  // Use the same primary color for focus styling
  static final Color primaryBlue = RegistrationScreen.primaryBlue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: primaryBlue.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        // The border is the key: subtle grey line, strong blue focus
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue, width: 2.5), // Strong focus indicator
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
        ),
        errorStyle: TextStyle(color: Colors.red.shade700, fontSize: 13),
      ),
    );
  }
}