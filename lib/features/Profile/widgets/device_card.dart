import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/models/devices.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/profile/controllers/realtime_device_controller.dart';
import 'package:siwatt_mobile/features/profile/pages/edit_device.dart';

class DeviceCard extends StatefulWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  late final RealtimeDeviceController controller;

  @override
  void initState() {
    super.initState();
    // Unique tag for each device card to support multiple cards
    controller = Get.put(
      RealtimeDeviceController(widget.device.id),
      tag: 'device_${widget.device.id}',
    );
  }

  @override
  void dispose() {
    // Clean up controller when card is removed
    Get.delete<RealtimeDeviceController>(tag: 'device_${widget.device.id}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final data = controller.realtimeData.value;
      // Fallback to widget.device if realtime data is not yet available, 
      // though widget.device might not have all fields.
      
      final isOnline = data?.isOnline ?? widget.device.isActive;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.device.deviceName,
                    style: textTheme.headlineMedium?.copyWith(color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    widget.device.location,
                    style: textTheme.labelSmall?.copyWith(color: Colors.grey, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    isOnline ? "Online" : "Offline",
                    style: textTheme.bodyMedium?.copyWith(
                        color: isOnline ? Colors.green : Colors.red, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.red, shape: BoxShape.circle),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Grid Parameters
          // If loading initially, show loading? Or zeroes?
          // Showing zeroes or dashes if data is null.
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              _buildParamCard("Tegangan", data?.voltage.toStringAsFixed(2) ?? "0", "V", SiwattColors.chartVoltage),
              _buildParamCard("Daya Aktif", data?.power.toStringAsFixed(2) ?? "0", "W", SiwattColors.chartPower),
              _buildParamCard("Faktor Daya", ((data?.pf ?? 0) * 100).toStringAsFixed(1), "%", SiwattColors.chartEnergy),
              _buildParamCard("Arus", data?.current.toStringAsFixed(3) ?? "0", "A", SiwattColors.chartCurrent),
              _buildParamCard("Total Hari Ini", data?.totalToday.toStringAsFixed(3) ?? "0", "KwH", SiwattColors.chartPower),
              _buildParamCard("Frekuensi", data?.frequency.toStringAsFixed(1) ?? "0", "Hz", Colors.grey),
            ],
          ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Waktu Online: ${controller.formattedUptime}",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      Text("Terakhir Update: ${controller.lastUpdateFormatted}",
                          style: TextStyle(fontSize: 10, color: Colors.green.shade700)),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => EditDevicePage(device: widget.device));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6), // Blue edit button
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  children: [
                    Text("Edit", style: TextStyle(fontSize: 12)),
                    SizedBox(width: 4),
                    Icon(Icons.edit, size: 12),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildParamCard(String title, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.normal),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: " "),
                TextSpan(
                  text: unit,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
