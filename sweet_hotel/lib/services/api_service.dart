import 'dart:convert';
import 'http_interceptor.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _interceptor = HttpInterceptor();

  // GET request với auto refresh token
  Future<dynamic> get(String url) async {
    try {
      final uri = Uri.parse(url);

      final response = await _interceptor.request(method: 'GET', url: uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getAvailable(String url, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse(url);

      final response = await _interceptor.request(
        method: 'GET',
        url: uri,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to post data: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // POST request với auto refresh token
  Future<dynamic> post(String url, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse(url);

      final response = await _interceptor.request(
        method: 'POST',
        url: uri,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to post data: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // PUT request với auto refresh token
  Future<dynamic> put(String url, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse(url);

      final response = await _interceptor.request(
        method: 'PUT',
        url: uri,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to update data: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request với auto refresh token
  Future<dynamic> delete(String url) async {
    try {
      final uri = Uri.parse(url);

      final response = await _interceptor.request(method: 'DELETE', url: uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to delete data: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
