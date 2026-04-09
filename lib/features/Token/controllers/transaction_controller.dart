import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:siwatt_mobile/core/models/token_graph_data.dart';
import 'package:siwatt_mobile/core/models/token_transaction.dart';
import 'package:siwatt_mobile/core/network/api_url.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';
import 'package:siwatt_mobile/features/main/controllers/main_controller.dart';
import 'package:siwatt_mobile/features/token/models/daily_prediction_data.dart';

class TransactionController extends GetxController{
 final dio = Get.find<DioClient>().dio;
  var isLoading = false.obs;
  var transactions = <TokenTransaction>[].obs;
  var graphData = <TokenGraphData>[].obs;
  var tokenBalance = 0.0.obs;
  var totalKwh = 0.0.obs;
  var totalCost = 0.0.obs;
  // Titik prediksi saldo token untuk 7 hari ke depan
  var predictionSpots = <DailyPredictionPoint>[].obs;

  // Pagination Variables
  var currentPage = 1;
  var totalPages = 1;
  var isLoadMoreRunning = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Refresh data when device changes
    ever(Get.find<MainController>().currentDeviceIndex, (_) {
      fetchTransactions(isRefresh: true);
      fetchGraphData();
      fetchDailyPrediction();
    });

    fetchTransactions(isRefresh: true);
    fetchGraphData();
    fetchDailyPrediction();
  }

  Future<bool> addTransaction(String amountKwh, String price) async {
    try {
      final deviceId = Get.find<MainController>().currentDevice?.id;
      if (deviceId == null) {
        Get.snackbar("Error", "No device selected", backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
      
      final body = {
        "device_id": deviceId.toString(),
        "amount_kwh": amountKwh,
        "price": price
      };

      final response = await dio.post(ApiUrl.transactions, data: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Transaction added successfully", backgroundColor: Colors.green, colorText: Colors.white);
        fetchTransactions(isRefresh: true); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding transaction: $e');
      Get.snackbar("Error", "Failed to add transaction", backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }
  Future<void> fetchGraphData() async {
    try {
      final deviceId = Get.find<MainController>().currentDevice?.id ?? 1;
      
      // Calculate date 15 days ago
      final startDate = DateTime.now().subtract(const Duration(days: 15));
      final formattedDate = DateFormat('yyyy-MM-dd').format(startDate);

      final response = await dio.get("${ApiUrl.transactions}/$deviceId/data?start_date=$formattedDate");
      
      if (response.statusCode == 200) {
        tokenBalance.value = double.tryParse(response.data['token_balance'].toString()) ?? 0.0;
        List<dynamic> data = response.data['data'];
        graphData.assignAll(data.map((item) => TokenGraphData.fromJson(item)).toList());
      }
    } catch (e) {
      print('Error fetching graph data: $e');
    }
  }

  /// Fetch prediksi harian konsumsi listrik dan hitung estimasi sisa token.
  /// Menggunakan saldo akhir data aktual sebagai titik awal, lalu kurangi
  /// energy_day setiap hari prediksi. Berhenti jika saldo sudah ≤ 0.
  /// Maksimal 7 hari ke depan.
  Future<void> fetchDailyPrediction() async {
    try {
      final deviceId = Get.find<MainController>().currentDevice?.id;
      if (deviceId == null) return;

      // date parameter = hari ini
      final today = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(today);
      final url = '${ApiUrl.devicePrediction}/$deviceId/prediction?type=daily&date=$dateStr';

      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final rawPredictions =
            (response.data['data']['prediction']['predictions'] as List<dynamic>)
                .map((e) => DailyPredictionPoint.fromJson(e))
                .toList();

        // Ambil saldo akhir dari data aktual grafik
        // Jika graphData kosong gunakan tokenBalance
        double lastBalance = graphData.isNotEmpty
            ? graphData.last.balance
            : tokenBalance.value;

        // Tanggal akhir data aktual — prediksi dimulai dari hari berikutnya
        DateTime? lastActualDate = graphData.isNotEmpty ? graphData.last.datetime : null;

        // Filter prediksi: hanya hari setelah data aktual, maks 7 hari
        final lastDate = lastActualDate;
        List<DailyPredictionPoint> filtered = rawPredictions.where((p) {
          if (lastDate == null) return true;
          // Bandingkan hanya tanggal (tanpa jam)
          final d = DateTime(p.date.year, p.date.month, p.date.day);
          final last = DateTime(lastDate.year, lastDate.month, lastDate.day);
          return d.isAfter(last);
        }).take(7).toList();

        // Hitung saldo berjalan, stop saat ≤ 0
        final computed = <DailyPredictionPoint>[];
        double runningBalance = lastBalance;
        for (final p in filtered) {
          final dailyUsage = p.energyDay; // konsumsi asli dari API
          runningBalance -= dailyUsage;
          if (runningBalance <= 0) {
            // Tambahkan titik terakhir di 0 sbg batas, lalu berhenti
            computed.add(DailyPredictionPoint(date: p.date, energyDay: 0, usage: dailyUsage));
            break;
          }
          computed.add(DailyPredictionPoint(date: p.date, energyDay: runningBalance, usage: dailyUsage));
        }

        predictionSpots.assignAll(computed);
      } else {
        predictionSpots.clear();
      }
    } catch (e) {
      print('Error fetching daily prediction: $e');
      predictionSpots.clear();
    }
  }

  Future<bool> correctBalance(String finalBalance) async {
    try {
      final deviceId = Get.find<MainController>().currentDevice?.id;
      if (deviceId == null) {
        Get.snackbar("Error", "No device selected", backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }

      final body = {
        "device_id": deviceId,
        "final_balance": double.tryParse(finalBalance) ?? 0.0
      };

      final response = await dio.post(ApiUrl.correction, data: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Balance corrected successfully", backgroundColor: Colors.green, colorText: Colors.white);
        fetchTransactions(isRefresh: true);
        Get.find<MainController>().getDevices();
        return true;
      }
      return false;
    } catch (e) {
      print('Error correcting balance: $e');
      Get.snackbar("Error", "Failed to correct balance", backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }

  Future<void> fetchTransactions({bool isRefresh = false}) async {
    if (isRefresh) {
      isLoading.value = true;
      currentPage = 1;
    } else {
      if (currentPage >= totalPages || isLoadMoreRunning.value) return;
      isLoadMoreRunning.value = true;
    }

    try {
      final deviceId = Get.find<MainController>().currentDevice?.id ?? 1;
      int pageToFetch = isRefresh ? 1 : currentPage + 1;

      final response = await dio.get("${ApiUrl.transactions}/$deviceId?page=$pageToFetch");
      if (response.statusCode == 200) {
        
        // Update pagination meta
        totalPages = response.data['total_pages'] ?? 1;
        currentPage = response.data['current_page'] ?? 1;

        // Handle the response as needed
        totalCost.value = double.tryParse(response.data['total_price_30days'].toString()) ?? 0.0;
        totalKwh.value = double.tryParse(response.data['total_token_bought_30days'].toString()) ?? 0.0;

        List<dynamic> data = response.data['data'];
        final newItems = data.map((item) => TokenTransaction.fromJson(item)).toList();

        if (isRefresh) {
          transactions.assignAll(newItems);
        } else {
          transactions.addAll(newItems);
        }
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    } finally {
      isLoading.value = false;
      isLoadMoreRunning.value = false;
    }
  }
}