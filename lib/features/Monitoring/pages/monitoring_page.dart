import 'package:flutter/material.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/Monitoring/models/monitoring_item.dart';
import 'package:siwatt_mobile/features/Monitoring/widgets/monitoring_card.dart';

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  int datapointLimit = 20;
  int? expandedIndex = 0; // Default first item expanded

  // Dummy data generation
  final List<MonitoringItem> items = [
    MonitoringItem(
      title: "Tegangan",
      value: "228,48",
      unit: "V",
      color: SiwattColors.chartVoltage,
      iconData: Icons.bolt, // Placeholder, usually letters usually
      iconLetter: 'V',
      dataPoints: [220, 225, 228, 226, 224, 225, 228, 230, 232, 230, 228, 229, 230, 231, 233, 230, 228],
    ),
    MonitoringItem(
      title: "Arus",
      value: "2,45",
      unit: "A",
      color: SiwattColors.chartCurrent,
      iconData: Icons.electric_meter,
      iconLetter: 'A',
      dataPoints: [1.0, 1.5, 2.0, 2.4, 3.0, 3.5, 3.2, 3.0, 2.8, 3.1, 3.5, 3.8, 3.5, 3.0, 2.5, 2.45],
    ),
    MonitoringItem(
      title: "Daya",
      value: "850,23",
      unit: "W",
      color: SiwattColors.chartPower,
      iconData: Icons.power,
      iconLetter: 'W',
      dataPoints: [500, 600, 700, 800, 850, 900, 880, 850, 820, 880, 920, 950, 900, 850, 850.23],
    ),
    MonitoringItem(
      title: "Faktor Daya",
      value: "98,55",
      unit: "%",
      color: SiwattColors.chartEnergy,
      iconData: Icons.percent,
      iconLetter: 'Pf',
      dataPoints: [90, 92, 95, 96, 98, 97, 95, 94, 96, 98, 99, 98, 97, 98, 98.55],
    ),
            MonitoringItem(
      title: "Frekuensi",
      value: "49,98",
      unit: "Hz",
      color: SiwattColors.textSecondary, // Example color
      iconData: Icons.waves,
      iconLetter: 'Hz',
      dataPoints: [50.1, 50.0, 49.9, 50.0, 50.1, 50.2, 50.1, 50.0, 49.9, 49.95, 49.98],
    ),
  ];

  void _onCardTap(int index) {
    setState(() {
      if (expandedIndex == index) {
        expandedIndex = null; // Collapse if already expanded
      } else {
        expandedIndex = index;
      }
    });
  }

  void _incrementLimit() {
    setState(() {
      datapointLimit++;
    });
  }

  void _decrementLimit() {
    setState(() {
      if (datapointLimit > 1) datapointLimit--;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              "Realtime Monitoring",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: SiwattColors.primaryDark,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  "Datapoint Limit:",
                  style: TextStyle(
                    fontSize: 14,
                    color: SiwattColors.textPrimary,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: _decrementLimit,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: SiwattColors.primary, width: 1.5),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.remove, size: 16, color: SiwattColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: SiwattColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "$datapointLimit",
                    style: const TextStyle(
                      color: SiwattColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _incrementLimit,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: SiwattColors.primary, width: 1.5),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.add, size: 16, color: SiwattColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListView.separated(
              itemCount: items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return MonitoringCard(
                  item: items[index],
                  isExpanded: expandedIndex == index,
                  onTap: () => _onCardTap(index),
                );
              },
            ),
            // Extra padding at bottom
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}




