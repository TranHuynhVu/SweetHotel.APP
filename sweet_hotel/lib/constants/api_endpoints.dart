class ApiEndpoints {
  // Base URL
  // Production
  static const String baseUrl = 'https://api.sweethotel.kodopo.tech/api';

  // Development - Android Emulator (thay PORT bằng port API của bạn)
  //static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Development - iOS Simulator hoặc thiết bị thật (uncomment và thay IP)
  //static const String baseUrl = 'http://192.168.1.xxx:5000/api';
  // Auth endpoints - trả về URL đầy đủ
  static const auth = _Auth();

  // Category endpoints - trả về URL đầy đủ
  static const category = _Category();

  // Room endpoints - trả về URL đầy đủ
  static const room = _Room();

  // Booking endpoints - trả về URL đầy đủ
  static const booking = _Booking();
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

// Booking endpoints
class _Booking {
  const _Booking();
  String get create => '${ApiEndpoints.baseUrl}/Bookings';
  String get all => '${ApiEndpoints.baseUrl}/Bookings';
  String byId(String id) => '${ApiEndpoints.baseUrl}/Bookings/$id';
  String myBookings(String userId) =>
      '${ApiEndpoints.baseUrl}/Bookings/MyBookings/$userId';
}
