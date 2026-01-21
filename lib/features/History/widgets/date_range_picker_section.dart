import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/history/controllers/history_controller.dart';
import 'package:intl/intl.dart';

class DateRangePickerSection extends StatelessWidget {
  const DateRangePickerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _pickDateRange(context, controller),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Rentang Tanggal",
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
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 18, color: SiwattColors.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() {
                          final start = controller.startDate.value;
                          final end = controller.endDate.value;
                          if (start == null || end == null) {
                             return const Text("Pilih Tanggal", style: TextStyle(color: Colors.grey));
                          }
                          final fmt = DateFormat('dd MMM yyyy');
                          if (start.year == end.year && start.month == end.month && start.day == end.day) {
                               return Text(fmt.format(start), style: const TextStyle(
                                   fontWeight: FontWeight.w500,
                                   fontSize: 14,
                               ));
                          }
                          return Text(
                            "${fmt.format(start)} - ${fmt.format(end)}",
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500, 
                                color: SiwattColors.textPrimary
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                      ),
                      const Icon(Icons.arrow_drop_down, color: SiwattColors.textSecondary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateRange(BuildContext context, HistoryController controller) async {
    final initialDateRange = (controller.startDate.value != null && controller.endDate.value != null)
        ? DateTimeRange(start: controller.startDate.value!, end: controller.endDate.value!)
        : DateTimeRange(start: DateTime.now(), end: DateTime.now());

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: SiwattColors.primary,
              onPrimary: Colors.white,
              onSurface: SiwattColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setDateRange(picked.start, picked.end);
    }
  }
}
