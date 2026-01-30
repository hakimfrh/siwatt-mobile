import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:siwatt_mobile/core/network/api_url.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/auth/models/login_response_model.dart';
// Import user model

class LoginController extends GetxController {
  final dio = Get.find<DioClient>().dio;
  final _storage = const FlutterSecureStorage();
  
  var isLoading = false.obs;

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final response = await dio.post(
        ApiUrl.login, 
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        if (loginResponse.data != null) {
          // Simpan token ke SecureStorage
          await _storage.write(key: 'token', value: loginResponse.data!.apiToken);
          
          // Simpan user ke Hive
          var userBox = Hive.box('userBox');
          await userBox.put('user', loginResponse.data!.user);

          Get.snackbar('Sukses', loginResponse.message, backgroundColor: SiwattColors.accentSuccess, colorText: Colors.white);
          
          // Navigate to Dashboard
          Get.offAllNamed('/main'); 
        }
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 400) {
          // Invalid credentials
          final detail = e.response?.data['detail'] ?? 'Login failed';
          Get.snackbar('Error', detail, backgroundColor: SiwattColors.accentDanger, colorText: Colors.white);
        } else if (e.response?.statusCode == 422) {
          // Validation error
          final errors = e.response?.data['errors'] as Map<String, dynamic>?;
          String errorMessage = 'Validation Error';
          if (errors != null) {
            errorMessage = errors.entries.map((e) => "${e.key}: ${e.value}").join('\n');
          }
          Get.snackbar('Validation Error', errorMessage, backgroundColor: SiwattColors.accentWarning, colorText: Colors.white);
        } else {
           Get.snackbar('Error', 'Terjadi kesalahan: ${e.response?.statusCode}', backgroundColor: SiwattColors.accentDanger, colorText: Colors.white);
        }
      } else {
        Get.snackbar('Error', 'Koneksi gagal', backgroundColor: SiwattColors.accentDanger, colorText: Colors.white);
      }
    } catch (e) {
       print(e);
       Get.snackbar('Error', 'Terjadi kesalahan tidak terduga', backgroundColor: SiwattColors.accentDanger, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    // Hapus token dari SecureStorage
    await _storage.delete(key: 'token');
    
    // Hapus user dari Hive
    var userBox = Hive.box('userBox');
    await userBox.clear();
    
    Get.offAllNamed('/login');
  }
}
