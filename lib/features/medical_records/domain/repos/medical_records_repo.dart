import 'dart:io';
import 'package:smartclinic/features/medical_records/data/model/medical_records_response.dart';
import '../../../../core/network/api_result.dart';

abstract class MedicalRecordsRepo {
  Future<ApiResult<UploadRecordResponse>> uploadRecord({
    required File file,
    required String title,
    required String description,
    required String patientId,
    int? appointmentId,
    String? doctorId,
  });

  Future<ApiResult<List<UploadRecordResponse>>> getPatientRecords(
    String patientId,
  );
}
