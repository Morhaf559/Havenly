import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_havenly_application/features/auth/service/auth_api_service.dart';
import 'package:my_havenly_application/features/home/view/screens/home_screen.dart';

class OtpController extends GetxController {
  var isLoading = false.obs;
  List<String> OtpDigits = List.filled(5, "");
  Future<void> OtpVerify(String phone) async {
    String OtpCode = OtpDigits.join("");
    if (OtpCode.length < 5) {
      Get.snackbar('Error', 'please complete the Code');
      return;
    }
    try {
      isLoading.value = true;
      bool? isSuccess = await AuthApiService.verifyOtp(phone, OtpCode);

      if (isSuccess!) {
        Get.snackbar('Congratulations', 'The account has been activated');
        Get.offAll(() => HomeScreen());
      }
    } catch (e) {
      Get.snackbar('Error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
