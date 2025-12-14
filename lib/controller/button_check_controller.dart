import 'package:get/get.dart';
import '';

class ButtonCheckController extends GetxController {
  RxBool isCheck = false.obs;

  void toggle() {
    isCheck != isCheck.toggle();
  }
}
