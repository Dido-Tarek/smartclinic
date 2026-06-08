// ── Single doctor ────────────────────────────────────────────────────────────
class DoctorModel {
  final String? id;
  final String? name;
  final String? specialization;
  final String? city;
  final String? area;
  final int? consultationType;
  final double? consultationPrice;
  final String? imageUrl;
  final String? profileImage;
  final int? reviewsCount;
  final double? rating;

  const DoctorModel({
    this.id,
    this.name,
    this.specialization,
    this.city,
    this.area,
    this.consultationType,
    this.consultationPrice,
    this.imageUrl,
    this.profileImage,
    this.reviewsCount,
    this.rating,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) => DoctorModel(
    id: json['id'] as String?,
    name: json['name'] as String?,
    specialization: json['specialization'] as String?,
    city: json['city'] as String?,
    area: json['area'] as String?,
    consultationType: json['consultationType'] as int?,
    consultationPrice: (json['consultationPrice'] as num?)?.toDouble(),
    imageUrl: json['imageUrl'] as String?,
    profileImage: json['profileImage'] as String?,
    reviewsCount: (json['reviewsCount'] as num?)?.toInt(),
    rating: (json['rating'] as num?)?.toDouble(),
  );

  String? get resolvedImageUrl => imageUrl ?? profileImage;
}

// ── POST /api/Doctors/search-doctors response ────────────────────────────────
class SearchDoctorsResponseModel {
  final List<DoctorModel> doctors;
  final int? totalCount;
  final int? pageNumber;
  final int? pageSize;
  final int? totalPages;

  const SearchDoctorsResponseModel({
    required this.doctors,
    this.totalCount,
    this.pageNumber,
    this.pageSize,
    this.totalPages,
  });

  factory SearchDoctorsResponseModel.fromJson(Map<String, dynamic> json) =>
      SearchDoctorsResponseModel(
        doctors: (json['doctors'] as List<dynamic>? ?? [])
            .map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalCount: json['totalCount'] as int?,
        pageNumber: json['pageNumber'] as int?,
        pageSize: json['pageSize'] as int?,
        totalPages: json['totalPages'] as int?,
      );
}

// ── GET /api/Doctors/{id} response ───────────────────────────────────────────
// The single-doctor endpoint returns the DoctorModel directly.
// Add extra fields here once your backend schema is confirmed.
typedef GetDoctorByIdResponseModel = DoctorModel;
