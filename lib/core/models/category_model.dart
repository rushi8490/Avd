class Category {
  final int cId;
  final String name;
  final String desc;
  final String createdAt;
  final String updatedAt;

  Category({
    required this.cId,
    required this.name,
    required this.desc,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create a Category from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      cId: json['cId'],
      name: json['name'],
      desc: json['desc'] ?? '', // In case desc is empty
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
