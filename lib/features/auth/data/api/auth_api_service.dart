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

  // تسجيل منشأة طبية
  @POST("{url}")
  @MultiPart()
  Future<dynamic> registerFacility({
    @Path("url") required String url,
    @Part(name: "FullName") required String name,
    @Part(name: "Email") required String email,
    @Part(name: "Password") required String password,
    @Part(name: "ConfirmPassword") String confirmPassword,
    @Part(name: "Gender") required gender,
    @Part(name: "BirthDate") required birthDate,
    @Part(name: "PhoneNumber") required String phoneNumber,
    @Part(name: "Address") required String address,
    @Part(name: "Specialization") required String specialization,
    @Part(name: "NationalidFront") required File nationalIdFront,
    @Part(name: "NationalidBack") required File nationalIdBack,
  });

  // تسجيل الدخول (Login)
  @POST("api/Auth/Login")
  Future<dynamic> login(@Body() LoginRequestModel loginRequestBody);
}
