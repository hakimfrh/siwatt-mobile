import 'dart:async';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/models/realtime_device_data.dart';
import 'package:siwatt_mobile/core/network/api_url.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';

class RealtimeDeviceController extends GetxController {
  final int deviceId;
  RealtimeDeviceController(this.deviceId);

  final isLoading = true.obs;
  final realtimeData = Rxn<RealtimeDeviceData>();
  Timer? _timer;
  final DioClient _dioClient = Get.find<DioClient>();

  @override
  void onInit() {
    super.onInit();
    fetchRealtimeData();
    // Refresh every 5 seconds for realtime effect
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => fetchRealtimeData(isBackground: true));
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> fetchRealtimeData({bool isBackground = false}) async {
    if (!isBackground) isLoading.value = true;
    try {
      final response = await _dioClient.dio.get('${ApiUrl.devices}/$deviceId/realtime');
      if (response.statusCode == 200 && response.data['code'] == 200) {
        realtimeData.value = RealtimeDeviceData.fromJson(response.data['data']);
      }
    } catch (e) {
      if (!isBackground) {
        // Only log errors, don't show snackbar to avoid spamming 
        print("Error fetching realtime data: $e");
      }
    } finally {
      if (!isBackground) isLoading.value = false;
    }
  }

  String get formattedUptime {
    if (realtimeData.value == null) return "-";
    int seconds = realtimeData.value!.upTime;
    
    final days = seconds ~/ 86400;
    seconds %= 86400;
    final hours = seconds ~/ 3600;
    seconds %= 3600;
    final minutes = seconds ~/ 60;
    
    List<String> parts = [];
    if (days > 0) parts.add("$days Hari");
    if (hours > 0) parts.add("$hours Jam");
    if (days == 0 && hours == 0) parts.add("$minutes Menit");
    
    return parts.join(" ");
  }

  String get lastUpdateFormatted {
    if (realtimeData.value == null) return "-";
    final diff = DateTime.now().difference(realtimeData.value!.updatedAt);
    if (diff.inSeconds < 60) return "${diff.inSeconds} detik yang lalu";
    if (diff.inMinutes < 60) return "${diff.inMinutes} menit yang lalu";
    return "${diff.inHours} jam yang lalu";
  }
}
