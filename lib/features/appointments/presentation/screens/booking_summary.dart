import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/doctor_view_card.dart';
import 'package:smartclinic/core/constants/assets.dart';

class BookingSummaryPage extends StatefulWidget {
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

  const BookingSummaryPage({
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
  State<BookingSummaryPage> createState() => _BookingSummaryPageState();
}

class _BookingSummaryPageState extends State<BookingSummaryPage> {
  late String _selectedPaymentMethod;
  final double _appointmentAmount = 20.0;
  final int _durationMinutes = 30;

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

  void _onConfirmAppointment() {
    final doctorName = widget.doctorName ?? 'Dr. Mai ElKady';
    final specialization = widget.specialization ?? 'Physician';
    final clinicName = widget.clinicName ?? 'Good Health Care';
    final rating = widget.rating ?? 4.8;
    final doctorImage = widget.doctorImage ?? AppImages.imagesDoctorDRMaiElKady;
    final yearsOfExperience = widget.yearsOfExperience ?? 6;
    final patientsCount = widget.patientsCount ?? 2000;
    final reviewsCount = widget.reviewsCount ?? 0;
    final consultationType = widget.consultationType;
    final selectedDate = widget.selectedDate;
    final selectedTime = widget.selectedTime;
    final patientName = widget.patientName;

    // Navigate to booking confirmation with all booking and doctor details
    Navigator.pushNamed(
      context,
      AppRoutes.bookingConfirmation,
      arguments: {
        'doctorName': doctorName,
        'specialization': specialization,
        'clinicName': clinicName,
        'rating': rating,
        'doctorImage': doctorImage,
        'yearsOfExperience': yearsOfExperience,
        'patientsCount': patientsCount,
        'reviewsCount': reviewsCount,
        'consultationType': consultationType,
        'selectedDate': selectedDate,
        'selectedTime': selectedTime,
        'patientName': patientName,
        'paymentMethod': _selectedPaymentMethod,
      },
    );
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
            onPressed: _onConfirmAppointment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
            '\$${_appointmentAmount.toStringAsFixed(2)}',
            isHeader: false,
          ),
          const SizedBox(height: 12),
          _buildReceiptRow(
            'Duration ($_durationMinutes mins)',
            '1 x \$${_appointmentAmount.toStringAsFixed(2)}',
            isHeader: false,
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade300, height: 1),
          const SizedBox(height: 12),
          _buildReceiptRow(
            'Total',
            '\$${totalAmount.toStringAsFixed(2)}',
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
