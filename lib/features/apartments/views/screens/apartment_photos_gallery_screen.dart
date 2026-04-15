import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_photo_model.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartment_media_repository.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';

/// Apartment Photos Gallery Screen
/// Simple gallery to view apartment photos
class ApartmentPhotosGalleryScreen extends StatelessWidget {
  const ApartmentPhotosGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments
    final arguments = Get.arguments;
    int? apartmentId;
    List<ApartmentPhotoModel>? initialPhotos;

    if (arguments is Map) {
      apartmentId = arguments['apartmentId'] as int?;
      initialPhotos = arguments['photos'] as List<ApartmentPhotoModel>?;
    }

    if (apartmentId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Photos'.tr)),
        body: Center(child: Text('Apartment ID is required'.tr)),
      );
    }

    final controller = Get.put(ApartmentPhotosGalleryController());
    controller.initialize(apartmentId, initialPhotos);

    return Scaffold(
      appBar: AppBar(
        title: Text('Photos'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.photos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.photos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined, size: 64.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                Text('No photos available'.tr, style: TextStyle(fontSize: 16.sp)),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(8.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4.w,
            mainAxisSpacing: 4.h,
          ),
          itemCount: controller.photos.length,
          itemBuilder: (context, index) {
            final photo = controller.photos[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _FullScreenPhotoViewer(
                      photos: controller.photos,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  color: Colors.grey[300],
                ),
                child: photo.imageUrl != null && photo.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: Image.network(
                          photo.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: Colors.grey),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Center(child: CircularProgressIndicator());
                          },
                        ),
                      )
                    : Icon(Icons.image, color: Colors.grey),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Full Screen Photo Viewer
/// Simple full-screen image viewer with swipe navigation
class _FullScreenPhotoViewer extends StatefulWidget {
  final List<ApartmentPhotoModel> photos;
  final int initialIndex;

  const _FullScreenPhotoViewer({
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<_FullScreenPhotoViewer> createState() => _FullScreenPhotoViewerState();
}

class _FullScreenPhotoViewerState extends State<_FullScreenPhotoViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.photos.length}',
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          final photo = widget.photos[index];
          return Center(
            child: photo.imageUrl != null && photo.imageUrl!.isNotEmpty
                ? InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: Image.network(
                      photo.imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 64.sp, color: Colors.white54),
                          SizedBox(height: 16.h),
                          Text('Failed to load image'.tr, style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 64.sp, color: Colors.white54),
                      SizedBox(height: 16.h),
                      Text('No image available'.tr, style: TextStyle(color: Colors.white54)),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

/// Controller for Apartment Photos Gallery
class ApartmentPhotosGalleryController extends BaseController {
  final ApartmentMediaRepository _repository = Get.find<ApartmentMediaRepository>();

  final RxList<ApartmentPhotoModel> photos = <ApartmentPhotoModel>[].obs;
  int? _apartmentId;

  void initialize(int apartmentId, List<ApartmentPhotoModel>? initialPhotos) {
    _apartmentId = apartmentId;
    if (initialPhotos != null && initialPhotos.isNotEmpty) {
      photos.value = initialPhotos;
    }
    loadPhotos();
  }

  Future<void> loadPhotos() async {
    if (_apartmentId == null) return;
    try {
      setLoading(true);
      clearError();
      final loadedPhotos = await _repository.getPhotos(_apartmentId!);
      photos.value = loadedPhotos;
    } catch (e) {
      handleError(e, title: 'Error loading photos');
    } finally {
      setLoading(false);
    }
  }

  @override
  Future<void> refresh() async => loadPhotos();
}
