import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:janvaani/controllers/issue_controller.dart';
import 'package:flutter/services.dart';

class FlagIssueWidget extends StatelessWidget {
  final String issueId;
  final IssueController issueController = Get.find<IssueController>();
  final TextEditingController _reasonController = TextEditingController();

  FlagIssueWidget({Key? key, required this.issueId}) : super(key: key);

  // Helper method to show an enhanced Snackbar
  void _showFeedbackSnackbar(
      String title, String message, Color backgroundColor, IconData icon) {
    HapticFeedback.mediumImpact();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
      barBlur: 5,
    );
  }

  // --- Reason Dialog (Only for Red Flag) ---
  void _showReasonDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'flagRed'.tr, // e.g., "Flag as Inappropriate"
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          content: TextField(
            controller: _reasonController,
            autofocus: true,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'enterFlagReasonHint'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red.shade400, width: 2),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _reasonController.clear();
                Get.back();
              },
              child: Text('cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                if (_reasonController.text.trim().isNotEmpty) {
                  issueController.flagIssue(
                    issueId,
                    'red',
                    reason: _reasonController.text.trim(),
                  );
                  // 1. Show Success Snackbar
                  _showFeedbackSnackbar(
                    'Report Submitted'.tr,
                    'issueFlaggedForReview'.tr,
                    Colors.orange.shade700,
                    Icons.report_problem,
                  );
                  _reasonController.clear();
                  Get.back();
                } else {
                  // 2. Show Error Snackbar for empty reason
                  _showFeedbackSnackbar(
                    'Error'.tr,
                    'provideReasonError'.tr,
                    Colors.red.shade600,
                    Icons.warning_rounded,
                  );
                }
              },
              child: Text('submit'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Combined Choice/Primary Dialog ---
  void _showChoiceDialog(BuildContext context) {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Define colors based on theme
        final Color primaryColor = Theme.of(context).primaryColor;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'flagIssueTitle'.tr, // e.g., "Report this Issue"
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'flagIssueDescription'.tr, // e.g., "Select the type of feedback you want to provide:"
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[50]
                      : Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    // *** ACTION 1: RED FLAG (Inappropriate/Irrelevant) ***
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back(); // Close this choice dialog
                          _showReasonDialog(context); // Immediately open reason dialog
                        },
                        // ICON CHANGE: Using a red flag icon
                        icon: Icon(Icons.flag_rounded, size: 20, color: Colors.white),
                        label: const Text(
                          'Red Flag', // Hardcoded as requested
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 15),

                    // *** ACTION 2: GREEN FLAG (Relevant/Accurate) ***
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          issueController.flagIssue(issueId, 'green');
                          Get.back(); // Close this choice dialog
                          _showFeedbackSnackbar(
                            'Confirmation'.tr,
                            'issueMarkedRelevant'.tr,
                            Colors.green.shade700,
                            Icons.verified_user,
                          );
                        },
                        // ICON CHANGE: Using a check circle icon for positive flag
                        icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
                        label: Text(
                          'Green Flag', // Hardcoded as requested
                          style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: Colors.green.shade400, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'cancel'.tr,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Improved Button (`build` method) ---
  @override
  Widget build(BuildContext context) {
    return Container(
      // Use a subtle colored container to make it look like a clear action item
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            width: 0.5),
      ),
      child: InkWell(
        // Directs the tap to the single, combined choice dialog
        onTap: () => _showChoiceDialog(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.flag_rounded, // Using a distinct flag icon
                size: 18,
                color: Colors.orange.shade700, // Attention-grabbing color
              ),
              const SizedBox(width: 6),
              Text(
                'flagIssue'.tr,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}