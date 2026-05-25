import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:smartclinic/features/auth/data/models/login_request_model.dart';

part 'auth_api_service.g.dart';

@RestApi(baseUrl: "http://smartclinicccc.runasp.net/")
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  // تسجيل مريض
  @POST("api/Auth/register-patient")
  @MultiPart()
  Future<dynamic> registerPatient({
    @Part(name: "FullName") required String fullName,
    @Part(name: "Email") required String email,
    @Part(name: "Password") required String password,
    @Part(name: "ConfirmPassword") required String confirmPassword,
    @Part(name: "PhoneNumber") required String phoneNumber,
    @Part(name: "Address") required String address,
    @Part(name: "BirthDate") required String birthDate,
    @Part(name: "Gender") required String gender,
    @Part(name: "BloodGroup") required String bloodGroup,
    @Part(name: "NationalIdFront") required File nationalIdFront,
    @Part(name: "NationalIdBack") required File nationalIdBack,
  });

  // تسجيل دكتور
  @POST("api/Auth/register-doctor")
  @MultiPart()
  Future<dynamic> registerDoctor({
    @Part(name: "FullName") required String name,
    @Part(name: "Email") required String email,
    @Part(name: "Password") required String password,
    @Part(name: "ConfirmPassword") required String confirmPassword,
    @Part(name: "Gender") required String gender,
    @Part(name: "BirthDate") required String birthDate,
    @Part(name: "PhoneNumber") required String phoneNumber,
    @Part(name: "Address") required String address,
    @Part(name: "Latitude") required String latitude,
    @Part(name: "Longitude") required String longitude,
    @Part(name: "Specialization") required String specialization,
    @Part(name: "NationalidFront") required File nationalIdFront,
    @Part(name: "NationalidBack") required File nationalIdBack,
  });

  // تسجيل منشأة طبية (Clinic Admin)
  @POST("api/Auth/register-clinic-admin")
  @MultiPart()
  Future<dynamic> registerClinicAdmin({
    @Part(name: "FullName") required String name,
    @Part(name: "Email") required String email,
    @Part(name: "Password") required String password,
    @Part(name: "ConfirmPassword") required String confirmPassword,
    @Part(name: "Gender") required String gender,
    @Part(name: "BirthDate") required String birthDate,
    @Part(name: "PhoneNumber") required String phoneNumber,
    @Part(name: "Address") required String address,
    @Part(name: "Latitude") required String latitude,
    @Part(name: "Longitude") required String longitude,
    @Part(name: "Specialization") required String specialization,
    @Part(name: "NationalidFront") required File nationalIdFront,
    @Part(name: "NationalidBack") required File nationalIdBack,
  });

  @POST("api/Auth/upload-verification-docs/{doctorId}")
  @MultiPart()
  Future<dynamic> uploadVerificationDocs({
    @Path("doctorId") required String doctorId,
    @Part(name: "syndicatCard") required File syndicatCard,
    @Part(name: "license") required File license,
    @Part(name: "nationalId") required File nationalId,
    @Part(name: "specializationCert") required File specializationCert,
  });

  @GET("api/Admin/pending-doctors")
  Future<List<dynamic>> getPendingDoctors();

  // تسجيل الدخول (Login)
  @POST("api/Auth/Login")
  Future<dynamic> login(@Body() LoginRequestModel loginRequestBody);

  // رفع مستندات التحقق للمالك (لمنشأة طبية)
  @POST("api/Auth/upload-owner-docs/{userId}")
  @MultiPart()
  Future<dynamic> uploadOwnerDocs({
    @Path("userId") required String userId,
    @Part(name: "medicalLicense") required File medicalLicense,
    @Part(name: "commercialRegister") required File commerialRegister,
    @Part(name: "taxCard") required File taxCard,
  });

  // مطالبة ملكية منشأة طبية (للطبيب الذي يدير منشأة طبية غير مسجلة)
  @POST("api/Clinics/claim-ownership/{clinicId}")
  @MultiPart()
  Future<dynamic> claimClinicOwnership({
    @Path("clinicId") required int clinicId,
    @Part(name: "LegalDoc1") required File legalDoc1,
    @Part(name: "LegalDoc2") required File legalDoc2,
    @Part(name: "LegalDoc3") required File legalDoc3,
  });
}
