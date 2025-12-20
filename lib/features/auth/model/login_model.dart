class LoginModel {
  final String? token;
  final String? firstName;
  final String? lastName;
  final String? phone;

  LoginModel({this.firstName, this.lastName, this.phone, this.token});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    var data = json['data'];
    var token = data['user'];
    return LoginModel(
      firstName: token['first_name'],
      lastName: token['last_name'],
      phone: token['phone'],
      token: data['token'],
    );
  }
}
/*"data": {
        "token": "26|Lj955obus7L16kqshq3Z5iHOwnPJUvZuobFEZ5MB32964643",
        "user": {
            "id": 1,
            "phone": "963964587965",
            "first_name": "first name",
            "last_name": "last name",
            "username": "username2",
            "date_of_birth": "2025-12-08",
            "role": "user",
            "id_photo": 1,
            "personal_photo": 1,
            "status": 2
        }
    }
} */