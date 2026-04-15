import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/features/reviews/models/review_model.dart';
import 'package:my_havenly_application/features/reviews/services/review_service.dart';

class ReviewController extends BaseController {
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxDouble averageRating = 0.0.obs;
  Future<void> fetchReviews(int apartmentId) async {
    try {
      setLoading(true);
      clearError();

      final result = await ReviewService.getReviews(apartmentId: apartmentId);
      reviews.value = result;
      _calculateAverageRating();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  void _calculateAverageRating() {
    if (reviews.isEmpty) {
      averageRating.value = 0.0;
      return;
    }

    final sum = reviews.fold(0.0, (sum, review) => sum + review.rate);
    averageRating.value = sum / reviews.length;
  }

  Future<void> createReview({
    required int apartmentId,
    required int rate,
    String? comment,
  }) async {
    try {
      final newReview = await ReviewService.createReview(
        apartmentId: apartmentId,
        rate: rate,
        comment: comment,
      );
      reviews.add(newReview);
      _calculateAverageRating();
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Failed to create review: ${e.toString()}'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  Future<void> updateReview({
    required int reviewId,
    required int rate,
    String? comment,
  }) async {
    try {
      final updatedReview = await ReviewService.updateReview(
        reviewId: reviewId,
        rate: rate,
        comment: comment,
      );

      final index = reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        reviews[index] = updatedReview;
        _calculateAverageRating();
      }
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Failed to update review: ${e.toString()}'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  Future<void> deleteReview(int reviewId) async {
    try {
      await ReviewService.deleteReview(reviewId);
      reviews.removeWhere((r) => r.id == reviewId);
      _calculateAverageRating();
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Failed to delete review: ${e.toString()}'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }
}
