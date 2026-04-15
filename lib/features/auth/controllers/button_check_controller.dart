import 'package:get/get.dart';

class ButtonCheckController extends GetxController {
  final isCheck = false.obs;

  void toggle() {
    isCheck.value = !isCheck.value;
  }

  void setValue(bool value) {
    isCheck.value = value;
  }

  void clear() {
    isCheck.value = false;
  }
}
