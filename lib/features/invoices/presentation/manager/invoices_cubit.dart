import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/features/invoices/data/repo/invoices_repo.dart';
import 'invoices_state.dart';

class InvoicesCubit extends Cubit<InvoicesState> {
  final InvoicesRepo _repo;

  InvoicesCubit(this._repo) : super(const InvoicesInitial());

  // ── PUT /api/Invoices/mark-as-paid/{appointmentId} ────────────────────────
  // Doctor or clinic owner — for cash-only appointments.
  Future<void> markAsPaid(int appointmentId) async {
    emit(const MarkAsPaidLoading());

    final result = await _repo.markAsPaid(appointmentId);

    result.fold(
      (error) => emit(MarkAsPaidFailure(error)),
      (response) => emit(MarkAsPaidSuccess(response)),
    );
  }

  // ── GET /api/Invoices/clinic-report/{clinicId} ────────────────────────────
  // Clinic owner sees full revenue; doctor sees only their personal share.
  Future<void> getClinicReport(int clinicId) async {
    emit(const GetClinicReportLoading());

    final result = await _repo.getClinicReport(clinicId);

    result.fold(
      (error) => emit(GetClinicReportFailure(error)),
      (response) => emit(GetClinicReportSuccess(response)),
    );
  }

  void reset() => emit(const InvoicesInitial());
}
