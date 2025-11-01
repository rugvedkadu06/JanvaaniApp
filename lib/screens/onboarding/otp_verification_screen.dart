// lib/screens/onboarding/otp_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// **FIX 2: Import Timer class**
import 'dart:async';
import '../../api/api_service.dart';

// --- Professional Color Palette (from Registration Screen) ---
// Define primaryBlue using the full MaterialColor to allow access to shades
final Color primaryBlue = Colors.blue.shade800;
final Color secondaryGrey = Colors.blueGrey.shade600;
final Color lightGrey = Colors.grey.shade100;
const int otpLength = 6;


// -------------------------------------------------------------------
// NEW: Segmented OTP Input Field Widget
// -------------------------------------------------------------------
class _SegmentedOtpInput extends StatelessWidget {
  final RxString otpText;
  final FocusNode focusNode;
  const _SegmentedOtpInput({required this.otpText, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    // Determine the base MaterialColor to safely access shades
    final MaterialColor blueMaterial = Colors.blue;

    // Hidden TextFormField to handle actual input (keyboard, paste)
    return Stack(
      children: [
        // 1. Invisible TextFormField for input logic
        TextFormField(
          autofocus: true,
          focusNode: focusNode,
          onChanged: (value) {
            // Only update if value is digits and length <= 6
            if (value.length <= otpLength) {
              otpText.value = value;
            }
            if (value.length == otpLength) {
              focusNode.unfocus(); // Auto-unfocus when complete
            }
          },
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.transparent, fontSize: 1), // Hide text
          cursorColor: Colors.transparent,
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          maxLength: otpLength,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),

        // 2. Visible Segments (Obx rebuilds this when otpText changes)
        Obx(() {
          List<Widget> otpBoxes = List.generate(otpLength, (index) {
            bool isFocused = otpText.value.length == index;
            String char = index < otpText.value.length ? otpText.value[index] : '';

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 45,
              height: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFocused ? primaryBlue : Colors.grey.shade300,
                  width: isFocused ? 2.5 : 1.5,
                ),
                boxShadow: isFocused
                    ? [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 1,
                  )
                ]
                    : null,
              ),
              child: Text(
                char,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  // **FIX 1: Use the MaterialColor for shade900 or directly use primaryBlue**
                  // Since primaryBlue is already blue.shade800, let's use a slightly darker version
                  color: blueMaterial.shade900,
                ),
              ),
            );
          });

          return GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(focusNode), // Focus on tap
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: otpBoxes,
            ),
          );
        }),
      ],
    );
  }
}
// -------------------------------------------------------------------

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  // State variables moved to State class for proper lifecycle management
  final apiService = Get.find<ApiService>();
  late final String email;
  final isLoading = false.obs;
  final otpText = ''.obs;
  final focusNode = FocusNode();
  final resendSeconds = 30.obs;

  // **FIX 2: Declare Timer correctly in State class**
  Timer? resendTimer;

  @override
  void initState() {
    super.initState();
    // Safely retrieve arguments
    email = Get.arguments as String;
    startResendTimer();
  }

  // **FIX 3: Dispose of Timer when widget is removed**
  @override
  void dispose() {
    resendTimer?.cancel();
    focusNode.dispose();
    super.dispose();
  }

  // Timer setup logic
  void startResendTimer() {
    resendSeconds.value = 30; // Reset timer
    // **FIX 2: Call Timer correctly**
    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value == 0) {
        timer.cancel();
        resendTimer = null; // Mark as null when done
      } else {
        resendSeconds.value--;
      }
    });
  }

  // --- Verification Logic ---
  void verifyOtpCode() async {
    final otp = otpText.value;
    if (otp.length != otpLength) {
      Get.snackbar(
        'error'.tr,
        'otpMustBe6Digits'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade600,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    HapticFeedback.lightImpact(); // Haptic feedback on verification attempt
    bool success = await apiService.verifyOtp(email, otp);
    isLoading.value = false;

    if (success) {
      Get.offAllNamed('/verify-face');
    } else {
      Get.snackbar(
        'verificationFailed'.tr,
        'invalidOtpPleaseTryAgain'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  // --- Resend Logic ---
  void resendOtpCode() async {
    if (resendSeconds.value > 0) return; // Prevent resend if timer is active

    Get.snackbar('Sending...', 'Resending OTP to $email', snackPosition: SnackPosition.TOP, backgroundColor: Colors.yellow.shade700, colorText: Colors.white);

    // Call API for resend
    // await apiService.resendOtp(email);

    startResendTimer(); // Restart the timer
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: Text('verifyOtp'.tr, style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: primaryBlue),
        elevation: 1,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.security, size: 70, color: primaryBlue),
                const SizedBox(height: 16),

                Text(
                    'secureVerification'.tr,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: primaryBlue)
                ),
                const SizedBox(height: 8),

                // Instruction Text with Email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text.rich(
                    TextSpan(
                      text: '${'otpSentTo'.tr} ',
                      style: TextStyle(fontSize: 14, color: secondaryGrey),
                      children: [
                        TextSpan(
                          text: email,
                          style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue),
                        ),
                        TextSpan(text: '. ${'checkSpamFolder'.tr}'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // OTP Input Field (Segmented)
                _SegmentedOtpInput(otpText: otpText, focusNode: focusNode),
                const SizedBox(height: 40),

                // Verify Button
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading.value || otpText.value.length != otpLength ? null : verifyOtpCode,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 4,
                    ),
                    child: isLoading.value
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                        : Text('verifyAndProceed'.tr.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )),
                const SizedBox(height: 20),

                // Resend OTP Section
                Obx(() {
                  final seconds = resendSeconds.value;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('didntReceiveCode'.tr, style: TextStyle(color: secondaryGrey)),
                      seconds > 0
                          ? Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Resend in $seconds s',
                          style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.bold),
                        ),
                      )
                          : TextButton(
                        onPressed: resendOtpCode,
                        child: Text('resendCode'.tr, style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}