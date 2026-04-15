import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/storage/storage_service.dart';
import 'package:my_havenly_application/features/reviews/controllers/review_controller.dart';
import 'package:my_havenly_application/features/reviews/models/review_model.dart';
import 'package:my_havenly_application/features/reviews/views/widgets/edit_review_bottom_sheet.dart';
import 'package:my_havenly_application/features/reviews/views/widgets/rating_widget.dart';

class ReviewsListWidget extends StatelessWidget {
  final List<ReviewModel>? reviews;
  final ReviewController? controller;

  const ReviewsListWidget({super.key, this.reviews, this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller != null) {
      return Obx(() {
        final reviewsList = controller!.reviews;
        return _buildReviewsList(reviewsList);
      });
    }
    return _buildReviewsList(reviews ?? []);
  }

  Widget _buildReviewsList(List<ReviewModel> reviewsList) {
    if (reviewsList.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.rate_review, size: 48.sp, color: Colors.grey),
              SizedBox(height: 8.h),
              Text(
                'No reviews yet'.tr,
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviewsList.length,
      itemBuilder: (context, index) {
        final review = reviewsList[index];
        return _ReviewItem(review: review, controller: controller);
      },
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final ReviewModel review;
  final ReviewController? controller;

  const _ReviewItem({required this.review, this.controller});

  bool _isCurrentUserReview() {
    final currentUsername = StorageService.read<String>('username');
    if (currentUsername != null && review.userName != null) {
      return currentUsername.toLowerCase() == review.userName!.toLowerCase();
    }
    return false;
  }

  void _showEditDialog(BuildContext context) {
    if (controller != null) {
      EditReviewBottomSheet.show(
        context: context,
        review: review,
        controller: controller!,
      );
    }
  }

  String _formatDate(String? date) {
    if (date == null) return '';
    try {
      final DateTime dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    review.userName ?? 'Anonymous',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (review.createdAt != null)
                  Text(
                    _formatDate(review.createdAt),
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                if (controller != null && _isCurrentUserReview())
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 20.sp),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDialog(context);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'.tr),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            RatingWidget(rating: review.rate.toDouble()),
            SizedBox(height: 8.h),
            if (review.comment != null && review.comment!.isNotEmpty)
              Text(review.comment!, style: TextStyle(fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }
}
