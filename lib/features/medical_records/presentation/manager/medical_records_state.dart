import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartclinic/features/medical_records/data/model/medical_records_response.dart';

part 'medical_records_state.freezed.dart';

@freezed
class MedicalRecordsState with _$MedicalRecordsState {
  const factory MedicalRecordsState.initial() = _Initial;
  const factory MedicalRecordsState.loading() = _Loading;
  const factory MedicalRecordsState.success(UploadRecordResponse data) =
      _Success;
  const factory MedicalRecordsState.error({required String message}) = _Error;
}
