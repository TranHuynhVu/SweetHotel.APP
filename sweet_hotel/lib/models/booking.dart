// Model cho Room info trong Booking
class BookingRoomInfo {
  final String id;
  final double price;
  final int discount;
  final String categoryName;

  BookingRoomInfo({
    required this.id,
    required this.price,
    required this.discount,
    required this.categoryName,
  });

  factory BookingRoomInfo.fromJson(Map<String, dynamic> json) {
    return BookingRoomInfo(
      id: json['id'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discount: json['discount'] ?? 0,
      categoryName: json['categoryName'] ?? '',
    );
  }
}

// Model cho User info trong Booking
class BookingUserInfo {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;

  BookingUserInfo({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
  });

  factory BookingUserInfo.fromJson(Map<String, dynamic> json) {
    return BookingUserInfo(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
    );
  }
}

class Booking {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String note;
  final double totalPrice;
  final String roomId;
  final String userId;
  final BookingRoomInfo? room;
  final BookingUserInfo? user;

  Booking({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.note,
    required this.totalPrice,
    required this.roomId,
    required this.userId,
    this.room,
    this.user,
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
      room: json['room'] != null
          ? BookingRoomInfo.fromJson(json['room'])
          : null,
      user: json['user'] != null
          ? BookingUserInfo.fromJson(json['user'])
          : null,
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

// Response model cho MyBookings API
class MyBookingsResponse {
  final List<Booking> upcoming;
  final List<Booking> current;
  final List<Booking> completed;
  final List<Booking> cancelled;
  final List<Booking> all;

  MyBookingsResponse({
    required this.upcoming,
    required this.current,
    required this.completed,
    required this.cancelled,
    required this.all,
  });

  factory MyBookingsResponse.fromJson(Map<String, dynamic> json) {
    return MyBookingsResponse(
      upcoming:
          (json['upcoming'] as List?)
              ?.map((item) => Booking.fromJson(item))
              .toList() ??
          [],
      current:
          (json['current'] as List?)
              ?.map((item) => Booking.fromJson(item))
              .toList() ??
          [],
      completed:
          (json['completed'] as List?)
              ?.map((item) => Booking.fromJson(item))
              .toList() ??
          [],
      cancelled:
          (json['cancelled'] as List?)
              ?.map((item) => Booking.fromJson(item))
              .toList() ??
          [],
      all:
          (json['all'] as List?)
              ?.map((item) => Booking.fromJson(item))
              .toList() ??
          [],
    );
  }
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
