class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://api.sweethotel.kodopo.tech/api';

  // Auth endpoints - trả về URL đầy đủ
  static const auth = _Auth();

  // Category endpoints - trả về URL đầy đủ
  static const category = _Category();

  // Room endpoints - trả về URL đầy đủ
  static const room = _Room();
}

// Auth endpoints
class _Auth {
  const _Auth();
  String get login => '${ApiEndpoints.baseUrl}/Auth/Login';
  String get register => '${ApiEndpoints.baseUrl}/Auth/Register';
  String get logout => '${ApiEndpoints.baseUrl}/Auth/Logout';
  String get refreshToken => '${ApiEndpoints.baseUrl}/Auth/RefreshToken';
}

// Category endpoints
class _Category {
  const _Category();
  String get all => '${ApiEndpoints.baseUrl}/Categories';
  String byId(String id) => '${ApiEndpoints.baseUrl}/Categories/$id';
}

// Room endpoints
class _Room {
  const _Room();
  String get all => '${ApiEndpoints.baseUrl}/Rooms';
  String byId(String id) => '${ApiEndpoints.baseUrl}/Rooms/$id';
  String get availableByDateRange =>
      '${ApiEndpoints.baseUrl}/Rooms/AvailableByDateRange';
}
