import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RouteTransitions {
  RouteTransitions._();
  static const Duration defaultDuration = Duration(milliseconds: 400);

  static GetPage buildPageRoute({
    required String name,
    required Widget Function() page,
    Bindings? binding,
    Duration duration = defaultDuration,
  }) {
    return GetPage(
      name: name,
      page: page,
      binding: binding,
      transition: Transition.fade,
      transitionDuration: duration,
    );
  }
}
