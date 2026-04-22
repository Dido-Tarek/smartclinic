import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/family_members/data/api/family_member_api_service.dart';
import 'package:smartclinic/features/family_members/data/models/family_member_model.dart';
import 'package:smartclinic/features/family_members/domain/repo/family_member_repo.dart';

class FamilyRepoImpl implements FamilyRepo {
  final FamilyApiService _apiService;
  FamilyRepoImpl(this._apiService);

  @override
  Future<ApiResult<dynamic>> addMember(FamilyMemberModel member) async {
    try {
      final response = await _apiService.addFamilyMember(member);
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<List<FamilyMemberModel>>> getFamily() async {
    try {
      final response = await _apiService.getMyFamily();
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<dynamic>> deleteMember(int id) async {
    try {
      final response = await _apiService.removeFamilyMember(id);
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
