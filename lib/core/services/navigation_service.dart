import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class NavigationService {
  static bool toNamed(String routeName, {dynamic arguments, String? fallback}) {
    try {
      Get.toNamed(routeName, arguments: arguments);
      return true;
    } catch (e) {
      debugPrint('NavigationService: Error navigating to $routeName: $e');

      // Try fallback if provided
      if (fallback != null) {
        try {
          Get.toNamed(fallback);
          return true;
        } catch (fallbackError) {
          debugPrint(
            'NavigationService: Error navigating to fallback $fallback: $fallbackError',
          );
        }
      }

      return false;
    }
  }

  static bool offNamed(
    String routeName, {
    dynamic arguments,
    String? fallback,
  }) {
    try {
      Get.offNamed(routeName, arguments: arguments);
      return true;
    } catch (e) {
      debugPrint('NavigationService: Error navigating off to $routeName: $e');

      if (fallback != null) {
        try {
          Get.offNamed(fallback);
          return true;
        } catch (fallbackError) {
          debugPrint(
            'NavigationService: Error navigating to fallback $fallback: $fallbackError',
          );
        }
      }

      return false;
    }
  }

  static bool offAllNamed(
    String routeName, {
    dynamic arguments,
    String? fallback,
  }) {
    try {
      Get.offAllNamed(routeName, arguments: arguments);
      return true;
    } catch (e) {
      debugPrint(
        'NavigationService: Error navigating offAll to $routeName: $e',
      );

      if (fallback != null) {
        try {
          Get.offAllNamed(fallback);
          return true;
        } catch (fallbackError) {
          debugPrint(
            'NavigationService: Error navigating to fallback $fallback: $fallbackError',
          );
        }
      }

      return false;
    }
  }

  static bool back({dynamic result, String? fallback}) {
    try {
      Get.back(result: result);
      return true;
    } catch (e) {
      debugPrint('NavigationService: Error going back: $e');

      if (fallback != null) {
        return offAllNamed(fallback);
      }

      return false;
    }
  }

  static bool to(dynamic page, {dynamic binding, String? fallback}) {
    try {
      if (binding != null) {
        Get.to(page, binding: binding);
      } else {
        Get.to(page);
      }
      return true;
    } catch (e) {
      debugPrint('NavigationService: Error navigating to widget: $e');

      if (fallback != null) {
        return offAllNamed(fallback);
      }

      return false;
    }
  }

  static bool off(dynamic page, {dynamic binding, String? fallback}) {
    try {
      if (binding != null) {
        Get.off(page, binding: binding);
      } else {
        Get.off(page);
      }
      return true;
    } catch (e) {
      debugPrint('NavigationService: Error navigating off to widget: $e');

      if (fallback != null) {
        return offAllNamed(fallback);
      }

      return false;
    }
  }

  static bool offAll(dynamic page, {dynamic binding, String? fallback}) {
    try {
      if (binding != null) {
        Get.offAll(page, binding: binding);
      } else {
        Get.offAll(page);
      }
      return true;
    } catch (e) {
      debugPrint('NavigationService: Error navigating offAll to widget: $e');

      if (fallback != null) {
        return offAllNamed(fallback);
      }

      return false;
    }
  }
}
