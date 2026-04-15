import 'package:get/get.dart';
import 'package:my_havenly_application/features/search/controllers/search_results_controller.dart';
import 'package:my_havenly_application/features/home/bindings/home_binding.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    final homeBinding = HomeBinding();
    homeBinding.dependencies();
    Get.lazyPut<SearchResultsController>(() => SearchResultsController());
  }
}
