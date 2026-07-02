import 'package:equatable/equatable.dart';
import 'package:smartclinic/features/clinic_admin/data/model/clinic_admin_response_model.dart';

abstract class ClinicAdminState extends Equatable {
  const ClinicAdminState();
  @override
  List<Object?> get props => [];
}

class ClinicAdminInitial extends ClinicAdminState {
  const ClinicAdminInitial();
}

// ── Full dashboard ────────────────────────────────────────────────────────────
class GetFullDashboardLoading extends ClinicAdminState {
  const GetFullDashboardLoading();
}

class GetFullDashboardSuccess extends ClinicAdminState {
  final FullDashboardResponseModel dashboard;
  const GetFullDashboardSuccess(this.dashboard);
  @override
  List<Object?> get props => [dashboard];
}

class GetFullDashboardFailure extends ClinicAdminState {
  final String errorMessage;
  const GetFullDashboardFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

// ── Today queue ───────────────────────────────────────────────────────────────
class GetTodayQueueLoading extends ClinicAdminState {
  const GetTodayQueueLoading();
}

class GetTodayQueueSuccess extends ClinicAdminState {
  final TodayQueueResponseModel response;
  const GetTodayQueueSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class GetTodayQueueFailure extends ClinicAdminState {
  final String errorMessage;
  const GetTodayQueueFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

// ── Clinic staff ──────────────────────────────────────────────────────────────
class GetClinicStaffLoading extends ClinicAdminState {
  const GetClinicStaffLoading();
}

class GetClinicStaffSuccess extends ClinicAdminState {
  final ClinicStaffResponseModel response;
  const GetClinicStaffSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class GetClinicStaffFailure extends ClinicAdminState {
  final String errorMessage;
  const GetClinicStaffFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

// ── Remove doctor ─────────────────────────────────────────────────────────────
class RemoveDoctorLoading extends ClinicAdminState {
  final String removingDoctorId;
  const RemoveDoctorLoading(this.removingDoctorId);
  @override
  List<Object?> get props => [removingDoctorId];
}

class RemoveDoctorSuccess extends ClinicAdminState {
  final RemoveDoctorResponseModel response;
  final String removedDoctorId;
  const RemoveDoctorSuccess(this.response, this.removedDoctorId);
  @override
  List<Object?> get props => [response, removedDoctorId];
}

class RemoveDoctorFailure extends ClinicAdminState {
  final String errorMessage;
  const RemoveDoctorFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

// ── Find doctor ───────────────────────────────────────────────────────────────
class FindDoctorLoading extends ClinicAdminState {
  const FindDoctorLoading();
}

class FindDoctorSuccess extends ClinicAdminState {
  final FindDoctorResponseModel response;
  const FindDoctorSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class FindDoctorFailure extends ClinicAdminState {
  final String errorMessage;
  const FindDoctorFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}

// ── Collect payment ───────────────────────────────────────────────────────────
class CollectPaymentLoading extends ClinicAdminState {
  final int invoiceId;
  const CollectPaymentLoading(this.invoiceId);
  @override
  List<Object?> get props => [invoiceId];
}

class CollectPaymentSuccess extends ClinicAdminState {
  final CollectPaymentResponseModel response;
  const CollectPaymentSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class CollectPaymentFailure extends ClinicAdminState {
  final String errorMessage;
  const CollectPaymentFailure(this.errorMessage);
  @override
  List<Object?> get props => [errorMessage];
}
