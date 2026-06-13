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
  final String? clinicName;
  final String? clinicAddress;
  final String? clinicPhone;
  final String? clinicWorkingHours;

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
    this.clinicName,
    this.clinicAddress,
    this.clinicPhone,
    this.clinicWorkingHours,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'] as Map<String, dynamic>?;
    final clinics = json['clinics'] as List<dynamic>?;
    String? city;
    String? area;
    Map<String, dynamic>? clinic;

    if (clinics != null && clinics.isNotEmpty) {
      final firstClinic = clinics.first;
      if (firstClinic is Map<String, dynamic>) {
        clinic = firstClinic;
        final location = clinic['location'] as String?;
        if (location != null && location.contains('-')) {
          final parts = location.split('-').map((part) => part.trim()).toList();
          if (parts.isNotEmpty) {
            city = parts.first;
            if (parts.length > 1) {
              area = parts[1];
            }
          }
        }
      }
    }

    return DoctorModel(
      id: json['doctorId'] as String?,
      name: json['fullName'] as String?,
      specialization: json['specialization'] as String?,
      city: city ?? json['city'] as String?,
      area: area ?? json['area'] as String?,
      consultationType: json['consultationType'] as int?,
      consultationPrice: (pricing == null)
          ? null
          : (pricing['clinicFee'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      profileImage: json['profileImage'] as String?,
      reviewsCount: (json['reviewCount'] as num?)?.toInt(),
      rating: (json['averageRating'] as num?)?.toDouble(),
      clinicName: clinic == null
          ? null
          : (clinic['name'] as String?) ??
              (clinic['clinicName'] as String?),
      clinicAddress: clinic == null
          ? null
          : (clinic['address'] as String?) ??
              (clinic['location'] as String?),
      clinicPhone: clinic == null
          ? null
          : (clinic['phone'] as String?) ??
              (clinic['phoneNumber'] as String?) ??
              (clinic['contact'] as String?),
      clinicWorkingHours: clinic == null
          ? null
          : (clinic['workingHours'] as String?) ??
              (clinic['workingTimes'] as String?),
    );
  }

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

  factory SearchDoctorsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawDoctors = json['data'] as List<dynamic>? ?? [];
    return SearchDoctorsResponseModel(
      doctors: rawDoctors
          .map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int?,
      pageNumber: json['pageNumber'] as int?,
      pageSize: json['pageSize'] as int?,
      totalPages: json['totalPages'] as int?,
    );
  }
}

// ── GET /api/Doctors/{id} response ───────────────────────────────────────────
// The single-doctor endpoint returns the DoctorModel directly.
// Add extra fields here once your backend schema is confirmed.
typedef GetDoctorByIdResponseModel = DoctorModel;
