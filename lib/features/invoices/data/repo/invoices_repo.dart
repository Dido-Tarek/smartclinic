import 'package:dartz/dartz.dart';
import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:smartclinic/features/invoices/data/model/invoices_response_model.dart';
import '../api/invoices_api_service.dart';

abstract class InvoicesRepo {
  /// Marks an appointment's invoice as paid (cash payments only).
  Future<Either<String, MarkInvoiceAsPaidResponseModel>> markAsPaid(
    int appointmentId,
  );

  /// Gets the revenue report for a clinic (or doctor's personal share).
  Future<Either<String, ClinicReportResponseModel>> getClinicReport(
    int clinicId,
  );
}

class InvoicesRepoImpl implements InvoicesRepo {
  final InvoicesApiService _apiService;

  InvoicesRepoImpl(this._apiService);

  @override
  Future<Either<String, MarkInvoiceAsPaidResponseModel>> markAsPaid(
    int appointmentId,
  ) async {
    try {
      final result = await _apiService.markAsPaid(appointmentId);
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, ClinicReportResponseModel>> getClinicReport(
    int clinicId,
  ) async {
    try {
      final result = await _apiService.getClinicReport(clinicId);
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
