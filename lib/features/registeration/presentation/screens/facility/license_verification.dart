import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:smartclinic/features/auth/domain/auth_repo.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/network/api_result.dart';
import 'package:smartclinic/core/widgets/auth_header.dart';
import 'package:smartclinic/core/widgets/custom_button.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:smartclinic/injection_dependency.dart';
import 'package:smartclinic/features/auth/data/models/verification_file_model.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:cherry_toast/cherry_toast.dart';

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
  bool _isSubmitting = false;
  final UserSession _userSession = getIt<UserSession>();

  String? get _doctorId {
    final args = widget.registrationArgs;
    if (args != null) {
      final value = args['userId'] ?? args['doctorId'] ?? args['id'];
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }

    final sessionUserId = _userSession.userId?.trim();
    if (sessionUserId == null || sessionUserId.isEmpty) {
      return null;
    }

    return sessionUserId;
  }

  @override
  void initState() {
    super.initState();
    final initialRegistrationNumber = _doctorId;
    if (initialRegistrationNumber != null) {
      _syndicateCardController.text = initialRegistrationNumber;
    }
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
      CherryToast.error(
        title: const Text('Missing files'),
        description: const Text('Please upload all required documents first.'),
      ).show(context);
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
      CherryToast.success(
        title: const Text('Success'),
        description: const Text(
          'Your documents were uploaded successfully and are under review now.',
        ),
      ).show(context);
      await Future.delayed(const Duration(milliseconds: 700));
      // Save the professional photo locally in session so it can be used
      // immediately for profile / search card display while backend processes it.
      if (_professionalPhotoFile?.path != null) {
        await _userSession.saveProfileImage(_professionalPhotoFile!.path!);
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.verification,
        arguments: {
          'email': _userSession.email,
          'registrationEmail': _userSession.email,
        },
      );
    } else if (response is Failure<dynamic>) {
      CherryToast.error(
        title: const Text('Error'),
        description: Text(response.message),
      ).show(context);
    }
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
}
