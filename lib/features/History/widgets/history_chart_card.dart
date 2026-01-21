import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/models/devices_data.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/history/controllers/history_controller.dart';
import 'package:intl/intl.dart';

class HistoryChartCard extends StatefulWidget {
  const HistoryChartCard({super.key});

  @override
  State<HistoryChartCard> createState() => _HistoryChartCardState();
}

class _HistoryChartCardState extends State<HistoryChartCard> {
  final HistoryController controller = Get.find<HistoryController>();
  String _selectedMetric = 'Energi';
  final List<String> _metrics = [
    "Tegangan",
    "Arus",
    "Daya",
    "Energi",
    "Faktor Daya",
    "Freq"
  ];

  double _getYValue(DeviceData item) {
    switch (_selectedMetric) {
      case 'Tegangan': return item.voltage;
      case 'Arus': return item.current;
      case 'Daya': return item.power;
      case 'Energi': return item.energyHour; // Or Energy total if appropriate
      case 'Faktor Daya': return item.pf; // Assuming percent 0-100 or 0-1
      case 'Freq': return item.frequency;
      default: return item.energyHour;
    }
  }

  String _getUnit() {
    switch (_selectedMetric) {
      case 'Tegangan': return 'V';
      case 'Arus': return 'A';
      case 'Daya': return 'W';
      case 'Energi': return 'kWh';
      case 'Faktor Daya': return '';
      case 'Freq': return 'Hz';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Frequency Tabs & Send Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 // Frequency Selection
                 Expanded(
                   child: SingleChildScrollView(
                     scrollDirection: Axis.horizontal,
                      child: Obx(() => Row(
                        children: [
                          _buildTabItem("Jam", "hour"),
                          _buildTabItem("Hari", "day"),
                          _buildTabItem("Minggu", "week"),
                          _buildTabItem("Bulan", "month"),
                        ],
                      )),
                   ),
                 ),
                 
                 // Send Button
                 const SizedBox(width: 8),
                 Obx(() {
                    if (controller.isLoading.value) {
                      return GestureDetector(
                        onTap: controller.cancelRequest,
                        child: Container(
                          width: 36, height: 36,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () => controller.fetchData(),
                      child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: SiwattColors.primarySoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.send, color: SiwattColors.primary, size: 20),
                      ),
                    );
                 }),
              ],
            ),
          ),
          
          const Divider(height: 1),
          const SizedBox(height: 24),

          // Chart Area
          SizedBox(
            height: 250,
            child: Obx(() {
               if (controller.isLoading.value && controller.historyDataList.isEmpty) {
                 return const Center(child: CircularProgressIndicator());
               }
               
               final data = List<DeviceData>.from(controller.historyDataList);
               // Sort data
               data.sort((a, b) => a.datetime.compareTo(b.datetime));
               
               if (data.isEmpty) {
                  return const Center(child: Text("Belum ada data. Silakan request."));
               }

               final freq = controller.selectedFrequency.value;
               
               // Generate Spots
               // X Axis: index 0..N
               List<FlSpot> spots = data.asMap().entries.map((e) {
                   return FlSpot(e.key.toDouble(), _getYValue(e.value));
               }).toList();
               
               if (spots.isEmpty) return const Center(child: Text("No Data"));
               
               double maxY = spots.map((e) => e.y).fold(0.0, (p, c) => c > p ? c : p);
               double minY = spots.map((e) => e.y).fold(double.infinity, (p, c) => c < p ? c : p);
               
               double yRange = maxY - minY;
               if (yRange == 0) yRange = 1;
               minY = (minY - yRange * 0.1).clamp(0, double.infinity);
               maxY = maxY + yRange * 0.1;
               
               double maxX = (spots.length - 1).toDouble();
               if (maxX < 1) maxX = 1;
               
               // Interval Calculation
               double interval = maxX / 5;
               if (interval < 1) interval = 1;
               
               return Padding(
                 padding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
                 child: LineChart(
                   LineChartData(
                     clipData: const FlClipData.all(),
                     gridData: FlGridData(
                       show: true,
                       drawVerticalLine: true,
                       // Use a smart interval for vertical lines
                       verticalInterval: interval,
                       getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withAlpha(50), strokeWidth: 1),
                       getDrawingVerticalLine: (_) => FlLine(color: Colors.grey.withAlpha(50), strokeWidth: 1),
                     ),
                     titlesData: FlTitlesData(
                       rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                       topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                       bottomTitles: AxisTitles(
                         sideTitles: SideTitles(
                           showTitles: true,
                           reservedSize: 24,
                           interval: interval,
                           getTitlesWidget: (value, meta) {
                             int idx = value.toInt();
                             if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                             final date = data[idx].datetime;
                             
                             // Label Formatting based on Frequency
                             String text = "";
                             if (freq == 'hour') {
                               text = DateFormat('HH:mm').format(date);
                             } else if (freq == 'day') {
                               text = DateFormat('dd/MM').format(date);
                             } else if (freq == 'week') {
                               // Assuming 'week' data point represents start of week? 
                               // Actually if API returns weekly aggregations, datetime might be start of week.
                               text = "W${(date.day / 7).ceil()}"; 
                               // Or just date
                               text = DateFormat('dd/MM').format(date);
                             } else if (freq == 'month') {
                               text = DateFormat('MMM').format(date);
                             }
                             
                             return Padding(
                               padding: const EdgeInsets.only(top: 8.0),
                               child: Text(
                                 text,
                                 style: const TextStyle(fontSize: 10, color: Color(0xff68737d), fontWeight: FontWeight.bold),
                               ),
                             );
                           },
                         ),
                       ),
                       leftTitles: AxisTitles(
                         sideTitles: SideTitles(
                           showTitles: true,
                           reservedSize: 40,
                           getTitlesWidget: (value, meta) {
                             if (value == minY || value == maxY) return const SizedBox.shrink();
                             return Text(
                               value.toStringAsFixed(1),
                               style: const TextStyle(fontSize: 10, color: Color(0xff67727d)),
                               textAlign: TextAlign.right,
                             );
                           },
                         ),
                       ),
                     ),
                     borderData: FlBorderData(show: true, border: const Border(left: BorderSide(color: Colors.black12), bottom: BorderSide(color: Colors.black12))),
                     minX: 0, maxX: maxX,
                     minY: minY, maxY: maxY,
                     lineTouchData: LineTouchData(
                       touchTooltipData: LineTouchTooltipData(
                         tooltipBgColor: SiwattColors.primary,
                         getTooltipItems: (touchedSpots) {
                           return touchedSpots.map((spot) {
                             int idx = spot.x.toInt();
                             if (idx < 0 || idx >= data.length) return null;
                             final date = data[idx].datetime;
                             
                             // Tooltip label
                             String label = "";
                              if (freq == 'hour') {
                               label = DateFormat('dd MMM HH:mm').format(date);
                             } else if (freq == 'day') {
                               label = DateFormat('EEEE, dd MMM').format(date);
                             } else if (freq == 'week') {
                               label = "Minggu ${DateFormat('dd MMM').format(date)}";
                             } else if (freq == 'month') {
                               label = DateFormat('MMMM yyyy').format(date);
                             }
                             
                             return LineTooltipItem(
                               "$label\n${spot.y.toStringAsFixed(2)}${_getUnit()}",
                               const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                             );
                           }).toList();
                         }
                       ),
                     ),
                     lineBarsData: [
                       LineChartBarData(
                         spots: spots,
                         isCurved: true,
                         color: SiwattColors.primary,
                         barWidth: 2,
                         isStrokeCapRound: true,
                         dotData: const FlDotData(show: false),
                         belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [SiwattColors.primary.withOpacity(0.5), SiwattColors.primary.withOpacity(0.1)],
                            ),
                         ),
                       ),
                     ],
                   ),
                 ),
               );
            }),
          ),
          
          const SizedBox(height: 24),
          
          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _metrics.map((m) => _buildMetricChip(m)).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, String freqKey) {
    bool isActive = controller.selectedFrequency.value == freqKey;
    return GestureDetector(
      onTap: () => controller.setFrequency(freqKey),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? SiwattColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip(String text) {
    bool isActive = _selectedMetric == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMetric = text;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? SiwattColors.primary : SiwattColors.input,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
