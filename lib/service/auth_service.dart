import 'dart:convert';
import 'dart:io';

import 'package:havenly/model/register_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  String baseUrl = 'http://127.0.0.1:8000/api';
  String apiKey = '';

  Future<RegisterModel?> register(
    String phone,
    String firstName,
    String lastName,
    String password,
    String confirmedPassword,
    String dateOfBirth,
    File idPhoto,
    File personalPhotoPath,
  ) async {
    Uri url = Uri.parse('$baseUrl/auth/register');
    var request = http.MultipartRequest('POST', url);

    request.fields['phone'] = phone;
    request.fields['first_name'] = firstName;
    request.fields['last_name'] = lastName;
    request.fields['password'] = password;
    request.fields['password_confirmation'] = confirmedPassword;
    request.fields['date_of_birth'] = dateOfBirth;
    /* request.fields['idPhoto'] = idPhoto.path;
    request.fields['personalPhotoPath'] = personalPhotoPath; */

    request.files.add(
      await http.MultipartFile.fromPath('idPhoto', idPhoto.path),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'personal_photo',
        personalPhotoPath.path,
      ),
    );

    var response = await request.send();

    final responseBody = await response.stream.bytesToString();
    final data = jsonDecode(responseBody);

    if (response.statusCode == 200) {
      return RegisterModel.formJson(data);
    } else {
      throw Exception(data['message'] ?? 'register failed');
    }
  }
}

/* mport 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather_models.dart';

String baseUrl = 'http://api.weatherapi.com/v1';
String ApiKey = '09c03652a16d46c799e90219252811';

class WeatherServices {
  Future<WeatherModels> getWeather({required String NameCity}) async {
    Uri url =
        Uri.parse('$baseUrl/forecast.json?key=$ApiKey&q=$NameCity&days=4');
    http.Response response = await http.get(url);
    Map<String, dynamic> data = jsonDecode(response.body);

    WeatherModels weather = WeatherModels.fromJson(data);

    return weather;
  }
}
 */

/* import 'dart:convert';
import 'package:havenly/model/register_model.dart';
import 'package:http/http.dart' as http;
import 'package:havenly/model/register_model.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Future<RegisterModel?> login(String phone, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      // استخراج user فقط
      final userJson = json['data']['user'];

      return RegisterModel.fromJson(userJson);
    }

    return null;
  }
}
 
 */
