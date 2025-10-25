class Room {
  final String id;
  final String status;
  final String amenities;
  final double price;
  final double discount;
  final String categoryId;
  final String categoryName;
  final List<RoomImage> images;

  Room({
    required this.id,
    required this.status,
    required this.amenities,
    required this.price,
    required this.discount,
    required this.categoryId,
    required this.categoryName,
    required this.images,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? '',
      status: json['status'] ?? 'Unavailable',
      amenities: json['amenities'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      images:
          (json['images'] as List<dynamic>?)
              ?.map((img) => RoomImage.fromJson(img))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'amenities': amenities,
      'price': price,
      'discount': discount,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'images': images.map((img) => img.toJson()).toList(),
    };
  }

  // Tính giá sau khi giảm
  double get finalPrice => price - (price * discount / 100);

  // Kiểm tra phòng có available không
  bool get isAvailable => status.toLowerCase() == 'available';

  // Lấy ảnh đầu tiên hoặc ảnh placeholder
  String get mainImage =>
      images.isNotEmpty ? images.first.path : 'https://via.placeholder.com/400';
}

class RoomImage {
  final String id;
  final String path;

  RoomImage({required this.id, required this.path});

  factory RoomImage.fromJson(Map<String, dynamic> json) {
    return RoomImage(id: json['id'] ?? '', path: json['path'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'path': path};
  }
}
