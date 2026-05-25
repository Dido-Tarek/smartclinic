import 'package:dio/dio.dart';
import 'package:smartclinic/features/family_members/data/models/family_member_request_model.dart';
import 'package:smartclinic/features/family_members/data/models/family_member_response_model.dart';

class FamilyApiService {
  final Dio _dio;

  FamilyApiService(this._dio);

  static const String _base = '/api/Family';

  // ── POST /api/Family/add ──────────────────────────────────────────────────
  Future<AddFamilyMemberResponseModel> addFamilyMember(
    AddFamilyMemberRequestModel request,
  ) async {
    final response = await _dio.post('$_base/add', data: request.toJson());
    return FamilyMemberModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── GET /api/Family/my-family ─────────────────────────────────────────────
  Future<MyFamilyResponseModel> getMyFamily() async {
    final response = await _dio.get('$_base/my-family');

    // Handle both wrapped { members: [...] } and raw [...] responses
    if (response.data is List) {
      return MyFamilyResponseModel.fromList(response.data as List<dynamic>);
    }
    return MyFamilyResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── DELETE /api/Family/remove/{id} ───────────────────────────────────────
  Future<RemoveFamilyMemberResponseModel> removeFamilyMember(int id) async {
    final response = await _dio.delete('$_base/remove/$id');

    // Some DELETE endpoints return 200 with no body
    if (response.data == null || response.data is! Map) {
      return const RemoveFamilyMemberResponseModel(
        message: 'Member removed successfully',
      );
    }
    return RemoveFamilyMemberResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
