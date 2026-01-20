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

  double _getYValue(DeviceData item) {
    switch (_selectedMetric) {
      case 'Tegangan':
        return item.voltage;
      case 'Arus':
        return item.current;
      case 'Daya':
        return item.power;
      case 'Energi':
        return item.energyHour;
      case 'Faktor Daya':
        return item.pf;
      case 'Freq':
        return item.frequency;
      default:
        return item.energyHour;
    }
  }

  String _getUnit() {
    switch (_selectedMetric) {
      case 'Tegangan':
        return 'V';
      case 'Arus':
        return 'A';
      case 'Daya':
        return 'W';
      case 'Energi':
        return 'kWh';
      case 'Faktor Daya':
        return '';
      case 'Freq':
        return 'Hz';
      default:
        return '';
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Row(
                      children: [
                        _buildTabButton("Hari", controller.selectedPeriod.value == 'Hari'),
                        _buildTabButton("Minggu", controller.selectedPeriod.value == 'Minggu'),
                        _buildTabButton("Bulan", controller.selectedPeriod.value == 'Bulan'),
                      ],
                    )),
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: SiwattColors.primarySoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_drop_down, size: 18),
                      Text(
                        controller.selectedPeriod.value,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: SiwattColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )),
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

              final period = controller.selectedPeriod.value;
              final data = List<DeviceData>.from(controller.graphDataList);
              data.sort((a, b) => a.datetime.compareTo(b.datetime));

              if (data.isEmpty) {
                return const Center(child: Text("No data available"));
              }

              List<FlSpot> spots;
              if (period == 'Hari') {
                spots = data.map((item) {
                  double x = item.datetime.hour + (item.datetime.minute / 60.0);
                  double y = _getYValue(item);
                  return FlSpot(x, y);
                }).toList();
              } else {
                spots = data.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), _getYValue(e.value));
                }).toList();
              }

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

              double minX, maxX;
              double? interval;
              if (period == 'Hari') {
                minX = 0;
                maxX = 23;
                interval = 6;
              } else {
                minX = 0;
                maxX = (spots.length - 1).toDouble();
                if (maxX < 1) maxX = 1;
                
                if (period == 'Minggu') {
                  interval = 1; // Force interval 1 for weekly view to align days
                } else {
                  interval = maxX / 5;
                  if (interval < 1) interval = 1;
                }
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
                child: LineChart(
                  LineChartData(
                    clipData: const FlClipData.all(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      drawHorizontalLine: true,
                      verticalInterval: interval,
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
                          interval: interval,
                          getTitlesWidget: (value, meta) {
                            if (period == 'Hari') {
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
                            } else {
                                int index = value.toInt();
                                if (index >= 0 && index < data.length) {
                                  final date = data[index].datetime;
                                  String text;
                                  if (period == 'Minggu') {
                                    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                                    text = days[date.weekday - 1];
                                  } else {
                                    text = '${date.day}/${date.month}';
                                  }
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                      text,
                                      style: const TextStyle(
                                        color: Color(0xff68737d),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                }
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
                    minX: minX,
                    maxX: maxX,
                    minY: minY,
                    maxY: maxY,
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: SiwattColors.primary,
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            String label;
                             if (period == 'Hari') {
                                final hour = barSpot.x.toInt();
                                final minute = ((barSpot.x - hour) * 60).toInt();
                                label = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
                             } else {
                                int index = barSpot.x.toInt();
                                if (index >= 0 && index < data.length) {
                                  final date = data[index].datetime;
                                  if (period == 'Minggu') {
                                    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
                                    label = days[date.weekday - 1];
                                  } else {
                                    label = '${date.day}/${date.month}';
                                  }
                                } else {
                                  label = '';
                                }
                             }
                            
                            return LineTooltipItem(
                              '$label\n${barSpot.y.toStringAsFixed(2)}${_getUnit()}',
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
    return GestureDetector(
      onTap: () => controller.changeGraphPeriod(text),
      child: Container(
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
