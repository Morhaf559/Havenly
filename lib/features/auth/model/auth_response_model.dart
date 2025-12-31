import 'package:my_havenly_application/features/auth/model/user_model.dart';

/// AuthResponseModel represents the authentication response structure
/// Response format: { "data": { "token": "...", "user": {...} } }
class AuthResponseModel {
  final String? token;
  final UserModel? user;

  AuthResponseModel({this.token, this.user});

  /// Parse from API response structure: { "data": { "token": "...", "user": {...} } }
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle nested data structure
      final data = json['data'] as Map<String, dynamic>?;
      if (data == null) {
        // Fallback: try direct parsing if data wrapper doesn't exist
        return AuthResponseModel(
          token: json['token']?.toString(),
          user: json['user'] != null
              ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
              : null,
        );
      }

      // Extract token
      final token = data['token']?.toString();

      // Extract user
      UserModel? user;
      if (data['user'] != null) {
        try {
          user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        } catch (e) {
          // Failed to parse user, user will remain null
        }
      }

      return AuthResponseModel(token: token, user: user);
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {'token': token, 'user': user?.toJson()},
    };
  }
}
