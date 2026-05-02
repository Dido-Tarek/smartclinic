import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/auth/domain/auth_repo.dart';
import 'package:smartclinic/features/registeration/data/model/medical_facility_register_model.dart';
import 'package:smartclinic/features/registeration/data/model/patient_register_model.dart';

import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepo _authRepo;
  String _selectedRole = 'Patient';
  dynamic _lastRegistrationData;

  RegisterCubit(this._authRepo) : super(const RegisterState.initial());

  String get selectedRole => _selectedRole;

  dynamic get lastRegistrationData => _lastRegistrationData;

  void setSelectedRole(String role) {
    final normalized = role.trim();
    _selectedRole = normalized.isEmpty ? 'Patient' : normalized;
  }

  // دالة تسجيل المريض
  Future<void> emitRegisterPatient(
    PatientRegisterRequestModel patientModel,
  ) async {
    emit(const RegisterState.loading());

    final response = await _authRepo.registerPatient(patientModel);

    response.when(
      success: (data) {
        _lastRegistrationData = data;
        emit(RegisterState.success(data));
      },
      failure: (message) {
        emit(RegisterState.error(message: message));
      },
    );
  }

  // دالة تسجيل المنشأة الطبية
  Future<void> emitRegisterFacility(
    MedicalFacilityRequestModel facilityModel,
  ) async {
    emit(const RegisterState.loading());

    final response = await _authRepo.registerFacility(facilityModel);

    response.when(
      success: (data) {
        _lastRegistrationData = data;
        emit(RegisterState.success(data));
      },
      failure: (message) {
        emit(RegisterState.error(message: message));
      },
    );
  }
}
