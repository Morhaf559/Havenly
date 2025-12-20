import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:havenly/features/auth/Binding/auth_binding.dart';
import 'package:havenly/features/auth/controller/login_controller.dart';
import 'package:havenly/features/auth/view/screens/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff00223B), Color(0xff050A10)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 110),
          child: Column(
            children: [
              Align(
                alignment: AlignmentGeometry.topCenter,
                child: Image.asset(
                  'assets/social_media/Havenly3.png',
                  width: 180,
                  height: 180,
                ),
              ),

              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [
                      Color(0xffBF953F),
                      Color(0xffFCF6BA),
                      Color(0xffB38728),
                      Color(0xffFBF5B7),
                      Color(0xffAA771C),
                    ],
                  ).createShader(bounds);
                },
                child: Text(
                  '..HAVENLY..',
                  style: TextStyle(
                    color: Color(0xffE0B251),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 12,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Unlock a world of comfort & control',
                style: TextStyle(fontSize: 14, color: Color(0xffE0B251)),
              ),
              SizedBox(height: 150),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Get.off(() => LoginScreen(), binding: AuthBinding());
                  },
                  child: Container(
                    child: Center(
                      child: Text(
                        'START YOUR JOURNEY',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xffAA771C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Color(0xff00233F),
                      border: Border.all(color: Color(0xffAA771C), width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
