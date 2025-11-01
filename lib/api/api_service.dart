// lib/api/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/user_controller.dart';
import '../controllers/issue_controller.dart';
import '../utils/global_constants.dart';

class ApiService extends GetxService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async => await _storage.write(key: 'jwt_token', value: token);
  Future<String?> getToken() async => await _storage.read(key: 'jwt_token');
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    Get.find<UserController>().clearUser();
    Get.find<IssueController>().issues.clear();
    Get.offAllNamed('/');
  }

  Future<bool> sendOtp(String name, String email, String phone) async {
    try {
      final res = await http.post(
          Uri.parse('$API_BASE_URL/auth/register-send-otp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': name, 'email': email, 'phone': phone})
      );
      if (res.statusCode == 200) return true;
      Get.snackbar('Error', jsonDecode(res.body)['error'] ?? 'Failed to send OTP.');
      return false;
    } catch (e) {
      Get.snackbar('Network Error', 'Could not connect to the server.');
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final res = await http.post(
          Uri.parse('$API_BASE_URL/auth/verify-otp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'otp': otp})
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        await saveToken(data['token']);
        Get.find<UserController>().loadUserFromJson(data['user']);
        return true;
      }
      Get.snackbar('Error', jsonDecode(res.body)['error'] ?? 'OTP verification failed.');
      return false;
    } catch (e) {
      Get.snackbar('Network Error', 'Could not connect to the server.');
      return false;
    }
  }

  Future<bool> uploadFace(XFile imageFile) async {
    final token = await getToken();
    if (token == null) return false;
    try {
      // 1) Optionally verify face using Flask service
      final verifyReq = http.MultipartRequest('POST', Uri.parse('$FACE_VERIFY_BASE_URL/verify-face'))
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path, contentType: MediaType('image', 'jpeg')));
      final verifyRes = await verifyReq.send();
      if (verifyRes.statusCode != 200) {
        Get.snackbar('Face Check Failed', 'Could not verify the captured face.');
        return false;
      }
      final verifyBytes = await verifyRes.stream.toBytes();
      final verifyJson = jsonDecode(String.fromCharCodes(verifyBytes));
      if ((verifyJson['faces'] ?? 0) < 1) {
        Get.snackbar('No Face Detected', 'Please align your face within the frame.');
        return false;
      }

      // 2) Read, crop to centered square, and re-encode JPEG
      final rawBytes = await File(imageFile.path).readAsBytes();
      final decoded = img.decodeImage(rawBytes);
      if (decoded == null) {
        Get.snackbar('Image Error', 'Could not process captured image.');
        return false;
      }
      final minSide = decoded.width < decoded.height ? decoded.width : decoded.height;
      final left = (decoded.width - minSide) ~/ 2;
      final top = (decoded.height - minSide) ~/ 2;
      final cropped = img.copyCrop(decoded, x: left, y: top, width: minSide, height: minSide);
      final jpegBytes = img.encodeJpg(cropped, quality: 90);

      // 3) Upload cropped image to existing backend (which uploads to Cloudinary)
      var request = http.MultipartRequest('POST', Uri.parse('$API_BASE_URL/user/upload-face'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(http.MultipartFile.fromBytes('faceImage', jpegBytes, filename: 'face.jpg', contentType: MediaType('image', 'jpeg')));

      var res = await request.send();
      if (res.statusCode == 200) {
        var responseData = await res.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        Get.find<UserController>().user.update((val) {
          val?.faceImageUrl = jsonDecode(responseString)['faceImageUrl'];
        });
        return true;
      }
      return false;
    } catch(e) {
      Get.snackbar('Upload Error', 'Failed to upload image.');
      return false;
    }
  }
}


