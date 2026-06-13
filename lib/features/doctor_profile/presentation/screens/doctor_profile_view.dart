import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/doctor_view_card.dart';
import 'package:smartclinic/features/user_management/presentation/manager/user_management_cubit.dart';
import 'package:smartclinic/features/user_management/presentation/manager/user_management_state.dart';
import 'package:smartclinic/features/user_management/data/model/doctor_profile_response_model.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/injection_dependency.dart';

class DoctorProfileView extends StatefulWidget {
  final String? doctorId;
  final String? doctorName;
  final String? doctorImage;
  final String? specialization;
  final double? rating;
  final int? reviewsCount;
  final double? clinicFee;
  final double? onlineFee;
  final double? homeVisitFee;
  final double? followUpFee;
  final double? emergencyFee;
  final String? clinicName;
  final String? clinicAddress;
  final String? clinicPhone;
  final String? clinicWorkingHours;
  final int? yearsOfExperience;
  final Set<String> enabledConsultationTypes;

  const DoctorProfileView({
    super.key,
    this.doctorId,
    this.doctorName,
    this.doctorImage,
    this.specialization,
    this.rating,
    this.reviewsCount,
    this.clinicFee,
    this.onlineFee,
    this.homeVisitFee,
    this.followUpFee,
    this.emergencyFee,
    this.clinicName,
    this.clinicAddress,
    this.clinicPhone,
    this.clinicWorkingHours,
    this.yearsOfExperience,
    this.enabledConsultationTypes = const {
      'clinic',
      'online',
      'homeVisit',
      'emergency',
    },
  });

