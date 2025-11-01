// lib/screens/issues/create_issue_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/issue_controller.dart';
import '../../api/ai_analysis_service.dart';
import '../../widgets/google_map_widget.dart'; // Ensure this import is correct
import 'preview_issue_page.dart';

class CreateIssuePage extends StatefulWidget {
  const CreateIssuePage({super.key});
  @override
  State<CreateIssuePage> createState() => _CreateIssuePageState();
}

class _CreateIssuePageState extends State<CreateIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();

  XFile? _imageFile;
  String? _locationMessage;
  bool _isFetchingLocation = false;
  double? _latitude;
  double? _longitude;

  final IssueController _issueCtrl = Get.find<IssueController>();

  // --- IMAGE PICK (No Change) ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image =
      await ImagePicker().pickImage(source: source, imageQuality: 70);
      if (image != null) {
        setState(() => _imageFile = image);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e");
    }
    Get.back(); // Dismiss the dialog after picking
  }

  void _showImageSourceDialog() {
    Get.defaultDialog(
      title: 'selectImageSource'.tr,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text('gallery'.tr),
            onTap: () => _pickImage(ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: Text('camera'.tr),
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ],
      ),
    );
  }

  // --- LOCATION (No Change) ---
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
      _locationMessage = 'Fetching location...'.tr;
    });

    try {
      // ... (Location fetching logic remains the same) ...
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);

      _latitude = position.latitude;
      _longitude = position.longitude;

      // Reverse geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(_latitude!, _longitude!);
      String address = placemarks.first.street ?? placemarks.first.name ?? 'Unknown Address';
      String city = placemarks.first.locality ?? '';
      String country = placemarks.first.country ?? '';

      setState(() {
        _locationMessage = '$address, $city, $country';
      });

    } catch (e) {
      setState(() {
        _locationMessage = 'Error: ${e.toString()}'.tr;
      });
      Get.snackbar('Location Error', e.toString());
    } finally {
      setState(() {
        _isFetchingLocation = false;
      });
    }
  }

  // --- PREVIEW (The Corrected Flow) ---
  Future<void> _onPreview() async {
    // 1. Validate form and mandatory fields
    if (!_formKey.currentState!.validate() ||
        _locationMessage == null ||
        _latitude == null ||
        _longitude == null ||
        _isFetchingLocation) {
      Get.snackbar('Error', 'Please complete all fields and successfully fetch location.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
      return;
    }

    // 2. Check for image
    if (_imageFile == null) {
      Get.snackbar('Error', 'A photo is required for issue analysis.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
      return;
    }

    // 3. ⚠️ CRITICAL: Call and AWAIT the AI Analysis
    final AiAnalysisResult? analysisResult =
    await _issueCtrl.analyzeImageForIssue(_imageFile!);

    // 4. Navigate only if analysis was successful
    if (analysisResult != null) {
      Get.to(() => PreviewIssuePage(
        title: _titleCtrl.text,
        description: _descCtrl.text,
        location: '${_landmarkCtrl.text}, $_locationMessage',
        imageFile: _imageFile,
        userName: Get.find<UserController>().user.value?.name ?? 'Anonymous',
        latitude: _latitude,
        longitude: _longitude,
        aiAnalysis: analysisResult, // Pass the required analysis result
      ));
    } else {
      Get.snackbar('Analysis Failed', 'Could not get analysis result. Please check the model status.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100);
    }
  }

  // --- BUILD HELPER METHODS ---
  Widget _buildTextField({required String label, required TextEditingController controller, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'requiredField'.tr;
        }
        return null;
      },
    );
  }

  // ⚠️ MINOR FIX: Correct usage of GoogleMapWidget based on its constructor
  Widget _buildMapPreview() {
    if (_latitude == null || _longitude == null) {
      return Container();
    }
    return Container(
      height: 200, // Provides a container height for the map
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300)
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMapWidget(
        latitude: _latitude!,
        longitude: _longitude!,
        isInteractive: false, // Prevents accidental scrolling while filling the form
        height: 200, // Pass the height to the widget's internal state
      ),
    );
  }

  // --- BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('createIssue'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(label: 'issueTitle'.tr, controller: _titleCtrl),
              const SizedBox(height: 16),
              _buildTextField(
                  label: 'description'.tr,
                  controller: _descCtrl,
                  maxLines: 4),
              const SizedBox(height: 16),
              _buildTextField(
                  label: 'nearbyLandmark'.tr, controller: _landmarkCtrl),
              const SizedBox(height: 20),

              // Location
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading:
                  const Icon(Icons.location_on, color: Color(0xFF007BFF)),
                  title: Text(_locationMessage ?? 'Location not fetched yet.'),
                  trailing: _isFetchingLocation
                      ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: _getCurrentLocation,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildMapPreview(),
              const SizedBox(height: 20),

              // Image
              if (_imageFile != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_imageFile!.path),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover),
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showImageSourceDialog,
                  icon: const Icon(Icons.add_a_photo),
                  label: Text(
                      _imageFile != null ? 'changePhoto'.tr : 'addPhoto'.tr),
                ),
              ),
              const SizedBox(height: 30),

              // Preview/Analyze Button (CRITICAL FIX HERE)
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  // Disable if analysis is running
                  onPressed: _issueCtrl.isAnalyzingImage.value ? null : _onPreview,
                  child: _issueCtrl.isAnalyzingImage.value
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text('Analyzing image...'),
                    ],
                  )
                      : Text('Analyze & Preview'.tr),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}