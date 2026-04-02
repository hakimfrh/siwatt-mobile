import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/network/api_url.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/auth/models/lupa_password_model.dart';

class LupaPasswordController extends GetxController {
  final dio = Get.find<DioClient>().dio;

  var isLoading = false.obs;

  // State yang disimpan antar step
  int? otpId;
  String? savedEmail;
  String? savedOtpCode;

  /// Step 1 — Kirim OTP ke email user
  /// Return [true] jika sukses (untuk navigasi ke step berikutnya)
  Future<bool> sendOtp(String email) async {
    isLoading.value = true;
    try {
      final response = await dio.post(ApiUrl.sendOtp, data: {'email': email});

      if (response.statusCode == 200) {
        final result = SendOtpResponse.fromJson(response.data);
        otpId = result.data?.otpId;
        savedEmail = email;
        Get.snackbar(
          'Sukses',
          result.message,
          backgroundColor: SiwattColors.accentSuccess,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final detail = e.response?.data['detail'] ?? e.response?.data['message'];

      if (statusCode == 404) {
        Get.snackbar(
          'Email tidak ditemukan',
          detail ?? 'Email tidak terdaftar di sistem',
          backgroundColor: SiwattColors.accentDanger,
          colorText: Colors.white,
        );
      } else if (statusCode == 429) {
        Get.snackbar(
          'OTP Masih Aktif',
          detail ?? 'Masih ada OTP aktif, tunggu hingga expired dulu',
          backgroundColor: SiwattColors.accentWarning,
          colorText: Colors.white,
        );
      } else if (statusCode == 500) {
        Get.snackbar(
          'Gagal Kirim Email',
          detail ?? 'Gagal mengirim email, coba lagi nanti',
          backgroundColor: SiwattColors.accentDanger,
          colorText: Colors.white,
        );
      } else if (e.response != null) {
        Get.snackbar(
          'Error',
          detail ?? 'Terjadi kesalahan: $statusCode',
          backgroundColor: SiwattColors.accentDanger,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Koneksi gagal',
          backgroundColor: SiwattColors.accentDanger,
          colorText: Colors.white,
        );
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan tidak terduga',
        backgroundColor: SiwattColors.accentDanger,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 2 — Verifikasi OTP
  /// Return [true] jika OTP valid (untuk navigasi ke step berikutnya)
  Future<bool> verifyOtp(String otpCode) async {
    if (savedEmail == null || otpId == null) {
      Get.snackbar(
        'Error',
        'Sesi tidak valid, mulai ulang dari awal',
        backgroundColor: SiwattColors.accentDanger,
        colorText: Colors.white,
      );
      return false;
    }

    isLoading.value = true;
    try {
      final response = await dio.post(ApiUrl.verifyOtp, data: {
        'email': savedEmail,
        'otp_id': otpId,
        'otp_code': otpCode,
      });

      if (response.statusCode == 200) {
        final result = VerifyOtpResponse.fromJson(response.data);
        if (result.data?.isValid == true) {
          savedOtpCode = otpCode;
          return true;
        } else {
          Get.snackbar(
            'OTP Tidak Valid',
            'Kode OTP yang kamu masukkan salah',
            backgroundColor: SiwattColors.accentDanger,
            colorText: Colors.white,
          );
          return false;
        }
      }
      return false;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final detail = e.response?.data['detail'] ?? e.response?.data['message'];

      if (statusCode == 400) {
        Get.snackbar(
          'OTP Tidak Valid',
          detail ?? 'OTP salah, tidak ditemukan, atau sudah digunakan',
          backgroundColor: SiwattColors.accentDanger,
          colorText: Colors.white,
        );
      } else if (e.response != null) {
        Get.snackbar(
          'Error',
          detail ?? 'Terjadi kesalahan: $statusCode',
          backgroundColor: SiwattColors.accentDanger,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Koneksi gagal',
          backgroundColor: SiwattColors.accentDanger,
          colorText: Colors.white,
        );
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan tidak terduga',
        backgroundColor: SiwattColors.accentDanger,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 3 — Reset password baru
  /// Return [true] jika password berhasil direset
  Future<bool> resetPassword(String newPassword) async {
    if (savedEmail == null || otpId == null || savedOtpCode == null) {
      Get.snackbar(
        'Error',
        'Sesi tidak valid, mulai ulang dari awal',
        backgroundColor: SiwattColors.accentDanger,
        colorText: Colors.white,
      );
      return false;
    }

    isLoading.value = true;
    try {
      final response = await dio.post(ApiUrl.resetPassword, data: {
        'email': savedEmail,
        'otp_id': otpId,
        'otp_code': savedOtpCode,
        'new_password': newPassword,
      });

      if (response.statusCode == 200) {
        final result = ResetPasswordResponse.fromJson(response.data);
        Get.snackbar(
          'Sukses',
          result.message,
          backgroundColor: SiwattColors.accentSuccess,
          colorText: Colors.white,
        );
        return true;
      }
      return false;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final detail = e.response?.data['detail'] ?? e.response?.data['message'];

      if (statusCode == 400) {
        Get.snackbar(
          'Error',
          detail ?? 'OTP sudah tidak valid atau kadaluarsa',
          backgroundColor: SiwattColors.accentDanger,
          colorText: Colors.white,
        );
      } else if (e.response != null) {
        Get.snackbar(
          'Error',
          detail ?? 'Terjadi kesalahan: $statusCode',
          backgroundColor: SiwattColors.accentDanger,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Koneksi gagal',
          backgroundColor: SiwattColors.accentDanger,
          colorText: Colors.white,
        );
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan tidak terduga',
        backgroundColor: SiwattColors.accentDanger,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
