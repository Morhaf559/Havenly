class UserModel {
  final int? id;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? role;
  final int? status;

  UserModel({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.role,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      phone: json['phone'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      username: json['username'] as String?,
      role: json['role'] as String?,
      status: json['status'] as int?,
    );
  }
}
