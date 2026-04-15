import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/core/utils/app_colors.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';
import 'package:my_havenly_application/features/favorites/controllers/favorite_controller.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartment_media_repository.dart';

class ApartmentCardWidget extends StatefulWidget {
  final ApartmentModel apartment;
  final VoidCallback? onTap;
  final bool showFavoriteButton;

  const ApartmentCardWidget({
    super.key,
    required this.apartment,
    this.onTap,
    this.showFavoriteButton = true,
  });

  @override
  State<ApartmentCardWidget> createState() => _ApartmentCardWidgetState();
}

class _ApartmentCardWidgetState extends State<ApartmentCardWidget> {
  String? _loadedMainImage;
  bool _isLoadingImage = false;
  bool _hasTriedLoading = false;

  @override
  void initState() {
    super.initState();
    _loadedMainImage = widget.apartment.mainImage;
    if ((_loadedMainImage == null || _loadedMainImage!.isEmpty) &&
        !_hasTriedLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            (_loadedMainImage == null || _loadedMainImage!.isEmpty) &&
            !_hasTriedLoading &&
            !_isLoadingImage) {
          _loadMainImageLazy();
        }
      });
    }
  }

  Future<void> _loadMainImageLazy() async {
    if (!mounted ||
        _isLoadingImage ||
        (_loadedMainImage != null && _loadedMainImage!.isNotEmpty) ||
        _hasTriedLoading)
      return;
    setState(() {
      _isLoadingImage = true;
      _hasTriedLoading = true;
    });
    try {
      final mediaRepository = Get.find<ApartmentMediaRepository>();
      final mainPhoto = await mediaRepository.getMainPhoto(widget.apartment.id);
      if (!mounted) return;
      if (mainPhoto != null &&
          mainPhoto.url != null &&
          mainPhoto.url!.isNotEmpty) {
        setState(() {
          _loadedMainImage = mainPhoto.url;
          _isLoadingImage = false;
        });
      } else {
        setState(() => _isLoadingImage = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.languageCode ?? 'ar';
    final title = widget.apartment.getLocalizedTitle(locale) ?? 'No Title'.tr;
    final address =
        widget.apartment.getLocalizedAddress(locale) ??
        widget.apartment.city ??
        'Unknown Location'.tr;
    final imageUrl = _loadedMainImage ?? widget.apartment.mainImage;

    return GestureDetector(
      onTap:
          widget.onTap ??
          () {
            if (widget.apartment.id > 0) {
              Get.toNamed(
                AppRoutes.apartmentDetails,
                arguments: widget.apartment.id,
              );
            }
          },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio:
                          16 / 9, // نسبة عرض إلى ارتفاع ثابتة للصورة لمنع الضرب
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.home,
                                      size: 40.sp,
                                      color: Colors.grey,
                                    ),
                              )
                            : _isLoadingImage
                            ? const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.home, size: 40.sp, color: Colors.grey),
                      ),
                    ),

                    // Content Section
                    Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title - Max 2 lines to handle long text
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.h),

                          // Location
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  address,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),

                          // Rating & Price - SpaceBetween for dynamic horizontal layout
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Rating
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 14.sp,
                                    color: Colors.amber,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    '${widget.apartment.rate ?? 0}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              // Price
                              Flexible(
                                child: Text(
                                  '\$${widget.apartment.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryNavy,
                                  ),
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Favorite Button Overlay
                if (widget.showFavoriteButton)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: _FavoriteButton(apartmentId: widget.apartment.id),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final int apartmentId;
  const _FavoriteButton({required this.apartmentId});

  @override
  Widget build(BuildContext context) {
    try {
      final favoritesController = Get.find<FavoritesController>();
      return Obx(() {
        final isFavorite = favoritesController.favoriteApartmentIds.contains(
          apartmentId,
        );
        return GestureDetector(
          onTap: () => favoritesController.toggleFavorite(apartmentId),
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 18.sp,
              color: isFavorite ? Colors.red : AppColors.primaryNavy,
            ),
          ),
        );
      });
    } catch (e) {
      return Container(
        padding: EdgeInsets.all(6.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.favorite_border,
          size: 18.sp,
          color: AppColors.primaryNavy,
        ),
      );
    }
  }
}
