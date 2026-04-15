import 'package:my_havenly_application/core/models/photo_model.dart';

class UserProfile {
  final int? id;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? role;
  final int? status;
  final String? dateOfBirth;
  final int? roleId;
  final PhotoModel? idPhoto;
  final PhotoModel? personalPhoto;

  UserProfile({
    this.id,
    this.phone,
    this.firstName,
    this.lastName,
    this.username,
    this.role,
    this.status,
    this.dateOfBirth,
    this.roleId,
    this.idPhoto,
    this.personalPhoto,
  });

  String get name {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (username != null) {
      return username!;
    }
    return '';
  }

  String get profileImageUrl {
    if (personalPhoto?.url != null) {
      return personalPhoto!.url!;
    }
    return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200';
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    try {
      PhotoModel? parsePhoto(dynamic photoData) {
        if (photoData == null) return null;
        if (photoData is int) {
          return PhotoModel(id: photoData);
        }
        if (photoData is Map<String, dynamic>) {
          try {
            return PhotoModel.fromJson(photoData);
          } catch (e) {
            return null;
          }
        }
        return null;
      }

      return UserProfile(
        id: json['id'] as int?,
        phone: json['phone'] as String?,
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        username: json['username'] as String?,
        role: json['role'] as String?,
        status: json['status'] as int?,
        dateOfBirth: json['date_of_birth'] as String?,
        roleId: json['role_id'] as int?,
        idPhoto: parsePhoto(json['id_photo']),
        personalPhoto: parsePhoto(json['personal_photo']),
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'role': role,
      'status': status,
      'date_of_birth': dateOfBirth,
      'role_id': roleId,
      'id_photo': idPhoto?.toJson(),
      'personal_photo': personalPhoto?.toJson(),
    };
  }
}
