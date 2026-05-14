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
import 'package:smartclinic/features/medical_records/presentation/manager/medical_records_cubit.dart';
import 'package:smartclinic/features/medical_records/presentation/manager/medical_records_state.dart';
import 'package:smartclinic/injection_dependency.dart';
import 'package:cherry_toast/cherry_toast.dart';

class UploadMedicalRecordsScreen extends StatefulWidget {
  const UploadMedicalRecordsScreen({super.key});

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
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _appointmentIdController = TextEditingController();
  final _doctorIdController = TextEditingController();
  final UserSession _userSession = getIt<UserSession>();
  String? _userId;

  final List<PlatformFile> _selectedFiles = <PlatformFile>[];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _appointmentIdController.dispose();
    _doctorIdController.dispose();
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
            _clearForm();
            Navigator.pushReplacementNamed(context, AppRoutes.healthIssues);
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
                          Text(
                            localizations.translate("past_records_label"),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
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
                        : localizations.translate("Save"),
                    onPressed: isLoading ? () {} : _submit,
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
      _selectedFiles.add(selectedFile);
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

    final appointmentIdText = _appointmentIdController.text.trim();
    final appointmentId = appointmentIdText.isEmpty
        ? null
        : int.tryParse(appointmentIdText);

    if (appointmentIdText.isNotEmpty && appointmentId == null) {
      CherryToast.error(
        title: const Text('Invalid ID'),
        description: const Text('Appointment ID must be a valid number.'),
      ).show(context);
      return;
    }

    context.read<MedicalRecordsCubit>().emitUploadRecord(
      file: File(selectedFile.path!),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      patientId: userId,
      appointmentId: appointmentId,
      doctorId: _doctorIdController.text.trim().isEmpty
          ? null
          : _doctorIdController.text.trim(),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _appointmentIdController.clear();
    _doctorIdController.clear();
    setState(() {
      _selectedFiles.clear();
    });
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
