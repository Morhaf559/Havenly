import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:my_havenly_application/features/auth/controller/locale_controller.dart';
import 'package:my_havenly_application/features/auth/controller/login_controller.dart';
import 'package:my_havenly_application/features/auth/controller/theme_controller.dart';
import 'package:my_havenly_application/features/auth/view/screens/register_screen.dart';
import 'package:my_havenly_application/features/auth/view/widget/button_check.dart';
import 'package:my_havenly_application/features/auth/view/widget/costum_button.dart';
import 'package:my_havenly_application/features/auth/view/widget/costum_field.dart';

import '../../Binding/auth_binding.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  LoginController loginController = Get.find<LoginController>();
  final LocaleController localeController = Get.find<LocaleController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeController.bg,

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100),
            Text(
              'Welcome Back !'.tr,
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'sign in to continue'.tr,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(18),
                color: ThemeController.card,
              ),
              padding: const EdgeInsets.all(10),
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Column(
                  children: [
                    Text(
                      'Log in'.tr,
                      style: TextStyle(
                        fontSize: 32,
                        color: Color(0xff001733),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    CostumField(
                      labelText: 'Phone Number'.tr,
                      controller: loginController.phoneController,
                    ),
                    SizedBox(height: 5),
                    CostumField(
                      labelText: 'Password'.tr,
                      isPassword: true,
                      controller: loginController.passwordController,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // ButtonCheck(
                        //   text: 'Remember me',
                        //   iconOff: Icon(Icons.radio_button_unchecked),
                        //   iconOn: Icon(Icons.radio_button_checked),
                        // )
                        Spacer(flex: 4),
                        GestureDetector(
                          onTap: () {
                            //page of FORGET PASSWORD
                          },
                          child: Text(
                            'Forget password?'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        //  Spacer(flex: 1),
                      ],
                    ),

                    Obx(() {
                      return CostumButton(
                        text: loginController.isLoading.value
                            ? 'Loading...'.tr
                            : 'Login'.tr,
                        Width: double.infinity,
                        color: Color(0xff024DAA),

                        onTap: loginController.isLoading.value
                            ? null
                            : () {
                                loginController.loginUser();
                                //The page next login
                              },
                      );
                    }),
                    ElevatedButton(
                      onPressed: () {
                        localeController.ChangeLang('ar');
                      },
                      child: Text(
                        'arabic'.tr,
                        style: TextStyle(color: Colors.amber),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        localeController.ChangeLang('en');
                      },
                      child: Text('english'.tr),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 1. تبديل الثيم في GetX
                        Get.changeThemeMode(
                          Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                        );

                        // 2. تحديث الواجهة فوراً لرؤية الألوان الجديدة
                        Get.forceAppUpdate();
                      },
                      child: Text("تبديل الوضع (ليلي/نهاري)"),
                    ),

                    SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?".tr,
                          style: TextStyle(
                            color: Color(0xff001733),
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              () => RegisterScreen(),
                              binding: AuthBinding(),
                            );
                          },
                          child: Text(
                            'Register Now'.tr,
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
