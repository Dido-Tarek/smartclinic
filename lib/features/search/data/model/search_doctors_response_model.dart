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
  final int? clinicId;
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
    this.clinicId,
    this.clinicName,
    this.clinicAddress,
    this.clinicPhone,
    this.clinicWorkingHours,
  });

  static const _baseUrl = 'http://smartclinicccc.runasp.net';

  static String? _resolveUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final t = raw.trim();
    final lower = t.toLowerCase();
    if (lower == 'null' || lower == 'string') return null;
    return t.startsWith('http') ? t : '$_baseUrl${t.startsWith('/') ? '' : '/'}$t';
  }

  static String? _formatSchedules(Map<String, dynamic>? clinic) {
    if (clinic == null) return null;
    final list = clinic['schedules'] as List<dynamic>?;
    if (list == null || list.isEmpty) return null;
    final lines = list.map((s) {
      if (s is! Map<String, dynamic>) return null;
      final day = (s['day'] ?? s['Day']) as String? ?? '';
      final from = (s['from'] ?? s['From']) as String? ?? '';
      final to = (s['to'] ?? s['To']) as String? ?? '';
      if (day.isEmpty) return null;
      return from.isNotEmpty ? '$day: $from – $to' : day;
    }).whereType<String>().toList();
    return lines.isEmpty ? null : lines.join('\n');
  }

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

    // Resolve photo: API returns relative photoUrl — prepend base URL
    final resolvedPhoto = _resolveUrl(
      (json['photoUrl'] as String?) ??
      (json['PhotoUrl'] as String?) ??
      (json['imageUrl'] as String?) ??
      (json['profileImage'] as String?),
    );

    // Working hours from schedules if no explicit field
    final workingHours = clinic == null
        ? null
        : (clinic['workingHours'] as String?) ??
          (clinic['workingTimes'] as String?) ??
          _formatSchedules(clinic);

    // Contact: doctorPhone lives at top level, not inside clinic
    final phone = (json['doctorPhone'] as String?) ??
        (json['phoneNumber'] as String?) ??
        (clinic == null ? null :
          (clinic['phone'] as String?) ??
          (clinic['phoneNumber'] as String?) ??
          (clinic['contact'] as String?));

    return DoctorModel(
      id: (json['doctorId'] ?? json['id']) as String?,
      name: (json['fullName'] ?? json['name']) as String?,
      specialization: json['specialization'] as String?,
      city: city ?? json['city'] as String?,
      area: area ?? json['area'] as String?,
      consultationType: json['consultationType'] as int?,
      consultationPrice: (pricing == null)
          ? null
          : (pricing['clinicFee'] as num?)?.toDouble(),
      imageUrl: resolvedPhoto,
      profileImage: resolvedPhoto,
      reviewsCount: (json['reviewCount'] as num?)?.toInt(),
      rating: (json['averageRating'] as num?)?.toDouble(),
      clinicId: clinic == null
          ? null
          : (clinic['id'] as num?)?.toInt() ??
            (clinic['clinicId'] as num?)?.toInt(),
      clinicName: clinic == null
          ? null
          : (clinic['name'] as String?) ?? (clinic['clinicName'] as String?),
      clinicAddress: clinic == null
          ? null
          : (clinic['address'] as String?) ?? (clinic['location'] as String?),
      clinicPhone: phone,
      clinicWorkingHours: workingHours,
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
