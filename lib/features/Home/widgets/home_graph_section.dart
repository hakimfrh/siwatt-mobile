import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/home/controllers/home_controller.dart';
import 'package:siwatt_mobile/core/models/devices_data.dart';

class HomeGraphSection extends StatefulWidget {
  final String selectedPeriod;

  const HomeGraphSection({
    super.key,
    required this.selectedPeriod,
  });

  @override
  State<HomeGraphSection> createState() => _HomeGraphSectionState();
}

class _HomeGraphSectionState extends State<HomeGraphSection> {
  final HomeController controller = Get.find<HomeController>();
  String _selectedMetric = 'Energi';

  List<FlSpot> _getSpots(List<DeviceData> data) {
    if (data.isEmpty) return [];

    // Sort by time just in case
    data.sort((a, b) => a.datetime.compareTo(b.datetime));

    return data.map((item) {
      double x = item.datetime.hour + (item.datetime.minute / 60.0);
      double y = 0.0;
      switch (_selectedMetric) {
        case 'Tegangan':
          y = item.voltage;
          break;
        case 'Arus':
          y = item.current;
          break;
        case 'Daya':
          y = item.power;
          break;
        case 'Energi':
          y = item.energyHour;
          break;
        case 'Faktor Daya':
          y = item.pf;
          break;
        case 'Freq':
          y = item.frequency;
          break;
        default:
          y = item.energyHour;
      }
      return FlSpot(x, y);
    }).toList();
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildTabButton("Hari", true),
                    _buildTabButton("Minggu", false),
                    _buildTabButton("Bulan", false),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: SiwattColors.primarySoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_drop_down, size: 18),
                      Text(
                        widget.selectedPeriod,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: SiwattColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final spots = _getSpots(controller.todayDataList);
              
              if (spots.isEmpty) {
                return const Center(child: Text("No data available"));
              }

              double minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
              double maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
              
              // Add some padding to Y axis
              double yRange = maxY - minY;
              if (yRange == 0) yRange = 1; // avoid division by zero
              if (minY > 0) {
                 minY = (minY - yRange * 0.1).clamp(0, double.infinity);
              }
              maxY = maxY + yRange * 0.1;

              return Padding(
                padding: const EdgeInsets.fromLTRB(0,0,24,0),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      drawHorizontalLine: true,
                      verticalInterval: 3, // Every 4 hours lines
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withAlpha(50),
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: Colors.grey.withAlpha(50), 
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 16,
                          interval: 6, // Interval for labels
                          getTitlesWidget: (value, meta) {
                            // value is hour (double)
                            int hour = value.toInt();
                            if (hour >= 0 && hour <= 23) {
                               return Padding(
                                 padding: const EdgeInsets.only(top: 5.0),
                                 child: Text(
                                  '${hour.toString().padLeft(2, '0')}:00',
                                  style: const TextStyle(
                                    color: Color(0xff68737d),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                 ),
                               );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            // Show fewer labels on Y axis to avoid clutter
                            if (value == minY || value == maxY) return const SizedBox.shrink();
                            
                            return Text(
                              value.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Color(0xff67727d),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.right,
                            );
                          },
                        ),
                      ), 
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        left: BorderSide(color: Colors.black12, width: 1),
                        bottom: BorderSide(color: Colors.black12, width: 1),
                      ),
                    ),
                    minX: 0,
                    maxX: 23, // 24 Hours
                    minY: minY,
                    maxY: maxY,
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: SiwattColors.primary,
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            final hour = barSpot.x.toInt();
                            final minute = ((barSpot.x - hour) * 60).toInt();
                            final timeStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
                            return LineTooltipItem(
                              '$timeStr\n${barSpot.y.toStringAsFixed(2)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
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
                            colors: [
                              SiwattColors.primary.withOpacity(0.5),
                              SiwattColors.primary.withOpacity(0.1),
                            ],
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMetricChip("Tegangan"),
                  _buildMetricChip("Arus"),
                  _buildMetricChip("Daya"),
                  _buildMetricChip("Energi"),
                  _buildMetricChip("Faktor Daya"),
                  _buildMetricChip("Freq"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.only(bottom: 6, right: 12, left: 12),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        border: isActive
            ? const Border(
                bottom: BorderSide(color: SiwattColors.primary, width: 2),
              )
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          color: isActive ? SiwattColors.textPrimary : Colors.grey,
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
