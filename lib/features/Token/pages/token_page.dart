import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/main/controllers/main_controller.dart';
import 'package:siwatt_mobile/features/token/controllers/transaction_controller.dart';
import 'package:siwatt_mobile/features/token/widgets/token_chart_card.dart';
import 'package:siwatt_mobile/features/token/widgets/token_history_card.dart';

class TokenPage extends StatefulWidget {
  const TokenPage({super.key});

  @override
  State<TokenPage> createState() => _TokenPageState();
}

class _TokenPageState extends State<TokenPage> {
  final TransactionController controller = Get.put(TransactionController());

  void _showAddTransactionModal(BuildContext context) {
    final amountController = TextEditingController();
    final priceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tambah Transaksi Token',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: SiwattColors.primaryDark,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Jumlah Kwh',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga (Rp)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                   if (amountController.text.isEmpty || priceController.text.isEmpty) {
                    Get.snackbar("Error", "Mohon isi semua data");
                    return;
                  }
                  
                  // Confirmation Dialog
                  Get.defaultDialog(
                    title: "Konfirmasi",
                    middleText: "Apakah anda yakin ingin menambahkan transaksi ini?",
                    textConfirm: "Ya, Simpan",
                    textCancel: "Batal",
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      Get.back(); // Close dialog
                      controller.addTransaction(
                        amountController.text,
                        priceController.text,
                      );
                      // implemented in controller: Get.back(); // Close modal on success
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SiwattColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Simpan', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final List<double> chartData = [
      220, 222, 225, 228, 230, 225, 220, 218, 219, 220, 222, 224, 226, 228, 225, 220
    ];

    return Scaffold(
      backgroundColor: SiwattColors.background,
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
              value: (Get.find<MainController>().currentDevice.value?.tokenBalance ?? 0.00).toStringAsFixed(2),
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
            Obx(() => ListView.builder(
              itemCount: controller.transactions.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return TokenHistoryCard(item: controller.transactions[index]);
              },
            )),
            // Padding for FAB space
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionModal(context),
        backgroundColor: SiwattColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
