import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_request_model.dart';
import 'package:smartclinic/features/clinic_management/data/repo/clinic_management_repo.dart';
import 'clinic_management_state.dart';

class ClinicManagementCubit extends Cubit<ClinicManagementState> {
  final ClinicManagementRepo _repo;

  ClinicManagementCubit(this._repo) : super(const ClinicManagementInitial());

  // ── POST /api/Clinics/send-employment-request ────────────────────────────
  Future<void> sendEmploymentRequest(SendEmploymentRequestModel request) async {
    emit(const SendEmploymentLoading());
    final result = await _repo.sendEmploymentRequest(request);
    result.fold(
      (e) => emit(SendEmploymentFailure(e)),
      (r) => emit(SendEmploymentSuccess(r)),
    );
  }

  // ── GET /api/Clinics/my-employment-requests ──────────────────────────────
  Future<void> getMyEmploymentRequests() async {
    emit(const GetMyEmploymentRequestsLoading());
    final result = await _repo.getMyEmploymentRequests();
    result.fold(
      (e) => emit(GetMyEmploymentRequestsFailure(e)),
      (r) => emit(GetMyEmploymentRequestsSuccess(r)),
    );
  }

  // ── POST /api/Clinics/respond-to-employment ──────────────────────────────
  Future<void> respondToEmployment({
    required int requestId,
    required bool accept,
    String? feedback,
  }) async {
    emit(const RespondToEmploymentLoading());
    final result = await _repo.respondToEmployment(
      RespondToEmploymentRequestModel(
        requestId: requestId,
        accept: accept,
        feedback: feedback,
      ),
    );
    result.fold((e) => emit(RespondToEmploymentFailure(e)), (r) {
      emit(RespondToEmploymentSuccess(r));
      // Refresh list after responding
      getMyEmploymentRequests();
    });
  }

  // ── GET /api/Clinics/my-clinics ──────────────────────────────────────────
  Future<void> getMyClinics() async {
    emit(const GetMyClinicsLoading());
    final result = await _repo.getMyClinics();
    result.fold(
      (e) => emit(GetMyClinicsFailure(e)),
      (r) => emit(GetMyClinicsSuccess(r)),
    );
  }

  // ── DELETE /api/Clinics/remove-clinic/{clinicId} ─────────────────────────
  Future<void> removeClinic(int clinicId) async {
    emit(RemoveClinicLoading(clinicId));
    final result = await _repo.removeClinic(clinicId);
    result.fold((e) => emit(RemoveClinicFailure(e)), (r) {
      emit(RemoveClinicSuccess(r, clinicId));
      getMyClinics();
    });
  }

  // ── PUT /api/Clinics/update-clinic-profile ───────────────────────────────
  Future<void> updateClinicProfile(
    UpdateClinicProfileRequestModel request,
  ) async {
    emit(const UpdateClinicProfileLoading());
    final result = await _repo.updateClinicProfile(request);
    result.fold(
      (e) => emit(UpdateClinicProfileFailure(e)),
      (r) => emit(UpdateClinicProfileSuccess(r)),
    );
  }

  // ── PUT /api/Clinics/update-financial-terms ──────────────────────────────
  Future<void> updateFinancialTerms(
    UpdateFinancialTermsRequestModel request,
  ) async {
    emit(const UpdateFinancialTermsLoading());
    final result = await _repo.updateFinancialTerms(request);
    result.fold(
      (e) => emit(UpdateFinancialTermsFailure(e)),
      (r) => emit(UpdateFinancialTermsSuccess(r)),
    );
  }

  // ── PUT /api/Clinics/update-doctor-schedule ──────────────────────────────
  Future<void> updateDoctorSchedule(
    UpdateDoctorScheduleRequestModel request,
  ) async {
    emit(const UpdateDoctorScheduleLoading());
    final result = await _repo.updateDoctorSchedule(request);
    result.fold(
      (e) => emit(UpdateDoctorScheduleFailure(e)),
      (r) => emit(UpdateDoctorScheduleSuccess(r)),
    );
  }

  // ── POST /api/Schedules/add-schedule ─────────────────────────────────────
  Future<void> addSchedule(AddScheduleRequestModel request) async {
    emit(const AddScheduleLoading());
    final result = await _repo.addSchedule(request);
    result.fold(
      (e) => emit(AddScheduleFailure(e)),
      (r) => emit(AddScheduleSuccess(r)),
    );
  }

  // ── DELETE /api/Schedules/delete-schedule/{id} ───────────────────────────
  Future<void> deleteSchedule(int id) async {
    emit(DeleteScheduleLoading(id));
    final result = await _repo.deleteSchedule(id);
    result.fold(
      (e) => emit(DeleteScheduleFailure(e)),
      (r) => emit(DeleteScheduleSuccess(r, id)),
    );
  }

  // ── GET /api/Schedules/doctor-availability/{doctorId} ────────────────────
  Future<void> getDoctorAvailability(String doctorId) async {
    emit(const GetDoctorAvailabilityLoading());
    final result = await _repo.getDoctorAvailability(doctorId);
    result.fold(
      (e) => emit(GetDoctorAvailabilityFailure(e)),
      (r) => emit(GetDoctorAvailabilitySuccess(r)),
    );
  }

  void reset() => emit(const ClinicManagementInitial());
}
