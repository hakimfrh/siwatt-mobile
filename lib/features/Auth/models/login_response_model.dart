import 'package:siwatt_mobile/core/models/user_model.dart';

class LoginResponse {
  final int code;
  final String message;
  final LoginData? data;

  LoginResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }
}

class LoginData {
  final User user;
  final String apiToken;

  LoginData({
    required this.user,
    required this.apiToken,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      user: User.fromJson(json['user']),
      apiToken: json['api_token'],
    );
  }
}
