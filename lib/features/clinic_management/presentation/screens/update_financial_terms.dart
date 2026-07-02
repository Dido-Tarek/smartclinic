import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_request_model.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_cubit.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_state.dart';

class UpdateFinancialTermsPage extends StatefulWidget {
  final String? doctorId;
  final int? clinicId;
  final Iterable? enabledAppointmentTypes;

  const UpdateFinancialTermsPage({super.key, this.doctorId, this.clinicId, this.enabledAppointmentTypes});

  @override
  State<UpdateFinancialTermsPage> createState() => _UpdateFinancialTermsPageState();
}

class _UpdateFinancialTermsPageState extends State<UpdateFinancialTermsPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _inClinicController = TextEditingController();
  final TextEditingController _followUpController = TextEditingController();
  final TextEditingController _onlineController = TextEditingController();
  final TextEditingController _homeVisitController = TextEditingController();
  final TextEditingController _emergencyController = TextEditingController();
  final TextEditingController _sessionDurationController = TextEditingController();

  late final Set<String> _enabledTypes;

  @override
  void initState() {
    super.initState();
    final data = widget.enabledAppointmentTypes;
    _enabledTypes = <String>{};
    if (data is Iterable) {
      _enabledTypes.addAll(data.map((e) => e.toString()).where((s) => s.isNotEmpty));
    }
    if (_enabledTypes.isEmpty) {
      _enabledTypes.addAll({'InClinic', 'VideoCall', 'HomeVisit', 'FollowUp', 'Emergency'});
    }
  }

  @override
  void dispose() {
    _inClinicController.dispose();
    _followUpController.dispose();
    _onlineController.dispose();
    _homeVisitController.dispose();
    _emergencyController.dispose();
    _sessionDurationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final doctorId = widget.doctorId ?? '';
    final clinicId = widget.clinicId ?? 0;

    final request = UpdateFinancialTermsRequestModel(
      doctorId: doctorId,
      clinicId: clinicId,
      inClinicFee: num.parse(_inClinicController.text.trim()),
      followUpFee: num.parse(_followUpController.text.trim()),
      onlineFee: num.parse(_onlineController.text.trim()),
      homeVisitFee: num.parse(_homeVisitController.text.trim()),
      emergencyFee: num.parse(_emergencyController.text.trim()),
      sessionDuration: int.parse(_sessionDurationController.text.trim()),
    );

    context.read<ClinicManagementCubit>().updateFinancialTerms(request);
  }

  Widget _buildNumberField({required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.deepNavy,
          ),
        ),
        const SizedBox(height: 8),
        AppTextFormField(
          hintText: label,
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            final parsed = num.tryParse(v.trim());
            if (parsed == null) return 'Invalid number';
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClinicManagementCubit, ClinicManagementState>(
      listener: (context, state) {
        if (state is UpdateFinancialTermsSuccess) {
          CherryToast.success(title: const Text('Updated'), description: const Text('Fees updated successfully')).show(context);
        } else if (state is UpdateFinancialTermsFailure) {
          CherryToast.error(title: const Text('Failed'), description: Text(state.errorMessage)).show(context);
        }
      },
      builder: (context, state) {
        final isSaving = state is UpdateFinancialTermsLoading;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: const CustomAppBar(
            title: 'Update Fees',
            showNotification: false,
            showBackButton: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_enabledTypes.contains('InClinic')) ...[
                      _buildNumberField(label: 'Examination Fee', controller: _inClinicController),
                      const SizedBox(height: 12),
                    ],
                    if (_enabledTypes.contains('FollowUp')) ...[
                      _buildNumberField(label: 'Follow-up Fee', controller: _followUpController),
                      const SizedBox(height: 12),
                    ],
                    if (_enabledTypes.contains('VideoCall')) ...[
                      _buildNumberField(label: 'Online Fee', controller: _onlineController),
                      const SizedBox(height: 12),
                    ],
                    if (_enabledTypes.contains('HomeVisit')) ...[
                      _buildNumberField(label: 'Home Visit Fee', controller: _homeVisitController),
                      const SizedBox(height: 12),
                    ],
                    if (_enabledTypes.contains('Emergency')) ...[
                      _buildNumberField(label: 'Emergency Fee', controller: _emergencyController),
                      const SizedBox(height: 12),
                    ],

                    _buildNumberField(label: 'Session Duration (minutes)', controller: _sessionDurationController),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepNavy,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: isSaving
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                            : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
