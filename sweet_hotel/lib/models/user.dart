class User {
  final String id;
  final String email;
  final String fullName;
  final String avatar;
  final String? phoneNumber;
  final List<String> roles;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.avatar,
    this.phoneNumber,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      avatar: json['avatar'] ?? '',
      phoneNumber: json['phoneNumber'],
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((role) => role.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'avatar': avatar,
      'phoneNumber': phoneNumber,
      'roles': roles,
    };
  }

  // Kiểm tra role
  bool get isClient => roles.contains('Client');
  bool get isAdmin => roles.contains('Admin');

  // Lấy role đầu tiên (chính)
  String get primaryRole => roles.isNotEmpty ? roles.first : 'Unknown';
}
