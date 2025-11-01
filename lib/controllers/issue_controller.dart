// lib/controllers/issue_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/issue.dart';
import 'navigation_controller.dart';
import 'reward_controller.dart';
import 'user_controller.dart';
import '../main_layout.dart';
import '../utils/global_constants.dart';
import '../api/api_service.dart';
import '../api/ai_analysis_service.dart';

class IssueController extends GetxController {
  var issues = <Issue>[].obs;
  var isLoading = true.obs;
  var selectedStatus = 'all'.obs;
  var showActiveIssues = false.obs;
  var isAnalyzingImage = false.obs; // Used for both analysis (creation) and submission (preview)
  var searchQuery = ''.obs;

  final AiAnalysisService _aiService = Get.find<AiAnalysisService>();
  final ApiService _apiService = Get.find<ApiService>();
  final UserController _userController = Get.find<UserController>();

  List<Issue> get filteredIssues {
    List<Issue> results = issues.toList();

    if (selectedStatus.value != 'all') {
      results = results
          .where((issue) => issue.status.name == selectedStatus.value)
          .toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      results = results
          .where((issue) =>
      issue.title.toLowerCase().contains(q) ||
          issue.description.toLowerCase().contains(q) ||
          issue.location.toLowerCase().contains(q))
          .toList();
    }

    return results;
  }

  @override
  void onInit() {
    super.onInit();
    loadIssues();
  }

  Future<void> loadIssues() async {
    isLoading.value = true;
    try {
      final token = await _apiService.getToken();
      if (token == null) {
        issues.clear();
        isLoading.value = false;
        return;
      }

      final filter = showActiveIssues.value ? 'active' : 'all';
      final response = await http.get(
        Uri.parse('$API_BASE_URL/issues?filter=$filter'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        issues.value = data.map((json) => Issue.fromJson(json)).toList();
      } else {
        issues.clear();
      }
    } catch (e) {
      issues.clear();
    }
    isLoading.value = false;
  }

  // ✅ CORRECTED: Public method to perform AI analysis. Resets flag in finally block.
  Future<AiAnalysisResult?> analyzeImageForIssue(XFile imageFile) async {
    if (imageFile == null) return null;
    isAnalyzingImage.value = true; // Set to TRUE before model call
    AiAnalysisResult? aiAnalysis;
    try {
      aiAnalysis = await _aiService.analyzeImage(imageFile);
      if (aiAnalysis != null) {
        print('AI Analysis completed: ${aiAnalysis.summary}');
      }
    } catch (e) {
      print('Error during AI analysis: $e');
      Get.snackbar('Analysis Failed', 'Could not complete AI analysis of the image.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange.shade100);
    } finally {
      // ⚠️ CRITICAL FIX: Reset the flag regardless of success or failure.
      isAnalyzingImage.value = false;
    }
    return aiAnalysis;
  }

  // ✅ MODIFIED: Accepts AiAnalysisResult
  Future<void> submitIssueToAPI({
    required String title,
    required String description,
    required String location,
    required String submittedBy,
    XFile? imageFile,
    double? latitude,
    double? longitude,
    AiAnalysisResult? aiAnalysis, // ✅ NEW: Pre-analyzed result
  }) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) {
        Get.snackbar('Error', 'Please login to submit issues');
        return;
      }

      // Step 1: Set analyzing flag to prevent double tap while submitting (now it means 'submitting')
      isAnalyzingImage.value = true;

      // Step 2: Submit to API
      var request = http.MultipartRequest('POST', Uri.parse('$API_BASE_URL/issues'));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['location'] = location;
      request.fields['submittedBy'] = submittedBy;

      if (latitude != null && longitude != null) {
        request.fields['latitude'] = latitude.toString();
        request.fields['longitude'] = longitude.toString();
      }

      if (aiAnalysis != null) {
        // ✅ PASSING AI ANALYSIS RESULT AS JSON
        request.fields['aiAnalysis'] = jsonEncode(aiAnalysis.toJson());
        if (aiAnalysis.annotatedImageUrl.isNotEmpty) {
          request.fields['annotatedImageUrl'] = aiAnalysis.annotatedImageUrl;
        }
      }

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('issueImage', imageFile.path));
      }

      final response = await request.send();
      isAnalyzingImage.value = false; // Reset flag after submission attempt

      if (response.statusCode == 201) {
        String successMessage = 'Issue submitted successfully!';
        if (aiAnalysis != null && aiAnalysis.detections.isNotEmpty) {
          successMessage += '\nAI detected: ${aiAnalysis.summary}';
        }
        Get.snackbar('Success', successMessage);
        await loadIssues();
        Get.find<NavigationController>().setIndex(0);
        Get.offAll(() => MainLayout());
      } else {
        Get.snackbar('Error', 'Failed to submit issue');
      }
    } catch (e) {
      isAnalyzingImage.value = false; // Reset flag on error
      Get.snackbar('Error', 'Network error: ${e.toString()}');
    }
  }

  // ... (rest of IssueController methods for filtering, flagging, redeeming) ...
  void filterByStatus(String status) {
    selectedStatus.value = status;
  }

  void toggleActiveIssues() {
    showActiveIssues.value = !showActiveIssues.value;
    loadIssues();
  }

  void searchIssues(String query) {
    searchQuery.value = query;
  }

  Future<void> flagIssue(String issueId, String flagType, {String? reason}) async {
    final user = _userController.user.value;
    if (user == null) {
      Get.snackbar('Error', 'Please login to flag issues');
      return;
    }

    final issue = issues.firstWhere((issue) => issue.id == issueId);
    if (issue.submittedBy == user.uniqueId) {
      Get.snackbar('ownIssueError'.tr, '', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      final token = await _apiService.getToken();
      final body = {
        'userId': user.uniqueId,
        'flagType': flagType,
      };

      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

      final response = await http.post(
        Uri.parse('$API_BASE_URL/issues/$issueId/flag'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Get.snackbar('flagSuccess'.tr, '', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
        loadIssues();
      } else {
        final responseBody = jsonDecode(response.body);
        if (responseBody['message'] == 'You have already flagged this issue') {
          Get.snackbar('alreadyFlaggedError'.tr, '', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
        } else {
          Get.snackbar('flagFailed'.tr, '', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Network error: ${e.toString()}');
    }
  }

  void redeemPointsForIssue(Issue issue) {
    final issueIndex = issues.indexWhere((i) => i.id == issue.id);
    if (issueIndex != -1 && !issues[issueIndex].pointsRedeemed) {
      issues[issueIndex].pointsRedeemed = true;
      Get.find<RewardController>().addTransaction('Redeemed for ${issue.id}', 50);
      saveIssues();
      issues.refresh();
      Get.snackbar('redeemSuccess'.tr, '',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } else {
      Get.snackbar('pointsRedeemed'.tr, '',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
    }
  }

  Future<void> saveIssues() async {
    final prefs = await SharedPreferences.getInstance();
    final issuesJson = issues.map((i) => jsonEncode(i.toJson())).toList();
    await prefs.setStringList('issues', issuesJson);
  }
}