

import 'package:flutter/material.dart';
import 'package:siwatt_mobile/core/models/devices.dart';

class DeviceCard extends StatelessWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              device.deviceName,
              style: textTheme.headlineMedium?.copyWith(
                  color: Colors.black, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Text(
                  device.isActive ? "Online" : "Offline",
                  style: textTheme.bodyMedium?.copyWith(
                    color: device.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: device.isActive ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                )
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Grid Parameters
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: [
            _buildParamCard(
                "Tegangan", "220.87", "V", colorScheme.primary),
            _buildParamCard(
                "Daya Aktif", "763.87", "W", colorScheme.secondary),
            _buildParamCard(
                "Faktor Daya", "89.82", "%", colorScheme.tertiary),
            _buildParamCard("Arus", "12.07", "A", colorScheme.error),
            _buildParamCard(
                "Daya Aktif", "80.87", "Kw", colorScheme.primary),
            _buildParamCard("Frekuensi", "50.82", "Hz", Colors.grey),
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
                    const Text("Waktu Online: 5 Hari",
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                    Text("Terakhir Update: 5 detik yang lalu",
                        style: TextStyle(
                            fontSize: 10, color: Colors.green.shade700)),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6), // Blue edit button
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Row(
                children: [
                  Text("Edit", style: TextStyle(fontSize: 12)),
                  SizedBox(width: 4),
                  Icon(Icons.edit, size: 12),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildParamCard(String title, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.normal),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: " "),
                TextSpan(
                  text: unit,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}