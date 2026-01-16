import 'package:flutter/material.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedPeriod = 'Hari Ini';
  String _selectedMetric = 'Energi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("SiWatt", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        backgroundColor: SiwattColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selamat Pagi, Budi !",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: SiwattColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            // Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SiwattColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: SiwattColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/icons/dashboard_card/Bolt.png',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Rata rata penggunaan Hari Ini",
                              style: TextStyle(fontSize: 12, color: SiwattColors.textPrimary),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "520,88 W",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: SiwattColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/icons/dashboard_card/Home.png',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sisa token saat ini",
                              style: TextStyle(fontSize: 12, color: SiwattColors.textPrimary),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "12,63 KwH",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: SiwattColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: SiwattColors.accentInfo,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/icons/dashboard_card/Time.png',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Perkiraan masa pakai",
                              style: TextStyle(fontSize: 12, color: SiwattColors.textPrimary),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "28 Hari Lagi",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: SiwattColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.black12),
                  const SizedBox(height: 8),
                  const Text(
                    "Perhitungan Perkiraan Masa pakai menggunakan Metode LSTM.\nHasil Perhitungan Hanya Sebagai Perkiraan.",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 10, color: SiwattColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Graph Section
            const Text(
              "Grafik penggunaan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: SiwattColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
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
                  Row(
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: SiwattColors.primarySoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_drop_down, size: 18),
                            Text(
                              _selectedPeriod,
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
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          drawHorizontalLine: true,
                          verticalInterval: 1,
                          horizontalInterval: 1,
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
                              reservedSize: 10,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                if (value % 1 == 0) {
                                  return Container(
                                    height: 4,
                                    width: 1,
                                    color: Colors.black,
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 10,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: 1,
                                      width: 4,
                                      color: Colors.black,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ), 
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            left: BorderSide(color: Colors.black, width: 1),
                            bottom: BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        minX: 0,
                        maxX: 16,
                        minY: 0,
                        maxY: 6,
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: SiwattColors.primary,
                            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                              return touchedBarSpots.map((barSpot) {
                                return LineTooltipItem(
                                  barSpot.y.toString(),
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
                            spots: const [
                              FlSpot(0, 1.2),
                              FlSpot(1, 1.3),
                              FlSpot(2, 1.5),
                              FlSpot(3, 1.8),
                              FlSpot(4, 2.5),
                              FlSpot(5, 4.5), // Peak
                              FlSpot(6, 3.8),
                              FlSpot(7, 3.0),
                              FlSpot(8, 2.7),
                              FlSpot(9, 2.5),
                              FlSpot(10, 2.3),
                              FlSpot(11, 2.2),
                            ],
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
                          LineChartBarData(
                            spots: const [
                              FlSpot(11, 2.2),
                              FlSpot(12, 2.8),
                              FlSpot(13, 1.5),
                              FlSpot(14, 3.2),
                              FlSpot(15, 1.2),
                              FlSpot(16, 1.8),
                            ],
                            isCurved: true,
                            color: Colors.grey,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            dashArray: [5, 5],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildMetricChip("Tegangan"),
                        _buildMetricChip("Arus"),
                        _buildMetricChip("Daya"),
                        _buildMetricChip("Energi", isActive: true),
                        _buildMetricChip("Faktor Daya"),
                        _buildMetricChip("Freq"),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
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

  Widget _buildMetricChip(String text, {bool isActive = false}) {
    return Container(
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
    );
  }
}
