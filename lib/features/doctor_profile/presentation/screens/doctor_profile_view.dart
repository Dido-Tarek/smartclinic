import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/doctor_view_card.dart';

class DoctorProfileView extends StatelessWidget {
  final String? doctorName;
  final String? doctorImage;
  final String? specialization;
  final double? rating;
  final int? reviewsCount;
  final Set<String> enabledConsultationTypes;

  const DoctorProfileView({
    super.key,
    this.doctorName,
    this.doctorImage,
    this.specialization,
    this.rating,
    this.reviewsCount,
    this.enabledConsultationTypes = const {
      'clinic',
      'online',
      'homeVisit',
      'emergency',
    },
  });

  @override
  Widget build(BuildContext context) {
    final name = _displayDoctorName(doctorName ?? 'Mai El Kady');
    final imagePath = doctorImage ?? AppImages.imagesDoctorDRMaiElKady;
    final doctorSpecialization = specialization ?? 'Dentist';
    final displayRating = rating ?? 3.8;
    final displayReviewsCount = reviewsCount ?? 425;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CustomAppBar(
        title: name,
        showNotification: true,
        onNotificationTap: () =>
            Navigator.pushNamed(context, AppRoutes.notifications),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Doctor card (already updated to horizontal layout) ──
              DoctorViewCard(
                doctorName: name,
                specialization: doctorSpecialization,
                clinicName: 'Dar El-Hekma Clinic',
                rating: displayRating,
                reviewsCount: displayReviewsCount,
                doctorImagePath: imagePath,
                yearsOfExperience: 5,
                patientsCount: 500,
              ),

              const SizedBox(height: 24),

              // ── About Me ────────────────────────────────────────────
              _SectionTitle('About Me'),
              const SizedBox(height: 8),
              Text(
                'Experienced Dental Consultant with 10+ years of practice in Egypt. '
                'Expert in pediatric, restorative, and cosmetic dentistry, '
                'specializing in patient-centered care verified by the Ministry of Health.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 24),

              // ── Clinic Information ──────────────────────────────────
              _SectionTitle('Clinic Information'),
              const SizedBox(height: 12),
              _ClinicInfoCard(),

              const SizedBox(height: 16),
              _SectionTitle('Consultation Types'),
              const SizedBox(height: 12),
              _ConsultationTypeChips(types: enabledConsultationTypes),

              const SizedBox(height: 24),

              // ── Reviews ─────────────────────────────────────────────
              _SectionTitle('Reviews'),
              const SizedBox(height: 12),
              SizedBox(
                height: 155,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 2,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) =>
                      _ReviewCard(_dummyReviews[index]),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.bookingDetails,
                arguments: {
                  'doctorId': name,
                  'clinicId': 0,
                  'name': name,
                    'image': imagePath,
                    'specialization': doctorSpecialization,
                  'clinicName': 'Dar El-Hekma Clinic',
                    'rating': displayRating,
                    'reviewsCount': displayReviewsCount,
                  'yearsOfExperience': 5,
                  'patientsCount': 500,
                  'enabledAppointmentTypes': enabledConsultationTypes.toList(),
                },
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Book Appointment',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  String _displayDoctorName(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('Dr.')) {
      return trimmed;
    }
    return 'Dr. $trimmed';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dummy review data — replace with real API data
// ─────────────────────────────────────────────────────────────────────────────
const _dummyReviews = [
  _ReviewData(
    name: 'Ahmed Mahmoud',
    timeAgo: '2 hours ago',
    rating: 5,
    review:
        'A professional and painless experience with a doctor who truly cares about patient comfort and dental health.',
  ),
  _ReviewData(
    name: 'Salma Khaled',
    timeAgo: '1 day ago',
    rating: 5,
    review:
        'A professional and painless experience with a doctor who truly cares about patient comfort and dental health.',
  ),
];

class _ReviewData {
  final String name;
  final String timeAgo;
  final int rating;
  final String review;

  const _ReviewData({
    required this.name,
    required this.timeAgo,
    required this.rating,
    required this.review,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Reusable bold section title
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.deepNavy,
      ),
    );
  }
}

/// Clinic info white card with map thumbnail + detail rows
class _ClinicInfoCard extends StatelessWidget {
  const _ClinicInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              AppImages.imagesIconsBestCustomerExperience,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),

          // Info rows
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _ClinicInfoRow(
                  icon: Icons.local_hospital_outlined,
                  label: 'Name:',
                  value: 'Dar El-Hekma Clinic',
                ),
                SizedBox(height: 6),
                _ClinicInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Contact:',
                  value: '01014256852',
                ),
                SizedBox(height: 6),
                _ClinicInfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address:',
                  value: '51 Rabbaa Street, Cairo',
                ),
                SizedBox(height: 6),
                _ClinicInfoRow(
                  icon: Icons.access_time_outlined,
                  label: 'Working Times:',
                  value: 'Mon - Fri, 6:00 PM - 11:00 PM',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClinicInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ClinicInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.skyBlue),
        const SizedBox(width: 4),
        Text(
          '$label ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.deepNavy,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ConsultationTypeChips extends StatelessWidget {
  final Set<String> types;

  const _ConsultationTypeChips({required this.types});

  @override
  Widget build(BuildContext context) {
    final items = _consultationLabels.entries
        .where((entry) => types.contains(entry.key))
        .toList();

    if (items.isEmpty) {
      return Text(
        'No consultation types are available right now.',
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items
          .map(
            (entry) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.skyBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.skyBlue,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

const Map<String, String> _consultationLabels = {
  'clinic': 'Clinic',
  'online': 'Online',
  'homeVisit': 'Home Visit',
  'emergency': 'Emergency',
};

/// Horizontal review card
class _ReviewCard extends StatelessWidget {
  final _ReviewData data;

  const _ReviewCard(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer info row
          Row(
            children: [
              // Avatar circle with initials
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.skyBlue.withValues(alpha: 0.15),
                child: Text(
                  data.name.isNotEmpty ? data.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.skyBlue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepNavy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      data.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Star rating
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                Icons.star_rounded,
                size: 16,
                color: i < data.rating
                    ? AppColors.yellowRating
                    : Colors.grey.shade300,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Review text
          Expanded(
            child: Text(
              data.review,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
