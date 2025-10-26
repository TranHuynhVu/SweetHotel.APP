import 'dart:convert';

class JwtHelper {
  /// Decode JWT token để lấy payload
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      // Add padding if needed
      var normalized = base64Url.normalize(payload);
      var decoded = utf8.decode(base64Url.decode(normalized));
      return json.decode(decoded);
    } catch (e) {
      return null;
    }
  }

  /// Lấy User ID từ token
  static String? getUserIdFromToken(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;

    // Key chính xác từ .NET Identity
    const nameIdentifierKey =
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';

    // Thử key nameidentifier trước (từ .NET Identity)
    if (payload.containsKey(nameIdentifierKey)) {
      return payload[nameIdentifierKey];
    }

    // Fallback cho các key phổ biến khác
    return payload['sub'] ??
        payload['userId'] ??
        payload['user_id'] ??
        payload['nameid'];
  }

  /// Lấy email từ token
  static String? getEmailFromToken(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;

    // Key chính xác từ .NET Identity
    const emailAddressKey =
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress';

    // Thử key emailaddress trước (từ .NET Identity)
    if (payload.containsKey(emailAddressKey)) {
      return payload[emailAddressKey];
    }

    // Fallback
    return payload['email'];
  }

  /// Lấy Full Name từ token
  static String? getFullNameFromToken(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;

    return payload['FullName'] ?? payload['fullName'] ?? payload['name'];
  }

  /// Lấy Role từ token
  static String? getRoleFromToken(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;

    // Key chính xác từ .NET Identity
    const roleKey =
        'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';

    // Thử key role trước (từ .NET Identity)
    if (payload.containsKey(roleKey)) {
      return payload[roleKey];
    }

    // Fallback
    return payload['role'];
  }

  /// Kiểm tra token đã hết hạn chưa
  static bool isTokenExpired(String token) {
    final payload = decodeToken(token);
    if (payload == null) return true;

    final exp = payload['exp'];
    if (exp == null) return false;

    final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expiryDate);
  }
}
