import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/features/governorates/models/governorate_model.dart';
import 'package:my_havenly_application/features/governorates/services/governorate_service.dart';

class GovernorateController extends BaseController {
  final RxList<GovernorateModel> governorates = <GovernorateModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchGovernorates();
  }

  Future<void> fetchGovernorates() async {
    try {
      setLoading(true);
      clearError();

      debugPrint('GovernorateController: Fetching governorates from API...');
      final result = await GovernorateService.getGovernorates();
      debugPrint('GovernorateController: Got ${result.length} governorates');
      governorates.value = result;
      
      if (result.isEmpty) {
        debugPrint('GovernorateController: Warning - No governorates returned from API');
      } else {
        debugPrint('GovernorateController: First governorate: ID=${result.first.id}, Name=${result.first.getLocalizedName('ar')}');
      }
    } catch (e, stackTrace) {
      debugPrint('GovernorateController: Error fetching governorates: $e');
      debugPrint('GovernorateController: Stack trace: $stackTrace');
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}

