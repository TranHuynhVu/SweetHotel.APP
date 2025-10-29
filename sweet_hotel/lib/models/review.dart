class Review {
  final String id;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String bookingId;
  final String? userId;

  Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.bookingId,
    this.userId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      bookingId: json['bookingId'] ?? '',
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'bookingId': bookingId,
      'userId': userId,
    };
  }
}

// Request model để tạo review
class CreateReviewRequest {
  final int rating;
  final String comment;
  final String bookingId;

  CreateReviewRequest({
    required this.rating,
    required this.comment,
    required this.bookingId,
  });

  Map<String, dynamic> toJson() {
    return {'rating': rating, 'comment': comment, 'bookingId': bookingId};
  }
}

// Request model để cập nhật review
class UpdateReviewRequest {
  final int rating;
  final String comment;

  UpdateReviewRequest({required this.rating, required this.comment});

  Map<String, dynamic> toJson() {
    return {'rating': rating, 'comment': comment};
  }
}
