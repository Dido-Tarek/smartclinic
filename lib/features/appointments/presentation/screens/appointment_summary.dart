import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/doctor_view_card.dart';

class AppointmentSummaryPage extends StatefulWidget {
  final String? doctorName;
  final String? specialization;
  final String? clinicName;
  final double? rating;
  final String? doctorImage;
  final int? yearsOfExperience;
  final int? patientsCount;
  final int? reviewsCount;
  final String? consultationType;
  final String? selectedDate;
  final String? selectedTime;
  final String? patientName;
  final String? paymentMethod;

  const AppointmentSummaryPage({
    super.key,
    this.doctorName,
    this.specialization,
    this.clinicName,
    this.rating,
    this.doctorImage,
    this.yearsOfExperience,
    this.patientsCount,
    this.reviewsCount,
    this.consultationType,
    this.selectedDate,
    this.selectedTime,
    this.patientName,
    this.paymentMethod,
  });

  @override
  State<AppointmentSummaryPage> createState() => _AppointmentSummaryPageState();
}

class _AppointmentSummaryPageState extends State<AppointmentSummaryPage> {
  String get _doctorName => widget.doctorName ?? 'Dr. Mai El Kady';
  String get _specialization => widget.specialization ?? 'Dentist';
  String get _clinicName => widget.clinicName ?? 'Dar El-Hekma Clinic';
  double get _rating => widget.rating ?? 3.8;
  String get _doctorImage =>
      widget.doctorImage ?? AppImages.imagesDoctorDRMaiElKady;
  int get _yearsOfExperience => widget.yearsOfExperience ?? 5;
  int get _patientsCount => widget.patientsCount ?? 500;
  int get _reviewsCount => widget.reviewsCount ?? 425;
  bool get _isOnlineConsultation => widget.consultationType == 'VideoCall';

  String get _appointmentTypeLabel {
    const labels = {
      'InClinic': 'Clinic Consultation',
      'VideoCall': 'Online Consultation',
      'HomeVisit': 'Home Visit',
      'FollowUp': 'Follow Up',
      'Emergency': 'Emergency Case',
    };

    return labels[widget.consultationType] ?? widget.consultationType ?? 'N/A';
  }

  void _openChatRoom() {
    Navigator.pushNamed(
      context,
      AppRoutes.doctorChatRoom,
      arguments: {
        'doctorName': _doctorName,
        'specialization': _specialization,
        'clinicName': _clinicName,
        'doctorImage': _doctorImage,
        'consultationType': widget.consultationType,
        'selectedDate': widget.selectedDate,
        'selectedTime': widget.selectedTime,
      },
    );
  }

  void _showOnlineRoomNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your online room link will appear here once confirmed.'),
      ),
    );
  }

  Future<void> _cancelAppointment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel appointment?'),
          content: const Text(
            'This will cancel the appointment and the money will not return to the wallet.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep Appointment'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cancel Appointment'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    CherryToast.info(
      title: const Text('Appointment cancelled'),
      description: const Text('The appointment was cancelled.'),
    ).show(context);

    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CustomAppBar(
        title: 'Appointment Summary',
        showNotification: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 124),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DoctorViewCard(
                doctorName: _doctorName,
                specialization: _specialization,
                clinicName: _clinicName,
                rating: _rating,
                doctorImagePath: _doctorImage,
                yearsOfExperience: _yearsOfExperience,
                patientsCount: _patientsCount,
                reviewsCount: _reviewsCount,
              ),
              const SizedBox(height: 24),
              _SectionTitle('About Me'),
              const SizedBox(height: 8),
              Text(
                'Experienced Dental Consultant with 10+ years of practice in Egypt. Expert in pediatric, restorative, and cosmetic dentistry, specializing in patient-centered care verified by the Ministry of Health.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle('Clinic Information'),
              const SizedBox(height: 12),
              const _ClinicInfoCard(),
              const SizedBox(height: 24),
              _SectionTitle('Appointment Details'),
              const SizedBox(height: 12),
              _DetailsCard(
                children: [
                  _DetailRow(
                    label: 'Consultation Type',
                    value: _appointmentTypeLabel,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Date',
                    value: widget.selectedDate ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Time',
                    value: widget.selectedTime ?? 'N/A',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _AvailabilityNotice(
                text:
                    'The chat between you and the doctor is available only for 7 days after booking confirmation.',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isOnlineConsultation) ...[
              SizedBox(
                height: 54,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showOnlineRoomNotice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Join Online Room',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              height: 54,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _openChatRoom,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.deepNavy, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Chat with Doctor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepNavy,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _cancelAppointment,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade400, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Cancel Appointment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ClinicInfoRow(
                  icon: Icons.local_hospital_outlined,
                  label: 'Name:',
                  value: 'Dar El-Hekma Clinic',
                ),
                SizedBox(height: 10),
                _ClinicInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Contact:',
                  value: '01014256852',
                ),
                SizedBox(height: 10),
                _ClinicInfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address:',
                  value: '51 Rabbaa Street, Cairo',
                ),
                SizedBox(height: 10),
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
  const _ClinicInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.skyBlue, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: AppColors.deepNavy,
                fontSize: 13,
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: '$label\n',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.deepNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvailabilityNotice extends StatelessWidget {
  const _AvailabilityNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.skyBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.skyBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
