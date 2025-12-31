import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_havenly_application/features/auth/Binding/auth_binding.dart';
import 'package:my_havenly_application/features/auth/controller/locale_controller.dart';
import 'package:my_havenly_application/features/auth/view/screens/login_screen.dart';
import 'package:my_havenly_application/features/home/view/screens/home_screen.dart';
import 'package:my_havenly_application/features/onboarding/view/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool forceShowOnboarding;

  SplashScreen({super.key, required this.forceShowOnboarding});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
    _navigateToNext();
  }

  /* Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Development mode: If forceShowOnboarding is true, always show onboarding
    // Production mode: Check GetStorage flag to determine if user has seen onboarding
    if (widget.forceShowOnboarding) {
      // Always show onboarding during development/testing
      Get.offAll(() => const OnboardingScreen());
    } else {
      // Normal production behavior: Check GetStorage flag
      final storage = GetStorage();
      final hasSeenOnboarding =
          storage.read<bool>('has_seen_onboarding') ?? false;

      if (hasSeenOnboarding) {
        Get.offAll(() => LoginScreen(), binding: AuthBinding());
      } else {
        Get.offAll(() => const OnboardingScreen());
      }
    }
  } */
  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final storage = GetStorage();
    // 1. تحقق من وضع التطوير (Force Onboarding)
    if (widget.forceShowOnboarding) {
      Get.offAll(() => const OnboardingScreen());
      return;
    }
    // 2. قراءة حالة الـ Onboarding والتوكن
    final bool hasSeenOnboarding =
        storage.read<bool>('has_seen_onboarding') ?? false;
    final String? token = storage.read<String>('token');

    // 3. منطق التوجيه الذكي
    if (!hasSeenOnboarding) {
      // إذا لم يشاهد الاونبوردينج ابداً
      Get.offAll(() => const OnboardingScreen());
    } else if (token != null && token.isNotEmpty) {
      // إذا شاهد الاونبوردينج ومعـه توكن (مسجل دخول سابقاً)
      // ملاحظة: تأكد من عمل Import لـ HomeScreen
      Get.offAll(() => const HomeScreen());
    } else {
      // شاهد الاونبوردينج ولكن ليس معه توكن
      Get.offAll(() => LoginScreen(), binding: AuthBinding());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff001733),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo/Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.home,
                        size: 70,
                        color: Color(0xff001733),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // App Name
                    const Text(
                      'Havenly',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Find Your Perfect Home',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
