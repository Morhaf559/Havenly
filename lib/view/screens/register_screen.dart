import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:havenly/controller/date_controller.dart';
import 'package:havenly/view/screens/login_screen.dart';
import 'package:havenly/view/widget/button_check.dart';
import 'package:havenly/view/widget/costum_button.dart';
import 'package:havenly/view/widget/costum_field.dart';
import 'package:havenly/view/widget/date_time_widget.dart';
import 'package:havenly/view/widget/image_picker_widget.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  @override
  final DateController dateController = Get.put(DateController());

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff001733),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        children: [
          Center(
            child: Column(
              children: [
                const Text(
                  'Hello !',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Fill your information bellow or register',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const Text(
                  'with social account',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Create Account',
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
                              //  text: 'First Name',
                              labelText: 'First Name',
                              width: 175,
                              alignment: Alignment.centerLeft,
                            ),
                          ),

                          Expanded(
                            child: CostumField(
                              // text: 'Last Name',
                              labelText: 'Last Name',
                              width: 175,
                              alignment: Alignment.centerRight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      CostumField(labelText: 'Phone Number'),
                      const SizedBox(height: 10),

                      CostumField(labelText: 'Password', isPassword: true),
                      const SizedBox(height: 10),
                      CostumField(
                        labelText: 'Confirmed Password',
                        isPassword: true,
                      ),

                      ElevatedButton(
                        onPressed: () {
                          final controller = Get.find<DateController>();
                          final date = controller.selectedDate.value;
                        },
                        child: Text('Register'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ImagePickerWidget(text: 'Upload your ID image'),
                          ImagePickerWidget(text: 'Upload personal photo'),
                        ],
                      ),

                      Row(
                        children: [
                          ButtonCheck(
                            text: 'Agree with',
                            iconOff: const Icon(Icons.radio_button_unchecked),
                            iconOn: const Icon(Icons.radio_button_checked),
                          ),
                          const Text(
                            ' Terms and Condition',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      CostumButton(
                        text: 'Sign up',
                        Width: double.infinity,
                        color: const Color(0xff024DAA),
                        onTap: () {},
                      ),

                      const SizedBox(height: 15),

                      Row(
                        children: const [
                          Expanded(
                            child: Divider(
                              color: Color(0xff001733),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "Or Register With",
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Color(0xff001733),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CostumButton(
                            Width: 60,
                            color: const Color(0xffEEEEEE),
                            image: 'assets/social_media/facebook.png',
                            onTap: () {},
                          ),
                          const SizedBox(width: 10),
                          CostumButton(
                            Width: 60,
                            color: const Color(0xffEEEEEE),
                            image: 'assets/social_media/google.png',
                            onTap: () {},
                          ),
                          const SizedBox(width: 10),
                          CostumButton(
                            Width: 60,
                            color: const Color(0xffEEEEEE),
                            image: 'assets/social_media/apple.png',
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: TextStyle(
                              color: Color(0xff001733),
                              fontSize: 11,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.off(LoginScreen());
                            },
                            child: const Text(
                              ' Login',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 11,
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
