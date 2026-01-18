import 'package:flutter/material.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/token/models/token_transaction_model.dart';
import 'package:siwatt_mobile/features/token/widgets/token_chart_card.dart';
import 'package:siwatt_mobile/features/token/widgets/token_history_card.dart';

class TokenPage extends StatelessWidget {
  const TokenPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final List<TokenTransactionModel> transactions = List.generate(
      5,
      (index) => TokenTransactionModel(
        date: "27/06/2025",
        time: "19:20",
        price: "Rp. 50.000,00",
        kwh: "28,70",
      ),
    );

    final List<double> chartData = [
      220, 222, 225, 228, 230, 225, 220, 218, 219, 220, 222, 224, 226, 228, 225, 220
    ];

    return Scaffold(
      backgroundColor: SiwattColors.background,
      appBar: AppBar(
        backgroundColor: SiwattColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          "SiWatt",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Riwayat Pembelian Token",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: SiwattColors.primaryDark,
              ),
            ),
            const SizedBox(height: 20),
            TokenChartCard(
              value: "228,48",
              unit: "KwH",
              dataPoints: chartData,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.filter_list, color: Colors.black, size: 20),
                const SizedBox(width: 8),
                const Text(
                  "Sebulan Terakhir (Total 28,70 KwH)",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: SiwattColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              itemCount: transactions.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return TokenHistoryCard(item: transactions[index]);
              },
            ),
            // Padding for FAB space
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: SiwattColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
