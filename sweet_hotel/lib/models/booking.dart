class Booking {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String note;
  final double totalPrice;
  final String roomId;
  final String userId;

  Booking({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.note,
    required this.totalPrice,
    required this.roomId,
    required this.userId,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),
      status: json['status'] ?? 'Pending',
      note: json['note'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      roomId: json['roomId'] ?? '',
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'note': note,
      'totalPrice': totalPrice,
      'roomId': roomId,
      'userId': userId,
    };
  }

  // Số đêm ở
  int get numberOfNights {
    return endDate.difference(startDate).inDays;
  }

  // Kiểm tra status
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isConfirmed => status.toLowerCase() == 'confirmed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isCompleted => status.toLowerCase() == 'completed';
}

// Request model để tạo booking
class CreateBookingRequest {
  final DateTime startDate;
  final DateTime endDate;
  final String note;
  final String roomId;
  final String userId;

  CreateBookingRequest({
    required this.startDate,
    required this.endDate,
    required this.note,
    required this.roomId,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'note': note,
      'roomId': roomId,
      'userId': userId,
    };
  }
}
