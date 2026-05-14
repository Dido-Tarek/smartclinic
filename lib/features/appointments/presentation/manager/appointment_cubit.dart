import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/features/appointments/data/model/appointment_request_model.dart';
import 'package:smartclinic/features/appointments/data/repo/appointment_repo.dart';
import 'package:smartclinic/features/appointments/presentation/manager/appointment_state.dart';

class AppointmentsCubit extends Cubit<AppointmentsState> {
  final AppointmentsRepo _repo;

  AppointmentsCubit(this._repo) : super(const AppointmentsInitial());

  // ── POST /api/Appointments/book ──────────────────────────────────────────
  Future<void> bookAppointment(BookAppointmentRequestModel request) async {
    emit(const BookAppointmentLoading());

    final result = await _repo.bookAppointment(request);

    result.fold(
      (error) => emit(BookAppointmentFailure(error)),
      (appointment) => emit(BookAppointmentSuccess(appointment)),
    );
  }

  // ── GET /api/Appointments/my-appointments ────────────────────────────────
  Future<void> getMyAppointments() async {
    emit(const GetMyAppointmentsLoading());

    final result = await _repo.getMyAppointments();

    result.fold(
      (error) => emit(GetMyAppointmentsFailure(error)),
      (response) => emit(GetMyAppointmentsSuccess(response)),
    );
  }

  // ── GET /api/Appointments/doctor-requests/{clinicId} ────────────────────
  Future<void> getDoctorRequests(int clinicId) async {
    emit(const GetDoctorRequestsLoading());

    final result = await _repo.getDoctorRequests(clinicId);

    result.fold(
      (error) => emit(GetDoctorRequestsFailure(error)),
      (response) => emit(GetDoctorRequestsSuccess(response)),
    );
  }

  // ── PUT /api/Appointments/update-status/{id} ─────────────────────────────
  Future<void> updateAppointmentStatus({
    required int id,
    required String status,
    String? adminMessage,
  }) async {
    emit(const UpdateAppointmentStatusLoading());

    final result = await _repo.updateAppointmentStatus(
      id: id,
      request: UpdateAppointmentStatusRequestModel(
        status: status,
        adminMessage: adminMessage,
      ),
    );

    result.fold(
      (error) => emit(UpdateAppointmentStatusFailure(error)),
      (appointment) => emit(UpdateAppointmentStatusSuccess(appointment)),
    );
  }

  // ── PUT /api/Appointments/cancel-my-appointment/{id} ────────────────────
  Future<void> cancelMyAppointment(int id) async {
    emit(const CancelAppointmentLoading());

    final result = await _repo.cancelMyAppointment(id);

    result.fold(
      (error) => emit(CancelAppointmentFailure(error)),
      (response) => emit(CancelAppointmentSuccess(response)),
    );
  }

  // ── GET /api/Appointments/available-slots ────────────────────────────────
  Future<void> getAvailableSlots({
    required String doctorId,
    required int clinicId,
    required String date,
  }) async {
    emit(const GetAvailableSlotsLoading());

    final result = await _repo.getAvailableSlots(
      doctorId: doctorId,
      clinicId: clinicId,
      date: date,
    );

    result.fold(
      (error) => emit(GetAvailableSlotsFailure(error)),
      (response) => emit(GetAvailableSlotsSuccess(response)),
    );
  }

  // ── GET /api/Appointments/queue-position/{appointmentId} ─────────────────
  Future<void> getQueuePosition(int appointmentId) async {
    emit(const GetQueuePositionLoading());

    final result = await _repo.getQueuePosition(appointmentId);

    result.fold(
      (error) => emit(GetQueuePositionFailure(error)),
      (response) => emit(GetQueuePositionSuccess(response)),
    );
  }

  void reset() => emit(const AppointmentsInitial());
}
