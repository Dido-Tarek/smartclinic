import 'dart:io';

import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/auth/data/models/facility_claim_ownership_request.dart.dart';
import 'package:smartclinic/features/auth/data/models/verification_file_model.dart';
import 'package:smartclinic/features/registeration/data/model/medical_facility_register_model.dart';
import 'package:smartclinic/features/registeration/data/model/patient_register_model.dart';
import 'package:smartclinic/features/auth/data/api/auth_api_service.dart';
import 'package:smartclinic/features/auth/data/models/login_request_model.dart';
import 'package:smartclinic/injection_dependency.dart';
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

  @override
  Future<ApiResult<dynamic>> registerFacility(
    MedicalFacilityRequestModel facilityModel,
  ) async {
    final selectedRole = _normalizeFacilityRole(
      getIt<UserSession>().roleString,
    );
    try {
      final response = selectedRole == UserRole.doctor
          ? await _apiService.registerDoctor(
              name: facilityModel.fullname,
              email: facilityModel.email,
              password: facilityModel.password,
              confirmPassword: facilityModel.confirmPassword,
              address: facilityModel.address,
              phoneNumber: facilityModel.phone,
              specialization: facilityModel.specialization,
              birthDate: facilityModel.birthDate,
              gender: facilityModel.gender,
              nationalIdFront: facilityModel.nationalIdFront,
              nationalIdBack: facilityModel.nationalIdBack,
            )
          : await _apiService.registerClinicAdmin(
              name: facilityModel.fullname,
              email: facilityModel.email,
              password: facilityModel.password,
              confirmPassword: facilityModel.confirmPassword,
              address: facilityModel.address,
              phoneNumber: facilityModel.phone,
              specialization: facilityModel.specialization,
              birthDate: facilityModel.birthDate,
              gender: facilityModel.gender,
              nationalIdFront: facilityModel.nationalIdFront,
              nationalIdBack: facilityModel.nationalIdBack,
            );
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  UserRole _normalizeFacilityRole(String? role) {
    switch (role?.trim()) {
      case 'Doctor':
        return UserRole.doctor;
      case 'Hospital':
      case 'MedicalFacility':
      case 'ClinicAdmin':
        return UserRole.hospital;
      default:
        return UserRole.hospital;
    }
  }

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

  @override
  Future<ApiResult<dynamic>> uploadVerificationDocs({
    required String doctorId,
    required VerificationFileModel files,
  }) async {
    try {
      final response = await _apiService.uploadVerificationDocs(
        doctorId: doctorId,
        syndicatCard: files.syndicatCard,
        license: files.license,
        nationalId: files.nationalId,
        specializationCert: files.specializationCert,
      );
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<List<dynamic>>> getPendingDoctors() async {
    try {
      final response = await _apiService.getPendingDoctors();
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult> uploadFacilityCredentials({
    required bool isClaiming,
    required targetId,
    required FacilityClaimOwnershipRequest request,
  }) async {
    try {
      if (isClaiming) {
        // API: claim-ownership
        final response = await _apiService.claimClinicOwnership(
          clinicId: targetId as int,
          legalDoc1: request.file1,
          legalDoc2: request.file2,
          legalDoc3: request.file3,
        );
        return ApiResult.success(response);
      } else {
        // API: upload-owner-docs
        final response = await _apiService.uploadOwnerDocs(
          userId: targetId as String,
          medicalLicense: request.file1,
          commerialRegister: request.file2,
          taxCard: request.file3,
        );
        return ApiResult.success(response);
      }
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
