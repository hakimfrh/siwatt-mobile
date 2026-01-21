import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:siwatt_mobile/core/models/devices_data.dart';
import 'package:siwatt_mobile/core/models/user_model.dart';
import 'package:siwatt_mobile/core/network/api_url.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';
import 'package:siwatt_mobile/features/home/models/dashboardStats.dart';
import 'package:siwatt_mobile/features/main/controllers/main_controller.dart';

class HomeController extends GetxController {
  final dio = Get.find<DioClient>().dio;
  var isLoading = false.obs;
  var graphDataList = <DeviceData>[].obs;
  var selectedPeriod = 'Hari'.obs;
  var dashboardStats = Rx<DashboardStats?>(null);

  User? get user => Hive.box('userBox').get('user') as User?;
  String get userName => user?.fullName.split(' ')[0] ?? 'User';

  @override
  void onInit() {
    super.onInit();
    refreshData(currentDeviceID: Get.find<MainController>().currentDevice.value?.id ?? 1);
  }

  Future<void> refreshData({int currentDeviceID = 1}) async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchGraphData(period: selectedPeriod.value, currentDeviceID: currentDeviceID),
        fetchDashboardStats(currentDeviceID: currentDeviceID),
      ]);
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeGraphPeriod(String period) {
    selectedPeriod.value = period;
    fetchGraphData(period: period, currentDeviceID: Get.find<MainController>().currentDevice.value?.id ?? 1);
  }

  Future<void> fetchGraphData({String period = 'Hari', int currentDeviceID = 1}) async {
    try {
      DateTime now = DateTime(2025,12,15);
      String endDate = now.toIso8601String().split('T')[0];
      String startDate = endDate;
      String frequency = 'hour';
      int? limit;

      if (period == 'Minggu') {
        startDate = now.subtract(const Duration(days: 7)).toIso8601String().split('T')[0];
        frequency = 'day';
        limit = -1;
      } else if (period == 'Bulan') {
        startDate = now.subtract(const Duration(days: 30)).toIso8601String().split('T')[0];
        frequency = 'day';
        limit = -1;
      }

      String url = '${ApiUrl.deviceData}?start_date=$startDate&end_date=$endDate&device_id=$currentDeviceID&frequency=$frequency';
      if (limit != null) {
        url += '&limit=$limit';
      }

      final response = await dio.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        graphDataList.value = data.map((item) => DeviceData.fromJson(item)).toList();
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
