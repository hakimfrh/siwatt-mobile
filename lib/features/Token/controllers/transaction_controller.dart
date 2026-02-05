import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:siwatt_mobile/core/models/token_graph_data.dart';
import 'package:siwatt_mobile/core/models/token_transaction.dart';
import 'package:siwatt_mobile/core/network/api_url.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';
import 'package:siwatt_mobile/features/main/controllers/main_controller.dart';

class TransactionController extends GetxController{
 final dio = Get.find<DioClient>().dio;
  var isLoading = false.obs;
  var transactions = <TokenTransaction>[].obs;
  var graphData = <TokenGraphData>[].obs;
  var totalKwh = 0.0.obs;
  var totalCost = 0.0.obs;

  // Pagination Variables
  var currentPage = 1;
  var totalPages = 1;
  var isLoadMoreRunning = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Refresh data when device changes
    ever(Get.find<MainController>().currentDevice, (_) {
      fetchTransactions(isRefresh: true);
      fetchGraphData();
    });

    fetchTransactions(isRefresh: true);
    fetchGraphData();
  }

  Future<bool> addTransaction(String amountKwh, String price) async {
    try {
      final deviceId = Get.find<MainController>().currentDevice.value?.id;
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
      final deviceId = Get.find<MainController>().currentDevice.value?.id ?? 1;
      
      // Calculate date 15 days ago
      final startDate = DateTime.now().subtract(const Duration(days: 15));
      final formattedDate = DateFormat('yyyy-MM-dd').format(startDate);

      final response = await dio.get("${ApiUrl.transactions}/$deviceId/data?start_date=$formattedDate");
      
      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'];
        graphData.assignAll(data.map((item) => TokenGraphData.fromJson(item)).toList());
      }
    } catch (e) {
      print('Error fetching graph data: $e');
    }
  }

  Future<bool> correctBalance(String finalBalance) async {
    try {
      final deviceId = Get.find<MainController>().currentDevice.value?.id;
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
      final deviceId = Get.find<MainController>().currentDevice.value?.id ?? 1;
      int pageToFetch = isRefresh ? 1 : currentPage + 1;

      final response = await dio.get("${ApiUrl.transactions}/$deviceId?page=$pageToFetch");
      if (response.statusCode == 200) {
        
        // Update pagination meta
        totalPages = response.data['total_pages'] ?? 1;
        currentPage = response.data['current_page'] ?? 1;

        // Handle the response as needed
        totalCost.value = double.tryParse(response.data['total_price'].toString()) ?? 0.0;
        totalKwh.value = double.tryParse(response.data['total_token_bought'].toString()) ?? 0.0;

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