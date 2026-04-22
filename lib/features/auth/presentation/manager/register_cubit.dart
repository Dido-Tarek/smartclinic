import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/auth/domain/auth_repo.dart';
import 'package:smartclinic/features/registeration/data/model/medical_facility_register_model.dart';
import 'package:smartclinic/features/registeration/data/model/patient_register_model.dart';

import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepo _authRepo;

  RegisterCubit(this._authRepo) : super(const RegisterState.initial());

  // دالة تسجيل المريض
  Future<void> emitRegisterPatient(
    PatientRegisterRequestModel patientModel,
  ) async {
    emit(const RegisterState.loading());

    final response = await _authRepo.registerPatient(patientModel);

    response.when(
      success: (data) {
        emit(RegisterState.success(data));
      },
      failure: (message) {
        emit(RegisterState.error(message: message));
      },
    );
  }

  // دالة تسجيل المنشأة الطبية
  // Future<void> emitRegisterFacility(
  //   MedicalFacilityRegisterModel facilityModel,
  // ) async {
  //   emit(const RegisterState.loading());

  //   final response = await _authRepo.registerFacility(facilityModel);

  //   response.when(
  //     success: (data) {
  //       emit(RegisterState.success(data));
  //     },
  //     failure: (message) {
  //       emit(RegisterState.error(message: message));
  //     },
  //   );
  // }
}
