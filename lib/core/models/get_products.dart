class addProduct {
  int? productId;
  String? name;
  String? quantity;
  String? dimensions;
  String? description;
  int? cid;
  String? updatedAt;
  String? createdAt;

  addProduct(
      {this.productId,
        this.name,
        this.quantity,
        this.dimensions,
        this.description,
        this.cid,
        this.updatedAt,
        this.createdAt});

  addProduct.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    name = json['name'];
    quantity = json['quantity'];
    dimensions = json['dimensions'];
    description = json['description'];
    cid = json['cid'];
    updatedAt = json['updatedAt'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['productId'] = this.productId;
    data['name'] = this.name;
    data['quantity'] = this.quantity;
    data['dimensions'] = this.dimensions;
    data['description'] = this.description;
    data['cid'] = this.cid;
    data['updatedAt'] = this.updatedAt;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
