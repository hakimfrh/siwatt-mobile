import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/monitoring/models/monitoring_item.dart';

class MonitoringCard extends StatelessWidget {
  final MonitoringItem item;
  final bool isExpanded;
  final VoidCallback onTap;

  const MonitoringCard({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: isExpanded ? 250 : 120, // Expanded vs Collapsed Height
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isExpanded ? _buildExpandedView() : _buildCollapsedView(),
      ),
    );
  }

  Widget _buildExpandedView() {
    // Calculate dynamic interval to show roughly 5 labels regardless of data size
    double dynamicInterval = 1.0;
    if (item.dataPoints.isNotEmpty) {
      dynamicInterval = (item.dataPoints.length / 5).ceilToDouble();
      if (dynamicInterval < 1) dynamicInterval = 1.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: SiwattColors.textPrimary,
              ),
            ),
            Text(
              "${item.value} ${item.unit}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: item.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
                getDrawingVerticalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35, // Increased space for Y axis labels with decimals
                     getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toStringAsFixed(1), // Show 1 decimal place
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true, // Show X axis ticks
                    interval: dynamicInterval,
                     getTitlesWidget: (value, meta) {
                       int index = value.toInt();
                       String text = '';
                       if (index >= 0 && index < item.timestamps.length) {
                         text = DateFormat('mm:ss').format(item.timestamps[index]);
                       } else if (item.dataPoints.isNotEmpty && index < item.dataPoints.length) {
                          // Fallback if timestamps are missing for some reason but data exists
                          text = index.toString(); 
                       }
                       
                       return Padding(
                         padding: const EdgeInsets.only(top: 4.0),
                         child: Text(
                             text, // Show minute:second
                             style: const TextStyle(fontSize: 10, color: Colors.grey)
                         ),
                       );
                     }
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  left: BorderSide(color: Colors.black.withOpacity(0.5)),
                  bottom: BorderSide(color: Colors.black.withOpacity(0.5)),
                ),
              ),
              minX: 0,
              maxX: item.dataPoints.isEmpty ? 10 : (item.dataPoints.length - 1).toDouble(),
              minY: item.dataPoints.isEmpty ? 0 : item.dataPoints.reduce((a, b) => a < b ? a : b) * 0.9,
              maxY: item.dataPoints.isEmpty ? 100 : item.dataPoints.reduce((a, b) => a > b ? a : b) * 1.1,
              lineBarsData: [
                LineChartBarData(
                  spots: item.dataPoints
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value))
                      .toList(),
                  isCurved: true,
                  preventCurveOverShooting: true,
                  color: item.color,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        item.color.withOpacity(0.3),
                        item.color.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedView() {
    return Stack(
      children: [
        // Content Layer
        Positioned(
          left: 0,
          top: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item.iconLetter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: SiwattColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "${item.value} ${item.unit}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: SiwattColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        
        // Chart Layer (Push to bottom right or fill bottom)
        Positioned(
          right: 0,
          bottom: 0,
          top: 20, // Start below title somewhat
          width: 150, // Limit width so it doesn't overlap text too much
          child: IgnorePointer( // Ignore touches on the small chart part
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: item.dataPoints.isEmpty ? 10 : (item.dataPoints.length - 1).toDouble(),
                minY: item.dataPoints.isEmpty ? 0 : item.dataPoints.reduce((a, b) => a < b ? a : b) * 0.9,
                maxY: item.dataPoints.isEmpty ? 100 : item.dataPoints.reduce((a, b) => a > b ? a : b) * 1.1,
                lineBarsData: [
                  LineChartBarData(
                    spots: item.dataPoints
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: item.color,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          item.color.withOpacity(0.3),
                          item.color.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
