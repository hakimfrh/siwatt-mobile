import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/Main/controllers/main_controller.dart';
import 'package:siwatt_mobile/features/Home/pages/home_page.dart';
import 'package:siwatt_mobile/features/Monitoring/pages/monitoring_page.dart';
import 'package:siwatt_mobile/features/Token/pages/token_page.dart';
import 'package:siwatt_mobile/features/History/pages/history_page.dart';
import 'package:siwatt_mobile/features/Profile/pages/profile_page.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.put(MainController());

    final List<Widget> pages = [
      const HomePage(),
      const MonitoringPage(),
      const TokenPage(),
      const HistoryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: Obx(() => pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            type: BottomNavigationBarType.fixed, // Ensure all icons are shown
            backgroundColor: SiwattColors.primaryDark,
            // selectedItemColor: Colors.teal, // Matches the theme in screenshots
            // unselectedItemColor: Colors.grey,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                icon: Image.asset('assets/icons/bottom_navigation/Home - off.png', width: 24, height: 24),
                activeIcon: Image.asset('assets/icons/bottom_navigation/Home - on.png', width: 24, height: 24),
                label: 'Home',
              ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/icons/bottom_navigation/Monitoring - off.png', width: 24, height: 24),
              activeIcon: Image.asset('assets/icons/bottom_navigation/Monitoring - on.png', width: 24, height: 24),
              label: 'Monitoring',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/icons/bottom_navigation/Token - off.png', width: 24, height: 24),
              activeIcon: Image.asset('assets/icons/bottom_navigation/Token - on.png', width: 24, height: 24),
              label: 'Token',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/icons/bottom_navigation/History - off.png', width: 24, height: 24),
              activeIcon: Image.asset('assets/icons/bottom_navigation/History - on.png', width: 24, height: 24),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/icons/bottom_navigation/User - off.png', width: 24, height: 24),
              activeIcon: Image.asset('assets/icons/bottom_navigation/User - on.png', width: 24, height: 24),
              label: 'Profile',
            ),
            ],
          ),
        ),
      ),
    );
  }
}
