import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart'; // Import for clipboard functionality
import '../../controllers/user_controller.dart';
import 'reward_list_page.dart';
// Note: You may need to import your Reward model used in userCtrl.redeemedRewards
// import '../../models/redeemed_reward.dart';
import 'package:intl/intl.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  // Helper to mask a part of the reward code for security
  String _maskCode(String code) {
    if (code.length < 5) return code;
    return '${code.substring(0, 3)}...${code.substring(code.length - 3)}';
  }

  // Helper to copy the code to clipboard and show a snackbar
  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    Get.snackbar(
      'Copied!',
      'Redemption code copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userCtrl = Get.find<UserController>();
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rewards & Offers'),
          // Using theme colors instead of hardcoded teal for consistency
          // backgroundColor: Colors.teal,
          bottom: TabBar(
            // --- Styled TabBar for consistency with RedeemRewardsPage ---
            indicatorSize: TabBarIndicatorSize.label,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: theme.primaryColor.withOpacity(0.1),
              border: Border.all(color: theme.primaryColor, width: 1),
            ),
            labelPadding: const EdgeInsets.symmetric(horizontal: 10),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey.shade600,
            // -----------------------------------------------------------
            tabs: const [
              Tab(text: 'Redeem Rewards'),
              Tab(text: 'My Rewards'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Redeem Rewards
            const RewardListPage(),

            // Tab 2: My Rewards (Redeemed Rewards)
            Obx(() => userCtrl.redeemedRewards.isNotEmpty
                ? ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: userCtrl.redeemedRewards.length,
              itemBuilder: (context, index) {
                final reward = userCtrl.redeemedRewards[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    elevation: 3, // Added slight elevation
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),

                      // Leading: Visual cue of the reward status
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.qr_code_2_sharp, color: Colors.green, size: 28),
                      ),

                      // Title: The name of the reward
                      title: Text(
                        reward.title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      // Subtitle: Code and Date
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Code: ${_maskCode(reward.code)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Redeemed on: ${DateFormat.yMMMd().format(reward.redeemedAt)}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),

                      // Trailing: Copy button
                      trailing: IconButton(
                        icon: const Icon(Icons.copy_outlined),
                        color: theme.primaryColor,
                        tooltip: 'Copy Code',
                        onPressed: () => _copyCode(reward.code),
                      ),
                    ),
                  ),
                );
              },
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No rewards redeemed yet',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey.shade600)),
                  Text('Start earning points to redeem exciting rewards!',
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}