import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ScreenUtilInit Wrapper
/// Configures ScreenUtil for responsive design
class AppScreenUtilInit extends StatelessWidget {
  final Widget child;

  const AppScreenUtilInit({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(420, 950),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => this.child,
    );
  }
}

