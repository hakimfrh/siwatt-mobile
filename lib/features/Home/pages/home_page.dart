import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/features/home/controllers/home_controller.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/home/widgets/home_graph_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = Get.put(HomeController());
  final String _selectedPeriod = 'Hari Ini';
  final String _selectedMetric = 'Energi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              "Selamat Pagi, Budi !",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: SiwattColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            // Info Card
            Obx(() {
                 final stats = controller.dashboardStats.value;
                 return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SiwattColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: SiwattColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/icons/dashboard_card/Bolt.png',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                       Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Rata rata penggunaan Hari Ini",
                              style: TextStyle(fontSize: 12, color: SiwattColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stats != null ? "${stats.avgUsageToday.toStringAsFixed(2)} W" : "-",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: SiwattColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/icons/dashboard_card/Home.png',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                       Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Sisa token saat ini",
                              style: TextStyle(fontSize: 12, color: SiwattColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stats != null ? "${stats.tokenBalance.toStringAsFixed(2)} kWh" : "-",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: SiwattColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: SiwattColors.accentInfo,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/icons/dashboard_card/Time.png',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                       Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Perkiraan masa pakai",
                              style: TextStyle(fontSize: 12, color: SiwattColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stats != null ? "${stats.estimatedDays} Hari Lagi" : "-",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: SiwattColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.black12),
                  const SizedBox(height: 8),
                  const Text(
                    "Perhitungan Perkiraan Masa pakai menggunakan Metode LSTM.\nHasil Perhitungan Hanya Sebagai Perkiraan.",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 10, color: SiwattColors.textSecondary),
                  ),
                ],
              ),
            );
            }),
            const SizedBox(height: 32),
            // Graph Section
            const Text(
              "Grafik penggunaan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: SiwattColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            HomeGraphSection(selectedPeriod: _selectedPeriod),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    ),
    );
  }
}
