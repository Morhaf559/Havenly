import 'package:havenly/features/auth/model/user_model.dart';

class AuthResponseModel {
  final String? token;
  final UserModel? user;

  AuthResponseModel({required this.token, required this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token']?.toString(),

      /*  user: RegisterModel.formJson(json['user']) */
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
