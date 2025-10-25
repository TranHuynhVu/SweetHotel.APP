class Category {
  final String id;
  final String name;
  final String description;
  final int maxPeople;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.maxPeople,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      maxPeople: json['maxPeople'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'maxPeople': maxPeople,
    };
  }
}
