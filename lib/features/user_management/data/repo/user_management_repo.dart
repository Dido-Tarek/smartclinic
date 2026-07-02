import 'dart:io';

import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:smartclinic/features/user_management/data/api/user_management_api_service.dart';
import 'package:smartclinic/features/user_management/data/model/doctor_profile_response_model.dart';
import 'package:smartclinic/features/user_management/data/model/patient_profile_response_model.dart';
import 'package:smartclinic/features/user_management/data/model/reset_password_request_model.dart';

class UserManagementRepo {
  final UserManagementApiService _apiService;
  UserManagementRepo(this._apiService);

  Future<ApiResult<void>> logout() async {
    try {
      await _apiService.logout();
      return const ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  Future<ApiResult<String>> forgotPassword(String email) async {
    try {
      final response = await _apiService.forgotPassword(email);
      // Response returns { "message": "...", "debugToken": "..." }
      final token = response.data['debugToken'] as String?;
      return ApiResult.success(token ?? '');
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  Future<ApiResult<DoctorProfileModel>> getProfile(String id) async {
    try {
      final response = await _apiService.getDoctorProfile(id);
      return ApiResult.success(DoctorProfileModel.fromJson(response.data));
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  Future<ApiResult<PatientProfileModel>> getPatientProfile() async {
    try {
      final response = await _apiService.getPatientProfile();
      return ApiResult.success(PatientProfileModel.fromJson(response.data));
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  Future<ApiResult<dynamic>> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _apiService.resetPassword(request);
      return ApiResult.success(response.data);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  Future<ApiResult<void>> updateDoctorProfile(
    Map<String, dynamic> data,
    File? image,
  ) async {
    try {
      await _apiService.updateDoctorProfile(data, image);
      return const ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  Future<ApiResult<void>> updatePatientProfile(
    Map<String, dynamic> data,
    File? image,
  ) async {
    try {
      await _apiService.updatePatientProfile(data, image);
      return const ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
