import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:smartclinic/features/auth/domain/auth_repo.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/core/widgets/auth_header.dart';
import 'package:smartclinic/core/widgets/custom_button.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:smartclinic/injection_dependency.dart';
import 'package:smartclinic/features/auth/data/models/verification_file_model.dart';
import 'package:smartclinic/core/routes/app_routes.dart';

enum LicenseReviewStatus { done, pending, rejected }

class LicenseVerificationPage extends StatefulWidget {
  final LicenseReviewStatus reviewStatus;
  final Map<String, dynamic>? registrationArgs;

  const LicenseVerificationPage({
    super.key,
    this.reviewStatus = LicenseReviewStatus.pending,
    this.registrationArgs,
  });

  @override
  State<LicenseVerificationPage> createState() =>
      _LicenseVerificationPageState();
}

class _LicenseVerificationPageState extends State<LicenseVerificationPage> {
  static const List<String> _allowedExtensions = <String>[
    'pdf',
    'jpg',
    'jpeg',
    'png',
  ];

  final TextEditingController _syndicateCardController =
      TextEditingController();
  final TextEditingController _proffesionalPhotoController =
      TextEditingController();
  final TextEditingController _specializationCertificateController =
      TextEditingController();

  PlatformFile? _medicalLicenseFile;
  PlatformFile? _syndicateCardFile;
  PlatformFile? _professionalPhotoFile;
  PlatformFile? _specializationCertificateFile;
  LicenseReviewStatus _currentReviewStatus = LicenseReviewStatus.pending;
  bool _isSubmitting = false;

  String? get _doctorId {
    final args = widget.registrationArgs;
    if (args == null) {
      return null;
    }

    final value = args['userId'] ?? args['doctorId'] ?? args['id'];
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  @override
  void initState() {
    super.initState();
    _currentReviewStatus = widget.reviewStatus;
    final initialRegistrationNumber = _doctorId;
    if (initialRegistrationNumber != null) {
      _syndicateCardController.text = initialRegistrationNumber;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshReviewStatus();
    });
  }

