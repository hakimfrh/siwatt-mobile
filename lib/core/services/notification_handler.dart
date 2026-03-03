import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/features/main/controllers/main_controller.dart';

/// Handler untuk navigasi dari notification
class NotificationHandler {
  /// Handle navigation berdasarkan data dari notification
  static Future<void> handleNavigation(Map<String, dynamic> data) async {
    debugPrint('🚀 Handling Notification Navigation: $data');
    
    if (data['type'] == 'low-credit' && data['device_id'] != null) {
      try {
        // Tunggu sebentar agar UI thread siap (terutama dari background resume)
        await Future.delayed(const Duration(milliseconds: 500)); 

        int? deviceId = int.tryParse(data['device_id'].toString());
        if (deviceId != null) {
          bool handled = false;
          
          // Try to use existing MainController if available
          try {
            if (Get.isRegistered<MainController>()) {
              debugPrint('✅ MainController found, switching device...');
              Get.find<MainController>().switchToDevice(deviceId);
              handled = true;
            }
          } catch (e) {
            debugPrint('⚠️ MainController check error: $e');
          }

          // If controller not found, navigate to main page with arguments
          if (!handled) {
            debugPrint('🔄 MainController NOT found, navigating to /main with arguments...');
            Get.offAllNamed('/main', arguments: {'device_id': deviceId});
          }
        } else {
          debugPrint('❌ Invalid Device ID format');
        }
      } catch (e) {
        debugPrint('❌ Error handling notification navigation: $e');
      }
    } else {
      debugPrint('⚠️ Notification data skipped (type mismatch or no device_id)');
    }
  }
}
