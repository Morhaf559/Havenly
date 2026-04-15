import 'package:my_havenly_application/core/network/api_service.dart';
import 'package:my_havenly_application/features/reviews/models/review_model.dart';

class ReviewService {
  static Future<List<ReviewModel>> getReviews({int? apartmentId}) async {
    final queryParameters = apartmentId != null
        ? {'apartment_id': apartmentId}
        : null;

    return await ApiService.getList<ReviewModel>(
      path: '/apartment/review',
      queryParameters: queryParameters,
      fromJson: (json) => ReviewModel.fromJson(json),
    );
  }

  static Future<ReviewModel> createReview({
    required int apartmentId,
    required int rate,
    String? comment,
  }) async {
    return await ApiService.post<ReviewModel>(
      path: '/apartment/review/',
      queryParameters: {'apartment_id': apartmentId, 'rate': rate},
      data: comment != null ? {'comment': comment} : null,
      fromJson: (json) => ReviewModel.fromJson(json),
    );
  }

  static Future<ReviewModel> updateReview({
    required int reviewId,
    required int rate,
    String? comment,
  }) async {
    return await ApiService.put<ReviewModel>(
      path: '/apartment/review/$reviewId',
      queryParameters: {'rate': rate},
      data: comment != null ? {'comment': comment} : null,
      fromJson: (json) => ReviewModel.fromJson(json),
    );
  }

  static Future<void> deleteReview(int reviewId) async {
    await ApiService.delete(path: '/apartment/review/$reviewId');
  }
}
