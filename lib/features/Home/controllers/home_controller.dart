import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:siwatt_mobile/core/models/devices_data.dart';
import 'package:siwatt_mobile/core/models/user_model.dart';
import 'package:siwatt_mobile/core/network/api_url.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';
import 'package:siwatt_mobile/features/home/models/dashboardStats.dart';
import 'package:siwatt_mobile/features/home/models/prediction_data.dart';
import 'package:siwatt_mobile/features/main/controllers/main_controller.dart';

class HomeController extends GetxController {
  final dio = Get.find<DioClient>().dio;
  var isLoading = false.obs;
  var graphDataList = <DeviceData>[].obs;
  var selectedPeriod = 'Hari'.obs;
  var dashboardStats = Rx<DashboardStats?>(null);
  var predictionPoints = <PredictionPoint>[].obs;

  User? get user => Hive.box('userBox').get('user') as User?;
  String get userName => user?.fullName.split(' ')[0] ?? 'User';

  @override
  void onInit() {
    super.onInit();
    final mainController = Get.find<MainController>();

    // Trigger refresh when device list first loads (initial app launch race condition)
    ever(mainController.devices, (_) {
      if (mainController.currentDevice != null) {
        refreshData();
      }
    });

    // Trigger refresh when user switches device
    ever(mainController.currentDeviceIndex, (_) {
      refreshData();
    });
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      final futures = [
        fetchGraphData(period: selectedPeriod.value),
        fetchDashboardStats(),
      ];
      if (selectedPeriod.value == 'Hari') {
        futures.add(fetchPredictionData());
      }
      await Future.wait(futures);
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeGraphPeriod(String period) {
    selectedPeriod.value = period;
    if (period != 'Hari') {
      predictionPoints.clear();
    } else {
      fetchPredictionData();
    }
    fetchGraphData(period: period);
  }

  Future<void> fetchGraphData({String period = 'Hari'}) async {
    final currentDeviceID = Get.find<MainController>().currentDevice?.id;
    if (currentDeviceID == null) return;
    try {
      DateTime now = DateTime.now();
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

  Future<void> fetchDashboardStats() async {
    final currentDeviceID = Get.find<MainController>().currentDevice?.id;
    if (currentDeviceID == null) return;
    try {
      final response = await dio.get('${ApiUrl.dashboardData}?device_id=$currentDeviceID');
      if (response.statusCode == 200) {
        dashboardStats.value = DashboardStats.fromJson(response.data['data']);
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
    }
  }

  Future<void> fetchPredictionData() async {
    final currentDevice = Get.find<MainController>().currentDevice;
    if (currentDevice == null) return;
    try {
      // API membutuhkan tanggal KEMARIN sebagai parameter date
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dateStr = yesterday.toIso8601String().split('T')[0];
      final url =
          '${ApiUrl.devicePrediction}/${currentDevice.id}/prediction?type=hourly&date=$dateStr';

      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data['code'] == 200) {
        final data = PredictionData.fromJson(response.data);
        predictionPoints.value = data.predictions;
      } else {
        predictionPoints.clear();
      }
    } catch (e) {
      print('Error fetching prediction data: $e');
      predictionPoints.clear();
    }
  }
}
