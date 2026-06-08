import 'package:dio/dio.dart';
import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/clinic/data/api/clinic_api_service.dart';
import 'package:smartclinic/features/clinic/data/model/add_clinic_request_model.dart';
import 'package:smartclinic/features/clinic/data/model/add_clinic_response_model.dart';
import 'package:smartclinic/features/clinic/domain/facility_repo.dart';

class FacilityRepoImpl implements FacilityRepo {
  final ClinicApiService _apiService;

  FacilityRepoImpl(this._apiService);

  @override
  Future<ApiResult<AddClinicResponseModel>> addNewClinic(
    AddClinicRequestModel model,
  ) async {
    try {
      final response = await _apiService.addClinic(
        model.name,
        model.address,
        model.phoneNumber,
        model.city,
        model.area,
        model.isOwner,
        // تحويل الصور والملفات القانونية لـ MultipartFile
        clinicImage: model.clinicImage != null
            ? await MultipartFile.fromFile(model.clinicImage!.path)
            : null,
        latitude: model.latitude,
        longitude: model.longitude,
        specialization: model.specialization,
        sessionDuration: model.sessionDuration,
        legalDocument1: model.legalDocument1 != null
            ? await MultipartFile.fromFile(model.legalDocument1!.path)
            : null,
        legalDocument2: model.legalDocument2 != null
            ? await MultipartFile.fromFile(model.legalDocument2!.path)
            : null,
        legalDocument3: model.legalDocument3 != null
            ? await MultipartFile.fromFile(model.legalDocument3!.path)
            : null,
        clinicFee: model.clinicFee,
        onlineFee: model.onlineFee,
        homeVisitFee: model.homeVisitFee,
        followUpFee: model.followUpFee,
        emergencyFee: model.emergencyFee,
      );

      return ApiResult.success(AddClinicResponseModel.fromJson(response as Map<String, dynamic>));
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
