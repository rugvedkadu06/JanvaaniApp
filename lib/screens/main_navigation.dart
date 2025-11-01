import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/localization_controller.dart';
import 'issues/issue_list_page.dart';
import 'profile/profile_page.dart';

class NavigationController extends GetxController {
  final PageController pageController = PageController();
  final currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }
}

class MainNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Get.put(NavigationController());

    return Obx(() {
      // This Obx ensures the entire navigation rebuilds on language change
      final localizationController = Get.find<LocalizationController>();

      return Scaffold(
        body: PageView(
          controller: Get.find<NavigationController>().pageController,
          onPageChanged: (index) {
            Get.find<NavigationController>().changePage(index);
          },
          children: [
            IssueListPage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: Obx(() {
          final navigationController = Get.find<NavigationController>();
          return BottomNavigationBar(
            currentIndex: navigationController.currentIndex.value,
            onTap: navigationController.changePage,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.report_problem),
                label: 'nav_issues'.tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'nav_profile'.tr,
              ),
            ],
          );
        }),
      );
    });
  }
}
