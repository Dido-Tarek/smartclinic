import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/features/appointments/data/model/appointment_request_model.dart';
import 'package:smartclinic/features/appointments/data/repo/appointment_repo.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/doctor_view_card.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/injection_dependency.dart';

class BookingSummaryPage extends StatefulWidget {
  final String? doctorId;
  final int? clinicId;
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
  final int? familyMemberId;
  final String? notes;
  final String? paymentMethod;

  const BookingSummaryPage({
    super.key,
    this.doctorId,
    this.clinicId,
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
    this.familyMemberId,
    this.notes,
    this.paymentMethod,
  });

  @override
  State<BookingSummaryPage> createState() => _BookingSummaryPageState();
}

class _BookingSummaryPageState extends State<BookingSummaryPage> {
  late String _selectedPaymentMethod;
  bool _isSubmitting = false;
  final double _appointmentAmount = 20.0;
  final int _durationMinutes = 30;

  DateTime? _parseBookingDate(String value) {
    final parsedIso = DateTime.tryParse(value);
    if (parsedIso != null) {
      return parsedIso;
    }

    final isoDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (isoDate != null) {
      final year = int.tryParse(isoDate.group(1)!);
      final month = int.tryParse(isoDate.group(2)!);
      final day = int.tryParse(isoDate.group(3)!);
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }

    final slashDate = RegExp(
      r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})$',
    ).firstMatch(value);
    if (slashDate != null) {
      final first = int.tryParse(slashDate.group(1)!);
      final second = int.tryParse(slashDate.group(2)!);
      final year = int.tryParse(slashDate.group(3)!);
      if (first != null && second != null && year != null) {
        final firstCandidate = DateTime(year, second, first);
        if (_matchesDateParts(firstCandidate, year, second, first)) {
          return firstCandidate;
        }

        final secondCandidate = DateTime(year, first, second);
        if (_matchesDateParts(secondCandidate, year, first, second)) {
          return secondCandidate;
        }
      }
    }

    final namedDate = RegExp(
      r'^(?:[A-Za-z]{3,9},\s*)?(\d{1,2})\s+([A-Za-z]{3,9})\s+(\d{4})$',
    ).firstMatch(value);
    if (namedDate != null) {
      final day = int.tryParse(namedDate.group(1)!);
      final month = _monthNumber(namedDate.group(2)!);
      final year = int.tryParse(namedDate.group(3)!);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }

  bool _matchesDateParts(DateTime candidate, int year, int month, int day) {
    return candidate.year == year &&
        candidate.month == month &&
        candidate.day == day;
  }

  int? _monthNumber(String monthName) {
    const monthNames = <String, int>{
      'january': 1,
      'february': 2,
      'march': 3,
      'april': 4,
      'may': 5,
      'june': 6,
      'july': 7,
      'august': 8,
      'september': 9,
      'october': 10,
      'november': 11,
      'december': 12,
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'sept': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };

    return monthNames[monthName.toLowerCase()];
  }

  String _formatIsoDate(DateTime date) {
    final utcDate = DateTime.utc(date.year, date.month, date.day);
    return utcDate.toIso8601String();
  }

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = 'wallet';
  }

  String _getConsultationTypeLabel(String? type) {
    const labels = {
      'clinic': 'Clinic Consultation',
      'online': 'Online Consultation',
      'homeVisit': 'Home Visit',
      'emergency': 'Emergency Case',
    };
    return labels[type] ?? type ?? 'N/A';
  }

  String _getPaymentMethodLabel(String? method) {
    return method == 'cash' ? 'Cash' : 'Wallet';
  }

  bool _isOnlineConsultation(String? type) {
    final normalized = (type ?? '').toLowerCase();
    return normalized.contains('online');
  }

  Future<void> _onConfirmAppointment() async {
    final patientId = getIt<UserSession>().userId?.trim();
    final doctorId = (widget.doctorId?.trim().isNotEmpty ?? false)
        ? widget.doctorId!.trim()
        : '5fe5c967-3797-4dac-a1a8-3faba1265e32';
    final clinicId = widget.clinicId ?? 2;
    final selectedDate = widget.selectedDate;
    final selectedTime = widget.selectedTime;
    final consultationType = widget.consultationType ?? 'clinic';

    if (patientId == null ||
        patientId.isEmpty ||
        selectedDate == null ||
        selectedTime == null) {
      CherryToast.error(
        title: const Text('Booking failed'),
        description: const Text('Missing booking information.'),
      ).show(context);
      return;
    }

    setState(() => _isSubmitting = true);

    final normalizedDate = _normalizeDateForApi(selectedDate);
    final normalizedTime = _normalizeTimeForApi(selectedTime);

    final request = BookAppointmentRequestModel(
      patientId: patientId,
      doctorId: doctorId,
      clinicId: clinicId,
      date: normalizedDate,
      time: normalizedTime,
      type: consultationType,
      familyMemberId: widget.familyMemberId,
      notes: widget.notes,
      patientName: widget.patientName,
      payFromWallet: _selectedPaymentMethod == 'wallet',
    );

    final result = await getIt<AppointmentsRepo>().bookAppointment(request);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    result.fold(
      (error) {
        CherryToast.error(
          title: const Text('Booking failed'),
          description: Text(error),
        ).show(context);
      },
      (_) {
        CherryToast.success(
          title: const Text('Appointment booked'),
          description: const Text(
            'Your appointment was submitted successfully.',
          ),
        ).show(context);

        if (_selectedPaymentMethod == 'wallet') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.appointments,
            (route) => false,
            arguments: {'initialIndex': 0},
          );
          return;
        }

        Navigator.pushNamed(
          context,
          AppRoutes.bookingConfirmation,
          arguments: {
            'doctorName': widget.doctorName,
            'specialization': widget.specialization,
            'clinicName': widget.clinicName,
            'rating': widget.rating,
            'doctorImage': widget.doctorImage,
            'yearsOfExperience': widget.yearsOfExperience,
            'patientsCount': widget.patientsCount,
            'reviewsCount': widget.reviewsCount,
            'consultationType': consultationType,
            'selectedDate': selectedDate,
            'selectedTime': selectedTime,
            'patientName': widget.patientName,
            'paymentMethod': _selectedPaymentMethod,
          },
        );
      },
    );
  }

  String _normalizeDateForApi(String? dateStr) {
    if (dateStr == null) return '';
    final parsed = _parseBookingDate(dateStr.trim());
    if (parsed != null) {
      return _formatDateOnly(parsed);
    }

    return dateStr.trim();
  }

  String _normalizeTimeForApi(String? timeStr) {
    if (timeStr == null) return '';
    final trimmed = timeStr.trim();
    if (trimmed.isEmpty) return trimmed;

    final ampmMatch = RegExp(
      r'^(\d{1,2}):(\d{2})(?::(\d{2}))?\s*([AaPp][Mm])\b',
    ).firstMatch(trimmed);
    if (ampmMatch != null) {
      final hour = int.parse(ampmMatch.group(1)!);
      final minute = int.parse(ampmMatch.group(2)!);
      final ampm = ampmMatch.group(4)!.toLowerCase();
      var hour24 = hour % 12;
      if (ampm == 'pm') {
        hour24 += 12;
      }
      return '${hour24.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }

    final hhmm = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(trimmed);
    if (hhmm != null) {
      return '${int.parse(hhmm.group(1)!).toString().padLeft(2, '0')}:${hhmm.group(2)!}';
    }

    final hhmmss = RegExp(r'^(\d{1,2}):(\d{2}):(\d{2})$').firstMatch(trimmed);
    if (hhmmss != null) {
      return '${int.parse(hhmmss.group(1)!).toString().padLeft(2, '0')}:${hhmmss.group(2)!}';
    }

    return trimmed;
  }

  String _formatDateOnly(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = widget.doctorName ?? 'Dr. Mai ElKady';
    final specialization = widget.specialization ?? 'Physician';
    final clinicName = widget.clinicName ?? 'Good Health Care';
    final rating = widget.rating ?? 4.8;
    final reviewsCount = widget.reviewsCount ?? 0;
    final yearsOfExperience = widget.yearsOfExperience ?? 6;
    final patientsCount = widget.patientsCount ?? 2000;
    final doctorImage = widget.doctorImage ?? AppImages.imagesDoctorDRMaiElKady;
    final paymentMethodLabel = _getPaymentMethodLabel(_selectedPaymentMethod);
    final showCashOption = !_isOnlineConsultation(widget.consultationType);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const CustomAppBar(title: 'Summary', showNotification: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Information Section
              _buildSectionTitle('Doctor Information'),
              const SizedBox(height: 12),
              DoctorViewCard(
                doctorName: doctorName,
                specialization: specialization,
                clinicName: clinicName,
                rating: rating,
                doctorImagePath: doctorImage,
                yearsOfExperience: yearsOfExperience,
                patientsCount: patientsCount,
                reviewsCount: reviewsCount,
              ),
              const SizedBox(height: 24),

              // Booking Information Section
              _buildSectionTitle('Booking Information'),
              const SizedBox(height: 12),
              _buildBookingInfoCard(),
              const SizedBox(height: 24),

              // Payment Information Section
              _buildSectionTitle('Payment Method'),
              const SizedBox(height: 12),
              _buildPaymentMethodCard(showCashOption: showCashOption),
              const SizedBox(height: 8),
              Text(
                'Selected: $paymentMethodLabel',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Receipt Section
              _buildSectionTitle('Payment Summary'),
              const SizedBox(height: 12),
              _buildReceiptCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _onConfirmAppointment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              _isSubmitting ? 'Booking...' : 'Confirm',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.deepNavy,
      ),
    );
  }

  Widget _buildBookingInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        children: [
          _buildInfoRow(
            'Consultation Type',
            _getConsultationTypeLabel(widget.consultationType),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Date', widget.selectedDate ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow('Time', widget.selectedTime ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.deepNavy,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard({required bool showCashOption}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        children: [
          _buildPaymentOption(
            'Wallet',
            'wallet',
            'Pay from your wallet balance',
          ),
          if (showCashOption) ...[
            const SizedBox(height: 12),
            _buildPaymentOption('Cash', 'cash', 'Pay cash on appointment'),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, String value, String subtitle) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _selectedPaymentMethod == value
              ? AppColors.skyBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _selectedPaymentMethod == value
                ? AppColors.skyBlue
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedPaymentMethod = newValue;
                  });
                }
              },
              activeColor: AppColors.skyBlue,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard() {
    final totalAmount = _appointmentAmount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        children: [
          _buildReceiptRow(
            'Amount',
            'EGP ${_appointmentAmount.toStringAsFixed(2)}',
            isHeader: false,
          ),
          const SizedBox(height: 12),
          _buildReceiptRow(
            'Duration ($_durationMinutes mins)',
            '1 x EGP ${_appointmentAmount.toStringAsFixed(2)}',
            isHeader: false,
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade300, height: 1),
          const SizedBox(height: 12),
          _buildReceiptRow(
            'Total',
            'EGP ${totalAmount.toStringAsFixed(2)}',
            isHeader: true,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    required bool isHeader,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHeader ? 14 : 13,
            color: isHeader ? AppColors.deepNavy : AppColors.textSecondary,
            fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHeader ? 14 : 13,
            color: AppColors.deepNavy,
            fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
