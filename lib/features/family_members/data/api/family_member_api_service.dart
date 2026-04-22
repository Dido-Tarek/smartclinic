import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/family_member_model.dart';

part 'family_member_api_service.g.dart';

@RestApi(baseUrl: "http://smartclinicccc.runasp.net/")
abstract class FamilyApiService {
  factory FamilyApiService(Dio dio, {String baseUrl}) = _FamilyApiService;

  @POST("api/Family/add")
  Future<dynamic> addFamilyMember(@Body() FamilyMemberModel member);

  @GET("api/Family/my-family")
  Future<List<FamilyMemberModel>> getMyFamily();

  @DELETE("api/Family/remove/{id}")
  Future<dynamic> removeFamilyMember(@Path("id") int memberId);
}
