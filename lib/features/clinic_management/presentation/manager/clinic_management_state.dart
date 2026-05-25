import 'package:equatable/equatable.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_response_model.dart';

abstract class ClinicManagementState extends Equatable {
  const ClinicManagementState();
  @override
  List<Object?> get props => [];
}

class ClinicManagementInitial extends ClinicManagementState {
  const ClinicManagementInitial();
}

// ── Send employment request ───────────────────────────────────────────────────
class SendEmploymentLoading extends ClinicManagementState {
  const SendEmploymentLoading();
}

class SendEmploymentSuccess extends ClinicManagementState {
  final SendEmploymentResponseModel response;
  const SendEmploymentSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class SendEmploymentFailure extends ClinicManagementState {
  final String errorMessage;
  const SendEmploymentFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

// ── Get my employment requests ────────────────────────────────────────────────
class GetMyEmploymentRequestsLoading extends ClinicManagementState {
  const GetMyEmploymentRequestsLoading();
}

class GetMyEmploymentRequestsSuccess extends ClinicManagementState {
  final MyEmploymentRequestsResponseModel response;
  const GetMyEmploymentRequestsSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class GetMyEmploymentRequestsFailure extends ClinicManagementState {
  final String errorMessage;
  const GetMyEmploymentRequestsFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

// ── Respond to employment ─────────────────────────────────────────────────────
class RespondToEmploymentLoading extends ClinicManagementState {
  const RespondToEmploymentLoading();
}

class RespondToEmploymentSuccess extends ClinicManagementState {
  final RespondToEmploymentResponseModel response;
  const RespondToEmploymentSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class RespondToEmploymentFailure extends ClinicManagementState {
  final String errorMessage;
  const RespondToEmploymentFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

// ── Get my clinics ────────────────────────────────────────────────────────────
class GetMyClinicsLoading extends ClinicManagementState {
  const GetMyClinicsLoading();
}

class GetMyClinicsSuccess extends ClinicManagementState {
  final MyClinicsResponseModel response;
  const GetMyClinicsSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class GetMyClinicsFailure extends ClinicManagementState {
  final String errorMessage;
  const GetMyClinicsFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

// ── Remove clinic ─────────────────────────────────────────────────────────────
class RemoveClinicLoading extends ClinicManagementState {
  final int removingId;
  const RemoveClinicLoading(this.removingId);
  @override
  List<Object?> get props => [removingId];
}

class RemoveClinicSuccess extends ClinicManagementState {
  final RemoveClinicResponseModel response;
  final int removedId;
  const RemoveClinicSuccess(this.response, this.removedId);
  @override
  List<Object?> get props => [response, removedId];
}

class RemoveClinicFailure extends ClinicManagementState {
  final String errorMessage;
  const RemoveClinicFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

// ── Update clinic profile ─────────────────────────────────────────────────────
class UpdateClinicProfileLoading extends ClinicManagementState {
  const UpdateClinicProfileLoading();
}

class UpdateClinicProfileSuccess extends ClinicManagementState {
  final UpdateClinicProfileResponseModel response;
  const UpdateClinicProfileSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class UpdateClinicProfileFailure extends ClinicManagementState {
  final String errorMessage;
  const UpdateClinicProfileFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

// ── Update financial terms ────────────────────────────────────────────────────
class UpdateFinancialTermsLoading extends ClinicManagementState {
  const UpdateFinancialTermsLoading();
}

class UpdateFinancialTermsSuccess extends ClinicManagementState {
  final UpdateFinancialTermsResponseModel response;
  const UpdateFinancialTermsSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class UpdateFinancialTermsFailure extends ClinicManagementState {
  final String errorMessage;
  const UpdateFinancialTermsFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

// ── Update doctor schedule ────────────────────────────────────────────────────
class UpdateDoctorScheduleLoading extends ClinicManagementState {
  const UpdateDoctorScheduleLoading();
}

class UpdateDoctorScheduleSuccess extends ClinicManagementState {
  final UpdateDoctorScheduleResponseModel response;
  const UpdateDoctorScheduleSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class UpdateDoctorScheduleFailure extends ClinicManagementState {
  final String errorMessage;
  const UpdateDoctorScheduleFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

// ── Add schedule ──────────────────────────────────────────────────────────────
class AddScheduleLoading extends ClinicManagementState {
  const AddScheduleLoading();
}

class AddScheduleSuccess extends ClinicManagementState {
  final AddScheduleResponseModel response;
  const AddScheduleSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class AddScheduleFailure extends ClinicManagementState {
  final String errorMessage;
  const AddScheduleFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

// ── Delete schedule ───────────────────────────────────────────────────────────
class DeleteScheduleLoading extends ClinicManagementState {
  final int deletingId;
  const DeleteScheduleLoading(this.deletingId);
  @override
  List<Object?> get props => [deletingId];
}

class DeleteScheduleSuccess extends ClinicManagementState {
  final DeleteScheduleResponseModel response;
  final int deletedId;
  const DeleteScheduleSuccess(this.response, this.deletedId);
  @override
  List<Object?> get props => [response, deletedId];
}

class DeleteScheduleFailure extends ClinicManagementState {
  final String errorMessage;
  const DeleteScheduleFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

// ── Doctor availability ───────────────────────────────────────────────────────
class GetDoctorAvailabilityLoading extends ClinicManagementState {
  const GetDoctorAvailabilityLoading();
}

class GetDoctorAvailabilitySuccess extends ClinicManagementState {
  final DoctorAvailabilityResponseModel response;
  const GetDoctorAvailabilitySuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class GetDoctorAvailabilityFailure extends ClinicManagementState {
  final String errorMessage;
  const GetDoctorAvailabilityFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}
