// lib/api/ai_analysis_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../utils/global_constants.dart';

class AiAnalysisService extends GetxService {

  /// Sends image to AI model for analysis and returns detection results
  Future<AiAnalysisResult?> analyzeImage(XFile imageFile) async {
    try {
      // Uses the AI_MODEL_BASE_URL/analyze endpoint as defined in global_constants.dart
      var request = http.MultipartRequest('POST', Uri.parse('$AI_MODEL_BASE_URL/analyze'));
      // The field name 'image' must match what your Python server expects
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        final jsonData = jsonDecode(responseData);

        return AiAnalysisResult.fromJson(jsonData);
      } else {
        print('AI Analysis failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during AI analysis: $e');
      return null;
    }
  }
}

class Detection {
  final String className;
  final double confidence;
  final List<int> bbox; // [x1, y1, x2, y2]
  final String severity;
  final String priority;

  Detection({
    required this.className,
    required this.confidence,
    required this.bbox,
    required this.severity,
    required this.priority,
  });

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      className: json['class'],
      confidence: json['confidence'].toDouble(),
      bbox: List<int>.from(json['bbox']),
      severity: json['severity'],
      priority: json['priority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class': className,
      'confidence': confidence,
      'bbox': bbox,
      'severity': severity,
      'priority': priority,
    };
  }
}

class AiAnalysisResult {
  final String id;
  final String annotatedImageUrl;
  final List<Detection> detections;
  final DateTime createdAt;

  AiAnalysisResult({
    required this.id,
    required this.annotatedImageUrl,
    required this.detections,
    required this.createdAt,
  });

  factory AiAnalysisResult.fromJson(Map<String, dynamic> json) {
    // Assuming 'createdAt' is millisecondsSinceEpoch from AI service
    // If it's an ISO 8601 string, change to: DateTime.parse(json['createdAt'])
    int timestamp = json['createdAt'] is int ? json['createdAt'] : int.tryParse(json['createdAt'].toString()) ?? DateTime.now().millisecondsSinceEpoch;

    return AiAnalysisResult(
      id: json['_id'],
      annotatedImageUrl: json['annotatedImageUrl'],
      detections: (json['detections'] as List)
          .map((detection) => Detection.fromJson(detection))
          .toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'annotatedImageUrl': annotatedImageUrl,
      // NOTE: MongoDB uses standard datetime objects, but for client-side transfer
      // millisecondsSinceEpoch is safer for JSON serialization.
      'detections': detections.map((d) => d.toJson()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  String get highestSeverity {
    if (detections.isEmpty) return 'Unknown';
    final severities = detections.map((d) => d.severity).toList();
    if (severities.contains('High')) return 'High';
    if (severities.contains('Medium')) return 'Medium';
    if (severities.contains('Low')) return 'Low';
    return 'Unknown';
  }

  String get highestPriority {
    if (detections.isEmpty) return 'Low';
    final priorities = detections.map((d) => d.priority).toList();
    if (priorities.contains('Urgent')) return 'Urgent';
    if (priorities.contains('Normal')) return 'Normal';
    if (priorities.contains('Low')) return 'Low';
    return 'Low';
  }

  String get summary {
    if (detections.isEmpty) return 'No issues detected';
    final classCounts = <String, int>{};
    for (final detection in detections) {
      classCounts[detection.className] = (classCounts[detection.className] ?? 0) + 1;
    }
    final summaryParts = <String>[];
    classCounts.forEach((className, count) {
      summaryParts.add('$count ${className.toLowerCase()}');
    });
    return summaryParts.join(', ');
  }
}