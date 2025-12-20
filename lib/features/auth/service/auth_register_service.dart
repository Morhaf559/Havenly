import 'dart:convert';
import 'dart:io';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:havenly/features/auth/model/auth_response_model.dart';
import 'package:havenly/features/auth/model/image_id_upload_model.dart';
import 'package:http/http.dart' as http;

class AuthRegisterService {
  //  String baseUrl = 'http://127.0.0.1:8000/api/';
  String baseUrl = 'http://10.0.2.2:8000/api';
  String apiKey = '';

  Future<ImageIdUploadModel?> UploadIdImage(
    File imageFile,
    String imageType,
    String imageFor,
  ) async {
    Uri url = Uri.parse('$baseUrl/media');
    var request = http.MultipartRequest('POST', url);

    request.headers.addAll({'Accept': 'application/json'});
    request.fields['type'] = imageType;
    request.fields['for'] = imageFor;
    request.files.add(
      await http.MultipartFile.fromPath('medium', imageFile.path),
    );
    var response = await request.send().timeout(
      Duration(seconds: 30),
      onTimeout: () {
        throw SocketException('image upload took 15 second');
      },
    );
    final responseBody = await response.stream.bytesToString();
    final data = jsonDecode(responseBody);
    print('Image Upload Status Code: ${response.statusCode}');
    print('Image Upload RAW Response: $responseBody');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ImageIdUploadModel.fromJson(data);
    } else {
      throw Exception(
        data['message'] ?? 'Image upload failed: ${data['errors']}',
      );
    }
  }

  Future<AuthResponseModel?> register(
    String phone,
    String firstName,
    String lastName,
    String username,
    String password,
    String confirmedPassword,
    String dateOfBirth,
    File idPhoto,
    File personalPhotoPath,
  ) async {
    final idPhotoResult = await UploadIdImage(idPhoto, '1', 'id-photo');
    final int? idPhotoID = idPhotoResult!.id;

    final personalPhotoResult = await UploadIdImage(
      personalPhotoPath,
      '1',
      'personal-photo',
    );
    final int? personalPhotoID = personalPhotoResult!.id;

    final registerUrl = Uri.parse('$baseUrl/auth/register');

    var request = http.MultipartRequest('POST', registerUrl);
    /* request.headers.addAll({'Accept': 'application/json'}); */

    final Map<String, dynamic> body = {
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'password': password,
      'password_confirmation': confirmedPassword,
      'date_of_birth': dateOfBirth,

      'id_photo': idPhotoID,
      'personal_photo': personalPhotoID,
    };

    final response = await http.post(
      registerUrl,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResponseModel.fromJson(data['data']);
    } else {
      print('Registration Failed Details: ${data['errors']}');
      throw Exception(data['message'] ?? 'register failed');
    }
  }
}
