import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
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
        fetchTransactions(); // Refresh list
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
      final response = await dio.get("${ApiUrl.transactions}/$deviceId/data");
      
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
        fetchTransactions();
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

  Future<void> fetchTransactions() async {
    isLoading.value = true;
    try {
      final response = await dio.get("${ApiUrl.transactions}/${Get.find<MainController>().currentDevice.value?.id ?? 1}");
      if (response.statusCode == 200) {
        // Handle the response as needed
        totalCost.value = double.tryParse(response.data['total_price'].toString()) ?? 0.0;
        totalKwh.value = double.tryParse(response.data['total_token_bought'].toString()) ?? 0.0;

        List<dynamic> data = response.data['data'];
        transactions.assignAll(data.map((item) => TokenTransaction.fromJson(item)).toList());
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    } finally {
      isLoading.value = false;
    }
  
    // Implement transaction fetching logic here
  }
}