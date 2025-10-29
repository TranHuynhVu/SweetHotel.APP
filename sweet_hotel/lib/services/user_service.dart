import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import '../models/user.dart';
import '../constants/api_endpoints.dart';
import '../services/auth_service.dart';

class UserService {
  final _apiService = ApiService();
  final _authService = AuthService();

  /// Lấy thông tin user theo ID
  Future<User> getUserById(String userId) async {
    try {
      final response = await _apiService.get(ApiEndpoints.user.byId(userId));

      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load user info: $e');
    }
  }

  /// Lấy thông tin user hiện tại
  Future<User> getCurrentUser() async {
    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      return await getUserById(userId);
    } catch (e) {
      throw Exception('Failed to load current user: $e');
    }
  }

  /// Upload avatar
  Future<User> uploadAvatar(String userId, File imageFile) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final uri = Uri.parse(ApiEndpoints.user.uploadAvatar(userId));
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to upload avatar');
      }
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  /// Change password
  Future<void> changePassword(
    String userId,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      await _apiService.post(ApiEndpoints.user.changePassword(userId), {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  /// Update user profile
  Future<User> updateProfile(
    String userId, {
    required String fullName,
    required String phoneNumber,
    String? avatar,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.user.update(userId),
        {
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'avatar': avatar ?? '',
        },
      );

      // If response is null (204), reload user info
      if (response == null) {
        return await getUserById(userId);
      }

      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
