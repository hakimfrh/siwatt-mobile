import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/models/devices_data.dart';
import 'package:siwatt_mobile/core/network/api_url.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';
import 'package:siwatt_mobile/features/main/controllers/main_controller.dart';

class HistoryController extends GetxController {
  final dio = Get.find<DioClient>().dio;
  
  var startDate = Rx<DateTime?>(DateTime.now());
  var endDate = Rx<DateTime?>(DateTime.now());
  
  // Frequency options: hour, day, week, month
  var selectedFrequency = 'hour'.obs;
  var isLoading = false.obs;
  
  var historyDataList = <DeviceData>[].obs;
  
  // Averages
  var avgVoltage = 0.0.obs;
  var avgCurrent = 0.0.obs;
  var avgPower = 0.0.obs;
  var avgFrequency = 0.0.obs;
  var avgPf = 0.0.obs;
  
  CancelToken? _cancelToken;

  @override
  void onInit() {
    super.onInit();
    // Default range is today
    startDate.value = DateTime.now();
    endDate.value = DateTime.now();
  }

  void setDateRange(DateTime start, DateTime end) {
    // Only update time part to 00:00:00 and 23:59:59 if needed, but API likely handles date part only
    startDate.value = start;
    endDate.value = end;
    _updateDefaultFrequency();
  }

  void _updateDefaultFrequency() {
      if (startDate.value == null || endDate.value == null) return;
      
      final diff = endDate.value!.difference(startDate.value!).inDays;
      if (diff <= 3) {
          selectedFrequency.value = 'hour';
      } else if (diff <= 60) {
          selectedFrequency.value = 'day';
      } else if (diff <= 365) {
          selectedFrequency.value = 'week';
      } else {
          selectedFrequency.value = 'month';
      }
  }

  void setFrequency(String freq) {
    selectedFrequency.value = freq;
  }

  Future<void> fetchData() async {
      if (startDate.value == null || endDate.value == null) {
          Get.snackbar("Info", "Pilih rentang tanggal terlebih dahulu");
          return;
      }
      
      // Check for potential large data
      int days = endDate.value!.difference(startDate.value!).inDays + 1;
      bool needsConfirm = false;
      
      // Rough estimation logic
      if ((selectedFrequency.value == 'hour' && days > 7) || // > 168 points
          (selectedFrequency.value == 'day' && days > 100)) { // > 100 points
          needsConfirm = true;
      }

      if (needsConfirm) {
         final confirm = await Get.dialog<bool>(
            AlertDialog(
              title: const Text("Konfirmasi"),
              content: const Text("Rentang data yang diminta cukup besar. Proses mungkin memakan waktu. Lanjutkan?"),
              actions: [
                TextButton(onPressed: () => Get.back(result: false), child: const Text("Batal")),
                TextButton(onPressed: () => Get.back(result: true), child: const Text("Lanjut")),
              ],
            )
         );
         if (confirm != true) return;
      }

      isLoading.value = true;
      _cancelToken = CancelToken();
      
      try {
        final currentDeviceID = Get.find<MainController>().currentDevice.value?.id ?? 1;
        final startStr = startDate.value!.toIso8601String().split('T')[0];
        final endStr = endDate.value!.toIso8601String().split('T')[0];
        
        final response = await dio.get(
          ApiUrl.deviceData,
          queryParameters: {
            'start_date': startStr,
            'end_date': endStr,
            'device_id': currentDeviceID,
            'get_average': 'True',
            'limit': -1,
            'frequency': selectedFrequency.value,
          },
          cancelToken: _cancelToken,
        );

        if (response.statusCode == 200) {
          final data = response.data;
          
          // Update Averages
          avgVoltage.value = (data['avg_voltage'] ?? 0.0).toDouble();
          avgCurrent.value = (data['avg_current'] ?? 0.0).toDouble();
          avgPower.value = (data['avg_power'] ?? 0.0).toDouble();
          avgFrequency.value = (data['avg_frequency'] ?? 0.0).toDouble();
          avgPf.value = (data['avg_pf'] ?? 0.0).toDouble() * 100; // Assuming PF is 0-1, converting to % for display as per UI? 
          // Wait, UI sample says "Tegangan 89.82 %" which has yellow color. Wait, looking at image text vs code. 
          // Code says: UsageStatModel(title: "Tegangan", value: "89.82", unit: "%"...
          // That's likely a copy paste error in the user's provided snippet. Usually PF is unitless or %.
          // Let's assume the 3rd card is PF.
          
          final List<dynamic> list = data['data'];
          historyDataList.value = list.map((item) => DeviceData.fromJson(item)).toList();
        }
      } catch (e) {
        if (e is DioException && CancelToken.isCancel(e)) {
           // Cancelled
        } else {
           print("Error fetching history: $e");
           Get.snackbar("Error", "Gagal mengambil data history");
        }
      } finally {
        isLoading.value = false;
        _cancelToken = null;
      }
  }

  void cancelRequest() {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel();
    }
  }
}
