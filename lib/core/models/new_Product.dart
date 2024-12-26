class NewProduct {
  final String id;
  final String name;
  final String company;
  final String purchaseDate;
  final String warranty;
  final String creator;
  final String createdBy;
  final String assignedTo;
  final String status;
  final String department;
  final String quantity;
  final String category;
  final List<Location> locations;
  final String createdAt;
  final String updatedAt;
  final String qr;
  final String productImg;

  NewProduct({
    required this.id,
    required this.name,
    required this.company,
    required this.purchaseDate,
    required this.warranty,
    required this.creator,
    required this.createdBy,
    required this.assignedTo,
    required this.status,
    required this.department,
    required this.quantity,
    required this.category,
    required this.locations,
    required this.createdAt,
    required this.updatedAt,
    required this.qr,
    required this.productImg,
  });

  factory NewProduct.fromJson(Map<String, dynamic> json) {
    return NewProduct(
      id: json['_id'],
      name: json['name'],
      company: json['company'],
      purchaseDate: json['purchaseDate'].toString(),
      warranty: json['warranty'],
      creator: json['creator'],
      createdBy: json['createdBy'],
      assignedTo: json['assignedTo'],
      status: json['status'],
      department: json['department'],
      quantity: json['quantity'],
      category: json['category'],
      locations: (json['locations'] as List)
          .map((locationJson) => Location.fromJson(locationJson))
          .toList(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      qr: json['qr'],
      productImg: json['productImg'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'company': company,
      'purchaseDate': purchaseDate.toString(),
      'warranty': warranty,
      'creator': creator,
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'status': status,
      'department': department,
      'quantity': quantity,
      'category': category,
      'locations': locations.map((location) => location.toJson()).toList(),
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
      'qr': qr,
      'productImg': productImg,
    };
  }
}

class Location {
  final String location;
  final String quantity;

  Location({
    required this.location,
    required this.quantity,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      location: json['location'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'quantity': quantity,
    };
  }
}