  @override
  void dispose() {
    _syndicateCardController.dispose();
    _proffesionalPhotoController.dispose();
    _specializationCertificateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AuthHeader(
                      title: localizations.translate(
                        'license_verification_title',
                      ),
                      subTitle: localizations.translate(
                        'license_verification_subtitle',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      localizations.translate('medical_license_label'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildUploadContainer(
                      localizations,
                      selectedFile: _medicalLicenseFile,
                      onTap: _pickMedicalLicense,
                      onClear: () => setState(() => _medicalLicenseFile = null),
                      hintText: localizations.translate(
                        'medical_license_upload_text',
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      localizations.translate('Syndicate_card_label'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppTextFormField(
                      hintText: localizations.translate('syndicate_card_hint'),
                      controller: _syndicateCardController,
                      type: TextFormFieldType.fileUpload,
                      onSuffixTap: _pickSyndicateCard,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      localizations.translate('professional_photo_label'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppTextFormField(
                      hintText: localizations.translate(
                        'professional_photo_hint',
                      ),
                      controller: _proffesionalPhotoController,
                      type: TextFormFieldType.fileUpload,
                      onSuffixTap: _pickProfessionalPhoto,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      localizations.translate('specilization_certi_label'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppTextFormField(
                      hintText: localizations.translate(
                        'specilization_certi_hint',
                      ),
                      controller: _specializationCertificateController,
                      type: TextFormFieldType.fileUpload,
                      onSuffixTap: _pickSpecializationCertificate,
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
              child: _buildStatusBadge(localizations),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
              child: CustomButton(
                text: localizations.translate('Save'),
                onPressed: _isSubmitting ? () {} : _submitVerification,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMedicalLicense() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      allowMultiple: false,
    );

    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      _medicalLicenseFile = result.files.first;
    });
  }

  Future<void> _pickSyndicateCard() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      allowMultiple: false,
    );

    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      _syndicateCardFile = result.files.first;
      _syndicateCardController.text = result.files.first.name;
    });
  }

  Future<void> _pickProfessionalPhoto() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      allowMultiple: false,
    );

    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      _professionalPhotoFile = result.files.first;
      _proffesionalPhotoController.text = result.files.first.name;
    });
  }

  Future<void> _pickSpecializationCertificate() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      allowMultiple: false,
    );

    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      _specializationCertificateFile = result.files.first;
      _specializationCertificateController.text = result.files.first.name;
    });
  }

  Future<void> _submitVerification() async {
    final doctorId = _doctorId;
    if (doctorId == null ||
        doctorId.isEmpty ||
        _medicalLicenseFile == null ||
        _syndicateCardFile == null ||
        _professionalPhotoFile == null ||
        _specializationCertificateFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final response = await getIt<AuthRepo>().uploadVerificationDocs(
      doctorId: doctorId,
      files: VerificationFileModel(
        syndicatCard: File(_syndicateCardFile!.path!),
        license: File(_medicalLicenseFile!.path!),
        nationalId: File(_professionalPhotoFile!.path!),
        specializationCert: File(_specializationCertificateFile!.path!),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (response is Success<dynamic>) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification data submitted')),
      );
      await _waitForApprovalAndNavigate();
    } else if (response is Failure<dynamic>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _refreshReviewStatus() async {
    final doctorId = _doctorId;
    if (doctorId == null || doctorId.isEmpty) {
      return;
    }

    final response = await getIt<AuthRepo>().getPendingDoctors();
    if (!mounted) {
      return;
    }

    if (response is Success<List<dynamic>>) {
      final status = _resolveReviewStatus(doctorId, response.data);
      if (status != null) {
        setState(() {
          _currentReviewStatus = status;
        });
      }
    }
  }

  LicenseReviewStatus? _resolveReviewStatus(
    String doctorId,
    List<dynamic> doctors,
  ) {
    for (final doctor in doctors) {
      if (doctor is! Map) {
        continue;
      }

      final normalized = doctor.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final candidateId =
          normalized['userId'] ?? normalized['doctorId'] ?? normalized['id'];
      if (candidateId?.toString() != doctorId) {
        continue;
      }

      return _mapStatus(
        normalized['status'] ??
            normalized['approvalStatus'] ??
            normalized['reviewStatus'],
      );
    }

    return LicenseReviewStatus.pending;
  }

  Future<void> _waitForApprovalAndNavigate() async {
    final doctorId = _doctorId;
    if (doctorId == null || doctorId.isEmpty) {
      return;
    }

    const int maxAttempts = 15;
    const Duration pollDelay = Duration(seconds: 2);

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final response = await getIt<AuthRepo>().getPendingDoctors();
      if (!mounted) {
        return;
      }

      if (response is Success<List<dynamic>>) {
        final status = _resolveReviewStatus(doctorId, response.data);
        if (status == LicenseReviewStatus.done) {
          setState(() {
            _currentReviewStatus = LicenseReviewStatus.done;
          });
          if (!mounted) {
            return;
          }
          Navigator.of(
            context,
          ).pushReplacementNamed(AppRoutes.medicalFacilityManagement);
          return;
        }

        if (status == LicenseReviewStatus.rejected) {
          setState(() {
            _currentReviewStatus = LicenseReviewStatus.rejected;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification was rejected.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          _currentReviewStatus = LicenseReviewStatus.pending;
        });
      }

      if (attempt < maxAttempts - 1) {
        await Future.delayed(pollDelay);
      }
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification is still pending. Try again later.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  LicenseReviewStatus? _mapStatus(dynamic statusValue) {
    final status = statusValue?.toString().trim().toLowerCase();
    if (status == null || status.isEmpty) {
      return null;
    }

    if (status.contains('approve') ||
        status.contains('done') ||
        status.contains('complete')) {
      return LicenseReviewStatus.done;
    }

    if (status.contains('reject') ||
        status.contains('decline') ||
        status.contains('deny')) {
      return LicenseReviewStatus.rejected;
    }

    return LicenseReviewStatus.pending;
  }

  Widget _buildUploadContainer(
    AppLocalizations localizations, {
    required PlatformFile? selectedFile,
    required VoidCallback onTap,
    required VoidCallback onClear,
    required String hintText,
  }) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: const Radius.circular(18),
        color: AppColors.softLavender.withValues(alpha: 0.45),
        strokeWidth: 1.4,
        dashPattern: const <double>[8, 8],
        padding: EdgeInsets.zero,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.cardBg.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(18),
          ),
          child: selectedFile == null
              ? Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 64,
                      color: AppColors.skyBlue,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hintText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: AppColors.deepNavy,
                      size: 26,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedFile.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            localizations.translate('medical_license_uploaded'),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onClear,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.error,
                        size: 22,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AppLocalizations localizations) {
    final Color statusColor = _statusColor;
    final String statusValue = _statusLabel(localizations);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: statusColor, width: 2),
                color: Colors.white,
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Status: ',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: statusValue,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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

  Color get _statusColor {
    switch (_currentReviewStatus) {
      case LicenseReviewStatus.done:
        return AppColors.success;
      case LicenseReviewStatus.pending:
        return AppColors.warning;
      case LicenseReviewStatus.rejected:
        return AppColors.error;
    }
  }

  String _statusLabel(AppLocalizations localizations) {
    switch (_currentReviewStatus) {
      case LicenseReviewStatus.done:
        return localizations.translate('license_status_done');
      case LicenseReviewStatus.pending:
        return localizations.translate('license_status_pending');
      case LicenseReviewStatus.rejected:
        return localizations.translate('license_status_rejected');
    }
  }
}
