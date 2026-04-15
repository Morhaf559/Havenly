import 'package:get/get.dart';
import 'package:my_havenly_application/features/apartments/services/apartments_api_service.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartments_repository.dart';
import 'package:my_havenly_application/features/apartments/services/apartment_media_api_service.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartment_media_repository.dart';
import 'package:my_havenly_application/features/apartments/controllers/apartment_list_controller.dart';
import 'package:my_havenly_application/features/apartments/controllers/apartment_details_controller.dart';
import 'package:my_havenly_application/features/apartments/controllers/add_apartment_controller.dart';
import 'package:my_havenly_application/features/reviews/bindings/reviews_binding.dart';
import 'package:my_havenly_application/features/governorates/bindings/governorates_binding.dart';

class ApartmentsBinding extends Bindings {
  @override
  void dependencies() {
    final reviewsBinding = ReviewsBinding();
    reviewsBinding.dependencies();

    final governoratesBinding = GovernoratesBinding();
    governoratesBinding.dependencies();

    Get.lazyPut<ApartmentsApiService>(() => ApartmentsApiService());
    Get.lazyPut<ApartmentMediaApiService>(() => ApartmentMediaApiService());

    Get.lazyPut<ApartmentsRepository>(() => ApartmentsRepository());
    Get.lazyPut<ApartmentMediaRepository>(() => ApartmentMediaRepository());

    Get.lazyPut<ApartmentListController>(() => ApartmentListController());
    Get.lazyPut<ApartmentDetailsController>(() => ApartmentDetailsController());
    Get.lazyPut<AddApartmentController>(() => AddApartmentController());
  }
}
