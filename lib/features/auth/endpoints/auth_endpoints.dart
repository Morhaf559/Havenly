class AuthEndpoints {
  AuthEndpoints._();

  static const String basePath = '/auth';

  static const String login = '$basePath/login';

  static const String register = '$basePath/register';

  static const String resetPassword = '$basePath/reset-password';

  static const String getCurrentUser = '$basePath/me';

  static const String updateProfile = '$basePath/profile';

  static String buildPath(String path, {Map<String, dynamic>? params}) {
    if (params == null || params.isEmpty) {
      return '$basePath/$path';
    }

    String result = '$basePath/$path';
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value.toString());
      result = result.replaceAll('{$key}', value.toString());
    });

    return result;
  }

  static const String sendOtp = '$basePath/send-otp';

  static const String verifyOtp = '$basePath/verify-otp';
}
