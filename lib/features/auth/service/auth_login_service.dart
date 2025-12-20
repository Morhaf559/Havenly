import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:havenly/features/auth/model/login_model.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:havenly/features/auth/model/auth_response_model.dart';

class AuthLoginService {
  var box = GetStorage();
  String baseUrl = 'http://10.0.2.2:8000/api';

  Future<AuthResponseModel?> Login(String phone, String password) async {
    try {
      final loginUrl = Uri.parse('$baseUrl/auth/login');
      final response = await http.post(
        loginUrl,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'phone': phone.trim(), 'password': password}),
      );
      print("Status Code from Server: ${response.statusCode}");
      print("Body from Server: ${response.body}");
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
      print('Error connection$e');
      return null;
    }
  }
} /*   */
