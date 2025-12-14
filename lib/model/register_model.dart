class RegisterModel {
  final String phone;
  final String firstName;
  final String lastName;
  final String password;
  final String confirmedPassword;
  final String dateOfBirth;
  final String idPhoto;
  final String personalPhotoPath;

  RegisterModel({
    required this.phone,
    required this.password,
    required this.confirmedPassword,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.idPhoto,
    required this.personalPhotoPath,
  });

  factory RegisterModel.formJson(Map<String, dynamic> json) {
    return RegisterModel(
      phone: json['phone'],
      password: json['password'],
      confirmedPassword: json['passwordConfirmation'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: json['dateOfBirth'],
      idPhoto: json['idPhoto'],
      personalPhotoPath: json['personalPhoto'],
    );
  }
}


/* class UserModel {
  final int id;
  final String phone;
  final String firstName;
  final String lastName;
  final String username;
  final String role;
  final int status;

  UserModel({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.role,
    required this.status,
  });

  /// تحويل JSON → UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phone: json['phone'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      username: json['username'],
      role: json['role'],
      status: json['status'],
    );
  }
}
 */