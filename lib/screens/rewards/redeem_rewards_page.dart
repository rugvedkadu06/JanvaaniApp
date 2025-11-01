// lib/screens/rewards/redeem_rewards_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/reward_controller.dart';
import '../../models/coupon.dart';
import '../../widgets/coupon_card.dart';
import '../../widgets/rewards_panel_widget.dart';

// Define the categories for the TabBar
enum CouponCategory { all, food, entertainment, utilities, giftCards }

class RedeemRewardsPage extends StatelessWidget {
  const RedeemRewardsPage({super.key});

  // --- MOCK COUPON DATA WITH CATEGORIES ---
  // (Data remains the same for consistency)
  static final List<Coupon> _allCoupons = [
    Coupon(id: 'PIZZA30', title: "30% Off on Pizza", description: "Valid at any Domino's outlet", cost: 150, icon: Icons.local_pizza, color: Colors.red.shade400, validTill: DateTime.now().add(const Duration(days: 30)), category: CouponCategory.food),
    Coupon(id: 'COFFEEFREE', title: "Free Coffee", description: "Get one free coffee at Starbucks", cost: 100, icon: Icons.coffee, color: Colors.brown.shade400, validTill: DateTime.now().add(const Duration(days: 15)), category: CouponCategory.food),
    Coupon(id: 'RECHARGE50', title: "₹50 Mobile Recharge", description: "Valid for any prepaid carrier", cost: 200, icon: Icons.phone_android, color: Colors.blue.shade400, validTill: DateTime.now().add(const Duration(days: 60)), category: CouponCategory.utilities),
    Coupon(id: 'MUSIC1M', title: "1 Month Music Subscription", description: "For Spotify or Gaana", cost: 300, icon: Icons.music_note, color: Colors.green.shade400, validTill: DateTime.now().subtract(const Duration(days: 5)), category: CouponCategory.entertainment),
    Coupon(id: 'MOVIE100', title: "Movie Ticket Voucher", description: "Flat ₹100 off on BookMyShow", cost: 250, icon: Icons.movie, color: Colors.purple.shade400, validTill: DateTime.now().add(const Duration(days: 45)), category: CouponCategory.entertainment),
    Coupon(id: 'AMZNGIFT', title: "₹200 Amazon Gift Card", description: "E-Gift Card delivered instantly", cost: 500, icon: Icons.card_giftcard, color: Colors.orange.shade400, validTill: DateTime.now().add(const Duration(days: 90)), category: CouponCategory.giftCards),
    Coupon(id: 'DATA5GB', title: "5GB Extra Data", description: "Valid for Jio/Airtel post redemption", cost: 180, icon: Icons.signal_cellular_alt, color: Colors.cyan.shade400, validTill: DateTime.now().add(const Duration(days: 30)), category: CouponCategory.utilities),
  ];

  static Map<CouponCategory, List<Coupon>> get _categorizedCoupons {
    final Map<CouponCategory, List<Coupon>> map = {};

    // Non-expired coupons only
    final available = _allCoupons.where((c) => !c.isExpired).toList();

    for (var category in CouponCategory.values) {
      if (category == CouponCategory.all) {
        map[category] = available;
      } else {
        map[category] = available.where((c) => c.category == category).toList();
      }
    }
    return map;
  }

  // Helper to convert Enum to a readable string for the TabBar
  String _getCategoryTitle(CouponCategory category) {
    switch (category) {
      case CouponCategory.all: return 'All'.tr;
      case CouponCategory.food: return 'Food & Drinks'.tr;
      case CouponCategory.entertainment: return 'Entertainment'.tr;
      case CouponCategory.utilities: return 'Utilities'.tr;
      case CouponCategory.giftCards: return 'Gift Cards'.tr;
    }
  }

