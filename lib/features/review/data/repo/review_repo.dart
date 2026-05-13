import 'package:dartz/dartz.dart';
import 'package:smartclinic/core/network/api_error_handler.dart';
import 'package:smartclinic/features/review/data/api/review_api_service.dart';
import 'package:smartclinic/features/review/data/model/review_request_model.dart';
import 'package:smartclinic/features/review/data/model/review_response_model.dart';

abstract class ReviewsRepo {
  Future<Either<String, AddReviewResponseModel>> addReview(
    AddReviewRequestModel request,
  );

  Future<Either<String, GetDoctorReviewsResponseModel>> getDoctorReviews(
    String doctorId,
  );
}

class ReviewsRepoImpl implements ReviewsRepo {
  final ReviewsApiService _apiService;

  ReviewsRepoImpl(this._apiService);

  @override
  Future<Either<String, AddReviewResponseModel>> addReview(
    AddReviewRequestModel request,
  ) async {
    try {
      final result = await _apiService.addReview(request);
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<String, GetDoctorReviewsResponseModel>> getDoctorReviews(
    String doctorId,
  ) async {
    try {
      final result = await _apiService.getDoctorReviews(doctorId);
      return Right(result);
    } catch (e) {
      return Left(ApiErrorHandler.handle(e));
    }
  }
}
