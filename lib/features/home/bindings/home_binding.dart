import 'package:get/get.dart';
import 'package:my_havenly_application/features/home/controllers/home_controller.dart';
import 'package:my_havenly_application/features/home/repositories/home_repository.dart';
import 'package:my_havenly_application/features/governorates/bindings/governorates_binding.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    final governoratesBinding = GovernoratesBinding();
    governoratesBinding.dependencies();

    Get.lazyPut<HomeRepository>(() => HomeRepository());

    Get.lazyPut<HomeController>(() => HomeController());
  }
}
