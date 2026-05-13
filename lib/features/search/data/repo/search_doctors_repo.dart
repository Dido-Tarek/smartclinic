import 'package:dartz/dartz.dart';
import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:smartclinic/features/search/data/model/search_doctors_request_model.dart';
import 'package:smartclinic/features/search/data/model/search_doctors_response_model.dart';
import '../api/doctors_api_service.dart';

abstract class DoctorsRepo {
  Future<Either<String, SearchDoctorsResponseModel>> searchDoctors(
    SearchDoctorsRequestModel request,
  );

  Future<Either<String, GetDoctorByIdResponseModel>> getDoctorById(String id);
}

class DoctorsRepoImpl implements DoctorsRepo {
  final DoctorsApiService _apiService;

  DoctorsRepoImpl(this._apiService);

  @override
  Future<Either<String, SearchDoctorsResponseModel>> searchDoctors(
    SearchDoctorsRequestModel request,
  ) async {
    try {
      final result = await _apiService.searchDoctors(request);
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, GetDoctorByIdResponseModel>> getDoctorById(
    String id,
  ) async {
    try {
      final result = await _apiService.getDoctorById(id);
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
