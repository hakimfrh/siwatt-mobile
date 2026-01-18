import 'package:get/get.dart';
import 'package:siwatt_mobile/core/models/devices.dart';
import 'package:siwatt_mobile/core/network/api_url.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';

class MainController extends GetxController {
  final dio = Get.find<DioClient>().dio;
  var currentIndex = 0.obs;
  var devices = <Device>[].obs;
  var currentDevice = Rx<Device?>(null);

  @override
  void onInit() {
    super.onInit();
    getDevices();
  }

  void changePage(int index) {
    currentIndex.value = index;
  }

  void changeDevice(Device device) {
    currentDevice.value = device;
  }

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
      }
    } catch (e) {
      print('Error fetching device list $e');
    }
  }
}
