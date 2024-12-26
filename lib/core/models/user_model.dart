class UserModel {
  String? sId;
  String? email;
  String? location;
  String? role;
  String? department;
  String? name;
  String? createdAt;
  String? updatedAt;

  UserModel(
      {this.sId,
        this.email,
        this.location,
        this.role,
        this.department,
        this.name,
        this.createdAt,
        this.updatedAt});

  UserModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    location = json['location'];
    role = json['role'];
    department = json['department'];
    name = json['name'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['email'] = this.email;
    data['location'] = this.location;
    data['role'] = this.role;
    data['department'] = this.department;
    data['name'] = this.name;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
