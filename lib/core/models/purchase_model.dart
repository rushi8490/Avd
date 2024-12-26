class purchaseDetails {
  int? purchaseId;
  int? productId;
  String? date;
  String? purcaseFrom;
  String? warranty;
  String? prize;
  String? purchasedBy;
  String? createdBy;
  String? description;
  String? updatedAt;
  String? createdAt;

  purchaseDetails(
      {this.purchaseId,
        this.productId,
        this.date,
        this.purcaseFrom,
        this.warranty,
        this.prize,
        this.purchasedBy,
        this.createdBy,
        this.description,
        this.updatedAt,
        this.createdAt});

  purchaseDetails.fromJson(Map<String, dynamic> json) {
    purchaseId = json['purchaseId'];
    productId = json['productId'];
    date = json['date'];
    purcaseFrom = json['purcaseFrom'];
    warranty = json['warranty'];
    prize = json['prize'];
    purchasedBy = json['purchasedBy'];
    createdBy = json['createdBy'];
    description = json['description'];
    updatedAt = json['updatedAt'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['purchaseId'] = this.purchaseId;
    data['productId'] = this.productId;
    data['date'] = this.date;
    data['purcaseFrom'] = this.purcaseFrom;
    data['warranty'] = this.warranty;
    data['prize'] = this.prize;
    data['purchasedBy'] = this.purchasedBy;
    data['createdBy'] = this.createdBy;
    data['description'] = this.description;
    data['updatedAt'] = this.updatedAt;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
