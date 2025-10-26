import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_storage.dart';
import '../constants/api_endpoints.dart';

class HttpInterceptor {
  static final HttpInterceptor _instance = HttpInterceptor._internal();
  factory HttpInterceptor() => _instance;
  HttpInterceptor._internal();

  final _localStorage = LocalStorage();
  bool _isRefreshing = false;
  final List<Completer<String>> _refreshQueue = [];

  // Kiểm tra token có hết hạn không (dựa vào thời gian lưu)
  Future<bool> _isTokenExpired() async {
    // Lấy thời gian lưu token (bạn cần lưu thêm timestamp khi login)
    final tokenTimestamp = await _localStorage.getInt('token_timestamp');
    final expiresIn = await _localStorage.getInt('expires_in') ?? 3600;

    if (tokenTimestamp == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final elapsed = now - tokenTimestamp;

    // Token hết hạn nếu đã qua 90% thời gian (để an toàn)
    return elapsed >= (expiresIn * 0.9);
  }

  // Refresh access token
  Future<String> _refreshToken() async {
    // Nếu đang refresh, đợi kết quả
    if (_isRefreshing) {
      final completer = Completer<String>();
      _refreshQueue.add(completer);
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _localStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('No refresh token available');
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.auth.refreshToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];
        final expiresIn = data['expires_in'] ?? 3600;

        // Lưu token mới
        await _localStorage.saveToken(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
          tokenType: 'Bearer',
          expiresIn: expiresIn,
        );

        // Lưu timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await _localStorage.saveInt('token_timestamp', timestamp);

        // Hoàn thành các request đang chờ
        for (var completer in _refreshQueue) {
          completer.complete(newAccessToken);
        }
        _refreshQueue.clear();

        return newAccessToken;
      } else {
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      // Refresh failed, xóa token và logout
      await _localStorage.clearToken();

      for (var completer in _refreshQueue) {
        completer.completeError(e);
      }
      _refreshQueue.clear();

      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }

  // Get headers với auto refresh token
  Future<Map<String, String>> getHeaders() async {
    final headers = {'Content-Type': 'application/json'};

    var token = await _localStorage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      // Kiểm tra token hết hạn chưa
      if (await _isTokenExpired()) {
        try {
          token = await _refreshToken();
        } catch (e) {
          // Nếu refresh fail, bỏ qua token (user sẽ phải login lại)
          print('Token refresh failed: $e');
          return headers;
        }
      }

      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Thực hiện request với retry khi token hết hạn
  Future<http.Response> request({
    required String method,
    required Uri url,
    Map<String, String>? headers,
    dynamic body,
    int maxRetries = 1,
  }) async {
    http.Response response;
    int retryCount = 0;

    do {
      final authHeaders = await getHeaders();
      if (headers != null) {
        authHeaders.addAll(headers);
      }

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: authHeaders);
          break;
        case 'POST':
          response = await http.post(url, headers: authHeaders, body: body);
          break;
        case 'PUT':
          response = await http.put(url, headers: authHeaders, body: body);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: authHeaders);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // Nếu 401 Unauthorized, thử refresh token và retry
      if (response.statusCode == 401 && retryCount < maxRetries) {
        try {
          await _refreshToken();
          retryCount++;
          continue;
        } catch (e) {
          // Refresh failed, return response
          break;
        }
      }

      break;
    } while (retryCount <= maxRetries);

    return response;
  }
}
