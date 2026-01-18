import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';
import 'package:siwatt_mobile/features/auth/models/register_response_model.dart';

class RegisterController extends GetxController {
  final dio = Get.find<DioClient>().dio;
  var isLoading = false.obs;

  Future<void> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      final response = await dio.post(
        '/auth/register', 
        data: {
          'full_name': fullName,
          'username': username,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final registerResponse = RegisterResponse.fromJson(response.data);
         Get.snackbar('Sukses', registerResponse.message, backgroundColor: Colors.green, colorText: Colors.white);
         
         // Back to Login Page
         Get.offNamed('/login');
      }

    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 422) {
          // Validation error
          final errors = e.response?.data['errors'] as Map<String, dynamic>?;
          String errorMessage = 'Validation Error';
          if (errors != null) {
            errorMessage = errors.entries.map((e) => "${e.key}: ${e.value}").join('\n');
          }
           Get.snackbar('Validation Error', errorMessage, backgroundColor: Colors.orange, colorText: Colors.white);
        } else {
           final detail = e.response?.data['detail'] ?? 'Register failed';
           Get.snackbar('Error', detail, backgroundColor: Colors.red, colorText: Colors.white);
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
