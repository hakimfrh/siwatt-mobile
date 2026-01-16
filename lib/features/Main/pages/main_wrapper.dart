import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          type: BottomNavigationBarType.fixed, // Ensure all icons are shown
          selectedItemColor: Colors.teal, // Matches the theme in screenshots
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Monitoring',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flash_on),
              label: 'Token',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
