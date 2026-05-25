import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // ── shared resolved values ───────────────────────────────────────────────
  String get _consultationType =>
      widget.consultationType ?? 'Online Consultation';
  String get _selectedDate => widget.selectedDate ?? '2026-05-14';
  String get _selectedTime => widget.selectedTime ?? '10:00 AM';
  String get _paymentMethodRaw =>
      (widget.paymentMethod ?? 'wallet').toLowerCase();
  String get _paymentMethodLabel =>
      _paymentMethodRaw == 'cash' ? 'Cash' : 'Wallet';
  String get _paymentStatus => _paymentMethodRaw == 'cash' ? 'Unpaid' : 'Paid';
  bool get _isPaid => _paymentStatus == 'Paid';

  // ── PDF colours ──────────────────────────────────────────────────────────
  static final _pdfDeepNavy = PdfColor.fromInt(AppColors.deepNavy.value);
  static final _pdfSkyBlue = PdfColor.fromInt(AppColors.skyBlue.value);
  static final _pdfSecondary = PdfColor.fromInt(AppColors.textSecondary.value);
  static final _pdfBorder = PdfColor.fromInt(const Color(0xFFE6EAF0).value);
  static final _pdfBgLight = PdfColor.fromInt(const Color(0xFFE5F0FF).value);
  static final _pdfScaffoldBg = PdfColor.fromInt(const Color(0xFFEFF3F8).value);
  static final _pdfGreenText = PdfColor.fromInt(const Color(0xFF62C47E).value);
  static final _pdfGreenBg = PdfColor.fromInt(const Color(0xFFE8F7EA).value);
  static final _pdfOrangeText = PdfColor.fromInt(const Color(0xFFE67E22).value);
  static final _pdfOrangeBg = PdfColor.fromInt(const Color(0xFFFDEBD8).value);

  Future<pw.ThemeData> _buildPdfTheme() async {
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo-Bold.ttf'),
    );

    return pw.ThemeData.withFont(base: regularFont, bold: boldFont);
  }

  // ────────────────────────────────────────────────────────────────────────
  // Download
  // ────────────────────────────────────────────────────────────────────────
  Future<void> _downloadReceipt() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final pdf = await _buildReceiptPdf();
      final bytes = await pdf.save();
      final saved = await FilePicker.platform.saveFile(
        dialogTitle: 'Save receipt as',
        fileName: _buildReceiptFileName(),
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        bytes: bytes,
      );
      if (!mounted) return;
      final msg = saved == null
          ? 'Receipt download canceled.'
          : 'Receipt PDF saved to $saved';
      CherryToast.info(
        title: const Text('Receipt'),
        description: Text(msg),
      ).show(context);
    } catch (error) {
      if (!mounted) return;
      CherryToast.error(
        title: const Text('Export failed'),
        description: Text('Failed to export receipt PDF: $error'),
      ).show(context);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  String _buildReceiptFileName() {
    final now = DateTime.now();
    final d =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final t =
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
    return 'booking_receipt_${d}_$t.pdf';
  }

  // ────────────────────────────────────────────────────────────────────────
  // PDF builder — mirrors the screen 1-to-1
  // ────────────────────────────────────────────────────────────────────────
  Future<pw.Document> _buildReceiptPdf() async {
    final pdf = pw.Document();
    final pdfTheme = await _buildPdfTheme();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          theme: pdfTheme,
          buildBackground: (_) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: _pdfScaffoldBg),
          ),
        ),
        build: (_) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ── success badge ──────────────────────────────────────────
              pw.Center(
                child: pw.Container(
                  width: 80,
                  height: 80,
                  decoration: pw.BoxDecoration(
                    color: _pdfBgLight,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Container(
                      width: 46,
                      height: 46,
                      decoration: pw.BoxDecoration(
                        color: _pdfSkyBlue,
                        shape: pw.BoxShape.circle,
                      ),
                      child: pw.Center(child: _pdfCheckMark()),
                    ),
                  ),
                ),
              ),

              _gap(18),

              // ── title ──────────────────────────────────────────────────
              pw.Center(
                child: pw.Text(
                  'Booking Successful',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: _pdfDeepNavy,
                  ),
                ),
              ),

              _gap(8),

              pw.Center(
                child: pw.Text(
                  'Your appointment has been confirmed.\nYou can find the details below.',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 12, color: _pdfSecondary),
                ),
              ),

              _gap(24),

              // ── BOOKING INFORMATION ────────────────────────────────────
              _pdfSectionTitle('BOOKING INFORMATION'),
              _gap(8),
              _pdfCard([
                _pdfRow(
                  'Consultation Type',
                  _consultationType,
                  boldValue: true, // bold on screen
                ),
                _pdfDivider(),
                _pdfRow('Date', _selectedDate),
                _pdfDivider(),
                _pdfRow('Time', _selectedTime),
              ]),

              _gap(16),

              // ── PAYMENT INFORMATION ────────────────────────────────────
              _pdfSectionTitle('PAYMENT INFORMATION'),
              _gap(8),
              _pdfCard([
                // Payment Method row — has the "G" badge prefix like the screen
                pw.Row(
                  children: [
                    // G badge
                    pw.Container(
                      width: 18,
                      height: 18,
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromInt(
                          AppColors.skyBlue.withValues(alpha: 0.15).value,
                        ),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'G',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: _pdfSkyBlue,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Expanded(
                      child: pw.Text(
                        'Payment Method',
                        style: pw.TextStyle(fontSize: 13, color: _pdfSecondary),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Text(
                      _paymentMethodLabel,
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: _pdfDeepNavy,
                      ),
                    ),
                  ],
                ),

                _pdfDivider(),

                // Status row — coloured pill
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Status',
                        style: pw.TextStyle(fontSize: 13, color: _pdfSecondary),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        color: _isPaid ? _pdfGreenBg : _pdfOrangeBg,
                        borderRadius: pw.BorderRadius.circular(999),
                      ),
                      child: pw.Text(
                        _paymentStatus,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: _isPaid ? _pdfGreenText : _pdfOrangeText,
                        ),
                      ),
                    ),
                  ],
                ),
              ]),

              _gap(16),

              // ── PAYMENT SUMMARY ────────────────────────────────────────
              _pdfSectionTitle('PAYMENT SUMMARY'),
              _gap(8),
              _pdfCard([
                _pdfRow('Amount', 'EGP 20.00'),
                _pdfDivider(),
                _pdfRow('Duration (30 mins)', r'1 x EGP 20.00'),
                _pdfDivider(),
                // Total — both label AND value are bold + slightly larger
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Total',
                        style: pw.TextStyle(
                          fontSize: 15,
                          fontWeight: pw.FontWeight.bold,
                          color: _pdfDeepNavy,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Text(
                      'EGP 20.00',
                      style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        color: _pdfDeepNavy,
                      ),
                    ),
                  ],
                ),
              ]),

              _gap(20),

              // ── footer ─────────────────────────────────────────────────
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Generated by SmartClinic',
                  style: pw.TextStyle(color: _pdfSecondary, fontSize: 9),
                ),
              ),
            ],
          ),
        ], // MultiPage build returns List
      ),
    );

    return pdf;
  }

  // ── PDF micro helpers ────────────────────────────────────────────────────

  pw.SizedBox _gap(double h) => pw.SizedBox(height: h);

  pw.Widget _pdfSectionTitle(String title) => pw.Text(
    title,
    style: pw.TextStyle(
      color: PdfColor.fromInt(AppColors.deepNavy.withValues(alpha: 0.75).value),
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
      letterSpacing: 0.35,
    ),
  );

  pw.Widget _pdfCard(List<pw.Widget> children) => pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      borderRadius: pw.BorderRadius.circular(12),
      border: pw.Border.all(color: _pdfBorder, width: 0.8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: children,
    ),
  );

  pw.Widget _pdfDivider() => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 10),
    child: pw.Divider(height: 1, thickness: 0.8, color: _pdfBorder),
  );

  pw.Widget _pdfCheckMark() => pw.SizedBox(
    width: 18,
    height: 18,
    child: pw.Stack(
      children: [
        pw.Positioned(
          left: 2.5,
          top: 9.0,
          child: pw.Transform.rotateBox(
            angle: -0.72,
            child: pw.Container(
              width: 6.5,
              height: 2.4,
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        pw.Positioned(
          left: 6.0,
          top: 6.0,
          child: pw.Transform.rotateBox(
            angle: 0.72,
            child: pw.Container(
              width: 10.5,
              height: 2.4,
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  pw.Widget _pdfRow(String label, String value, {bool boldValue = false}) =>
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 13, color: _pdfSecondary),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: 13,
              color: _pdfDeepNavy,
              fontWeight: boldValue ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      );

  // ────────────────────────────────────────────────────────────────────────
  // Screen build — unchanged
  // ────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final consultationTypeValue =
        widget.consultationType ?? 'Online Consultation';
    final selectedDateValue = widget.selectedDate ?? '2026-05-14';
    final selectedTimeValue = widget.selectedTime ?? '10:00 AM';
    final patientNameValue = widget.patientName ?? 'Patient';
    final doctorNameValue = widget.doctorName ?? 'Dr. Mai El Kady';
    final specializationValue = widget.specialization ?? 'Physician';
    final clinicNameValue = widget.clinicName ?? 'Good Health Care';
    final ratingValue = widget.rating ?? 4.8;

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
                          value: _paymentMethodLabel,
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
                          value: _paymentStatus,
                          valueChip: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _isPaid
                                  ? const Color(0xFFE8F7EA)
                                  : const Color(0xFFFDEBD8),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _paymentStatus,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _isPaid
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
                        _InfoRow(label: 'Amount', value: r'$20.00'),
                        const Divider(height: 20),
                        _InfoRow(
                          label: 'Duration (30 mins)',
                          value: r'1 x $20.00',
                        ),
                        const Divider(height: 20),
                        _InfoRow(
                          label: 'Total',
                          value: 'EGP 20.00',
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
                          value: _paymentStatus,
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
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (r) => false,
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets (screen only — unchanged)
// ─────────────────────────────────────────────────────────────────────────────

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
