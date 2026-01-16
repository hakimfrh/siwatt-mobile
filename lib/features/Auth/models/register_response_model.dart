import 'package:siwatt_mobile/core/models/user_model.dart';

class RegisterResponse {
  final int code;
  final String message;
  final RegisterData? data;

  RegisterResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? RegisterData.fromJson(json['data']) : null,
    );
  }
}

class RegisterData {
  final User user;
  final String? apiToken;

  RegisterData({
    required this.user,
    this.apiToken,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      user: User.fromJson(json['user']),
      apiToken: json['api_token'],
    );
  }
}
