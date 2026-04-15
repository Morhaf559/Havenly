import 'package:my_havenly_application/core/models/user_model.dart';

class AuthResponseModel {
  final String? token;
  final UserModel? user;

  AuthResponseModel({this.token, this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      String? token;
      UserModel? user;
      token =
          json['token']?.toString() ??
          json['data']?['token']?.toString() ??
          json['access_token']?.toString();

      if (json.containsKey('id')) {
        user = UserModel.fromJson(json);
      } else if (json['user'] != null && json['user'] is Map<String, dynamic>) {
        user = UserModel.fromJson(json['user'] as Map<String, dynamic>);
      } else if (json['data'] != null && json['data'] is Map<String, dynamic>) {
        final data = json['data'] as Map<String, dynamic>;
        if (data.containsKey('id')) {
          user = UserModel.fromJson(data);
        } else if (data['user'] != null) {
          user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        }
      }

      return AuthResponseModel(token: token, user: user);
    } catch (e) {
      print("Error Parsing AuthResponseModel: $e");
      return AuthResponseModel(token: null, user: null);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {'token': token, 'user': user?.toJson()},
    };
  }

  bool get isValid => token != null && token!.isNotEmpty && user != null;
}
