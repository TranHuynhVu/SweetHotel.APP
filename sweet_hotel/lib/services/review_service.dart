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

  /// Xóa review
  Future<void> deleteReview(String reviewId) async {
    try {
      // API sử dụng POST method cho Delete endpoint
      await _apiService.post(
        ApiEndpoints.review.delete(reviewId),
        {}, // Empty body
      );
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  /// Cập nhật review
  Future<Review?> updateReview(
    String reviewId,
    UpdateReviewRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.review.update(reviewId),
        request.toJson(),
      );

      // Nếu response là null (204 No Content), trả về null
      if (response == null) {
        return null;
      }

      return Review.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }
}
