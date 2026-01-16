import 'package:flutter/material.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';

class DateRangePickerSection extends StatelessWidget {
  const DateRangePickerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tanggal awal",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: SiwattColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SiwattColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: const Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: SiwattColors.textSecondary),
                    // Empty space or placeholder could go here
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 28),
          child:
              Container(width: 10, height: 2, color: SiwattColors.textDisabled),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tanggal akhir",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: SiwattColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SiwattColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: const Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: SiwattColors.textSecondary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
