import 'package:get/get.dart';
import 'package:my_havenly_application/features/governorates/controllers/governorate_controller.dart';
import 'package:my_havenly_application/features/governorates/services/governorate_service.dart';

class GovernoratesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GovernorateService>(() => GovernorateService());

    Get.lazyPut<GovernorateController>(() => GovernorateController());
  }
}
