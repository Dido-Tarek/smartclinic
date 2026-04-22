import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/features/health_issues/data/models/health_issues_model.dart';

abstract class HealthIssuesRepo {
  Future<ApiResult<dynamic>> addHealthIssue(
    String patientId,
    HealthIssueModel issue,
  );
  Future<ApiResult<dynamic>> updateHealthIssue(int id, HealthIssueModel issue);
  Future<ApiResult<List<HealthIssueModel>>> getPatientHistory();
}
