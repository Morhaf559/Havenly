// Widget: Property Card with Image, Name, Location, and Action Buttons
import 'package:flutter/material.dart';
import '../models/property.dart';
import '../controllers/profile_controller.dart';
import '';

class PropertyCardWidget extends StatelessWidget {
  final Property property;
  final ProfileController controller;

  const PropertyCardWidget({
    super.key,
    required this.property,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Property Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1565C0).withOpacity(0.2),
                  width: 2,
                ),
                image: DecorationImage(
                  image: NetworkImage(property.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Property Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color(0xFF1565C0),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        property.location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Icons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFF1565C0),
                    size: 24,
                  ),
                  onPressed: () => controller.onChatPressed(property),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(0xFF1565C0),
                    size: 24,
                  ),
                  onPressed: () => controller.onMoreOptionsPressed(property),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

