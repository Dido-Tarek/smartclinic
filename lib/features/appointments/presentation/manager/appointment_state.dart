import 'package:equatable/equatable.dart';
import 'package:smartclinic/features/appointments/data/model/appointment_response_model.dart';

abstract class AppointmentsState extends Equatable {
  const AppointmentsState();

  @override
  List<Object?> get props => [];
}

// ── Shared ────────────────────────────────────────────────────────────────────

class AppointmentsInitial extends AppointmentsState {
  const AppointmentsInitial();
}

// ── Book appointment ──────────────────────────────────────────────────────────

class BookAppointmentLoading extends AppointmentsState {
  const BookAppointmentLoading();
}

class BookAppointmentSuccess extends AppointmentsState {
  final BookAppointmentResponseModel appointment;

  const BookAppointmentSuccess(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

class BookAppointmentFailure extends AppointmentsState {
  final String errorMessage;

  const BookAppointmentFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// ── My appointments ───────────────────────────────────────────────────────────

class GetMyAppointmentsLoading extends AppointmentsState {
  const GetMyAppointmentsLoading();
}

class GetMyAppointmentsSuccess extends AppointmentsState {
  final MyAppointmentsResponseModel response;

  const GetMyAppointmentsSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class GetMyAppointmentsFailure extends AppointmentsState {
  final String errorMessage;

  const GetMyAppointmentsFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// ── Doctor requests ───────────────────────────────────────────────────────────

class GetDoctorRequestsLoading extends AppointmentsState {
  const GetDoctorRequestsLoading();
}

class GetDoctorRequestsSuccess extends AppointmentsState {
  final DoctorRequestsResponseModel response;

  const GetDoctorRequestsSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class GetDoctorRequestsFailure extends AppointmentsState {
  final String errorMessage;

  const GetDoctorRequestsFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// ── Update status ─────────────────────────────────────────────────────────────

class UpdateAppointmentStatusLoading extends AppointmentsState {
  const UpdateAppointmentStatusLoading();
}

class UpdateAppointmentStatusSuccess extends AppointmentsState {
  final UpdateAppointmentStatusResponseModel appointment;

  const UpdateAppointmentStatusSuccess(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

class UpdateAppointmentStatusFailure extends AppointmentsState {
  final String errorMessage;

  const UpdateAppointmentStatusFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// ── Cancel appointment ────────────────────────────────────────────────────────

class CancelAppointmentLoading extends AppointmentsState {
  const CancelAppointmentLoading();
}

class CancelAppointmentSuccess extends AppointmentsState {
  final CancelAppointmentResponseModel response;

  const CancelAppointmentSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class CancelAppointmentFailure extends AppointmentsState {
  final String errorMessage;

  const CancelAppointmentFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// ── Available slots ───────────────────────────────────────────────────────────

class GetAvailableSlotsLoading extends AppointmentsState {
  const GetAvailableSlotsLoading();
}

class GetAvailableSlotsSuccess extends AppointmentsState {
  final AvailableSlotsResponseModel response;

  const GetAvailableSlotsSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class GetAvailableSlotsFailure extends AppointmentsState {
  final String errorMessage;

  const GetAvailableSlotsFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// ── Queue position ────────────────────────────────────────────────────────────

class GetQueuePositionLoading extends AppointmentsState {
  const GetQueuePositionLoading();
}

class GetQueuePositionSuccess extends AppointmentsState {
  final QueuePositionResponseModel response;

  const GetQueuePositionSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class GetQueuePositionFailure extends AppointmentsState {
  final String errorMessage;

  const GetQueuePositionFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
