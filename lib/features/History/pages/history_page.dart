import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/History/models/usage_stat_model.dart';
import 'package:siwatt_mobile/features/History/widgets/average_info_card.dart';
import 'package:siwatt_mobile/features/History/widgets/date_range_picker_section.dart';
import 'package:siwatt_mobile/features/History/widgets/history_chart_card.dart';
import 'package:siwatt_mobile/features/history/controllers/history_controller.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final HistoryController controller = Get.put(HistoryController());

    return Scaffold(
      backgroundColor: SiwattColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Riwayat Penggunaan Listrik",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: SiwattColors.primaryDark,
              ),
            ),
            const SizedBox(height: 16),
            const DateRangePickerSection(),
            const SizedBox(height: 20),
            const HistoryChartCard(),
            const SizedBox(height: 24),
            const Text(
              "Rata-rata :",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
               final List<UsageStatModel> stats = [
                UsageStatModel(
                  title: "Tegangan",
                  value: controller.avgVoltage.value.toStringAsFixed(2),
                  unit: "V",
                  color: const Color(0xFF2A9D8F),
                ),
                UsageStatModel(
                  title: "Daya Aktif",
                  value: controller.avgPower.value.toStringAsFixed(2),
                  unit: "W",
                  color: const Color(0xFFF97316),
                ),
                UsageStatModel(
                  title: "Faktor Daya",
                  value: controller.avgPf.value.toStringAsFixed(2),
                  unit: "%",
                  color: const Color(0xFFE9C46A),
                ),
                UsageStatModel(
                  title: "Arus",
                  value: controller.avgCurrent.value.toStringAsFixed(2),
                  unit: "A",
                  color: const Color(0xFF3B82F6),
                ),
                // Assuming Energy/Daya Aktif (in kW)
                UsageStatModel(
                  title: "Daya Aktif", 
                  value: (controller.avgPower.value / 1000).toStringAsFixed(2),
                  unit: "kW",
                  color: const Color(0xFFF97316),
                ),
                UsageStatModel(
                  title: "Frekuensi",
                  value: controller.avgFrequency.value.toStringAsFixed(2),
                  unit: "Hz",
                  color: const Color(0xFF9CA3AF),
                ),
              ];
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                itemCount: stats.length,
                itemBuilder: (context, index) {
                  return AverageInfoCard(item: stats[index]);
                },
              );
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
