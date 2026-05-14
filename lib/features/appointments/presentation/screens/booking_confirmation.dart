import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:cherry_toast/cherry_toast.dart';

class BookingConfirmationPage extends StatefulWidget {
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

  const BookingConfirmationPage({
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
  State<BookingConfirmationPage> createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  bool _isExporting = false;

  Future<void> _downloadReceipt() async {
    if (_isExporting) return;

    setState(() => _isExporting = true);

    try {
      final pdf = _buildReceiptPdf();
      final bytes = await pdf.save();
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save receipt as',
        fileName: _buildReceiptFileName(),
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        bytes: bytes,
      );

      if (!mounted) return;
      final message = savedPath == null
          ? 'Receipt download canceled.'
          : 'Receipt PDF saved to $savedPath';
      CherryToast.info(
        title: const Text('Receipt'),
        description: Text(message),
      ).show(context);
    } catch (error) {
      if (!mounted) return;
      CherryToast.error(
        title: const Text('Export failed'),
        description: Text('Failed to export receipt PDF: $error'),
      ).show(context);
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  String _buildReceiptFileName() {
    final now = DateTime.now();
    final datePart =
        '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timePart =
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    return 'booking_receipt_${datePart}_$timePart.pdf';
  }

  pw.Document _buildReceiptPdf() {
    final doctorNameValue = widget.doctorName ?? 'Dr. Mai El Kady';
    final specializationValue = widget.specialization ?? 'Physician';
    final clinicNameValue = widget.clinicName ?? 'Good Health Care';
    final ratingValue = widget.rating ?? 4.8;
    final selectedDateValue = widget.selectedDate ?? '2026-05-14';
    final selectedTimeValue = widget.selectedTime ?? '10:00 AM';
    final consultationTypeValue =
        widget.consultationType ?? 'Online Consultation';
    final patientNameValue = widget.patientName ?? 'Patient';
    final paymentMethodValue = (widget.paymentMethod ?? 'wallet').toLowerCase();
    final paymentStatusValue = paymentMethodValue == 'cash' ? 'Unpaid' : 'Paid';

    final pdf = pw.Document();
    final deepNavy = PdfColor.fromInt(AppColors.deepNavy.value);
    final skyBlue = PdfColor.fromInt(AppColors.skyBlue.value);
    final textSecondary = PdfColor.fromInt(AppColors.textSecondary.value);
    final successGreen = PdfColor.fromInt(const Color(0xFF62C47E).value);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(
                child: pw.Container(
                  width: 70,
                  height: 70,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(const Color(0xFFE5F0FF).value),
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Container(
                      width: 38,
                      height: 38,
                      decoration: pw.BoxDecoration(
                        color: skyBlue,
                        shape: pw.BoxShape.circle,
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          '✓',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text(
                  'Booking Successful',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: deepNavy,
                  ),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  'Your appointment has been confirmed.\nYou can find the details below.',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 11, color: textSecondary),
                ),
              ),
              pw.SizedBox(height: 18),
              _pdfSectionTitle('BOOKING INFORMATION', deepNavy),
              pw.SizedBox(height: 8),
              _pdfCard([
                _pdfRow('Consultation Type', consultationTypeValue, deepNavy),
                _pdfDivider(),
                _pdfRow('Date', selectedDateValue, deepNavy),
                _pdfDivider(),
                _pdfRow('Time', selectedTimeValue, deepNavy),
              ]),
              pw.SizedBox(height: 14),
              _pdfSectionTitle('PAYMENT INFORMATION', deepNavy),
              pw.SizedBox(height: 8),
              _pdfCard([
                _pdfRow(
                  'Payment Method',
                  paymentMethodValue == 'cash' ? 'Cash' : 'Wallet',
                  deepNavy,
                ),
                _pdfDivider(),
                _pdfRow(
                  'Status',
                  paymentStatusValue,
                  deepNavy,
                  valueWidget: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(
                        (paymentStatusValue == 'Paid'
                                ? const Color(0xFFE8F7EA)
                                : const Color(0xFFFDEBD8))
                            .value,
                      ),
                      borderRadius: pw.BorderRadius.circular(999),
                    ),
                    child: pw.Text(
                      paymentStatusValue,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: paymentStatusValue == 'Paid'
                            ? successGreen
                            : PdfColor.fromInt(const Color(0xFFE67E22).value),
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ]),
              pw.SizedBox(height: 14),
              _pdfSectionTitle('PAYMENT SUMMARY', deepNavy),
              pw.SizedBox(height: 8),
              _pdfCard([
                _pdfRow('Amount', '\$20.00', deepNavy),
                _pdfDivider(),
                _pdfRow('Duration (30 mins)', '1 x \$20.00', deepNavy),
                _pdfDivider(),
                _pdfRow('Total', '\$20.00', deepNavy, boldValue: true),
              ]),
              pw.SizedBox(height: 14),
              _pdfCard([
                _pdfRow('Doctor', doctorNameValue, deepNavy),
                _pdfDivider(),
                _pdfRow('Specialization', specializationValue, deepNavy),
                _pdfDivider(),
                _pdfRow('Clinic', clinicNameValue, deepNavy),
                _pdfDivider(),
                _pdfRow('Patient', patientNameValue, deepNavy),
                _pdfDivider(),
                _pdfRow('Rating', ratingValue.toStringAsFixed(1), deepNavy),
              ]),
              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Generated by SmartClinic',
                  style: pw.TextStyle(color: textSecondary, fontSize: 9),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _pdfSectionTitle(String title, PdfColor color) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: pw.FontWeight.bold,
        letterSpacing: 0.35,
      ),
    );
  }

  pw.Widget _pdfCard(List<pw.Widget> children) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(
          color: PdfColor.fromInt(const Color(0xFFE6EAF0).value),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  pw.Widget _pdfDivider() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Divider(
        height: 1,
        thickness: 1,
        color: PdfColor.fromInt(const Color(0xFFE6EAF0).value),
      ),
    );
  }

  pw.Widget _pdfRow(
    String label,
    String value,
    PdfColor textColor, {
    pw.Widget? valueWidget,
    bool boldValue = false,
  }) {
    final labelStyle = pw.TextStyle(
      color: PdfColor.fromInt(AppColors.textSecondary.value),
      fontSize: 13,
      fontWeight: pw.FontWeight.normal,
    );

    final valueFontSize = boldValue ? 14.0 : 13.0;
    final valueStyle = pw.TextStyle(
      color: textColor,
      fontSize: valueFontSize,
      fontWeight: boldValue ? pw.FontWeight.bold : pw.FontWeight.normal,
    );

    return pw.Row(
      children: [
        pw.Expanded(child: pw.Text(label, style: labelStyle)),
        pw.SizedBox(width: 12),
        valueWidget ??
            pw.Text(value, textAlign: pw.TextAlign.right, style: valueStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorNameValue = widget.doctorName ?? 'Dr. Mai El Kady';
    final specializationValue = widget.specialization ?? 'Physician';
    final clinicNameValue = widget.clinicName ?? 'Good Health Care';
    final ratingValue = widget.rating ?? 4.8;
    final selectedDateValue = widget.selectedDate ?? '2026-05-14';
    final selectedTimeValue = widget.selectedTime ?? '10:00 AM';
    final consultationTypeValue =
        widget.consultationType ?? 'Online Consultation';
    final patientNameValue = widget.patientName ?? 'Patient';
    final paymentMethodValue = (widget.paymentMethod ?? 'wallet').toLowerCase();
    final paymentStatusValue = paymentMethodValue == 'cash' ? 'Unpaid' : 'Paid';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CustomAppBar(
        title: 'Booking Confirmation',
        showBackButton: false,
        showNotification: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 6),
                    const Center(child: _SuccessBadge()),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Booking Successful',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.deepNavy,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Your appointment has been confirmed.\nYou can find the details below.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _SectionTitle('BOOKING INFORMATION'),
                    const SizedBox(height: 8),
                    _InfoCard(
                      children: [
                        _InfoRow(
                          label: 'Consultation Type',
                          value: consultationTypeValue,
                          valueStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepNavy,
                          ),
                        ),
                        const Divider(height: 20),
                        _InfoRow(label: 'Date', value: selectedDateValue),
                        const Divider(height: 20),
                        _InfoRow(label: 'Time', value: selectedTimeValue),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _SectionTitle('PAYMENT INFORMATION'),
                    const SizedBox(height: 8),
                    _InfoCard(
                      children: [
                        _InfoRow(
                          label: 'Payment Method',
                          value: paymentMethodValue == 'cash'
                              ? 'Cash'
                              : 'Wallet',
                          leading: const _PaymentMethodMark(),
                          valueStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepNavy,
                          ),
                        ),
                        const Divider(height: 20),
                        _InfoRow(
                          label: 'Status',
                          value: paymentStatusValue,
                          valueChip: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: paymentStatusValue == 'Paid'
                                  ? const Color(0xFFE8F7EA)
                                  : const Color(0xFFFDEBD8),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              paymentStatusValue,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: paymentStatusValue == 'Paid'
                                    ? const Color(0xFF62C47E)
                                    : const Color(0xFFE67E22),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _SectionTitle('PAYMENT SUMMARY'),
                    const SizedBox(height: 8),
                    _InfoCard(
                      children: [
                        _InfoRow(label: 'Amount', value: '\$20.00'),
                        const Divider(height: 20),
                        _InfoRow(
                          label: 'Duration (30 mins)',
                          value: '1 x \$20.00',
                        ),
                        const Divider(height: 20),
                        _InfoRow(
                          label: 'Total',
                          value: '\$20.00',
                          labelStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.deepNavy,
                          ),
                          valueStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoCard(
                      children: [
                        _InfoRow(label: 'Doctor', value: doctorNameValue),
                        const Divider(height: 20),
                        _InfoRow(
                          label: 'Specialization',
                          value: specializationValue,
                        ),
                        const Divider(height: 20),
                        _InfoRow(label: 'Clinic', value: clinicNameValue),
                        const Divider(height: 20),
                        _InfoRow(label: 'Patient', value: patientNameValue),
                        const Divider(height: 20),
                        _InfoRow(
                          label: 'Rating',
                          value: ratingValue.toStringAsFixed(1),
                        ),
                        const Divider(height: 20),
                        _InfoRow(
                          label: 'Payment Status',
                          value: paymentStatusValue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _isExporting ? null : _downloadReceipt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isExporting ? 'Downloading...' : 'Download Receipt',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.home,
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.deepNavy,
                        side: BorderSide(
                          color: AppColors.deepNavy.withValues(alpha: 0.25),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
}

class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFFE5F0FF),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.skyBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.35,
        color: AppColors.deepNavy.withValues(alpha: 0.75),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Widget? leading;
  final Widget? valueChip;

  const _InfoRow({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.leading,
    this.valueChip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              Flexible(
                child: Text(
                  label,
                  style:
                      labelStyle ??
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        valueChip ??
            Text(
              value,
              textAlign: TextAlign.right,
              style:
                  valueStyle ??
                  TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepNavy,
                  ),
            ),
      ],
    );
  }
}

class _PaymentMethodMark extends StatelessWidget {
  const _PaymentMethodMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: AppColors.skyBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.skyBlue,
          ),
        ),
      ),
    );
  }
}
