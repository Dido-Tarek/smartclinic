import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:smartclinic/features/health_issues/data/models/health_issues_model.dart';

part 'health_issues_api_service.g.dart';

@RestApi(baseUrl: "http://smartclinicccc.runasp.net/")
abstract class HealthIssuesApiService {
  factory HealthIssuesApiService(Dio dio, {String baseUrl}) =
      _HealthIssuesApiService;

  // إضافة مشكلة صحية
  @POST("api/HealthIssues/add/{patientId}")
  Future<dynamic> addHealthIssue(
    @Path("patientId") String patientId,
    @Body() Object body,
  );

  // تعديل مشكلة صحية
  @PUT("api/HealthIssues/update-issue/{id}")
  Future<dynamic> updateHealthIssue(
    @Path("id") int issueId,
    @Body() Object body,
  );

  // جلب التاريخ المرضي للمريض
  @GET("api/HealthIssues/patient-history")
  Future<List<HealthIssueModel>> getPatientHistory();
}
