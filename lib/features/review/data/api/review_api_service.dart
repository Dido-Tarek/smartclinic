import 'package:dio/dio.dart';
import 'package:smartclinic/features/review/data/model/review_request_model.dart';
import 'package:smartclinic/features/review/data/model/review_response_model.dart';

class ReviewsApiService {
  final Dio _dio;

  ReviewsApiService(this._dio);

  static const String _addReviewEndpoint = '/api/Reviews/add-review';
  static const String _getDoctorReviewsEndpoint = '/api/Reviews/doctor';

  // ── POST /api/Reviews/add-review ──────────────────────────────────────────
  Future<AddReviewResponseModel> addReview(
    AddReviewRequestModel request,
  ) async {
    final response = await _dio.post(
      _addReviewEndpoint,
      data: request.toJson(),
    );
    return ReviewModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── GET /api/Reviews/doctor/{doctorId} ────────────────────────────────────
  Future<GetDoctorReviewsResponseModel> getDoctorReviews(
    String doctorId,
  ) async {
    final response = await _dio.get('$_getDoctorReviewsEndpoint/$doctorId');
    return GetDoctorReviewsResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
