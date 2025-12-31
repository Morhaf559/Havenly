// Widget: Profile Section with Image, Name, and Role
import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';

class ProfileSectionWidget extends StatelessWidget {
  final ProfileController controller;

  const ProfileSectionWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF1565C0),
                width: 3,
              ),
              image: DecorationImage(
                image: NetworkImage(controller.profileImageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            controller.profileName,
            style: TextStyle(
              fontSize: controller.nameFontSize,
              fontWeight: FontWeight.bold,
              color: controller.nameColor,
            ),
          ),
          const SizedBox(height: 4),

          // Role
          Text(
            controller.profileRole,
            style: TextStyle(
              fontSize: controller.roleFontSize,
              color: controller.roleColor,
            ),
          ),
        ],
      ),
    );
  }
}
