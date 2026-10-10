class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.mobile,
  });

  final int id;
  final String name;
  final String email;
  final String? mobile;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      mobile: json['mobile'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
    };
  }
}
