class RegisterModel {
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? password;
  final String? confirmedPassword;
  final String? dateOfBirth;
  final String? idPhoto;
  final String? personalPhotoPath;

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

/*"data": {
        "token": "25|biyQQwPiMHVEXPEMk1twdi90xEjUyKZOumRT2uWr3dc66d66",
        "user": {
            "id": 18,
            "phone": "963964187533",
            "first_name": "first name",
            "last_name": "last name",
            "username": "username91",
            "date_of_birth": "2025-12-08",
            "role": "user",
            "id_photo": "1",
            "personal_photo": "1",
            "status": 2
        }
    }
} */
