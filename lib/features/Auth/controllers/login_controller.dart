import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:siwatt_mobile/core/network/api_url.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';
import 'package:siwatt_mobile/features/Auth/models/login_response_model.dart';
import 'dart:convert';

class LoginController extends GetxController {
  final dio = Get.find<DioClient>().dio;
  final storage = const FlutterSecureStorage();
  
  var isLoading = false.obs;

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final response = await dio.post(
        ApiUrl.login, // Sesuaikan endpoint jika berbeda
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        if (loginResponse.data != null) {
          // Simpan token
          await storage.write(key: 'token', value: loginResponse.data!.apiToken);
          await storage.write(key: 'user', value: jsonEncode(loginResponse.data!.user.toJson()));

          Get.snackbar('Sukses', loginResponse.message, backgroundColor: Colors.green, colorText: Colors.white);
          
          // Navigate to Dashboard
          Get.offAllNamed('/main'); 
        }
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 400) {
          // Invalid credentials
          final detail = e.response?.data['detail'] ?? 'Login failed';
          Get.snackbar('Error', detail, backgroundColor: Colors.red, colorText: Colors.white);
        } else if (e.response?.statusCode == 422) {
          // Validation error
          final errors = e.response?.data['errors'] as Map<String, dynamic>?;
          String errorMessage = 'Validation Error';
          if (errors != null) {
            errorMessage = errors.entries.map((e) => "${e.key}: ${e.value}").join('\n');
          }
          Get.snackbar('Validation Error', errorMessage, backgroundColor: Colors.orange, colorText: Colors.white);
        } else {
           Get.snackbar('Error', 'Terjadi kesalahan: ${e.response?.statusCode}', backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        Get.snackbar('Error', 'Koneksi gagal', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
       Get.snackbar('Error', 'Terjadi kesalahan tidak terduga', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
