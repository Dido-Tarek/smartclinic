import 'package:dartz/dartz.dart';
import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:smartclinic/features/prescriptions/data/api/prescription_api_service.dart';
import 'package:smartclinic/features/prescriptions/data/model/prescription_request_model.dart';
import 'package:smartclinic/features/prescriptions/data/model/prescriptions_resoponse_model.dart';

abstract class PrescriptionsRepo {
  Future<Either<String, AddPrescriptionResponseModel>> addPrescription(
    AddPrescriptionRequestModel request,
  );

  Future<Either<String, GetPrescriptionByIdResponseModel>> getPrescriptionById(
    int id,
  );

  Future<Either<String, MyPrescriptionsResponseModel>> getMyPrescriptions();
}

class PrescriptionsRepoImpl implements PrescriptionsRepo {
  final PrescriptionsApiService _apiService;

  PrescriptionsRepoImpl(this._apiService);

  @override
  Future<Either<String, AddPrescriptionResponseModel>> addPrescription(
    AddPrescriptionRequestModel request,
  ) async {
    try {
      final result = await _apiService.addPrescription(request);
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, GetPrescriptionByIdResponseModel>> getPrescriptionById(
    int id,
  ) async {
    try {
      final result = await _apiService.getPrescriptionById(id);
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, MyPrescriptionsResponseModel>>
  getMyPrescriptions() async {
    try {
      final result = await _apiService.getMyPrescriptions();
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
