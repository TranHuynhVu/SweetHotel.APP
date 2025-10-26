import '../services/api_service.dart';
import '../models/booking.dart';
import '../constants/api_endpoints.dart';

class BookingService {
  final _apiService = ApiService();

  /// Tạo booking mới
  Future<Booking> createBooking(CreateBookingRequest request) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.booking.create,
        request.toJson(),
      );

      return Booking.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  /// Lấy danh sách tất cả bookings của user hiện tại
  Future<List<Booking>> getMyBookings() async {
    try {
      final response = await _apiService.get(ApiEndpoints.booking.myBookings);

      if (response is List) {
        return response.map((json) => Booking.fromJson(json)).toList();
      }

      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to load bookings: $e');
    }
  }

  /// Lấy chi tiết một booking
  Future<Booking> getBookingById(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.booking.byId(id));
      return Booking.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load booking details: $e');
    }
  }

  /// Hủy booking
  Future<void> cancelBooking(String id) async {
    try {
      await _apiService.delete(ApiEndpoints.booking.byId(id));
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }
}
