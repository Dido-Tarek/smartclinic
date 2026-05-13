// ── Single review item ────────────────────────────────────────────────────────
class ReviewModel {
  final String? id;
  final String? doctorId;
  final String? patientId;
  final String? patientName;
  final String? patientImageUrl;
  final int? rating;
  final String? comment;
  final String? createdAt;

  const ReviewModel({
    this.id,
    this.doctorId,
    this.patientId,
    this.patientName,
    this.patientImageUrl,
    this.rating,
    this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    id: json['id'] as String?,
    doctorId: json['doctorId'] as String?,
    patientId: json['patientId'] as String?,
    patientName: json['patientName'] as String?,
    patientImageUrl: json['patientImageUrl'] as String?,
    rating: json['rating'] as int?,
    comment: json['comment'] as String?,
    createdAt: json['createdAt'] as String?,
  );
}

// ── POST /api/Reviews/add-review response ─────────────────────────────────────
// Returns the created review on success — adjust fields once backend confirms.
typedef AddReviewResponseModel = ReviewModel;

// ── GET /api/Reviews/doctor/{doctorId} response ───────────────────────────────
class GetDoctorReviewsResponseModel {
  final List<ReviewModel> reviews;
  final double? averageRating;
  final int? totalReviews;

  const GetDoctorReviewsResponseModel({
    required this.reviews,
    this.averageRating,
    this.totalReviews,
  });

  factory GetDoctorReviewsResponseModel.fromJson(Map<String, dynamic> json) =>
      GetDoctorReviewsResponseModel(
        reviews: (json['reviews'] as List<dynamic>? ?? [])
            .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        averageRating: (json['averageRating'] as num?)?.toDouble(),
        totalReviews: json['totalReviews'] as int?,
      );
}
