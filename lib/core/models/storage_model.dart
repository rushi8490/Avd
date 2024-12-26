class getStorageData {
  int? storageId;
  int? productId;
  int? lId;
  int? quantity;
  Null? desc;
  String? createdAt;
  String? updatedAt;

  getStorageData(
      {this.storageId,
        this.productId,
        this.lId,
        this.quantity,
        this.desc,
        this.createdAt,
        this.updatedAt});

  getStorageData.fromJson(Map<String, dynamic> json) {
    storageId = json['storageId'];
    productId = json['productId'];
    lId = json['lId'];
    quantity = json['quantity'];
    desc = json['desc'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['storageId'] = this.storageId;
    data['productId'] = this.productId;
    data['lId'] = this.lId;
    data['quantity'] = this.quantity;
    data['desc'] = this.desc;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
