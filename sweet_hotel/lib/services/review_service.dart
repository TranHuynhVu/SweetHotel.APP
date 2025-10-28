import '../services/api_service.dart';
import '../models/review.dart';
import '../constants/api_endpoints.dart';

class ReviewService {
  final _apiService = ApiService();

  /// Tạo review mới
  Future<Review> createReview(CreateReviewRequest request) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.review.create,
        request.toJson(),
      );

      return Review.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  /// Lấy danh sách reviews của một booking
  Future<List<Review>> getReviewsByBooking(String bookingId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.review.byBooking(bookingId),
      );

      if (response is List) {
        return response.map((json) => Review.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load reviews: $e');
    }
  }
}
