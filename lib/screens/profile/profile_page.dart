import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/issue_controller.dart';
import '../../controllers/reward_controller.dart';
import '../../api/api_service.dart';
import '../../models/issue.dart';
import '../../widgets/info_chip.dart';
import '../../widgets/stat_card.dart';

// --- MAIN WIDGET ---
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Find Controllers
    final userCtrl = Get.find<UserController>();
    final issueCtrl = Get.find<IssueController>();
    final rewardCtrl = Get.find<RewardController>();
    final apiService = Get.find<ApiService>();

    // Determine the safe area height for the title
    final topPadding = MediaQuery.of(context).padding.top + 16.0;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.0, topPadding, 16.0, 16.0),
        child: Column(
          children: [
            // NEW: Page Title (since AppBar is gone)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'profile'.tr,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Profile Header
            _ProfileHeader(userCtrl: userCtrl, issueCtrl: issueCtrl, rewardCtrl: rewardCtrl),
            const SizedBox(height: 32),
            // User Statistics Section
            _StatsSection(issueCtrl: issueCtrl, rewardCtrl: rewardCtrl),
            const SizedBox(height: 40),
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: Text('logout'.tr),
                onPressed: () => apiService.logout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Slightly larger radius
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PROFILE HEADER WIDGET ---
class _ProfileHeader extends StatelessWidget {
  final UserController userCtrl;
  final IssueController issueCtrl;
  final RewardController rewardCtrl;
  const _ProfileHeader({required this.userCtrl, required this.issueCtrl, required this.rewardCtrl});

  // Determine user level based on points
  Map<String, dynamic> _getUserLevel(int points) {
    if (points >= 5000) {
      return {'tag': 'Elite Contributor'.tr, 'color': Colors.purple.shade700};
    } else if (points >= 3000) {
      return {'tag': 'Gold Member'.tr, 'color': Colors.amber.shade700};
    } else if (points >= 1500) {
      return {'tag': 'Silver Member'.tr, 'color': Colors.grey.shade600};
    } else if (points >= 500) {
      return {'tag': 'Bronze Member'.tr, 'color': Colors.orange.shade600};
    } else {
      return {'tag': 'New Member'.tr, 'color': Colors.blue.shade600};
    }
  }

  Widget _buildUserTag(String tag, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildAvatarContent(String name, String? imageUrl) {
    // If no image is available, a simple primary initial is often cleaner than a logo.
    String initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.indigo,
        backgroundImage: NetworkImage(imageUrl),
      );
    } else {
      // Fallback to a large initial
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.blue.shade700,
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = userCtrl.user.value;
      final points = rewardCtrl.totalPoints.value;
      final userLevel = _getUserLevel(points);
      final formatter = NumberFormat.compact();

      return Card(
        elevation: 0, // Use a flat card with border for a modern look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Avatar
              _buildAvatarContent(user.name, user.faceImageUrl),

              const SizedBox(height: 16),

              // Name (Primary Focus)
              Text(
                user.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              // Level Tag and Points (Secondary Focus Row)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildUserTag(userLevel['tag']!, userLevel['color']!),
                  const SizedBox(width: 8),
                  InfoChip( // Use InfoChip to highlight points
                    icon: Icons.star_rate_rounded,
                    text: '${formatter.format(points)} Pts',
                    backgroundColor: Colors.yellow.shade100,
                    textColor: Colors.amber.shade800,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 24),

              // Contact Details (Cleaner vertical list)
              InfoChip(
                icon: Icons.email_outlined,
                text: user.email,
                backgroundColor: Colors.transparent, // Transparent background
                textColor: Colors.blueGrey.shade700,
              ),
              const SizedBox(height: 8),
              InfoChip(
                icon: Icons.phone_outlined,
                text: user.phone.isNotEmpty ? user.phone : 'noPhone'.tr,
                backgroundColor: Colors.transparent,
                textColor: Colors.blueGrey.shade700,
              ),
            ],
          ),
        ),
      );
    });
  }
}

// --- STATS SECTION WIDGET ---
class _StatsSection extends StatelessWidget {
  final IssueController issueCtrl;
  final RewardController rewardCtrl;
  const _StatsSection({required this.issueCtrl, required this.rewardCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            'yourStats'.tr,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ),
        Obx(() {
          final issues = issueCtrl.issues;
          // The total points card is now in the header, removing it from the grid for better focus.
          final created = issues.length;
          final resolved = issues.where((i) => i.status == IssueStatus.resolved).length;
          final inProgress = issues.where((i) => i.status == IssueStatus.inProgress).length;
          final approved = issues.where((i) => i.status == IssueStatus.approved).length;

          // Use NumberFormat for cleaner stats presentation
          String formatValue(int value) => NumberFormat.compact().format(value);

          return GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.15, // Slightly shorter cards for more items on screen
            children: [
              StatCard(label: 'issuesCreated'.tr, value: formatValue(created), color: Colors.blue),
              StatCard(label: 'issuesResolved'.tr, value: formatValue(resolved), color: Colors.green),
              StatCard(label: 'issuesApproved'.tr, value: formatValue(approved), color: Colors.indigo),
              StatCard(label: 'inProgress'.tr, value: formatValue(inProgress), color: Colors.orange),
            ],
          );
        }),
      ],
    );
  }
}