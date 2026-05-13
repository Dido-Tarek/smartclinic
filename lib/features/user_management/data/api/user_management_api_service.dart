import 'dart:io';
import 'package:dio/dio.dart';
import 'package:smartclinic/features/user_management/data/model/reset_password_request_model.dart';

class UserManagementApiService {
  final Dio _dio;
  UserManagementApiService(this._dio);

  Future<Response> forgotPassword(String email) async {
    return await _dio.post('/api/Auth/forgot-password', data: email);
  }

  Future<Response> resetPassword(ResetPasswordRequest request) async {
    return await _dio.post('/api/Auth/reset-password', data: request.toJson());
  }

  Future<Response> logout() async {
    return await _dio.post('/api/Auth/logout');
  }

  Future<Response> getDoctorProfile(String id) async {
    return await _dio.get('/api/Doctors/profile/$id');
  }

  Future<Response> updateDoctorProfile(
    Map<String, dynamic> data,
    File? image,
  ) async {
    FormData formData = FormData.fromMap({
      ...data, // يشمل الحقول مثل FullName, ClinicFee وغيرها
      if (image != null)
        'ProfileImage': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
    });
    return await _dio.post('/api/Doctors/update-profile', data: formData);
  }
}
