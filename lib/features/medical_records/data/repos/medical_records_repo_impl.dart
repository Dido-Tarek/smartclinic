import 'package:dio/dio.dart';
import 'package:smartclinic/features/medical_records/data/model/medical_records_request.dart';
import 'package:smartclinic/features/medical_records/data/model/medical_records_response.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../api/medical_records_api_service.dart';
import '../../domain/repos/medical_records_repo.dart';

class MedicalRecordsRepoImpl implements MedicalRecordsRepo {
  final MedicalRecordsApiService _apiService;

  MedicalRecordsRepoImpl(this._apiService);

  @override
  Future<ApiResult<UploadRecordResponse>> uploadRecord(
    MedicalRecordRequestModel request,
  ) async {
    try {
      if (!request.isValid) {
        return ApiResult.failure(
          'Please complete all medical record fields before uploading.',
        );
      }

      // تحويل الملف إلى MultipartFile للرفع
      final multipartFile = await MultipartFile.fromFile(
        request.file.path,
        filename: request.file.path.split(RegExp(r'[\\/]')).last,
      );

      // Log outgoing upload params for debugging server validation issues
      try {
        // ignore: avoid_print
        print(
          'Uploading medical record: filename=${multipartFile.filename}, title=${request.title}, patientId=${request.patientId}, appointmentId=${request.appointmentId}, doctorId=${request.doctorId}',
        );
      } catch (_) {}

      final response = await _apiService.uploadMedicalRecord(
        file: multipartFile,
        title: request.title.trim(),
        description: request.description.trim(),
        patientId: request.patientId.trim(),
        appointmentId: request.appointmentId,
        doctorId: request.doctorId?.trim(),
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

  @override
  Future<ApiResult<void>> deleteMedicalRecord(int id) async {
    try {
      await _apiService.deleteMedicalRecord(id);
      return const ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
