import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/registeration/data/model/medical_facility_register_model.dart';
import 'package:smartclinic/features/registeration/data/model/patient_register_model.dart';
import 'package:smartclinic/features/auth/data/api/auth_api_service.dart';
import 'package:smartclinic/features/auth/data/models/login_request_model.dart';
import 'auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final AuthApiService _apiService;

  AuthRepoImpl(this._apiService);

  @override
  Future<ApiResult<dynamic>> registerPatient(
    PatientRegisterRequestModel patientModel,
  ) async {
    try {
      final response = await _apiService.registerPatient(
        fullName: patientModel.fullName,
        email: patientModel.email,
        password: patientModel.password,
        confirmPassword: patientModel.confirmPassword,
        phoneNumber: patientModel.phone,
        address: patientModel.address,
        birthDate: patientModel.birthDate,
        gender: patientModel.gender,
        bloodGroup: patientModel.bloodGroup,
        nationalIdFront: patientModel.nationalIdFront,
        nationalIdBack: patientModel.nationalIdBack,
      );
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  // @override
  // Future<ApiResult<dynamic>> registerFacility(
  //   MedicalFacilityRegisterModel facilityModel,
  // ) async {
  //   try {
  //     final response = await _apiService.registerFacility(facilityModel);
  //     return ApiResult.success(response);
  //   } catch (error) {
  //     return ApiResult.failure(ApiErrorHandler.handle(error));
  //   }
  // }

  @override
  Future<ApiResult<dynamic>> login(String email, String password) async {
    try {
      final loginRequest = LoginRequestModel(email: email, password: password);
      final response = await _apiService.login(loginRequest);
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
