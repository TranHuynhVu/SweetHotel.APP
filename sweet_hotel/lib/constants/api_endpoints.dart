class ApiEndpoints {
  // Base URL cho Android Emulator dùng 10.0.2.2 thay vì localhost
  static const String baseUrl = 'https://10.0.2.2:7066/api';

  // Auth endpoints
  static const String login = '$baseUrl/Auth/Login';
  static const String register = '$baseUrl/Auth/Register';
  static const String logout = '$baseUrl/Auth/Logout';
  static const String refreshToken = '$baseUrl/Auth/RefreshToken';

  // User endpoints
  static const String userProfile = '$baseUrl/User/Profile';
  static const String updateProfile = '$baseUrl/User/Update';
  static const String changePassword = '$baseUrl/User/ChangePassword';

  // Room endpoints
  static const String rooms = '$baseUrl/Rooms';
  static String roomDetail(String id) => '$baseUrl/Rooms/$id';
}
