import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/features/clinic_admin/data/model/clinic_admin_request_model.dart';
import 'package:smartclinic/features/clinic_admin/data/repo/clinic_admin_repo.dart';

import 'clinic_admin_state.dart';

class ClinicAdminCubit extends Cubit<ClinicAdminState> {
  final ClinicAdminRepo _repo;

  ClinicAdminCubit(this._repo) : super(const ClinicAdminInitial());

  // ── GET /api/ClinicAdmin/full-dashboard/{clinicId} ───────────────────────
  /// Primary init call — loads the full dashboard in one shot.
  Future<void> getFullDashboard(int clinicId) async {
    emit(const GetFullDashboardLoading());
    final result = await _repo.getFullDashboard(clinicId);
    result.fold(
      (e) => emit(GetFullDashboardFailure(e)),
      (r) => emit(GetFullDashboardSuccess(r)),
    );
  }

  // ── GET /api/ClinicAdmin/today-queue/{clinicId} ──────────────────────────
  Future<void> getTodayQueue(int clinicId) async {
    emit(const GetTodayQueueLoading());
    final result = await _repo.getTodayQueue(clinicId);
    result.fold(
      (e) => emit(GetTodayQueueFailure(e)),
      (r) => emit(GetTodayQueueSuccess(r)),
    );
  }

  // ── GET /api/ClinicAdmin/{clinicId}/staff ────────────────────────────────
  Future<void> getClinicStaff(int clinicId) async {
    emit(const GetClinicStaffLoading());
    final result = await _repo.getClinicStaff(clinicId);
    result.fold(
      (e) => emit(GetClinicStaffFailure(e)),
      (r) => emit(GetClinicStaffSuccess(r)),
    );
  }

  // ── DELETE /api/ClinicAdmin/remove-doctor ────────────────────────────────
  Future<void> removeDoctor({
    required int clinicId,
    required String doctorId,
  }) async {
    emit(RemoveDoctorLoading(doctorId));
    final result = await _repo.removeDoctor(
      RemoveDoctorRequestModel(clinicId: clinicId, doctorId: doctorId),
    );
    result.fold((e) => emit(RemoveDoctorFailure(e)), (r) {
      emit(RemoveDoctorSuccess(r, doctorId));
      // Refresh staff list after removal
      getClinicStaff(clinicId);
    });
  }

  // ── GET /api/ClinicAdmin/find-doctor ─────────────────────────────────────
  Future<void> findDoctor(String contactInfo) async {
    if (contactInfo.trim().isEmpty) return;
    emit(const FindDoctorLoading());
    final result = await _repo.findDoctor(contactInfo.trim());
    result.fold(
      (e) => emit(FindDoctorFailure(e)),
      (r) => emit(FindDoctorSuccess(r)),
    );
  }

  // ── PUT /api/ClinicAdmin/collect-payment/{invoiceId} ─────────────────────
  Future<void> collectPayment(int invoiceId) async {
    emit(CollectPaymentLoading(invoiceId));
    final result = await _repo.collectPayment(invoiceId);
    result.fold(
      (e) => emit(CollectPaymentFailure(e)),
      (r) => emit(CollectPaymentSuccess(r)),
    );
  }

  void reset() => emit(const ClinicAdminInitial());
}
