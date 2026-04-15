import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_havenly_application/core/controllers/auth_state_controller.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  final bool forceShowOnboarding;

  const SplashScreen({super.key, required this.forceShowOnboarding});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (widget.forceShowOnboarding) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    try {
      final authStateController = Get.find<AuthStateController>();

      if (!authStateController.isStateLoaded) {
        await authStateController.ensureAuthStateLoaded();
      }

      if (authStateController.isLoggedIn) {
        Get.offAllNamed(AppRoutes.main);
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SplashScreen: Error checking auth state: $e');
      }
    }

    final storage = GetStorage();
    final hasSeenOnboarding =
        storage.read<bool>('has_seen_onboarding') ?? false;

    if (hasSeenOnboarding) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.shrink(),
    );
  }
}
