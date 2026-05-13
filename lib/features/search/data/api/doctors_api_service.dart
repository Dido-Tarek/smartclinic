import 'package:dio/dio.dart';
import 'package:smartclinic/features/search/data/model/search_doctors_response_model.dart';
import 'package:smartclinic/features/search/data/model/search_doctors_request_model.dart';

class DoctorsApiService {
  final Dio _dio;

  DoctorsApiService(this._dio);

  static const String _searchDoctorsEndpoint = '/api/Doctors/search-doctors';
  static const String _getDoctorByIdEndpoint = '/api/Doctors';

  // ── POST /api/Doctors/search-doctors ──────────────────────────────────────
  Future<SearchDoctorsResponseModel> searchDoctors(
    SearchDoctorsRequestModel request,
  ) async {
    final response = await _dio.post(
      _searchDoctorsEndpoint,
      data: request.toJson(),
    );
    return SearchDoctorsResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── GET /api/Doctors/{id} ─────────────────────────────────────────────────
  Future<GetDoctorByIdResponseModel> getDoctorById(String id) async {
    final response = await _dio.get('$_getDoctorByIdEndpoint/$id');
    return DoctorModel.fromJson(response.data as Map<String, dynamic>);
  }
}
