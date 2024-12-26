class Product {
  final int? productId;
  final String? name;
  final String? quantity;
  final String? dimensions;
  final String? description;
  final String? categoryName;
  final List<String>? images;

  Product({
    this.productId,
    this.name,
    this.quantity,
    this.dimensions,
    this.description,
    this.categoryName,
    this.images,
  });

  // Factory method to create a Product object from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    print("JSON $json");
    return Product(
      productId: json['productId'] ,
      name: json['name'] ?? '',
      quantity: json['quantity'],
      dimensions: json['dimensions'] ?? '',
      description: json['description'] ?? '',
      categoryName: json['categoryName'] ?? '',
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
    );
  }

  // Method to convert Product object to JSON
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'dimensions': dimensions,
      'description': description,
      'categoryName': categoryName,
      'images': images,
    };
  }
}
