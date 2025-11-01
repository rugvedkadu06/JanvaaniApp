// lib/main_layout.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'controllers/navigation_controller.dart';
import 'controllers/localization_controller.dart';
import 'screens/issues/create_issue_page.dart';
import 'screens/issues/issue_list_page.dart';
import 'screens/rewards/reward_list_page.dart';
import 'screens/profile/profile_page.dart';

class MainLayout extends StatelessWidget {
  MainLayout({super.key});
  final List<Widget> pages = [const IssueListPage(), const RewardListPage(), const ProfilePage()];
  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.find<NavigationController>();
    final locCtrl = Get.find<LocalizationController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('appName'.tr),
        actions: [
          PopupMenuButton<Locale>(
            onSelected: (locale) => locCtrl.changeLocale(locale.languageCode, locale.countryCode!),
            icon: const Icon(Icons.language),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              PopupMenuItem<Locale>(value: const Locale('en', 'US'), child: Text('english'.tr)),
              PopupMenuItem<Locale>(value: const Locale('hi', 'IN'), child: Text('hindi'.tr)),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: Obx(() => IndexedStack(index: navCtrl.selectedIndex.value, children: pages)),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Obx(() => _FloatingNavBar(
              selectedIndex: navCtrl.selectedIndex.value,
              onTap: navCtrl.setIndex,
              labels: ['issues'.tr, 'rewards'.tr, 'profile'.tr],
            )),
          ),
        ],
      ),
      floatingActionButton: Obx(() => navCtrl.selectedIndex.value == 0
          ? Padding(
        padding: const EdgeInsets.only(bottom: 84),
        child: FloatingActionButton(
          onPressed: () => Get.to(() => CreateIssuePage()),
          // --- CHANGED ICON HERE ---
          child: const Icon(Icons.edit_note),
          // Alternatively, try: Icons.post_add or Icons.add_circle
        ),
      )
          : const SizedBox.shrink()),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;
  final List<String> labels;
  const _FloatingNavBar({required this.selectedIndex, required this.onTap, required this.labels});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Stack(
            children: [
              // Animated active pill background
              _AnimatedActivePill(selectedIndex: selectedIndex),
              // Foreground nav items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavItem(index: 0, selectedIndex: selectedIndex, onTap: onTap, icon: Icons.list_alt_outlined, activeIcon: Icons.list_alt, label: labels[0]),
                  _NavItem(index: 1, selectedIndex: selectedIndex, onTap: onTap, icon: Icons.star_outline, activeIcon: Icons.star, label: labels[1]),
                  _NavItem(index: 2, selectedIndex: selectedIndex, onTap: onTap, icon: Icons.person_outline, activeIcon: Icons.person, label: labels[2]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final void Function(int) onTap;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.index, required this.selectedIndex, required this.onTap, required this.icon, required this.activeIcon, required this.label});
  @override
  Widget build(BuildContext context) {
    final bool isActive = index == selectedIndex;
    final Color activeColor = const Color(0xFF007BFF);
    return Expanded(
      child: InkWell(
        onTap: () { HapticFeedback.selectionClick(); onTap(index); },
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isActive ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(isActive ? activeIcon : icon, color: isActive ? activeColor : Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400, color: isActive ? activeColor : Colors.grey.shade700),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedActivePill extends StatelessWidget {
  final int selectedIndex;
  const _AnimatedActivePill({required this.selectedIndex});

  Alignment _alignmentForIndex(int index) {
    switch (index) {
      case 0:
        return Alignment.centerLeft;
      case 1:
        return Alignment.center;
      default:
        return Alignment.centerRight;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF007BFF);
    return Positioned.fill(
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        alignment: _alignmentForIndex(selectedIndex),
        child: FractionallySizedBox(
          widthFactor: 1 / 3,
          heightFactor: 1,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: activeColor.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: activeColor.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}