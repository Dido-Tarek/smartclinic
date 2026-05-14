import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/auth_header.dart';
import 'package:smartclinic/core/widgets/custom_button.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/features/auth/data/models/facility_claim_ownership_request.dart.dart';
import 'package:smartclinic/features/auth/presentation/manager/upload_credentials_cubit.dart';
import 'package:smartclinic/features/auth/presentation/manager/upload_credentials_state.dart';
import 'package:smartclinic/injection_dependency.dart';

class _ClinicOption {
  const _ClinicOption({
    required this.id,
    required this.name,
    required this.location,
  });

  final int id;
  final String name;
  final String location;
}

class MedicalFacilityManagementPage extends StatefulWidget {
  const MedicalFacilityManagementPage({super.key});

  @override
  State<MedicalFacilityManagementPage> createState() =>
      _MedicalFacilityManagementPageState();
}

class _MedicalFacilityManagementPageState
    extends State<MedicalFacilityManagementPage> {
  static const List<_ClinicOption> _clinicOptions = <_ClinicOption>[
    _ClinicOption(id: 1001, name: 'Al Noor Clinic', location: 'Downtown'),
    _ClinicOption(
      id: 1002,
      name: 'Blue Crescent Medical Center',
      location: 'City Center',
    ),
    _ClinicOption(
      id: 1003,
      name: 'MediCare Family Clinic',
      location: 'West District',
    ),
    _ClinicOption(
      id: 1004,
      name: 'LifeLine Specialty Clinic',
      location: 'North Avenue',
    ),
  ];

  final UserSession _userSession = getIt<UserSession>();
  final TextEditingController _clinicController = TextEditingController();
  final TextEditingController _clinicSearchController = TextEditingController();

  int? _selectedClinicId;
  bool _claimOwnershipFlow = false;
  bool _staffFlow = false;
  bool _credentialsUploaded = false;
  bool _isSubmitting = false;
  File? _documentOne;
  File? _documentTwo;
  File? _documentThree;

  @override
  void dispose() {
    _clinicController.dispose();
    _clinicSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocConsumer<UploadCredentialsCubit, UploadCredentialsState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {
            if (mounted) {
              setState(() {
                _isSubmitting = true;
              });
            }
          },
          success: (data) {
            if (!mounted) {
              return;
            }

            setState(() {
              _isSubmitting = false;
              _credentialsUploaded = true;
            });

            final navigator = Navigator.of(context);
            final role = getRoleEnum(_userSession.roleString);

            if (_claimOwnershipFlow) {
              CherryToast.success(
                title: const Text('Success'),
                description: Text(
                  localizations.translate("clinic_claim_success_message"),
                ),
              ).show(context);
              navigator.pushReplacementNamed(_resolveHomeRoute(role));
              return;
            }

            if (_staffFlow) {
              CherryToast.success(
                title: const Text('Success'),
                description: Text(
                  localizations.translate("staff_request_success_message"),
                ),
              ).show(context);
              return;
            }

            CherryToast.success(
              title: const Text('Success'),
              description: Text(
                localizations.translate('owner_documents_uploaded_message'),
              ),
            ).show(context);
          },
          error: (error) {
            if (!mounted) {
              return;
            }

            setState(() {
              _isSubmitting = false;
            });

            CherryToast.error(
              title: const Text('Error'),
              description: Text(error),
            ).show(context);
          },
        );
      },
      builder: (context, state) {
        // localization helper for this build scope
        final loc = AppLocalizations.of(context);
        String t(String key, [String? fallback]) =>
            loc?.translate(key) ?? (fallback ?? key);

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AuthHeader(
                            title: t(
                              'medical_facility_title',
                              'Medical Facility Management',
                            ),
                            subTitle: t(
                              'medical_facility_subtitle',
                              'Claim an unowned clinic or upload your own facility documents before continuing.',
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.55,
                              child: CustomButton(
                                text: t('add_new', 'Add New'),
                                color: AppColors.skyBlue,
                                onPressed: _onAddNewPressed,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildLabel(t('select_clinic', 'Select Clinic')),
                          AppTextFormField(
                            hintText: t(
                              'search_or_select_clinic',
                              'Search or select clinic',
                            ),
                            controller: _clinicController,
                            type: TextFormFieldType.speciality,
                            onSuffixTap: _onSelectClinicPressed,
                            onTap: _onSelectClinicPressed,
                          ),
                          const SizedBox(height: 20),
                          _buildLabel(t('upload_flow', 'Upload Flow')),
                          Row(
                            children: [
                              Expanded(
                                child: _buildRoleCard(
                                  title: t('claim', 'Claim'),
                                  description: t(
                                    'claim_description',
                                    'Claim an unowned clinic from search.',
                                  ),
                                  icon: Icons.verified_user_outlined,
                                  isSelected: _claimOwnershipFlow,
                                  onTap: _selectClaimFlow,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildRoleCard(
                                  title: t('not_listed', 'Not Listed'),
                                  description: t(
                                    'not_listed_description',
                                    'Upload your clinic documents here.',
                                  ),
                                  icon: Icons.apartment_outlined,
                                  isSelected:
                                      !_claimOwnershipFlow && !_staffFlow,
                                  onTap: _selectOwnerDocsFlow,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildRoleCard(
                                  title: t('staff', 'Staff'),
                                  description: t(
                                    'staff_description',
                                    'Access clinic operations.',
                                  ),
                                  icon: Icons.groups_2_outlined,
                                  isSelected: _staffFlow,
                                  onTap: _selectStaffFlow,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildLabel(
                            t('clinical_credentials', 'Clinical Credentials'),
                          ),
                          _buildCredentialsCard(),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusChip(),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: t('get_started', 'Get Started'),
                          color: _canContinue
                              ? AppColors.deepNavy
                              : AppColors.textSecondary,
                          onPressed: _onGetStartedPressed,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 138,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accentBlue.withValues(alpha: 0.35)
                : AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.skyBlue : AppColors.textPrimary,
              width: isSelected ? 1.6 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.skyBlue.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: isSelected
                    ? AppColors.deepNavy
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialsCard() {
    final title = _claimOwnershipFlow
        ? AppLocalizations.of(context)?.translate('upload_claim_documents') ??
              'Upload Claim Documents'
        : (_staffFlow
              ? AppLocalizations.of(
                      context,
                    )?.translate('upload_staff_documents') ??
                    'Upload Staff Documents'
              : AppLocalizations.of(
                      context,
                    )?.translate('upload_owner_documents') ??
                    'Upload Owner Documents');

    final description = _claimOwnershipFlow
        ? AppLocalizations.of(
                context,
              )?.translate('claim_documents_description') ??
              'Legal documents required to prove ownership of an unowned clinic.'
        : (_staffFlow
              ? AppLocalizations.of(
                      context,
                    )?.translate('staff_documents_description') ??
                    'Staff identification and employment proof for the selected clinic.'
              : AppLocalizations.of(
                      context,
                    )?.translate('owner_documents_description') ??
                    'License, commercial registration, and tax card for your own clinic.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.textPrimary),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _onUploadCredentialPressed,
            icon: const Icon(
              Icons.upload_file_outlined,
              color: AppColors.deepNavy,
              size: 22,
            ),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    final statusText = _claimOwnershipFlow
        ? (_credentialsUploaded
              ? AppLocalizations.of(
                      context,
                    )?.translate('status_claim_submitted') ??
                    'Status: Claim Submitted'
              : AppLocalizations.of(
                      context,
                    )?.translate('status_claim_pending') ??
                    'Status: Claim Pending')
        : (_staffFlow
              ? (_credentialsUploaded
                    ? AppLocalizations.of(
                            context,
                          )?.translate('status_staff_sent') ??
                          'Status: Staff Request Sent'
                    : AppLocalizations.of(
                            context,
                          )?.translate('status_staff_pending') ??
                          'Status: Staff Pending')
              : (_credentialsUploaded
                    ? AppLocalizations.of(
                            context,
                          )?.translate('status_owner_sent') ??
                          'Status: Owner Docs Uploaded'
                    : AppLocalizations.of(
                            context,
                          )?.translate('status_pending_review') ??
                          'Status: Pending Review'));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, color: AppColors.warning, size: 8),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _onSelectClinicPressed() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.scaffoldBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 18,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final query = _clinicSearchController.text.trim().toLowerCase();
              final clinics = _clinicOptions.where((clinic) {
                if (query.isEmpty) {
                  return true;
                }

                return clinic.name.toLowerCase().contains(query) ||
                    clinic.location.toLowerCase().contains(query);
              }).toList();

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.translate('search_clinic') ??
                        'Search Clinic',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppTextFormField(
                    controller: _clinicSearchController,
                    hintText:
                        AppLocalizations.of(
                          context,
                        )?.translate('type_clinic_name_or_area') ??
                        'Type clinic name or area',
                    type: TextFormFieldType.speciality,
                    onChanged: (_) {
                      setSheetState(() {});
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 320,
                    child: ListView.separated(
                      itemCount: clinics.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final clinic = clinics[index];
                        final isSelected = clinic.id == _selectedClinicId;
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            setState(() {
                              _selectedClinicId = clinic.id;
                              _clinicController.text = clinic.name;
                              // If staff flow is active, remain in staff flow when selecting a clinic.
                              if (_staffFlow) {
                                _claimOwnershipFlow = false;
                                // keep _staffFlow true
                              } else {
                                _claimOwnershipFlow = true;
                                _staffFlow = false;
                              }
                              _credentialsUploaded = false;
                              _clearDocuments();
                            });
                            Navigator.pop(bottomSheetContext);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accentBlue.withValues(alpha: 0.35)
                                  : AppColors.cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.skyBlue
                                    : AppColors.textPrimary,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_hospital_outlined,
                                  color: AppColors.deepNavy,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        clinic.name,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        clinic.location,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedClinicId = null;
                          _clinicController.clear();
                          _claimOwnershipFlow = false;
                          _credentialsUploaded = false;
                          _clearDocuments();
                        });
                        Navigator.pop(bottomSheetContext);
                      },
                      child: Text(
                        AppLocalizations.of(
                              context,
                            )?.translate('my_clinic_not_listed') ??
                            'My clinic is not listed',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _onUploadCredentialPressed() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.scaffoldBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        final labels = _claimOwnershipFlow
            ? <String>[
                AppLocalizations.of(
                      context,
                    )?.translate('ownership_lease_contract') ??
                    'Ownership/Lease Contract',
                AppLocalizations.of(
                      context,
                    )?.translate('syndicate_registration') ??
                    'Syndicate Registration',
                AppLocalizations.of(
                      context,
                    )?.translate('commercial_register_tax_card') ??
                    'Commercial Register & Tax Card',
              ]
            : _staffFlow
            ? <String>[
                AppLocalizations.of(
                      context,
                    )?.translate('professional_license') ??
                    'Professional Practice License',
                AppLocalizations.of(context)?.translate('syndicate_id') ??
                    'Syndicate ID Card',
                AppLocalizations.of(
                      context,
                    )?.translate('employment_contract') ??
                    'Employment Contract',
              ]
            : <String>[
                AppLocalizations.of(context)?.translate('medical_license') ??
                    'Medical License',
                AppLocalizations.of(
                      context,
                    )?.translate('commercial_register') ??
                    'Commercial Register',
                AppLocalizations.of(context)?.translate('tax_card') ??
                    'Tax Card',
              ];

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 18,
                bottom:
                    MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _claimOwnershipFlow
                          ? AppLocalizations.of(
                                  context,
                                )?.translate('claim_ownership_documents') ??
                                'Claim Ownership Documents'
                          : (_staffFlow
                                ? AppLocalizations.of(
                                        context,
                                      )?.translate('staff_documents') ??
                                      'Staff Documents'
                                : AppLocalizations.of(
                                        context,
                                      )?.translate('owner_documents') ??
                                      'Owner Documents'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _claimOwnershipFlow
                          ? AppLocalizations.of(
                                  context,
                                )?.translate('upload_legal_files_claim') ??
                                'Upload the legal files required to claim the selected clinic.'
                          : (_staffFlow
                                ? AppLocalizations.of(context)?.translate(
                                        'upload_staff_credentials',
                                      ) ??
                                      'Upload your staff credentials for the selected clinic.'
                                : AppLocalizations.of(
                                        context,
                                      )?.translate('upload_owner_files') ??
                                      'Upload the files that prove ownership of your clinic.'),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildDocumentPicker(
                      label: labels[0],
                      file: _documentOne,
                      onTap: () async {
                        final picked = await _pickFile();
                        if (!mounted || picked == null) {
                          return;
                        }
                        setState(() {
                          _documentOne = picked;
                        });
                        setSheetState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDocumentPicker(
                      label: labels[1],
                      file: _documentTwo,
                      onTap: () async {
                        final picked = await _pickFile();
                        if (!mounted || picked == null) {
                          return;
                        }
                        setState(() {
                          _documentTwo = picked;
                        });
                        setSheetState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDocumentPicker(
                      label: labels[2],
                      file: _documentThree,
                      onTap: () async {
                        final picked = await _pickFile();
                        if (!mounted || picked == null) {
                          return;
                        }
                        setState(() {
                          _documentThree = picked;
                        });
                        setSheetState(() {});
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: _claimOwnershipFlow
                          ? AppLocalizations.of(
                                  context,
                                )?.translate('claim_and_continue') ??
                                'Claim & Continue'
                          : (_staffFlow
                                ? AppLocalizations.of(
                                        context,
                                      )?.translate('request_access') ??
                                      'Request Access'
                                : AppLocalizations.of(
                                        context,
                                      )?.translate('upload') ??
                                      'Upload'),
                      onPressed: _isSubmitting
                          ? () {}
                          : () {
                              Navigator.pop(bottomSheetContext);
                              _submitCredentials();
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onAddNewPressed() {
    if (!_canContinue || _claimOwnershipFlow) {
      _showUploadRequiredMessage();
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.clinicDetails,
      arguments: <String, dynamic>{
        'isOwner': !_staffFlow,
        'legalDocument1': _documentOne,
        'legalDocument2': _documentTwo,
        'legalDocument3': _documentThree,
      },
    );
  }

  void _onGetStartedPressed() {
    if (!_canContinue) {
      _showUploadRequiredMessage();
      return;
    }

    if (_claimOwnershipFlow || _staffFlow) {
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      _resolveHomeRoute(getRoleEnum(_userSession.roleString)),
    );
  }

  Widget _buildDocumentPicker({
    required String label,
    required File? file,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.textPrimary),
        ),
        child: Row(
          children: [
            const Icon(Icons.attach_file_outlined, color: AppColors.deepNavy),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file == null
                        ? AppLocalizations.of(
                                context,
                              )?.translate('tap_to_attach_file') ??
                              'Tap to attach a file'
                        : file.path.split('\\').last,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.upload_file_outlined, color: AppColors.skyBlue),
          ],
        ),
      ),
    );
  }

  Future<File?> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final path = result.files.single.path;
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    return File(path);
  }

  Future<void> _submitCredentials() async {
    final fileOne = _documentOne;
    final fileTwo = _documentTwo;
    final fileThree = _documentThree;

    if (fileOne == null || fileTwo == null || fileThree == null) {
      if (!mounted) {
        return;
      }

      CherryToast.error(
        title: const Text('Missing files'),
        description: Text(
          AppLocalizations.of(
                context,
              )?.translate('please_upload_all_documents') ??
              'Please upload all required documents first.',
        ),
      ).show(context);
      return;
    }

    if (!_claimOwnershipFlow &&
        !_staffFlow &&
        (_userSession.userId == null || _userSession.userId!.trim().isEmpty)) {
      if (!mounted) {
        return;
      }

      CherryToast.error(
        title: const Text('Missing session'),
        description: Text(
          AppLocalizations.of(context)?.translate('missing_user_session') ??
              'Missing user session. Please sign in again.',
        ),
      ).show(context);
      return;
    }

    // Staff flow must have a selected clinic to request access for
    if (_staffFlow && _selectedClinicId == null) {
      if (!mounted) return;

      CherryToast.error(
        title: const Text('Select clinic'),
        description: Text(
          AppLocalizations.of(context)?.translate('select_clinic_for_staff') ??
              'Please select the clinic you want staff access for.',
        ),
      ).show(context);
      return;
    }

    final request = FacilityClaimOwnershipRequest(
      file1: fileOne,
      file2: fileTwo,
      file3: fileThree,
    );

    // If claiming ownership or requesting staff access for an unowned clinic,
    // send the clinicId. Otherwise send null to upload owner docs for the user.
    final clinicParam = (_claimOwnershipFlow || _staffFlow)
        ? _selectedClinicId
        : null;

    await context.read<UploadCredentialsCubit>().uploadCredentials(
      clinicId: clinicParam,
      request: request,
    );
  }

  void _selectClaimFlow() {
    setState(() {
      _claimOwnershipFlow = true;
      _staffFlow = false;
      _credentialsUploaded = false;
      _clearDocuments();
    });
  }

  void _selectOwnerDocsFlow() {
    setState(() {
      _claimOwnershipFlow = false;
      _staffFlow = false;
      _selectedClinicId = null;
      _clinicController.clear();
      _credentialsUploaded = false;
      _clearDocuments();
    });
  }

  void _selectStaffFlow() {
    setState(() {
      _claimOwnershipFlow = false;
      _staffFlow = true;
      _selectedClinicId = null;
      _clinicController.clear();
      _credentialsUploaded = false;
      _clearDocuments();
    });
  }

  void _clearDocuments() {
    _documentOne = null;
    _documentTwo = null;
    _documentThree = null;
  }

  void _showUploadRequiredMessage() {
    CherryToast.error(
      title: const Text('Upload required'),
      description: Text(
        AppLocalizations.of(
              context,
            )?.translate('upload_required_credentials') ??
            'Upload the required credentials before continuing.',
      ),
    ).show(context);
  }

  bool get _canContinue => _credentialsUploaded && !_isSubmitting;

  String _resolveHomeRoute(UserRole role) {
    if (role.isDoctor) {
      return AppRoutes.home;
    }

    if (role.isHospital) {
      return AppRoutes.hospitalhome;
    }

    return AppRoutes.home;
  }
}
