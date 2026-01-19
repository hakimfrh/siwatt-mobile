import 'package:get/get.dart';
import 'package:siwatt_mobile/core/models/token_transaction.dart';
import 'package:siwatt_mobile/core/network/api_url.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';
import 'package:siwatt_mobile/features/main/controllers/main_controller.dart';

class TransactionController extends GetxController{
 final dio = Get.find<DioClient>().dio;
  var isLoading = false.obs;
  var transactions = <TokenTransaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> addTransaction(String amountKwh, String price) async {
    try {
      final deviceId = Get.find<MainController>().currentDevice.value?.id;
      if (deviceId == null) {
        Get.snackbar("Error", "No device selected");
        return;
      }
      
      final body = {
        "device_id": deviceId.toString(),
        "amount_kwh": amountKwh,
        "price": price
      };

      final response = await dio.post(ApiUrl.transactions, data: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Transaction added successfully");
        fetchTransactions(); // Refresh list
        Get.back(); // Close modal being confident (though usually do this in UI)
      }
    } catch (e) {
      print('Error adding transaction: $e');
      Get.snackbar("Error", "Failed to add transaction");
    }
  }

  Future<void> fetchTransactions() async {
    isLoading.value = true;
    try {
      final response = await dio.get("${ApiUrl.transactions}/${Get.find<MainController>().currentDevice.value?.id ?? 1}");
      if (response.statusCode == 200) {
        // Handle the response as needed
        print('Transactions: ${response.data}');
        //Transactions: {code: 200, message: Token transactions retrieved, data_length: 2, total_data: 2, total_pages: 1, current_page: 1, data_per_page: 10, data: [{id: 1, device_id: 1, amount_kwh: 12.6000, price: 50000.00, created_at: 2026-01-10T08:38:49}, {id: 2, device_id: 1, amount_kwh: 8.6000, price: 25000.00, created_at: 2026-01-10T08:39:14}]}
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