import 'package:get/get.dart';
import 'package:my_havenly_application/features/reviews/controllers/review_controller.dart';
import 'package:my_havenly_application/features/reviews/services/review_service.dart';

class ReviewsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewService>(() => ReviewService());
    Get.lazyPut<ReviewController>(() => ReviewController());
  }
}
