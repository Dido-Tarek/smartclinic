import 'package:equatable/equatable.dart';
import 'package:smartclinic/features/invoices/data/model/invoices_response_model.dart';

abstract class InvoicesState extends Equatable {
  const InvoicesState();

  @override
  List<Object?> get props => [];
}

// ── Shared ────────────────────────────────────────────────────────────────────

class InvoicesInitial extends InvoicesState {
  const InvoicesInitial();
}

// ── Mark as paid ──────────────────────────────────────────────────────────────

class MarkAsPaidLoading extends InvoicesState {
  const MarkAsPaidLoading();
}

class MarkAsPaidSuccess extends InvoicesState {
  final MarkInvoiceAsPaidResponseModel response;

  const MarkAsPaidSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class MarkAsPaidFailure extends InvoicesState {
  final String errorMessage;

  const MarkAsPaidFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// ── Clinic report ─────────────────────────────────────────────────────────────

class GetClinicReportLoading extends InvoicesState {
  const GetClinicReportLoading();
}

class GetClinicReportSuccess extends InvoicesState {
  final ClinicReportResponseModel response;

  const GetClinicReportSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class GetClinicReportFailure extends InvoicesState {
  final String errorMessage;

  const GetClinicReportFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
