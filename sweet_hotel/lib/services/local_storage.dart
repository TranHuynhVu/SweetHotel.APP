import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  // Singleton pattern
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  // Lưu string
  Future<bool> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, value);
  }

  // Đọc string
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // Lưu int
  Future<bool> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(key, value);
  }

  // Đọc int
  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  // Lưu bool
  Future<bool> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(key, value);
  }

  // Đọc bool
  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  // Xóa một key
  Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
  }

  // Xóa tất cả data (logout)
  Future<bool> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }

  // Token management
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _expiresInKey = 'expires_in';

  Future<bool> saveToken({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
  }) async {
    await saveString(_accessTokenKey, accessToken);
    await saveString(_refreshTokenKey, refreshToken);
    await saveString(_tokenTypeKey, tokenType);
    await saveInt(_expiresInKey, expiresIn);

    // Lưu timestamp khi lưu token
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await saveInt('token_timestamp', timestamp);

    return true;
  }

  Future<String?> getAccessToken() => getString(_accessTokenKey);
  Future<String?> getRefreshToken() => getString(_refreshTokenKey);
  Future<String?> getTokenType() => getString(_tokenTypeKey);

  Future<bool> clearToken() async {
    await remove(_accessTokenKey);
    await remove(_refreshTokenKey);
    await remove(_tokenTypeKey);
    await remove(_expiresInKey);
    return true;
  }

  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
