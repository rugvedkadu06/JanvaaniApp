// lib/widgets/rewards_panel_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reward_controller.dart';

class RewardsPanelWidget extends StatelessWidget {
  const RewardsPanelWidget({super.key});

  // Define the primary color for consistency
  static const Color primaryBlue = Color(0xFF007BFF);

  @override
  Widget build(BuildContext context) {
    final rewardCtrl = Get.find<RewardController>();

    return Container(
      // Use Container for the gradient background
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: const LinearGradient(
          colors: [primaryBlue, Color(0xFF0056B3)], // A slight gradient for depth
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Card(
        // Card is transparent to show the Container's background
        color: Colors.transparent,
        elevation: 0, // Remove default card shadow
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Stack(
            children: [
              // 1. Subtle Background Icon for Depth
              Positioned(
                bottom: -10,
                right: -10,
                child: Icon(
                  Icons.star_half, // A more abstract star icon
                  size: 100,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),

              // 2. Main Content (Foreground)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label
                      Text(
                        'totalCoins'.tr,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Points Value
                      Obx(() => Text(
                        '${rewardCtrl.totalPoints.value}',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900, // Extra bold
                          fontSize: 42,
                          height: 1.0, // Tighter line spacing
                        ),
                      )),
                    ],
                  ),
                  // Current Icon (slightly adjusted for context)
                  Icon(
                    Icons.stars_sharp,
                    size: 40,
                    color: Colors.yellowAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}