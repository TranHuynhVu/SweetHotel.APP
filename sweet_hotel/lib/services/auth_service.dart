import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../models/register.dart';
import '../models/login.dart';
import '../services/local_storage.dart';
import '../utils/jwt_helper.dart';

class AuthService {
  // Timeout để tránh chờ quá lâu
  static const _timeout = Duration(seconds: 15);
  final _localStorage = LocalStorage();

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiEndpoints.auth.register),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RegisterResponse.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Registration failed';
      }
    } on TimeoutException {
      throw 'Connection timeout. Please try again.';
    } on SocketException {
      throw 'Cannot connect to server. Please check your connection.';
    } on FormatException {
      throw 'Invalid response from server.';
    } catch (e) {
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiEndpoints.auth.login),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));

        // Lưu token vào local storage
        await _localStorage.saveToken(
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
          tokenType: loginResponse.tokenType,
          expiresIn: loginResponse.expiresIn,
        );

        // Lấy và lưu User ID từ token
        final userId = JwtHelper.getUserIdFromToken(loginResponse.accessToken);
        if (userId != null) {
          await _localStorage.saveUserId(userId);
        }

        return loginResponse;
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Login failed';
      }
    } on TimeoutException {
      throw 'Connection timeout. Please try again.';
    } on SocketException {
      throw 'Cannot connect to server. Please check your connection.';
    } on FormatException {
      throw 'Invalid response from server.';
    } catch (e) {
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  // Logout
  Future<void> logout() async {
    await _localStorage.clearToken();
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    return await _localStorage.hasToken();
  }

  // Get access token
  Future<String?> getAccessToken() async {
    return await _localStorage.getAccessToken();
  }

  // Get user ID
  Future<String?> getUserId() async {
    return await _localStorage.getUserId();
  }
}
