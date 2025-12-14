import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:havenly/view/screens/register_screen.dart';
import 'package:havenly/view/widget/costum_button.dart';
import 'package:havenly/view/widget/costum_field.dart';
import 'package:havenly/view/widget/button_check.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff001733),

      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        children: [
          Column(
            children: [
              SizedBox(height: 40),
              Text(
                'Welcome Back !',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'sign in to continue',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(10),
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Column(
                    children: [
                      Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xff001733),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      CostumField(labelText: 'Phone Number'),
                      SizedBox(height: 5),
                      CostumField(labelText: 'Password', isPassword: true),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ButtonCheck(
                            text: 'Remember me',
                            iconOff: Icon(Icons.radio_button_unchecked),
                            iconOn: Icon(Icons.radio_button_checked),
                          ),
                          Spacer(flex: 4),
                          GestureDetector(
                            onTap: () {
                              //page of FORGET PASSWORD
                            },
                            child: Text(
                              'Forget password?',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          //  Spacer(flex: 1),
                        ],
                      ),

                      CostumButton(
                        text: 'Log in',
                        Width: double.infinity,
                        color: Color(0xff024DAA),
                        onTap: () {
                          //The page next login
                        },
                      ),
                      SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Color(0xff001733),
                              indent: 5,
                              endIndent: 5,
                            ),
                          ),
                          Text(
                            "Or Log in With",
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Color(0xff001733),
                              indent: 5,
                              endIndent: 5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CostumButton(
                            Width: 60,
                            color: Color(0xffEEEEEE),
                            image: 'assets/social_media/facebook.png',
                            onTap: () {
                              //account facebook
                            },
                          ),
                          CostumButton(
                            Width: 60,
                            color: Color(0xffEEEEEE),
                            image: 'assets/social_media/google.png',
                            onTap: () {
                              //account google
                            },
                          ),
                          CostumButton(
                            Width: 60,
                            color: Color(0xffEEEEEE),
                            image: 'assets/social_media/apple.png',
                            onTap: () {
                              //accomt apple
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: Color(0xff001733),
                              fontSize: 11,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.off(RegisterScreen());
                            },
                            child: Text(
                              'Register Now',
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
