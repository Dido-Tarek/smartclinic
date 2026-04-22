import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/custom_button.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:smartclinic/core/widgets/custom_small_text_field.dart';
import 'package:smartclinic/features/health_issues/data/models/health_issues_model.dart';
import 'package:smartclinic/features/health_issues/presentation/manager/health_issues_cubit.dart';
import 'package:smartclinic/features/health_issues/presentation/manager/health_issues_state.dart';
import 'package:smartclinic/injection_dependency.dart';

class AddHealthIssue extends StatefulWidget {
  const AddHealthIssue({super.key});

  @override
  State<AddHealthIssue> createState() => _AddHealthIssue();
}

class _AddHealthIssue extends State<AddHealthIssue> {
  final _conditionNameController = TextEditingController();
  final _diagnosedDateController = TextEditingController();
  final _notesController = TextEditingController();
  final _recoveryDateController = TextEditingController();
  final _statusController = TextEditingController();
  final UserSession _userSession = getIt<UserSession>();

  String? _patientId;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadPatientId();
  }

  @override
  void dispose() {
    _conditionNameController.dispose();
    _diagnosedDateController.dispose();
    _notesController.dispose();
    _recoveryDateController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocConsumer<HealthIssuesCubit, HealthIssuesState>(
      listener: (context, state) {
        state.whenOrNull(
          success: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.translate('health_issue_saved')),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pushReplacementNamed(context, AppRoutes.healthIssues);
          },
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.error,
              ),
            );
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
          appBar: CustomAppBar(
            title: localizations.translate("add_health_issue_title"),
            showBackButton: true,
            onBackTap: () => Navigator.maybePop(context),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(localizations.translate("condition_name_title")),
                  AppTextFormField(
                    hintText: localizations.translate("condition_name_hint"),
                    controller: _conditionNameController,
                    type: TextFormFieldType.text,
                  ),
                  const SizedBox(height: 18),

                  _buildLabel(localizations.translate("diagnosed_Date_title")),
                  AppTextFormField(
                    hintText: "_ _ / _ _ / _ _ _ _",
                    controller: _diagnosedDateController,
                    type: TextFormFieldType.date,
                    onTap: _pickDiagnosedDate,
                  ),
                  const SizedBox(height: 18),

                  _buildLabel(localizations.translate("notes_title")),
                  TextFormField(
                    controller: _notesController,
                    minLines: 3,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: localizations.translate("notes_hint"),
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: AppColors.cardBg,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.skyBlue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  _buildLabel(localizations.translate("status_title")),
                  CustomSmallTextField(
                    controller: _statusController,
                    iconType: SmallFieldIcon.menu,
                    onTap: _showStatusPicker,
                  ),
                  const SizedBox(height: 18),

                  if (_selectedStatus == 'inactive') ...[
                    _buildLabel(localizations.translate("recovery_date_title")),
                    AppTextFormField(
                      hintText: "_ _ / _ _ / _ _ _ _",
                      controller: _recoveryDateController,
                      type: TextFormFieldType.date,
                      onTap: _pickRecoveryDate,
                    ),
                    const SizedBox(height: 18),
                  ],

                  const SizedBox(height: 34),
                  CustomButton(
                    text: isLoading
                        ? localizations.translate('loading')
                        : localizations.translate("Save"),
                    onPressed: isLoading ? () {} : _submit,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showStatusPicker() async {
    final localizations = AppLocalizations.of(context)!;
    final status = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.translate('status_select_title'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _statusOptionTile(
                  value: 'active',
                  title: localizations.translate('status_active'),
                ),
                _statusOptionTile(
                  value: 'inactive',
                  title: localizations.translate('status_inactive'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || status == null) {
      return;
    }

    setState(() {
      _selectedStatus = status;
      _statusController.text = _localizedStatusLabel(
        localizations: localizations,
        status: status,
      );
      if (status != 'inactive') {
        _recoveryDateController.clear();
      }
    });
  }

  Widget _statusOptionTile({required String value, required String title}) {
    final isSelected = _selectedStatus == value;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isSelected ? AppColors.deepNavy : AppColors.textSecondary,
      ),
      onTap: () => Navigator.pop(context, value),
    );
  }

  void _submit() {
    final localizations = AppLocalizations.of(context)!;
    final patientId = _patientId?.trim() ?? '';

    if (patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.translate('patient_id_required')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_conditionNameController.text.trim().isEmpty ||
        _diagnosedDateController.text.trim().isEmpty ||
        _statusController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.translate('fill_required_fields')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedStatus == 'inactive' &&
        _recoveryDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.translate('recovery_date_required')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final issue = HealthIssueModel(
      name: _conditionNameController.text.trim(),
      status: _selectedStatus == 'inactive' ? 'Inactive' : 'Active',
      diagnosedDate: _diagnosedDateController.text.trim(),
      curedDate: _selectedStatus == 'inactive'
          ? _recoveryDateController.text.trim()
          : null,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    context.read<HealthIssuesCubit>().emitAddHealthIssue(patientId, issue);
  }

  Future<void> _loadPatientId() async {
    final patientId = _userSession.patientId;
    if (!mounted) {
      return;
    }
    setState(() {
      _patientId = patientId;
    });
  }

  String _localizedStatusLabel({
    required AppLocalizations localizations,
    required String status,
  }) {
    if (status == 'inactive') {
      return localizations.translate('status_inactive');
    }
    return localizations.translate('status_active');
  }

  Future<void> _pickDiagnosedDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (date == null) {
      return;
    }
    _diagnosedDateController.text = _formatDate(date);
  }

  Future<void> _pickRecoveryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (date == null) {
      return;
    }
    _recoveryDateController.text = _formatDate(date);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day / $month / $year';
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
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
}
