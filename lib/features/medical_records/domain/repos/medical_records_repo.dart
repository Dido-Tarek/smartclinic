import 'package:smartclinic/features/medical_records/data/model/medical_records_request.dart';
import 'package:smartclinic/features/medical_records/data/model/medical_records_response.dart';
import '../../../../core/network/api_result.dart';

abstract class MedicalRecordsRepo {
  Future<ApiResult<UploadRecordResponse>> uploadRecord(
    MedicalRecordRequestModel request,
  );

  Future<ApiResult<List<UploadRecordResponse>>> getPatientRecords(
    String patientId,
  );

  Future<ApiResult<void>> deleteMedicalRecord(int id);
}