  // 💡 ENHANCEMENT: Refactored to use a more visually appealing Bottom Sheet for redemption.
  void _showRedeemDialog(BuildContext context, Coupon coupon) {
    // Assuming you have a RewardController to get user points
    final rewardCtrl = Get.find<RewardController>();
    final canAfford = rewardCtrl.totalPoints.value >= coupon.cost;
    final colorScheme = Theme.of(context).colorScheme;

    Get.bottomSheet(
      // The container provides the background color, radius, and padding
      Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Close Button / Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'confirmRedemption'.tr,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Coupon Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: coupon.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: coupon.color, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(coupon.icon, size: 40, color: coupon.color),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          coupon.description,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Cost and Point Check
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'yourPoints'.tr, // "Your Points"
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
                Text(
                  '${NumberFormat.compact().format(rewardCtrl.totalPoints.value)} ${'points'.tr}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            )),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'couponCost'.tr, // "Coupon Cost"
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${coupon.cost} ${'points'.tr}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Confirmation Text
            Text(
              '${'redeemConfirmText'.tr}\n${'confirmEmailCode'.tr}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text('cancel'.tr, style: TextStyle(color: colorScheme.error)),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canAfford
                        ? () {
                      // 1. Close dialog
                      Get.back();
                      // 2. TODO: Implement actual points deduction logic here
                      // Example: rewardCtrl.deductPoints(coupon.cost, coupon.title);

                      // 3. Show success snackbar
                      Get.snackbar(
                        'success'.tr,
                        '${coupon.title} ${'voucherRedeemedEmail'.tr}!', // e.g., "Free Coffee voucher redeemed and code sent to your email!"
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green.shade600,
                        colorText: Colors.white,
                        icon: const Icon(Icons.mark_email_read, color: Colors.white),
                      );
                    }
                        : null, // Disable button if user cannot afford
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      canAfford ? 'redeemNow'.tr : 'notEnoughPoints'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            // Padding for safety on notch devices
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }


  @override
  Widget build(BuildContext context) {
    final availableCategories = CouponCategory.values;
    final expiredCoupons = _allCoupons.where((c) => c.isExpired).toList();

    // Add 'Expired' as the last tab
    final tabs = [
      ...availableCategories.map((c) => Tab(text: _getCategoryTitle(c))),
      Tab(text: 'expired'.tr)
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('redeemVouchersTitle'.tr),
          // --- STYLING THE TAB BAR ---
          bottom: TabBar(
            isScrollable: true,
            tabs: tabs,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Theme.of(context).primaryColor.withOpacity(0.1), // Subtle background indicator
              border: Border.all(color: Theme.of(context).primaryColor, width: 1),
            ),
            labelPadding: const EdgeInsets.symmetric(horizontal: 10),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey.shade600,
          ),
        ),
        body: Column(
          children: [
            // User's points panel (Card will handle its own margins)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: RewardsPanelWidget(),
            ),
            // The TabBarView takes up the remaining space
            Expanded(
              child: TabBarView(
                children: [
                  // Tab Views for each available category, using the static getter
                  ...availableCategories.map((category) => _buildCouponList(
                    context: context,
                    coupons: _categorizedCoupons[category]!,
                    isAvailable: true,
                    emptyMessage: 'noCouponsInCategory'.tr,
                  )),

                  // Expired Coupons Tab (Separate logic)
                  _buildCouponList(
                    context: context,
                    coupons: expiredCoupons,
                    isAvailable: false,
                    emptyMessage: 'noExpiredCoupons'.tr,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE COUPON LIST WIDGET ---
  Widget _buildCouponList({
    required BuildContext context,
    required List<Coupon> coupons,
    required bool isAvailable,
    required String emptyMessage,
  }) {
    if (coupons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        final coupon = coupons[index];
        return Opacity(
          opacity: isAvailable ? 1.0 : 0.5,
          child: Padding( // Added Padding to ensure margin between cards in the list
            padding: const EdgeInsets.only(bottom: 16.0),
            child: GestureDetector(
              onTap: isAvailable ? () => _showRedeemDialog(context, coupon) : null,
              child: CouponCard(coupon: coupon),
            ),
          ),
        );
      },
    );
  }
}