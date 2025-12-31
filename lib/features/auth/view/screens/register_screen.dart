import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/register_controller.dart';
import '../widget/button_check.dart';
import '../widget/costum_button.dart';
import '../widget/costum_field.dart';
import '../widget/date_time_widget.dart';
import '../widget/image_picker_widget.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  @override
  //final DateController dateController = Get.put(DateController());
  final RegisterController registerController = Get.find<RegisterController>();

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff001733),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        children: [
          Center(
            child: Column(
              children: [
                SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Create Account'.tr,
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xff001733),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Row(
                        children: [
                          Expanded(
                            child: CostumField(
                              controller:
                                  registerController.firstNameController,
                              //  text: 'First Name',
                              labelText: 'First Name'.tr,
                              width: 175,
                              alignment: Alignment.centerLeft,
                            ),
                          ),

                          Expanded(
                            child: CostumField(
                              controller: registerController.lastNameController,
                              // text: 'Last Name',
                              labelText: 'Last Name'.tr,
                              width: 175,
                              alignment: Alignment.centerRight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CostumField(
                        controller: registerController.usernameController,
                        labelText: 'Username'.tr,
                      ),
                      const SizedBox(height: 10),
                      CostumField(
                        controller: registerController.phoneController,
                        labelText: 'Phone Number'.tr,
                      ),
                      const SizedBox(height: 10),

                      CostumField(
                        controller: registerController.passwordController,
                        labelText: 'Password'.tr,
                        isPassword: true,
                      ),
                      const SizedBox(height: 10),
                      CostumField(
                        controller:
                            registerController.confirmedPasswordController,
                        labelText: 'Confirmed Password'.tr,
                        isPassword: true,
                      ),

                      DateTimeWidget(),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xffE0E4EB),
                              ),
                              child: ImagePickerWidget(
                                text: 'ID image'.tr,
                                onImagePicked: (path) {
                                  registerController.idImagePath.value = path;
                                },
                              ),
                            ),
                          ),

                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xffE0E4EB),
                              ),
                              child: ImagePickerWidget(
                                text: 'personal photo'.tr,
                                onImagePicked: (path) {
                                  registerController.personalPhotoPath.value =
                                      path;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Row(
                      //   children: [
                      //     ButtonCheck(
                      //       text: 'Agree with',
                      //       iconOff: const Icon(Icons.radio_button_unchecked),
                      //       iconOn: const Icon(Icons.radio_button_checked),
                      //     ),
                      //     const Text(
                      //       ' Terms and Condition',
                      //       style: TextStyle(
                      //         fontSize: 10,
                      //         color: Colors.blue,
                      //         decoration: TextDecoration.underline,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(height: 15),

                      Obx(() {
                        return CostumButton(
                          text: registerController.isLoading.value
                              ? 'Loading...'.tr
                              : 'Sign up'.tr,
                          Width: double.infinity,
                          color: const Color(0xff024DAA),
                          onTap: registerController.isLoading.value
                              ? null
                              : () {
                                  registerController.registerUser();
                                },
                        );
                      }),

                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?".tr,
                            style: TextStyle(
                              color: Color(0xff001733),
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.off(LoginScreen());
                            },
                            child: Text(
                              'Login'.tr,
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
