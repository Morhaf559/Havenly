import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../utils/error_handler.dart';

abstract class BaseController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);
  ErrorType? errorType;
  void setLoading(bool value) {
    isLoading.value = value;
  }

  void setError(String? message) {
    errorMessage.value = message;
  }

  void setErrorFromException(dynamic error) {
    if (error is DioException) {
      errorType = ErrorHandler.getErrorType(error);
      errorMessage.value = ErrorHandler.handleDioException(error);
    } else {
      errorType = ErrorType.unknown;
      errorMessage.value = ErrorHandler.handleException(error);
    }
  }

  void clearError() {
    errorMessage.value = null;
    errorType = null;
  }

  void handleError(dynamic error, {String? title, bool showDialog = false}) {
    setErrorFromException(error);
    ErrorHandler.handleError(error, title: title, showDialog: showDialog);
  }
}
