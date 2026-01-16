import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:siwatt_mobile/core/network/api_url.dart';

class DioClient extends GetxService {
  late Dio dio;
  final storage = const FlutterSecureStorage();
  

  Future<DioClient> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiUrl.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ambil token dari secure storage
          String? token = await storage.read(key: 'token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
           
           // Header tambahan jika diperlukan
           options.headers['Accept'] = 'application/json';

           return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle global error di sini
          print("Dio Error: ${e.message}");
          if (e.response?.statusCode == 401) {
            // Contoh handling jika token expired (Logout user / Refresh Token)
            Get.offAllNamed('/login');
            print("Unauthorized! Redirecting to login.");
          }
          return handler.next(e);
        },
        onResponse: (response, handler) {
           // Bisa log response data di sini
           return handler.next(response);
        }
      ),
    );
    
    return this;
  }
}
