import 'dart:async';
import 'package:intl/intl.dart';
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
  Timer? _timer;
  bool _showTotalKwh = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _showTotalKwh = !_showTotalKwh;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showAddTransactionModal(BuildContext context) {
    final amountController = TextEditingController();
    final priceController = TextEditingController();
    final correctionController = TextEditingController();
    final textTheme = Theme.of(context).textTheme;

    bool isTopUp = true;
    double currentKwh = Get.find<MainController>().currentDevice.value?.tokenBalance ?? 0.0;
    double? difference;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Tambah Transaksi Token',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SiwattColors.primaryDark),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setModalState(() {
                            isTopUp = true;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isTopUp ? SiwattColors.primary : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            "TopUp",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isTopUp ? SiwattColors.primary : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          setModalState(() {
                            isTopUp = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: !isTopUp ? SiwattColors.primary : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            "Edit Saldo",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: !isTopUp ? SiwattColors.primary : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AnimatedSize(
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 150),
                    reverseDuration: const Duration(milliseconds: 150),
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 100),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: isTopUp
                          ? Column(
                              key: const ValueKey('TopUp'),
                              children: [
                                TextField(
                                  controller: priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    labelText: 'Harga',
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Image.asset('assets/icons/money-in.png', width: 24, height: 24),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.blue),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: amountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    labelText: 'Jumlah Kwh',
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Image.asset('assets/icons/bolt-circle.png', width: 24, height: 24),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.transparent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              key: const ValueKey('EditSaldo'),
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  "Kwh Saat Ini",
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${currentKwh.toStringAsFixed(2)} KwH",
                                      style: textTheme.titleLarge
                                          ?.copyWith(fontWeight: FontWeight.w600, color: Colors.black),
                                    ),
                                    if (difference != null)
                                      Text(
                                        "${difference! > 0 ? '+' : ''}${difference!.toStringAsFixed(2)} KwH",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: difference! > 0 ? Colors.green : Colors.orange,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: correctionController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (val) {
                                    double? newVal = double.tryParse(val);
                                    setModalState(() {
                                      if (newVal != null) {
                                        difference = newVal - currentKwh;
                                      } else {
                                        difference = null;
                                      }
                                    });
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    labelText: 'Jumlah Kwh',
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Image.asset('assets/icons/bolt-circle.png', width: 24, height: 24),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (isTopUp) {
                        if (amountController.text.isEmpty || priceController.text.isEmpty) {
                          Get.snackbar("Error", "Mohon isi semua data", backgroundColor: Colors.red, colorText: Colors.white);
                          return;
                        }

                        // Confirmation Dialog TopUp
                        Get.defaultDialog(
                          title: "Konfirmasi",
                          middleText: "Apakah anda yakin ingin menambahkan transaksi ini?",
                          textConfirm: "Ya, Simpan",
                          textCancel: "Batal",
                          buttonColor: SiwattColors.primary,
                          confirmTextColor: Colors.white,
                          cancelTextColor: SiwattColors.primary,
                          onConfirm: () async {
                            Get.back(); // Close dialog
                            final success = await controller.addTransaction(amountController.text, priceController.text);
                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        );
                      } else {
                         if (correctionController.text.isEmpty) {
                            Get.snackbar("Error", "Mohon isi data", backgroundColor: Colors.green, colorText: Colors.white);
                            return;
                          }
                          
                          // Confirmation Dialog Edit Saldo
                          Get.defaultDialog(
                            title: "Konfirmasi",
                            middleText: "Apakah anda yakin ingin mengubah saldo menjadi ${correctionController.text} KwH?",
                            textConfirm: "Ya, Simpan",
                            textCancel: "Batal",
                            buttonColor: SiwattColors.primary,
                            confirmTextColor: Colors.white,
                            cancelTextColor: SiwattColors.primary,
                            onConfirm: () async {
                              Get.back(); // Close dialog
                              final success = await controller.correctBalance(correctionController.text);
                              if (success && context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                          );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SiwattColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: SiwattColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchTransactions();
          await controller.fetchGraphData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Riwayat Pembelian Token",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SiwattColors.primaryDark),
              ),
              const SizedBox(height: 20),
              Obx(
                () => TokenChartCard(
                  value: (Get.find<MainController>().currentDevice.value?.tokenBalance ?? 0.00).toStringAsFixed(2),
                  unit: "KwH",
                  dataPoints: controller.graphData.toList(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.filter_list, color: Colors.black, size: 20),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Text(
                        "Sebulan Terakhir :  ",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: SiwattColors.textPrimary),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        layoutBuilder: (currentChild, previousChildren) {
                          return Stack(
                            alignment: Alignment.centerLeft,
                            children: <Widget>[
                              ...previousChildren,
                              if (currentChild != null) currentChild,
                            ],
                          );
                        },
                        transitionBuilder: (child, animation) {
                          final inAnimation = Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(animation);
                          final outAnimation = Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero).animate(animation);

                          if (child.key == const ValueKey("kwh")) {
                            return ClipRect(
                              child: SlideTransition(position: _showTotalKwh ? inAnimation : outAnimation, child: child),
                            );
                          } else {
                            return ClipRect(
                              child: SlideTransition(position: !_showTotalKwh ? inAnimation : outAnimation, child: child),
                            );
                          }
                        },
                        child: _showTotalKwh
                            ? Container(
                                key: const ValueKey("kwh"),
                                child: Obx(
                                  () => Text(
                                    "+${controller.totalKwh.value.toStringAsFixed(2)} KwH",
                                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: SiwattColors.accentSuccess),
                                  ),
                                ),
                              )
                            : Container(
                                key: const ValueKey("cost"),
                                child: Obx(
                                  () => Text(
                                    NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(controller.totalCost.value),
                                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: SiwattColors.accentSuccess),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(
                () => ListView.builder(
                  itemCount: controller.transactions.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return TokenHistoryCard(item: controller.transactions[index]);
                  },
                ),
              ),
              // Padding for FAB space
              const SizedBox(height: 80),
            ],
          ),
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
