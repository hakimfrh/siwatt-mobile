import 'package:get/get.dart';
import 'package:siwatt_mobile/core/models/devices_data.dart';
import 'package:siwatt_mobile/core/network/api_url.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';
import 'package:siwatt_mobile/features/home/models/dashboardStats.dart';

class HomeController extends GetxController {
  final dio = Get.find<DioClient>().dio;
  var isLoading = false.obs;
  var deviceData = Rx<dynamic>(null);
  var todayDataList = <DeviceData>[].obs;
  var dashboardStats = Rx<DashboardStats?>(null);

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData({int currentDeviceID = 1}) async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchTodayData(currentDeviceID: currentDeviceID),
        fetchDashboardStats(currentDeviceID: currentDeviceID),
      ]);
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTodayData({int currentDeviceID = 1}) async {
    try {
      // String todayDate = DateTime.now().toIso8601String().split('T')[0];
      String todayDate = "2025-12-15";
      final response = await dio.get('${ApiUrl.deviceData}?start_date=${todayDate}&end_date=${todayDate}&device_id=${currentDeviceID}');
      // Handle the response as needed
      if (response.statusCode == 200) {
        //  print(response.data.toString());
        final List<dynamic> data = response.data['data'];
        todayDataList.value = data.map((item) => DeviceData.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchDashboardStats({int currentDeviceID = 1}) async {
    try {
      final response = await dio.get('${ApiUrl.dashboardData}?device_id=$currentDeviceID');
      if (response.statusCode == 200) {
        dashboardStats.value = DashboardStats.fromJson(response.data['data']);
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
    }
  }
}
