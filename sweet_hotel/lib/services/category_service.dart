import '../services/api_service.dart';
import '../models/category.dart';
import '../constants/api_endpoints.dart';

class CategoryService {
  final _apiService = ApiService();

  /// Lấy danh sách tất cả categories
  Future<List<Category>> getAllCategories() async {
    try {
      final response = await _apiService.get(ApiEndpoints.category.all);

      if (response is List) {
        return response.map((json) => Category.fromJson(json)).toList();
      }

      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  /// Lấy chi tiết một category
  Future<Category> getCategoryById(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.category.byId(id));
      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load category details: $e');
    }
  }
}
