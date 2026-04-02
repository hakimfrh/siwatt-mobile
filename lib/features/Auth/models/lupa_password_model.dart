// Model for POST /auth/send-otp response
class SendOtpResponse {
  final int code;
  final String message;
  final SendOtpData? data;

  SendOtpResponse({required this.code, required this.message, this.data});

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? SendOtpData.fromJson(json['data']) : null,
    );
  }
}

class SendOtpData {
  final int otpId;
  final String email;
  final String expiresAt;

  SendOtpData({required this.otpId, required this.email, required this.expiresAt});

  factory SendOtpData.fromJson(Map<String, dynamic> json) {
    return SendOtpData(
      otpId: json['otp_id'],
      email: json['email'],
      expiresAt: json['expires_at'],
    );
  }
}

// Model for POST /auth/verify-otp response
class VerifyOtpResponse {
  final int code;
  final VerifyOtpData? data;

  VerifyOtpResponse({required this.code, this.data});

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      code: json['code'] ?? 0,
      data: json['data'] != null ? VerifyOtpData.fromJson(json['data']) : null,
    );
  }
}

class VerifyOtpData {
  final int otpId;
  final bool isValid;
  final String expirationTime;

  VerifyOtpData({required this.otpId, required this.isValid, required this.expirationTime});

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) {
    return VerifyOtpData(
      otpId: json['otp_id'],
      isValid: json['is_valid'],
      expirationTime: json['expiration_time'],
    );
  }
}

// Model for POST /auth/reset-password response
class ResetPasswordResponse {
  final int code;
  final String message;

  ResetPasswordResponse({required this.code, required this.message});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
