import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:siwatt_mobile/core/models/devices.dart';
import 'package:siwatt_mobile/core/models/user_model.dart';
import 'package:siwatt_mobile/core/network/api_url.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';

class MainController extends GetxController {
  final dio = Get.find<DioClient>().dio;
  var currentIndex = 0.obs;
  var devices = <Device>[].obs;
  var currentDevice = Rx<Device?>(null);

  User? get user => Hive.box('userBox').get('user') as User?;

  @override
  void onInit() {
    super.onInit();
    // Check arguments
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args.containsKey('device_id')) {
        pendingDeviceId = int.tryParse(args['device_id'].toString());
      }
    }
    getDevices();
  }

  void changePage(int index) {
    currentIndex.value = index;
  }

  void changeDevice(Device device) {
    currentDevice.value = device;
    update(); // Notify GetBuilder if any
  }

  Future<void> refreshDevices() async {
    await getDevices();
  }

  int? pendingDeviceId;

  Future<void> getDevices() async {
    try {
      final response = await dio.get(ApiUrl.devices);
      if (response.statusCode == 200) {
        // print('Devices: ${response.data}');
        final List<dynamic> data = response.data['data'];
        final deviceList = data.map((item) => Device.fromJson(item)).toList();
        devices.assignAll(deviceList);

        if (devices.isNotEmpty && currentDevice.value == null) {
          currentDevice.value = devices.first;
        }

        if (pendingDeviceId != null) {
          switchToDevice(pendingDeviceId!);
          pendingDeviceId = null;
        }
      }
    } catch (e) {
      print('Error fetching device list $e');
    }
  }

  void switchToDevice(int deviceId) {
    print('Switching to device ID: $deviceId');
    if (devices.isEmpty) {
      pendingDeviceId = deviceId;
      return;
    }

    final device = devices.firstWhereOrNull((d) => d.id == deviceId);
    if (device != null) {
      changeDevice(device);
      changePage(0);
      
      // Only navigate if not already on the main route
      if (Get.currentRoute != '/main') {
        Get.offNamedUntil('/main', (route) => false);
      }
    } else {
      print('Device with ID $deviceId not found');
    }
  }
}
