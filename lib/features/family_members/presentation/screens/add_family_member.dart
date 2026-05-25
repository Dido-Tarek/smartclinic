import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/custom_button.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:smartclinic/core/widgets/custom_small_text_field.dart';
import 'package:smartclinic/features/family_members/presentation/manager/family_member_cubit.dart';
import 'package:smartclinic/features/family_members/presentation/manager/family_member_state.dart';
import 'package:smartclinic/injection_dependency.dart';

class AddFamilyMember extends StatefulWidget {
  const AddFamilyMember({super.key});

  @override
  State<AddFamilyMember> createState() => _AddFamilyMember();
}

class _AddFamilyMember extends State<AddFamilyMember> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _relationController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final UserSession _userSession = getIt<UserSession>();
  String? _userId;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _relationController.dispose();
    _bloodTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocConsumer<FamilyCubit, FamilyState>(
      listener: (context, state) {
        if (state is AddFamilyMemberSuccess) {
            CherryToast.success(
              title: const Text('Saved'),
              description: Text(localizations.translate('family_member_saved')),
            ).show(context);
            Navigator.pop(context, true);
        } else if (state is AddFamilyMemberFailure) {
            final message = state.errorMessage;
            CherryToast.error(
              title: const Text('Error'),
              description: Text(message),
            ).show(context);
        }
      },
      builder: (context, state) {
        final isLoading = state is AddFamilyMemberLoading;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: CustomAppBar(
            title: localizations.translate("add_family_member_title"),
            showBackButton: true,
            onBackTap: () => Navigator.maybePop(context),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(localizations.translate("Full_Name_title")),
                  AppTextFormField(
                    hintText: localizations.translate("Full_Name_hint"),
                    controller: _nameController,
                    type: TextFormFieldType.text,
                  ),
                  const SizedBox(height: 18),

                  _buildLabel(localizations.translate("relation_title")),
                  AppTextFormField(
                    hintText: localizations.translate("relation_hint"),
                    controller: _relationController,
                    type: TextFormFieldType.text,
                  ),
                  const SizedBox(height: 18),

                  _buildLabel(localizations.translate("Date_of_Birth_title")),
                  AppTextFormField(
                    hintText: "_ _ / _ _ / _ _ _ _",
                    controller: _dobController,
                    type: TextFormFieldType.date,
                    onTap: _pickDateOfBirth,
                  ),
                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(
                            localizations.translate("Blood_Type_title"),
                          ),
                          CustomSmallTextField(
                            hintText: "e.g, AB+",
                            controller: _bloodTypeController,
                            iconType: SmallFieldIcon.menu,
                            onTap: _pickBloodType,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(localizations.translate("Gender_title")),
                          GenderSelectionField(
                            onGenderChanged: (gender) {
                              setState(() {
                                _selectedGender = gender;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  CustomButton(
                    text: isLoading
                        ? localizations.translate('loading')
                        : localizations.translate("Save"),
                    onPressed: isLoading ? () {} : _onSavePressed,
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

  // --- الـ UI Label الموحد ---
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

  Future<void> _loadUserId() async {
    final userId = _userSession.userId;
    if (!mounted) {
      return;
    }
    setState(() {
      _userId = userId;
    });
  }

  Future<void> _pickDateOfBirth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (date == null) {
      return;
    }
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    _dobController.text = '$day / $month / $year';
  }

  Future<void> _pickBloodType() async {
    final values = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: values.length,
            itemBuilder: (context, index) {
              final value = values[index];
              return ListTile(
                title: Text(value),
                onTap: () => Navigator.pop(context, value),
              );
            },
          ),
        );
      },
    );

    if (selected != null && selected.isNotEmpty) {
      _bloodTypeController.text = selected;
    }
  }

  void _onSavePressed() {
    final localizations = AppLocalizations.of(context)!;

    if ((_userId ?? '').trim().isEmpty) {
      CherryToast.error(
        title: const Text('Missing user'),
        description: Text(localizations.translate('user_id_required')),
      ).show(context);
      return;
    }

    if (_nameController.text.trim().isEmpty ||
        _relationController.text.trim().isEmpty ||
        _dobController.text.trim().isEmpty ||
        _bloodTypeController.text.trim().isEmpty ||
        (_selectedGender ?? '').isEmpty) {
      CherryToast.error(
        title: const Text('Validation'),
        description: Text(localizations.translate('fill_required_fields')),
      ).show(context);
      return;
    }

    // Format the date for API (YYYY-MM-DD)
    final birthDateForApi = _formatBirthDateForApi(_dobController.text.trim());
    if (birthDateForApi == null) {
      CherryToast.error(
        title: const Text('Invalid Date'),
        description: Text(localizations.translate('invalid_date_format')),
      ).show(context);
      return;
    }

    context.read<FamilyCubit>().addFamilyMember(
      patientId: _userId!.trim(),
      name: _nameController.text.trim(),
      relation: _relationController.text.trim(),
      gender: _selectedGender!,
      birthDate: birthDateForApi,
      bloodType: _bloodTypeController.text.trim(),
    );
  }

  String? _formatBirthDateForApi(String value) {
    final normalized = value.replaceAll(' ', '');
    final parts = normalized.split('/');
    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return null;
    }

    final date = DateTime.tryParse(
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
    );
    if (date == null) {
      return null;
    }

    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
