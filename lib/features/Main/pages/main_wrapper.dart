import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/main/controllers/main_controller.dart';
import 'package:siwatt_mobile/features/home/pages/home_page.dart';
import 'package:siwatt_mobile/features/monitoring/pages/monitoring_page.dart';
import 'package:siwatt_mobile/features/token/pages/token_page.dart';
import 'package:siwatt_mobile/features/history/pages/history_page.dart';
import 'package:siwatt_mobile/features/profile/pages/profile_page.dart';
import 'package:siwatt_mobile/features/auth/controllers/login_controller.dart';

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final MainController controller = Get.put(MainController());
    final LoginController authController = Get.put(LoginController());

    final List<Widget> pages = [const HomePage(), const MonitoringPage(), const TokenPage(), const HistoryPage(), const ProfilePage()];

    return Scaffold(
      appBar: AppBar(
        title: Text('Siwatt', style: textTheme.headlineLarge?.copyWith(color: Colors.white)),
        backgroundColor: SiwattColors.primary,
        // The leading icon (drawer menu) is automatically added by Scaffold when a drawer is present.
      ),
      drawer: Drawer(
        backgroundColor: colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,          
            children: [
              SizedBox(height: 16,),
              Row(
                children: [
                  Text("Devices", style: textTheme.headlineLarge?.copyWith(color: Colors.white)),
                Spacer(),
                InkWell(
                  onTap: () {
                    
                  },
                  child: Icon(Icons.add, color: Colors.white,),
                )
                ],
              ),
              SizedBox(height: 24,),
              Expanded(
                child: Obx(() {
                  if (controller.devices.isEmpty) {
                    return const Center(child: Text("No devices found", style: TextStyle(color: Colors.white)));
                  }
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: controller.devices.length,
                    itemBuilder: (context, index) {
                      final device = controller.devices[index];
                      return Obx(() {
                        final isSelected = controller.currentDevice.value?.id == device.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ListTile(
                            onTap: () {
                              controller.changeDevice(device);
                              Get.back();
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            tileColor: isSelected 
                                ? Colors.white.withOpacity(0.2) 
                                : Colors.white.withOpacity(0.05),
                            leading: const Icon(Icons.router, color: Colors.white),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  device.deviceName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'ID: ${device.deviceCode}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  );
                }),
              ),
              // Minimalist Logout Button
              ListTile(
                onTap: () {
                   authController.logout();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                tileColor: Colors.red.withOpacity(0.1),
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() => pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => Theme(
          data: Theme.of(context).copyWith(splashColor: Colors.transparent, highlightColor: Colors.transparent),
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
