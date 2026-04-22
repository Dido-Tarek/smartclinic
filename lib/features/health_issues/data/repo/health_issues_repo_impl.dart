import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/health_issues/data/api/health_issues_api_service.dart';
import 'package:smartclinic/features/health_issues/data/models/health_issues_model.dart';
import 'package:smartclinic/features/health_issues/domain/repo/health_issues_repo.dart';

class HealthIssuesRepoImpl implements HealthIssuesRepo {
  final HealthIssuesApiService _apiService;
  HealthIssuesRepoImpl(this._apiService);

  @override
  Future<ApiResult<dynamic>> addHealthIssue(
    String patientId,
    HealthIssueModel issue,
  ) async {
    try {
      final response = await _apiService.addHealthIssue(patientId, issue);
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<dynamic>> updateHealthIssue(
    int id,
    HealthIssueModel issue,
  ) async {
    try {
      final response = await _apiService.updateHealthIssue(id, issue);
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<List<HealthIssueModel>>> getPatientHistory() async {
    try {
      final response = await _apiService.getPatientHistory();
      return ApiResult.success(response);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
