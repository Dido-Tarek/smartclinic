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
      // Build DTO with PascalCase keys to match server model binding
      final Map<String, dynamic> dto = {};
      dto['Name'] = issue.name;
      dto['Status'] = issue.status;
      dto['DiagnosedDate'] = issue.diagnosedDate;
      dto['IsEstimated'] = issue.isEstimated;
      if (issue.curedDate != null) dto['CuredDate'] = issue.curedDate;
      if (issue.notes != null) dto['Notes'] = issue.notes;
      if (issue.linkedRecordId != null)
        dto['LinkedRecordId'] = issue.linkedRecordId;

      // Also include top-level PascalCase fields in case server expects them directly
      final Map<String, dynamic> payload = Map<String, dynamic>.from(dto);
      payload['dto'] = dto;
      try {
        // ignore: avoid_print
        print('HealthIssue payload: ${payload}');
      } catch (_) {}
      final response = await _apiService.addHealthIssue(patientId, payload);
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
      // For update, also wrap under 'dto' with PascalCase keys
      final Map<String, dynamic> dto = {};
      if (issue.id != null) dto['Id'] = issue.id;
      dto['Name'] = issue.name;
      dto['Status'] = issue.status;
      dto['DiagnosedDate'] = issue.diagnosedDate;
      dto['IsEstimated'] = issue.isEstimated;
      if (issue.curedDate != null) dto['CuredDate'] = issue.curedDate;
      if (issue.notes != null) dto['Notes'] = issue.notes;
      if (issue.linkedRecordId != null)
        dto['LinkedRecordId'] = issue.linkedRecordId;

      try {
        // ignore: avoid_print
        print('HealthIssue update payload: ${ {'dto': dto} }');
      } catch (_) {}
      final Map<String, dynamic> updatePayload = Map<String, dynamic>.from(dto);
      updatePayload['dto'] = dto;
      final response = await _apiService.updateHealthIssue(id, updatePayload);
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
