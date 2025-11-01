// lib/widgets/coupon_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/coupon.dart';
import '../controllers/reward_controller.dart';
import 'info_chip.dart';

class CouponCard extends StatelessWidget {
  final Coupon coupon;
  const CouponCard({super.key, required this.coupon});

  void _showCouponDetails(BuildContext context, Coupon coupon) {
    final rewardCtrl = Get.find<RewardController>();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 35, backgroundColor: coupon.color.withOpacity(0.1), child: Icon(coupon.icon, size: 35, color: coupon.color)),
            const SizedBox(height: 16),
            Text(coupon.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(coupon.description, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            InfoChip(icon: Icons.calendar_today, text: '${'validTill'.tr}: ${DateFormat.yMMMd().format(coupon.validTill)}'),
            const SizedBox(height: 24),
            Obx(() {
              final isRedeemed = rewardCtrl.isCouponRedeemed(coupon.id);
              final canAfford = rewardCtrl.totalPoints.value >= coupon.cost;
              final canRedeem = !coupon.isExpired && !isRedeemed && canAfford;

              String buttonText = '${'redeem'.tr} for ${coupon.cost} ${'points'.tr}';
              if(coupon.isExpired) buttonText = 'expired'.tr;
              if(isRedeemed) buttonText = 'redeemed'.tr;
              if(!canAfford && !isRedeemed && !coupon.isExpired) buttonText = 'notEnoughPoints'.tr;

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canRedeem ? () {
                    Get.defaultDialog(
                      title: 'confirmRedemption'.tr,
                      middleText: '${'confirmRedemptionBody'.tr} ${coupon.cost} ${'points'.tr} for "${coupon.title}"?',
                      textConfirm: 'redeem'.tr,
                      textCancel: 'cancel'.tr,
                      onConfirm: () => rewardCtrl.redeemCoupon(coupon),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(backgroundColor: canRedeem ? coupon.color : Colors.grey.shade400),
                  child: Text(buttonText),
                ),
              );
            }),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rewardCtrl = Get.find<RewardController>();
    final isExpired = coupon.isExpired;

    return Obx(() {
      final isRedeemed = rewardCtrl.isCouponRedeemed(coupon.id);
      final isUnavailable = isExpired || isRedeemed;

      return Opacity(
        opacity: isUnavailable ? 0.5 : 1.0,
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showCouponDetails(context, coupon),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(backgroundColor: coupon.color.withOpacity(0.1), radius: 30, child: Icon(coupon.icon, size: 30, color: coupon.color)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(coupon.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('${'cost'.tr}: ${coupon.cost} ${'points'.tr}', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUnavailable)
                  Positioned(
                    top: 8,
                    right: -40,
                    child: Transform.rotate(
                      angle: 0.785,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
                        color: isRedeemed ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
                        child: Text(
                          isRedeemed ? 'redeemed'.tr : 'expired'.tr,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}


