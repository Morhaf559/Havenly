import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_photo_model.dart';
import 'package:my_havenly_application/features/favorites/controllers/favorite_controller.dart';

/// Apartment Image Gallery Widget
/// Displays images in a PageView with indicators and action buttons
class ApartmentImageGallery extends StatefulWidget {
  final List<ApartmentPhotoModel> photos;
  final int? apartmentId;

  const ApartmentImageGallery({
    super.key,
    required this.photos,
    this.apartmentId,
  });

  @override
  State<ApartmentImageGallery> createState() => _ApartmentImageGalleryState();
}

class _ApartmentImageGalleryState extends State<ApartmentImageGallery> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image container
        Container(
          height: 350.h,
          width: double.infinity,
          color: Colors.grey[300],
          child: widget.photos.isEmpty
              ? Icon(
                  Icons.image,
                  size: 64.sp,
                  color: Colors.grey[600],
                )
              : PageView.builder(
                  controller: _pageController,
                  itemCount: widget.photos.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final photo = widget.photos[index];
                    return Image.network(
                      photo.imageUrl ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.broken_image,
                            size: 64.sp,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        
        // Top action buttons
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
                
                // Favorite button
                if (widget.apartmentId != null)
                  _FavoriteButton(apartmentId: widget.apartmentId!),
              ],
            ),
          ),
        ),

        // Page indicators (centered at bottom of image)
        if (widget.photos.length > 1)
          Positioned(
            bottom: 16.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.photos.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: _currentPage == index ? 24.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Favorite Button for Image Gallery
/// Custom styled favorite button with white icon
class _FavoriteButton extends StatelessWidget {
  final int apartmentId;

  const _FavoriteButton({required this.apartmentId});

  @override
  Widget build(BuildContext context) {
    // Controller should be initialized via FavoritesBinding
    // Use Get.find or Get.put based on whether binding is initialized
    final controller = Get.find<FavoritesController>();

    return Obx(() {
      // Use observable variable directly instead of calling a method
      final isFavorite = controller.favoriteApartmentIds.contains(apartmentId);

      return GestureDetector(
        onTap: () async {
          // Optimistic UI: Toggle happens immediately in controller
          await controller.toggleFavorite(apartmentId);
        },
        child: Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
            size: 24.sp,
          ),
        ),
      );
    });
  }
}

