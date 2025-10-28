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
}
