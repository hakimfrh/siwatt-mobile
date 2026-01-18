import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/monitoring/controllers/mqtt_controller.dart';
import 'package:siwatt_mobile/features/monitoring/widgets/monitoring_card.dart';

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  int? expandedIndex = 0; // Default first item expanded
  final MqttController controller = Get.put(MqttController());

  void _onCardTap(int index) {
    setState(() {
      if (expandedIndex == index) {
        expandedIndex = null; // Collapse if already expanded
      } else {
        expandedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: SiwattColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Realtime Monitoring",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: SiwattColors.primaryDark,
                  ),
                ),
                const Spacer(),
                Obx(() => IconButton.filled(
                  onPressed: controller.isConnecting.value ? null : () {
                    controller.connect();
                  }, 
                  icon: controller.isConnecting.value 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : Icon(controller.isConnected.value ? Icons.stop_rounded : Icons.play_arrow_rounded), 
                  style: IconButton.styleFrom(
                    backgroundColor: controller.isConnected.value ? Colors.red : SiwattColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )),
              ],
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
                  onTap: controller.decrementLimit,
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
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: SiwattColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${controller.datapointLimit.value}",
                    style: const TextStyle(
                      color: SiwattColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )),
                const SizedBox(width: 12),
                InkWell(
                  onTap: controller.incrementLimit,
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
            Obx(() => Row(
              children: [
                Text("Status: ", style: textTheme.bodyMedium),
                Text(
                  controller.isConnected.value ? "Connected" : "Disconnected", 
                  style: textTheme.bodyMedium?.copyWith(
                    color: controller.isConnected.value ? SiwattColors.accentSuccess : Colors.red,
                  )
                ),
              ],
            )),
            const SizedBox(height: 20),
            Obx(() => ListView.separated(
              itemCount: controller.items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return MonitoringCard(
                  item: controller.items[index],
                  isExpanded: expandedIndex == index,
                  onTap: () => _onCardTap(index),
                );
              },
            )),
            // Extra padding at bottom
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}





