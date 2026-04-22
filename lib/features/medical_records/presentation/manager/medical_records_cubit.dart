import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/medical_records/domain/repos/medical_records_repo.dart';
import 'package:smartclinic/features/medical_records/presentation/manager/medical_records_state.dart';

class MedicalRecordsCubit extends Cubit<MedicalRecordsState> {
  final MedicalRecordsRepo _repo;
  MedicalRecordsCubit(this._repo) : super(const MedicalRecordsState.initial());

  Future<void> emitUploadRecord({
    required File file,
    required String title,
    required String description,
    required String patientId,
    int? appointmentId,
    String? doctorId,
  }) async {
    emit(const MedicalRecordsState.loading());
    final result = await _repo.uploadRecord(
      file: file,
      title: title,
      description: description,
      patientId: patientId,
      appointmentId: appointmentId,
      doctorId: doctorId,
    );
    result.when(
      success: (data) => emit(MedicalRecordsState.success(data)),
      failure: (error) => emit(MedicalRecordsState.error(message: error)),
    );
  }
}
