import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';

class HistoryChartCard extends StatefulWidget {
  const HistoryChartCard({super.key});

  @override
  State<HistoryChartCard> createState() => _HistoryChartCardState();
}

class _HistoryChartCardState extends State<HistoryChartCard> {
  int _selectedTabIndex = 0; // 0: Hari, 1: Minggu, 2: Bulan
  String _selectedFilter = "Energi"; // Default selected filter
  final List<String> _filters = [
    "Tegangan",
    "Arus",
    "Daya",
    "Energi",
    "Faktor Daya",
    "Freq"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Tabs and Date Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildTabItem(0, "Hari"),
                  const SizedBox(width: 16),
                  _buildTabItem(1, "Minggu"),
                  const SizedBox(width: 16),
                  _buildTabItem(2, "Bulan"),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1), // Light teal bg
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_drop_down, size: 18, color: Colors.black87),
                    SizedBox(width: 4),
                    Text(
                      "23/02/2024",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(thickness: 1, height: 24),

          // Chart
          SizedBox(
            height: 200,
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
                    color: Colors.black, // Darker vertical ticks like image
                    strokeWidth: 1,
                  ),
                  horizontalInterval: 1,
                  verticalInterval: 1,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      interval: 1,
                      getTitlesWidget: (value, meta) =>
                          const Text("", style: TextStyle(fontSize: 0)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) =>
                          const Text("", style: TextStyle(fontSize: 0)),
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Colors.black),
                    bottom: BorderSide(color: Colors.black),
                  ),
                ),
                minX: 0,
                maxX: 30, // Approx
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateDummyData(),
                    isCurved: true,
                    color: const Color(0xFF2A9D8F), // Teal
                    barWidth: 0, // Fill only, no line stroke visible in image usually or very thin
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF2A9D8F).withOpacity(0.8),
                          const Color(0xFF2A9D8F).withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2A9D8F) // Selected Teal
                            : const Color(0xFFE0F2F1), // Unselected Light Teal
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? Colors.white : Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? Colors.black87
                  : SiwattColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 2,
              width: 20,
              color: const Color(0xFF2A9D8F),
            ),
        ],
      ),
    );
  }

  List<FlSpot> _generateDummyData() {
    // Generate a curve similar to the image
    return [
      const FlSpot(0, 4),
      const FlSpot(2, 4.5),
      const FlSpot(5, 5.5),
      const FlSpot(8, 5.0),
      const FlSpot(12, 4.2),
      const FlSpot(15, 4.3),
      const FlSpot(18, 4.2),
      const FlSpot(22, 4.5),
      const FlSpot(26, 5.2),
      const FlSpot(28, 5.5),
      const FlSpot(30, 4.8),
    ];
  }
}
