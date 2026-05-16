class ApiUrl {
  static const String baseUrl = 'http://206.189.89.117:8000';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String devices = '/api/devices';
  static const String deviceData = '/api/data-hourly';
  static const String dashboardData = '/api/dashboard/stats';
  static const String transactions = '/api/tokens/transactions';
  static const String correction = '/api/tokens/correction';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String devicePrediction = '/api/devices';
  static const String tokenPrices = '/api/tokens/prices';
}
