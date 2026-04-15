import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/features/favorites/controllers/favorite_controller.dart';

class FavoriteIconButton extends StatelessWidget {
  final int apartmentId;

  const FavoriteIconButton({
    super.key,
    required this.apartmentId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavoritesController>();

    return Obx(() {
      final isFavorite = controller.favoriteApartmentIds.contains(apartmentId);

      return IconButton(
        onPressed: () async {
          await controller.toggleFavorite(apartmentId);
        },
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 28.sp,
          color: isFavorite ? Colors.red : Colors.grey,
        ),
        iconSize: 28.sp,
      );
    });
  }
}

