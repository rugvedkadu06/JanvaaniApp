// lib/screens/issues/issue_detail_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/issue.dart';
import '../../controllers/issue_controller.dart';
import '../../widgets/info_chip.dart';
import '../../widgets/status_tracker.dart';
import '../../widgets/google_map_widget.dart';
import '../../api/ai_analysis_service.dart';
import '../../widgets/flag_issue_widget.dart'; // Keeping the original import

// Theme Placeholders for visual consistency with CourseInfoScreen
class IssueAppTheme {
  static const Color nearlyWhite = Color(0xFFFAFAFA);
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color nearlyBlue = Color(0xFF00B6F0);
  static const Color darkerText = Color(0xFF17262A);
  static const Color grey = Color(0xFF3A5160);
}

class IssueDetailPage extends StatelessWidget {
  final Issue issue;
  const IssueDetailPage({super.key, required this.issue});

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4.0,
                child: issue.imageUrl != null && issue.imageUrl!.isNotEmpty
                    ? Image.network(issue.imageUrl!, fit: BoxFit.contain)
                    : issue.imagePath != null && issue.imagePath!.isNotEmpty
                    ? Image.file(File(issue.imagePath!), fit: BoxFit.contain)
                    : Image.network(issue.placeholderImageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullMap(BuildContext context) {
    if (issue.coordinates == null) return;

    // Use a simple MaterialPageRoute push for the full map view
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('issueLocation'.tr + ': ' + issue.title),
          ),
          body: GoogleMapWidget(
            latitude: issue.coordinates!['latitude']!,
            longitude: issue.coordinates!['longitude']!,
            title: issue.title,
            description: issue.location,
            height: double.infinity,
            isInteractive: true,
          ),
        ),
      ),
    );
  }

  // --- EXISTING METHOD: Build Rejected Status UI ---
  Widget _buildRejectedStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel, color: Colors.red, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'issueRejected'.tr, // A translated string like "This issue has been rejected by the administrator."
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- NEW METHOD: Build Flag Counts UI ---
  Widget _buildFlagCounts(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Red Flags
        Row(
          children: [
            const Icon(Icons.flag, color: Colors.red, size: 16),
            const SizedBox(width: 4),
            Text(issue.redFlags.toString(), style: const TextStyle(color: Colors.red)),
            const SizedBox(width: 16),
          ],
        ),
        // Green Flags
        Row(
          children: [
            const Icon(Icons.flag, color: Colors.green, size: 16),
            const SizedBox(width: 4),
            Text(issue.greenFlags.toString(), style: const TextStyle(color: Colors.green)),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final issueCtrl = Get.find<IssueController>();
    final currentStatusIndex = IssueStatus.values.indexOf(issue.status);

    // Design parameters from CourseInfoScreen
    final double imageAspectRatio = 1.2;
    final double imageAreaHeight = MediaQuery.of(context).size.width / imageAspectRatio;
    final double roundedOffset = 24.0; // The height of the rounded corner cut-in

    return Container(
      color: IssueAppTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            // 1. Issue Image Area (Top part of the screen)
            Column(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: imageAspectRatio,
                  child: GestureDetector(
                    onTap: () => _showFullImage(context),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        issue.imageUrl != null && issue.imageUrl!.isNotEmpty
                            ? Image.network(issue.imageUrl!, fit: BoxFit.cover)
                            : issue.imagePath != null && issue.imagePath!.isNotEmpty
                            ? Image.file(File(issue.imagePath!), fit: BoxFit.cover)
                            : Image.network(issue.placeholderImageUrl, fit: BoxFit.cover),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.zoom_in, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 2. Rounded Detail Card (Content Area)
            Positioned(
              top: imageAreaHeight - roundedOffset,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: IssueAppTheme.nearlyWhite,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32.0),
                      topRight: Radius.circular(32.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: IssueAppTheme.grey.withOpacity(0.2),
                        offset: const Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 32), // Top padding for the floating button

                          // Title
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
                            child: Text(
                              issue.title,
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: IssueAppTheme.darkerText,
                              ),
                            ),
                          ),

                          // Submitter, Date, Location, and Flag Counts
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InfoChip(icon: Icons.person_outline, text: 'Submitted by: ${issue.submittedBy}'),
                                    InfoChip(icon: Icons.calendar_today_outlined, text: DateFormat.yMMMMd().format(issue.createdAt)),
                                    InfoChip(icon: Icons.location_on_outlined, text: issue.location),
                                  ],
                                ),
                              ),
                              _buildFlagCounts(context), // Flag counts positioned to the right
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Description
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              issue.description,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                                fontWeight: FontWeight.w200,
                                color: IssueAppTheme.grey,
                              ),
                            ),
                          ),

                          // AI Analysis Section
                          if (issue.aiAnalysis != null /*&& issue.aiAnalysis!.detections.isNotEmpty*/) ...[
                            const SizedBox(height: 24),
                            _buildAiAnalysisSection(context),
                          ],

                          // Map Section
                          if (issue.coordinates != null) ...[
                            const SizedBox(height: 24),
                            Text(
                                'Location on Map',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _showFullMap(context),
                              child: GoogleMapWidget(
                                latitude: issue.coordinates!['latitude']!,
                                longitude: issue.coordinates!['longitude']!,
                                title: issue.title,
                                description: issue.location,
                                height: 200,
                                isInteractive: false,
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),
                          // Status Tracker
                          Text(
                              'statusTracker'.tr,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 16),

                          // CONDITIONAL UI FOR REJECTED STATUS
                          if (issue.status == IssueStatus.rejected)
                            _buildRejectedStatus(context)
                          else
                            StatusTracker(currentIndex: currentStatusIndex),

                          // Padding for the bottom safety area and the floating button
                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 100,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Floating Action Button (Flag Issue Widget - positioned like the heart icon)
            Positioned(
              top: imageAreaHeight - roundedOffset - 35,
              right: 35,
              child: FlagIssueWidget(issueId: issue.id),
            ),

            // 4. Redeem Points Button (Positioned at the very bottom, like the 'Join Course' button)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 16, // Lifted up from the very bottom
                  top: 16,
                ),
                child: issue.status == IssueStatus.resolved
                    ? Obx(() {
                  final latestIssue = issueCtrl.issues.firstWhere((i) => i.id == issue.id, orElse: () => issue);
                  return Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: latestIssue.pointsRedeemed ? IssueAppTheme.grey : IssueAppTheme.nearlyBlue, // Using nearlyBlue as primary color
                      borderRadius: const BorderRadius.all(
                        Radius.circular(16.0),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: (latestIssue.pointsRedeemed ? IssueAppTheme.grey : IssueAppTheme.nearlyBlue)
                                .withOpacity(0.5),
                            offset: const Offset(1.1, 1.1),
                            blurRadius: 10.0),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                        onTap: latestIssue.pointsRedeemed ? null : () => issueCtrl.redeemPointsForIssue(issue),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star, color: IssueAppTheme.nearlyWhite, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                latestIssue.pointsRedeemed ? 'pointsRedeemed'.tr : 'redeemPoints'.tr,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  letterSpacing: 0.0,
                                  color: IssueAppTheme.nearlyWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                })
                    : const SizedBox.shrink(), // Hide button if not resolved
              ),
            ),

            // 5. Custom Back Button (Replaces the standard AppBar)
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: SizedBox(
                width: AppBar().preferredSize.height,
                height: AppBar().preferredSize.height,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius:
                    BorderRadius.circular(AppBar().preferredSize.height),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: IssueAppTheme.nearlyWhite, // White icon for visibility over the image
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NOTE: Helper methods for AI analysis remain unchanged
  // Assuming AiAnalysisResult and Detection classes are properly imported and defined.

  Widget _buildAiAnalysisSection(BuildContext context) {
    final analysis = issue.aiAnalysis!;

    return Card(
      elevation: 0.0, // Reduced elevation for a flatter look
      color: IssueAppTheme.nearlyWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: IssueAppTheme.nearlyBlue),
                const SizedBox(width: 8),
                Text(
                  'AI Analysis Results',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: IssueAppTheme.darkerText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnalysisSummary(context, analysis),
            const SizedBox(height: 16),
            if (analysis.detections != null && analysis.detections.isNotEmpty)
              ...analysis.detections.map((detection) => _buildDetectionCard(context, detection)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSummary(BuildContext context, dynamic analysis) {
    final severity = analysis.highestSeverity;
    final priority = analysis.highestPriority;

    Color severityColor;
    IconData severityIcon;

    switch (severity) {
      case 'High':
        severityColor = Colors.red;
        severityIcon = Icons.warning;
        break;
      case 'Medium':
        severityColor = Colors.orange;
        severityIcon = Icons.info;
        break;
      case 'Low':
        severityColor = Colors.green;
        severityIcon = Icons.check_circle;
        break;
      default:
        severityColor = IssueAppTheme.grey;
        severityIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: severityColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(severityIcon, color: severityColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summary: ${analysis.summary}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Severity: $severity | Priority: $priority',
                  style: TextStyle(
                    color: IssueAppTheme.grey.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionCard(BuildContext context, dynamic detection) {
    Color severityColor;
    IconData severityIcon;

    switch (detection.severity) {
      case 'High':
        severityColor = Colors.red;
        severityIcon = Icons.warning;
        break;
      case 'Medium':
        severityColor = Colors.orange;
        severityIcon = Icons.info;
        break;
      case 'Low':
        severityColor = Colors.green;
        severityIcon = Icons.check_circle;
        break;
      default:
        severityColor = IssueAppTheme.grey;
        severityIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(severityIcon, color: severityColor, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detection.className,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Confidence: ${(detection.confidence * 100).toStringAsFixed(1)}% | Severity: ${detection.severity} | Priority: ${detection.priority}',
                  style: TextStyle(
                    color: IssueAppTheme.grey.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}