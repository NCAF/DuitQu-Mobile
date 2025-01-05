class Category {
  final int? id;
  final String name;
  final String type;
  final String? createdAt;
  final String? updatedAt;

  Category({
    this.id,
    required this.name,
    required this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
    };
  }
}
