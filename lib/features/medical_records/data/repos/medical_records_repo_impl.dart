import 'dart:io';

import 'package:dio/dio.dart';
import 'package:smartclinic/features/medical_records/data/model/medical_records_response.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../api/medical_records_api_service.dart';
import '../../domain/repos/medical_records_repo.dart';

class MedicalRecordsRepoImpl implements MedicalRecordsRepo {
  final MedicalRecordsApiService _apiService;

  MedicalRecordsRepoImpl(this._apiService);

  @override
  Future<ApiResult<UploadRecordResponse>> uploadRecord({
    required File file,
    required String title,
    required String description,
    required String patientId,
    int? appointmentId,
    String? doctorId,
  }) async {
    try {
      // تحويل الملف إلى MultipartFile للرفع
      final multipartFile = await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      );

      final response = await _apiService.uploadMedicalRecord(
        file: multipartFile,
        title: title,
        description: description,
        patientId: patientId,
        appointmentId: appointmentId,
        doctorId: doctorId,
      );

      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<List<UploadRecordResponse>>> getPatientRecords(
    String patientId,
  ) async {
    try {
      final response = await _apiService.getPatientRecords(patientId);
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
