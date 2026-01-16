import 'package:flutter/material.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/History/models/usage_stat_model.dart';
import 'package:siwatt_mobile/features/History/widgets/average_info_card.dart';
import 'package:siwatt_mobile/features/History/widgets/date_range_picker_section.dart';
import 'package:siwatt_mobile/features/History/widgets/history_chart_card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data Stats
    final List<UsageStatModel> stats = [
      UsageStatModel(
        title: "Tegangan",
        value: "220.87",
        unit: "V",
        color: const Color(0xFF2A9D8F), // Teal
      ),
      UsageStatModel(
        title: "Daya Aktif",
        value: "763.87",
        unit: "W",
        color: const Color(0xFFF97316), // Orange
      ),
      UsageStatModel(
        title: "Tegangan", // As per image text, likely Power Factor?
        value: "89.82",
        unit: "%",
        color: const Color(0xFFE9C46A), // Yellow/Gold
      ),
      UsageStatModel(
        title: "Arus",
        value: "12.07",
        unit: "A",
        color: const Color(0xFF3B82F6), // Blue
      ),
      UsageStatModel(
        title: "Daya Aktif",
        value: "80.87",
        unit: "Kw",
        color: const Color(0xFFF97316), // Orange
      ),
      UsageStatModel(
        title: "Frekuensi",
        value: "50.82",
        unit: "Hz",
        color: const Color(0xFF9CA3AF), // Grey
      ),
    ];

    return Scaffold(
      backgroundColor: SiwattColors.background,
      appBar: AppBar(
        backgroundColor: SiwattColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          "SiWatt",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
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
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1, // Adjust to fit square-ish shape
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                return AverageInfoCard(item: stats[index]);
              },
            ),
            // Extra padding
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
