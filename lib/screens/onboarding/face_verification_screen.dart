// lib/screens/onboarding/face_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../api/api_service.dart';

class FaceVerificationScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const FaceVerificationScreen({super.key, required this.cameras});
  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen>
    with SingleTickerProviderStateMixin { // <--- Added SingleTickerProviderStateMixin for AnimationController
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final RxBool _isLoading = false.obs; // <--- Changed to RxBool for GetX reactivity
  final RxString _promptText = 'alignFaceInstruction'.tr.obs; // <--- Reactive prompt text

  // Animation for the scanning effect
  AnimationController? _scanAnimationController;
  Animation<double>? _scanAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Duration of one scan cycle
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      _scanAnimationController!,
    );

    if (widget.cameras.isNotEmpty) {
      final frontCamera = widget.cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => widget.cameras.first,
      );
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      _initializeControllerFuture = _controller?.initialize().then((_) {
        // Start the scanning animation loop once camera is initialized
        if (mounted) {
          _scanAnimationController?.repeat(reverse: true); // Loop back and forth
        }
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scanAnimationController?.dispose(); // Dispose animation controller
    super.dispose();
  }

  Future<void> _captureAndUpload() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _controller!.value.isTakingPicture ||
        _isLoading.value) { // Prevent multiple taps
      return;
    }

    try {
      _isLoading.value = true; // Use .value for RxBool
      _scanAnimationController?.stop(); // Stop scanning effect during upload
      _promptText.value = 'scanningAndUploading'.tr; // Update prompt

      final image = await _controller!.takePicture();

      bool success = await Get.find<ApiService>().uploadFace(image);
      if (success) {
        Get.snackbar(
          'success'.tr,
          'faceVerifiedSuccessfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        );
        await Future.delayed(const Duration(milliseconds: 1500)); // Give time for snackbar
        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'error'.tr,
          'faceUploadFailedTryAgain'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
        _isLoading.value = false;
        _promptText.value = 'alignFaceInstruction'.tr; // Reset prompt
        _scanAnimationController?.repeat(reverse: true); // Restart scanning
      }
    } catch (e) {
      debugPrint('Error capturing or uploading image: $e');
      Get.snackbar(
        'error'.tr,
        'anErrorOccurredTryAgain'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      _isLoading.value = false;
      _promptText.value = 'alignFaceInstruction'.tr; // Reset prompt
      _scanAnimationController?.repeat(reverse: true); // Restart scanning
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no cameras are found, show a message and a skip button.
    if (widget.cameras.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('faceVerification'.tr)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("No cameras found on this device."),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.offAllNamed('/home'),
                child: const Text('Skip to Home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(''.tr), // Empty title as per original, text moves to body
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    'faceVerification'.tr,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Text( // <--- Reactive prompt text
                    _promptText.value,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    textAlign: TextAlign.center,
                  )),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: AspectRatio( // Maintain aspect ratio for the camera feed
                  aspectRatio: 1, // Make it square for the circle clipping
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 5.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval( // Use ClipOval to ensure camera preview is always circular
                      child: FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (_controller != null && _controller!.value.isInitialized) {
                              return Stack( // Stack for camera and scanning effect
                                alignment: Alignment.center,
                                children: [
                                  Positioned.fill(child: CameraPreview(_controller!)),
                                  // Scanning Effect Overlay
                                  AnimatedBuilder(
                                    animation: _scanAnimation!,
                                    builder: (context, child) {
                                      return Positioned(
                                        top: (_scanAnimation!.value * 100).clamp(0.0, 100.0), // Adjust range for scan line movement
                                        // Use CustomPaint to draw a simple horizontal line
                                        child: Obx(() => _isLoading.value
                                            ? const SizedBox.shrink() // Hide scanner if loading
                                            : Container(
                                          width: 300, // Match container width
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.lightGreenAccent, // Neon green scanner
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.lightGreenAccent.withOpacity(0.7),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                        ),
                                      );
                                    },
                                  ),
                                  // Loading Overlay (semi-transparent)
                                  Obx(() => _isLoading.value
                                      ? Container(
                                    color: Colors.black54, // Dark overlay
                                    child: const Center(
                                      child: CircularProgressIndicator(color: Colors.white),
                                    ),
                                  )
                                      : const SizedBox.shrink()),
                                ],
                              );
                            } else {
                              return const Center(child: Text('Error initializing camera.'));
                            }
                          }
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Replaced the conditional CircularProgressIndicator with the button's internal loading state
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(() => ElevatedButton( // <--- Reactive button state
                    onPressed: _isLoading.value ? null : _captureAndUpload,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.deepPurple, // More vibrant button color
                      foregroundColor: Colors.white,
                      elevation: 5,
                    ),
                    child: _isLoading.value
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                        : Text('verifyMyFace'.tr, style: const TextStyle(fontSize: 18)),
                  )),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Get.offAllNamed('/home'),
                    child: Text('skipForNow'.tr,
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}