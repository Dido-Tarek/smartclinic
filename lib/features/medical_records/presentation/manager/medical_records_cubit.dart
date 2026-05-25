import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/medical_records/data/model/medical_records_request.dart';
import 'package:smartclinic/features/medical_records/data/model/medical_records_response.dart';
import 'package:smartclinic/features/medical_records/domain/repos/medical_records_repo.dart';
import 'package:smartclinic/features/medical_records/presentation/manager/medical_records_state.dart';

class MedicalRecordsCubit extends Cubit<MedicalRecordsState> {
  final MedicalRecordsRepo _repo;
  MedicalRecordsCubit(this._repo) : super(const MedicalRecordsState.initial());

  Future<void> emitUploadRecord({
    required MedicalRecordRequestModel request,
  }) async {
    emit(const MedicalRecordsState.loading());
    final result = await _repo.uploadRecord(request);
    result.when(
      success: (data) => emit(MedicalRecordsState.success(data)),
      failure: (error) => emit(MedicalRecordsState.error(message: error)),
    );
  }

  Future<List<UploadRecordResponse>> getMedicalRecords(String patientId) async {
    final result = await _repo.getPatientRecords(patientId);
    return result.when(
      success: (data) => data,
      failure: (error) => <UploadRecordResponse>[],
    );
  }

  Future<bool> deleteMedicalRecord(int id) async {
    final result = await _repo.deleteMedicalRecord(id);
    return result.when(success: (_) => true, failure: (_) => false);
  }
}
