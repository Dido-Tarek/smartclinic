import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/auth_header.dart';
import 'package:smartclinic/core/widgets/custom_button.dart';
import 'package:smartclinic/features/medical_records/data/model/medical_records_request.dart';
import 'package:smartclinic/features/medical_records/presentation/manager/medical_records_cubit.dart';
import 'package:smartclinic/features/medical_records/presentation/manager/medical_records_state.dart';
import 'package:smartclinic/injection_dependency.dart';
import 'package:cherry_toast/cherry_toast.dart';

enum MedicalRecordsSource { registration, profile }

class UploadMedicalRecordsScreen extends StatefulWidget {
  const UploadMedicalRecordsScreen({
    super.key,
    this.source = MedicalRecordsSource.registration,
  });

  final MedicalRecordsSource source;

  @override
  State<UploadMedicalRecordsScreen> createState() =>
      _UploadMedicalRecordsScreenState();
}

class _UploadMedicalRecordsScreenState
    extends State<UploadMedicalRecordsScreen> {
  static const List<String> _allowedExtensions = <String>[
    'png',
    'jpg',
    'jpeg',
    'pdf',
  ];

  final _formKey = GlobalKey<FormState>();
  final UserSession _userSession = getIt<UserSession>();
  String? _userId;
  String _selectedFileTitle = '';
  bool _hasSavedRecord = false;
  bool _hasExistingRecords = false;
  bool _loadedExistingRecords = false;

  final List<PlatformFile> _selectedFiles = <PlatformFile>[];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadExistingRecordsFlag();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocConsumer<MedicalRecordsCubit, MedicalRecordsState>(
      listener: (context, state) {
        state.whenOrNull(
          success: (data) {
            CherryToast.success(
              title: const Text('Uploaded'),
              description: Text(data.message ?? 'Medical record uploaded'),
            ).show(context);
            setState(() {
              _selectedFiles.clear();
              _hasSavedRecord = true;
              _hasExistingRecords = true;
            });
          },
          error: (message) {
            CherryToast.error(
              title: const Text('Error'),
              description: Text(message),
            ).show(context);
          },
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AuthHeader(
                            title: localizations.translate(
                              "upload_records_title",
                            ),
                            subTitle: localizations.translate(
                              "upload_records_subtitle",
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                localizations.translate("past_records_label"),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (_selectedFiles.isNotEmpty ||
                                  _hasExistingRecords)
                                TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.medicalRecordsHistory,
                                          );
                                        },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'see all',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.skyBlue,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              radius: const Radius.circular(18),
                              color: AppColors.softLavender.withValues(
                                alpha: 0.35,
                              ),
                              strokeWidth: 1.4,
                              dashPattern: const <double>[8, 8],
                              padding: EdgeInsets.zero,
                            ),
                            child: InkWell(
                              onTap: isLoading ? null : _pickFile,
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 34,
                                  horizontal: 22,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBg.withValues(
                                    alpha: 0.35,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 80,
                                      color: AppColors.skyBlue,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      localizations.translate(
                                        "upload_area_text",
                                      ),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textSecondary
                                            .withValues(alpha: 0.9),
                                        height: 1.45,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (_selectedFiles.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Uploaded files',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...List.generate(_selectedFiles.length, (index) {
                              final file = _selectedFiles[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildUploadedFileTile(
                                  file: file,
                                  onDelete: () => _removeSelectedFile(index),
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: CustomButton(
                    text: isLoading
                        ? 'Uploading...'
                        : _hasSavedRecord
                        ? 'Continue'
                        : 'Save and Continue',
                    onPressed: isLoading
                        ? () {}
                        : _hasSavedRecord
                        ? _continueAfterSave
                        : _submit,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
    );

    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    final selectedFile = result.files.single;
    final selectedPath = selectedFile.path;

    if (!_isAllowedExtension(selectedFile)) {
      CherryToast.error(
        title: const Text('Invalid file'),
        description: const Text(
          'Only PNG, JPG, JPEG, and PDF files are allowed.',
        ),
      ).show(context);
      return;
    }

    final isDuplicate = _selectedFiles.any((file) => file.path == selectedPath);
    if (isDuplicate) {
      return;
    }

    setState(() {
      _hasSavedRecord = false;
      _selectedFiles.add(selectedFile);
      _selectedFileTitle = _buildTitleFromFileName(selectedFile.name);
    });
  }

  void _submit() {
    final localizations = AppLocalizations.of(context)!;
    final userId = _userId?.trim() ?? '';

    if (userId.isEmpty) {
      CherryToast.error(
        title: const Text('Missing user'),
        description: Text(localizations.translate('user_id_required')),
      ).show(context);
      return;
    }

    if (_selectedFiles.isEmpty) {
      CherryToast.error(
        title: const Text('No file'),
        description: const Text('Choose a file before uploading.'),
      ).show(context);
      return;
    }

    final selectedFile = _selectedFiles.last;

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final request = MedicalRecordRequestModel(
      file: File(selectedFile.path!),
      title: _selectedFileTitle.isEmpty
          ? _buildTitleFromFileName(selectedFile.name)
          : _selectedFileTitle,
      description: '',
      patientId: userId,
    );

    context.read<MedicalRecordsCubit>().emitUploadRecord(request: request);
  }

  void _continueAfterSave() {
    if (widget.source == MedicalRecordsSource.registration) {
      Navigator.pushReplacementNamed(context, AppRoutes.healthIssues);
      return;
    }

    Navigator.of(context).pop(true);
  }

  void _clearForm() {
    _selectedFileTitle = '';
    setState(() {
      _selectedFiles.clear();
      _hasSavedRecord = false;
    });
  }

  Future<void> _loadExistingRecordsFlag() async {
    if (_loadedExistingRecords) {
      return;
    }
    _loadedExistingRecords = true;

    final patientId = _userSession.userId?.trim() ?? '';
    if (patientId.isEmpty || !mounted) {
      return;
    }

    final records = await context.read<MedicalRecordsCubit>().getMedicalRecords(
      patientId,
    );
    if (!mounted) {
      return;
    }

    if (records.isNotEmpty) {
      setState(() {
        _hasExistingRecords = true;
      });
    }
  }

  Future<void> _loadUserId() async {
    final userId = _userSession.userId;
    if (!mounted) {
      return;
    }
    setState(() {
      _userId = userId;
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool _isAllowedExtension(PlatformFile file) {
    final extension = (file.extension ?? file.name.split('.').last)
        .toLowerCase();
    return _allowedExtensions.contains(extension);
  }

  String _buildTitleFromFileName(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot <= 0) {
      return fileName;
    }
    return fileName.substring(0, lastDot);
  }

  void _removeSelectedFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }


  Widget _buildUploadedFileTile({
    required PlatformFile file,
    required VoidCallback onDelete,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textPrimary, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.insert_drive_file_outlined,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatFileSize(file.size),
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
