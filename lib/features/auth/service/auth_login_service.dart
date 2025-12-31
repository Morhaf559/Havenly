import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:my_havenly_application/features/auth/controller/locale_controller.dart';
import 'package:my_havenly_application/features/auth/model/auth_response_model.dart';

class AuthLoginService {
  var box = GetStorage();
  String baseUrl = 'http://10.0.2.2:8000/api';

  Future<AuthResponseModel?> Login(String phone, String password) async {
    try {
      String currentLang = Get.locale?.languageCode ?? 'ar';
      final loginUrl = Uri.parse('$baseUrl/auth/login');
      final response = await http.post(
        loginUrl,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Language': currentLang,
        },
        body: jsonEncode({'phone': phone.trim(), 'password': password}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        AuthResponseModel userLogin = AuthResponseModel.fromJson(responseData);

        if (userLogin.token != null) {
          await box.write('token', userLogin.token);
          await box.write('first_name', userLogin.user?.firstName);
        }
        return userLogin;
      } else {
        var errorData = jsonDecode(response.body);
        String errorMessage = errorData['message'] ?? "Error";
        Get.snackbar("فشل", errorMessage, backgroundColor: Colors.red);
        return null;
      }
    } catch (e) {
      return null;
    }
  }
} /*   */
