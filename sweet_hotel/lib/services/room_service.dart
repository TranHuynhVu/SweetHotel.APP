import '../services/api_service.dart';
import '../models/room.dart';
import '../constants/api_endpoints.dart';

class RoomService {
  final _apiService = ApiService();

  /// Lấy danh sách tất cả phòng
  Future<List<Room>> getAllRooms() async {
    try {
      final response = await _apiService.get(ApiEndpoints.room.all);

      if (response is List) {
        return response.map((json) => Room.fromJson(json)).toList();
      }

      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to load rooms: $e');
    }
  }

  /// Lấy chi tiết một phòng
  Future<Room> getRoomById(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.room.byId(id));
      return Room.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load room details: $e');
    }
  }

  /// Lọc phòng theo category
  Future<List<Room>> getRoomsByCategory(String categoryId) async {
    try {
      final rooms = await getAllRooms();
      return rooms.where((room) => room.categoryId == categoryId).toList();
    } catch (e) {
      throw Exception('Failed to filter rooms: $e');
    }
  }

  /// Lọc phòng available
  Future<List<Room>> getAvailableRooms() async {
    try {
      final rooms = await getAllRooms();
      return rooms.where((room) => room.isAvailable).toList();
    } catch (e) {
      throw Exception('Failed to get available rooms: $e');
    }
  }

  /// Lọc phòng theo khoảng thời gian và các tiêu chí khác
  Future<List<Room>> getAvailableRoomsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? categoryId,
    int? maxPeople,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String>[];
      queryParams.add(
        'startDate=${Uri.encodeComponent(startDate.toIso8601String())}',
      );
      queryParams.add(
        'endDate=${Uri.encodeComponent(endDate.toIso8601String())}',
      );

      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams.add('categoryId=${Uri.encodeComponent(categoryId)}');
      }

      if (maxPeople != null && maxPeople > 0) {
        queryParams.add('maxPeople=$maxPeople');
      }

      final queryString = queryParams.join('&');
      final response = await _apiService.get(
        '${ApiEndpoints.room.availableByDateRange}?$queryString',
      );

      if (response is List) {
        return response.map((json) => Room.fromJson(json)).toList();
      }

      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to load available rooms: $e');
    }
  }
}
