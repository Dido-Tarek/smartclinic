import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'clinic_api_service.g.dart';

@RestApi(baseUrl: "http://smartclinicccc.runasp.net/")
abstract class ClinicApiService {
  factory ClinicApiService(Dio dio, {String baseUrl}) = _ClinicApiService;

  @POST("api/clinics/add")
  @MultiPart()
  Future<dynamic> addClinic(
    @Part(name: "Name") String name,
    @Part(name: "Address") String address,
    @Part(name: "PhoneNumber") String phoneNumber,
    @Part(name: "City") String city,
    @Part(name: "Area") String area,
    @Part(name: "IsOwner") bool isOwner, {
    @Part(name: "ClinicImage") MultipartFile? clinicImage,
    @Part(name: "Latitude") double? latitude,
    @Part(name: "Longitude") double? longitude,
    @Part(name: "Specialization") String? specialization,
    @Part(name: "SessionDuration") int? sessionDuration,
    @Part(name: "LegalDocument1") MultipartFile? legalDocument1,
    @Part(name: "LegalDocument2") MultipartFile? legalDocument2,
    @Part(name: "LegalDocument3") MultipartFile? legalDocument3,
    @Part(name: "ClinicFee") double? clinicFee,
    @Part(name: "OnlineFee") double? onlineFee,
    @Part(name: "HomeVisitFee") double? homeVisitFee,
    @Part(name: "FollowUpFee") double? followUpFee,
    @Part(name: "EmergencyFee") double? emergencyFee,
  });
}
