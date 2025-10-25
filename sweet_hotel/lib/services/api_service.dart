import 'dart:convert';
import '../constants/api_endpoints.dart';
import 'http_interceptor.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _interceptor = HttpInterceptor();

  // GET request với auto refresh token
  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse(
        endpoint.startsWith('http')
            ? endpoint
            : '${ApiEndpoints.baseUrl}$endpoint',
      );

      final response = await _interceptor.request(method: 'GET', url: url);

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

  Future<dynamic> getAvailable(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse(
        endpoint.startsWith('http')
            ? endpoint
            : '${ApiEndpoints.baseUrl}$endpoint',
      );

      final response = await _interceptor.request(
        method: 'GET',
        url: url,
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
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(
        endpoint.startsWith('http')
            ? endpoint
            : '${ApiEndpoints.baseUrl}$endpoint',
      );

      final response = await _interceptor.request(
        method: 'POST',
        url: url,
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
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(
        endpoint.startsWith('http')
            ? endpoint
            : '${ApiEndpoints.baseUrl}$endpoint',
      );

      final response = await _interceptor.request(
        method: 'PUT',
        url: url,
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
  Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse(
        endpoint.startsWith('http')
            ? endpoint
            : '${ApiEndpoints.baseUrl}$endpoint',
      );

      final response = await _interceptor.request(method: 'DELETE', url: url);

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