  @override
  State<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  final UserSession _userSession = getIt<UserSession>();
  DoctorProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    if (widget.doctorId != null && widget.doctorId!.trim().isNotEmpty) {
      context.read<UserManagementCubit>().getDoctorProfile(
        widget.doctorId!.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserManagementCubit, UserManagementState>(
      listener: (context, state) async {
        if (state is ProfileLoaded) {
          setState(() {
            _profile = state.profile;
          });
        }
      },
      builder: (context, state) {
        final name = _displayDoctorName(
          _profile?.fullName ?? widget.doctorName ?? 'Mai El Kady',
        );
        final isCurrentUserProfile =
            widget.doctorId != null &&
            widget.doctorId!.trim().isNotEmpty &&
            widget.doctorId!.trim() == (_userSession.userId ?? '').trim();
        final imagePath =
            _profile?.profileImage ??
            (isCurrentUserProfile ? _userSession.profileImage : null) ??
            widget.doctorImage ??
            AppImages.imagesDoctorDRMaiElKady;
        final doctorSpecialization =
            _profile?.specialization ?? widget.specialization ?? 'Dentist';
        final displayRating = widget.rating ?? 4.0;
        final displayReviewsCount = widget.reviewsCount ?? 0;
        final clinicFee = _profile?.clinicFee ?? widget.clinicFee;
        final onlineFee = _profile?.onlineFee ?? widget.onlineFee;
        final homeVisitFee = _profile?.homeVisitFee ?? widget.homeVisitFee;
        final followUpFee = _profile?.followUpFee ?? widget.followUpFee;
        final emergencyFee = _profile?.emergencyFee ?? widget.emergencyFee;
        final bio = _profile?.bio ?? 'No bio available.';
        final clinicName =
            _profile?.clinicName ?? widget.clinicName ?? 'Clinic';
        final clinicAddress =
            _profile?.clinicAddress ??
            widget.clinicAddress ??
            'Address not available';
        final clinicPhone =
            _profile?.clinicPhone ??
            widget.clinicPhone ??
            'Contact not available';
        final clinicWorkingHours =
            _profile?.clinicWorkingHours ??
            widget.clinicWorkingHours ??
            'Working times are not available yet.';
        final yearsOfExperience =
            _profile?.yearsOfExperience ?? widget.yearsOfExperience ?? 0;

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
                  // ── Doctor card
                  DoctorViewCard(
                    doctorName: name,
                    specialization: doctorSpecialization,
                    clinicName: clinicName,
                    rating: displayRating,
                    reviewsCount: displayReviewsCount,
                    doctorImagePath: imagePath,
                    yearsOfExperience: yearsOfExperience,
                    patientsCount: 0,
                  ),

                  const SizedBox(height: 24),

                  // ── About Me
                  _SectionTitle('About Me'),
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Clinic Information
                  _SectionTitle('Clinic Information'),
                  const SizedBox(height: 12),
                  _ClinicInfoCard(
                    clinicName: clinicName,
                    clinicPhone: clinicPhone,
                    clinicAddress: clinicAddress,
                    clinicWorkingHours: clinicWorkingHours,
                  ),

                  const SizedBox(height: 16),
                  _FeeInfoCard(
                    clinicFee: clinicFee,
                    onlineFee: onlineFee,
                    homeVisitFee: homeVisitFee,
                    followUpFee: followUpFee,
                    emergencyFee: emergencyFee,
                  ),

                  const SizedBox(height: 16),
                  _SectionTitle('Consultation Types'),
                  const SizedBox(height: 12),
                  _ConsultationTypeChips(
                    types: widget.enabledConsultationTypes,
                  ),

                  const SizedBox(height: 24),

                  // ── Reviews
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
                      'doctorId': widget.doctorId ?? widget.doctorName,
                      'clinicId': 0,
                      'name': name,
                      'image': imagePath,
                      'specialization': doctorSpecialization,
                      'rating': displayRating,
                      'reviewsCount': displayReviewsCount,
                      'yearsOfExperience': _profile?.yearsOfExperience ?? 0,
                      'patientsCount': 0,
                      'clinicFee': clinicFee,
                      'onlineFee': onlineFee,
                      'homeVisitFee': homeVisitFee,
                      'followUpFee': followUpFee,
                      'emergencyFee': emergencyFee,
                      'clinicName': clinicName,
                      'clinicAddress': clinicAddress,
                      'clinicPhone': clinicPhone,
                      'clinicWorkingHours': clinicWorkingHours,
                      'enabledAppointmentTypes': widget.enabledConsultationTypes
                          .toList(),
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
      },
    );
  }
}

String _displayDoctorName(String value) {
  final normalized = _normalizeDoctorName(value);
  if (normalized.startsWith('Dr.')) {
    return normalized;
  }
  return 'Dr. $normalized';
}

String _normalizeDoctorName(String value) {
  var trimmed = value.trim();
  while (trimmed.isNotEmpty) {
    if (trimmed.startsWith('Dr.')) {
      trimmed = trimmed.substring(3).trim();
      continue;
    }
    if (trimmed.startsWith('Dr')) {
      trimmed = trimmed.substring(2).trim();
      continue;
    }
    if (trimmed.startsWith('د.')) {
      trimmed = trimmed.substring(2).trim();
      continue;
    }
    if (trimmed.startsWith('د')) {
      trimmed = trimmed.substring(1).trim();
      continue;
    }
    break;
  }
  return trimmed.isEmpty ? value.trim() : trimmed;
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
  final String clinicName;
  final String clinicPhone;
  final String clinicAddress;
  final String clinicWorkingHours;

  const _ClinicInfoCard({
    required this.clinicName,
    required this.clinicPhone,
    required this.clinicAddress,
    required this.clinicWorkingHours,
  });

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
              children: [
                _ClinicInfoRow(
                  icon: Icons.local_hospital_outlined,
                  label: 'Name:',
                  value: clinicName,
                ),
                const SizedBox(height: 6),
                _ClinicInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Contact:',
                  value: clinicPhone,
                ),
                const SizedBox(height: 6),
                _ClinicInfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address:',
                  value: clinicAddress,
                ),
                const SizedBox(height: 6),
                _ClinicInfoRow(
                  icon: Icons.access_time_outlined,
                  label: 'Working Times:',
                  value: clinicWorkingHours,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeInfoCard extends StatelessWidget {
  final double? clinicFee;
  final double? onlineFee;
  final double? homeVisitFee;
  final double? followUpFee;
  final double? emergencyFee;

  const _FeeInfoCard({
    this.clinicFee,
    this.onlineFee,
    this.homeVisitFee,
    this.followUpFee,
    this.emergencyFee,
  });

  @override
  Widget build(BuildContext context) {
    final fees = <String, double?>{
      'Clinic Fee': clinicFee,
      'Online Fee': onlineFee,
      'Home Visit Fee': homeVisitFee,
      'Follow Up Fee': followUpFee,
      'Emergency Fee': emergencyFee,
    };

    final availableFees = fees.entries.where((entry) => entry.value != null);

    return Container(
      width: double.infinity,
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
      child: availableFees.isEmpty
          ? Text(
              'Fee details are not available yet.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: availableFees
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.monetization_on_outlined,
                            size: 16,
                            color: AppColors.skyBlue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${entry.key}: ${entry.value!.toStringAsFixed(0)} EGP',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.deepNavy,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
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
