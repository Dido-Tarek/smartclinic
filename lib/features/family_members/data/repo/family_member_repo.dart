import 'package:dartz/dartz.dart';
import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:smartclinic/features/family_members/data/api/family_member_api_service.dart';
import 'package:smartclinic/features/family_members/data/models/family_member_request_model.dart';
import 'package:smartclinic/features/family_members/data/models/family_member_response_model.dart';

abstract class FamilyRepo {
  Future<Either<String, AddFamilyMemberResponseModel>> addFamilyMember(
    AddFamilyMemberRequestModel request,
  );

  Future<Either<String, MyFamilyResponseModel>> getMyFamily();

  Future<Either<String, RemoveFamilyMemberResponseModel>> removeFamilyMember(
    int id,
  );
}

class FamilyRepoImpl implements FamilyRepo {
  final FamilyApiService _apiService;

  FamilyRepoImpl(this._apiService);

  @override
  Future<Either<String, AddFamilyMemberResponseModel>> addFamilyMember(
    AddFamilyMemberRequestModel request,
  ) async {
    try {
      return Right(await _apiService.addFamilyMember(request));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, MyFamilyResponseModel>> getMyFamily() async {
    try {
      return Right(await _apiService.getMyFamily());
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, RemoveFamilyMemberResponseModel>> removeFamilyMember(
    int id,
  ) async {
    try {
      return Right(await _apiService.removeFamilyMember(id));
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
