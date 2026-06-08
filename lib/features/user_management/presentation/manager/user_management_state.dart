import 'package:smartclinic/features/user_management/data/model/doctor_profile_response_model.dart';
import 'package:smartclinic/features/user_management/data/model/patient_profile_response_model.dart';

abstract class UserManagementState {}

class UserManagementInitial extends UserManagementState {}

class UserManagementLoading extends UserManagementState {}

class UserManagementError extends UserManagementState {
  final String message;
  UserManagementError(this.message);
}

class UserManagementSuccess extends UserManagementState {}

class LogoutSuccess extends UserManagementState {}

class ProfileLoaded extends UserManagementState {
  final DoctorProfileModel profile;
  ProfileLoaded(this.profile);
}

class PatientProfileLoaded extends UserManagementState {
  final PatientProfileModel profile;
  PatientProfileLoaded(this.profile);
}
