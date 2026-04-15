import 'package:my_havenly_application/core/network/api_service.dart';
import 'package:my_havenly_application/features/governorates/models/governorate_model.dart';

class GovernorateService {
  static Future<List<GovernorateModel>> getGovernorates() async {
    return await ApiService.getList<GovernorateModel>(
      path: '/governorates',
      fromJson: (json) => GovernorateModel.fromJson(json),
    );
  }
}

