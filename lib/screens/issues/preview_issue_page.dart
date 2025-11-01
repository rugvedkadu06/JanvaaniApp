// lib/screens/issues/preview_issue_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../controllers/issue_controller.dart';
import '../../widgets/info_chip.dart';
import '../../api/ai_analysis_service.dart';

class PreviewIssuePage extends StatelessWidget {
  final String title, description, location, userName;
  final XFile? imageFile;
  final double? latitude;
  final double? longitude;
  // ✅ NEW FIELD: To hold the analysis result from the previous screen
  final AiAnalysisResult? aiAnalysis;

  const PreviewIssuePage({
    super.key,
    required this.title,
    required this.description,
    required this.location,
    this.imageFile,
    required this.userName,
    this.latitude,
    this.longitude,
    // ✅ NEW PARAMETER
    this.aiAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final issueCtrl = Get.find<IssueController>();
    return Scaffold(
      appBar: AppBar(title: Text('previewIssue'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageFile != null) ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(imageFile!.path), height: 200, width: double.infinity, fit: BoxFit.cover)),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // ✅ Display AI summary here
            if (aiAnalysis != null) ...[
              InfoChip(icon: Icons.auto_fix_high, text: 'AI Analysis: ${aiAnalysis!.summary}'),
              InfoChip(icon: Icons.priority_high, text: 'Priority: ${aiAnalysis!.highestPriority}'),
              const SizedBox(height: 8),
            ],
            InfoChip(icon: Icons.person_outline, text: 'Submitted by: $userName'),
            InfoChip(icon: Icons.calendar_today_outlined, text: DateFormat.yMMMMd().format(DateTime.now())),
            InfoChip(icon: Icons.location_on_outlined, text: location),
            const SizedBox(height: 16),
            Text(description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() => ElevatedButton(
              onPressed: issueCtrl.isAnalyzingImage.value ? null : () => issueCtrl.submitIssueToAPI(
                title: title,
                description: description,
                location: location,
                submittedBy: userName,
                imageFile: imageFile,
                latitude: latitude,
                longitude: longitude,
                // ✅ PASS THE AI ANALYSIS RESULT TO THE SUBMISSION METHOD
                aiAnalysis: aiAnalysis,
              ),
              child: issueCtrl.isAnalyzingImage.value
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  // ✅ FIXED TEXT: Now reflects submission, not analysis.
                  Text('Submitting issue...'),
                ],
              )
                  : Text('confirmAndSubmit'.tr)
          ))
      ),
    );
  }
}