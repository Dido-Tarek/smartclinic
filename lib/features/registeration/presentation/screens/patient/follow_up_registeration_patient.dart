import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/auth_header.dart';
import 'package:smartclinic/core/widgets/custom_button.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:smartclinic/core/widgets/custom_small_text_field.dart';
import 'package:smartclinic/features/auth/presentation/manager/register_cubit.dart';
import 'package:smartclinic/features/auth/presentation/manager/register_state.dart';
import 'package:smartclinic/features/registeration/data/model/patient_register_model.dart';
import 'package:smartclinic/injection_dependency.dart';

class FollowUpRegisterScreen extends StatefulWidget {
  const FollowUpRegisterScreen({super.key});

  @override
  State<FollowUpRegisterScreen> createState() => _FollowUpRegisterScreenState();
}

class _FollowUpRegisterScreenState extends State<FollowUpRegisterScreen> {
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final UserSession _userSession = getIt<UserSession>();
  String? _selectedGender;
  final List<PlatformFile> _nationalIdFiles = [];
  bool _argsLoaded = false;
  Map<String, dynamic> _registrationArgs = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _registrationArgs = args.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
      _argsLoaded = true;
    }
  }

  @override
  void dispose() {
    _dobController.dispose();
    _addressController.dispose();
    _nationalIdController.dispose();
    _bloodTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {
            CherryToast.info(
              title: const Text('Please wait'),
              description: const Text('Registering patient...'),
            ).show(context);
          },
          success: (data) async {
            final navigator = Navigator.of(context);
            final selectedRole = context.read<RegisterCubit>().selectedRole;
            final userId = _extractUserId(data);
            final fullName = _readRegistrationValue('name');
            final email = _readRegistrationValue('email');
            if (userId == null || userId.trim().isEmpty) {
              CherryToast.error(
                title: const Text('Registration'),
                description: const Text(
                  'Registration succeeded, but user id was not returned. Please try again.',
                ),
              ).show(context);
              return;
            }

            await _userSession.clearSession();
            await _userSession.saveUserId(userId.trim());
            await _userSession.saveRole(selectedRole);
            if (fullName != null) {
              await _userSession.saveFullName(fullName);
            }
            if (email != null) {
              await _userSession.saveEmail(email);
            }
            if (!mounted) {
              return;
            }

            CherryToast.success(
              title: const Text('Success'),
              description: const Text('Registration completed successfully'),
            ).show(context);
            if (getRoleEnum(selectedRole).isPatient) {
              navigator.pushReplacementNamed(
                AppRoutes.verification,
                arguments: {'email': email},
              );
              return;
            }

            navigator.pushReplacementNamed(_resolveHomeRoute(selectedRole));
          },
          error: (message) {
            CherryToast.error(
              title: const Text('Registration failed'),
              description: Text(message),
            ).show(context);
          },
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                AuthHeader(
                  title: localizations.translate("complete_profile_title"),
                  subTitle: localizations.translate(
                    "complete_profile_subtitle",
                  ),
                ),
                const SizedBox(height: 30),

                _buildLabel(localizations.translate("Date_of_Birth_title")),
                AppTextFormField(
                  hintText: "_ _ / _ _ / _ _ _ _",
                  controller: _dobController,
                  type: TextFormFieldType.date,
                  onTap: _pickDiagnosedDate,
                ),
                const SizedBox(height: 18),

                _buildLabel(localizations.translate("Address_title")),
                AppTextFormField(
                  hintText: localizations.translate("Address_hint"),
                  controller: _addressController,
                  type: TextFormFieldType.text,
                ),
                const SizedBox(height: 18),

                _buildLabel(localizations.translate("National_ID_title")),
                AppTextFormField(
                  hintText: localizations.translate("National_ID_hint"),
                  controller: _nationalIdController,
                  type: TextFormFieldType.fileUpload,
                  onSuffixTap: _pickNationalIdFile,
                ),
                if (_nationalIdFiles.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_nationalIdFiles.length, (index) {
                      final file = _nationalIdFiles[index];
                      final label = index == 0 ? 'Front' : 'Back';
                      return InputChip(
                        label: Text('$label: ${file.name}'),
                        onPressed: () => _replaceNationalIdFile(index),
                        onDeleted: () => _removeNationalIdFile(index),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        backgroundColor: AppColors.cardBg,
                        side: const BorderSide(color: AppColors.textPrimary),
                        labelStyle: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                      );
                    }),
                  ),
                ],
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

                BlocBuilder<RegisterCubit, RegisterState>(
                  builder: (context, state) {
                    final isLoading = state.maybeWhen(
                      loading: () => true,
                      orElse: () => false,
                    );
                    return CustomButton(
                      text: localizations.translate("Register"),
                      onPressed: isLoading ? () {} : () => _onRegisterPressed(),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
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
    _dobController.text = _formatDate(date);
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
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: values.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
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

  Future<void> _pickNationalIdFile() async {
    if (_nationalIdFiles.length >= 2) {
      CherryToast.error(
        title: const Text('Files limit'),
        description: const Text(
          'Maximum 2 files reached. Remove or tap a file to replace it.',
        ),
      ).show(context);
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      _nationalIdFiles.add(result.files.single);
      _updateNationalIdControllerText();
    });
  }

  Future<void> _replaceNationalIdFile(int index) async {
    if (index < 0 || index >= _nationalIdFiles.length) {
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    setState(() {
      _nationalIdFiles[index] = result.files.single;
      _updateNationalIdControllerText();
    });
  }

  void _removeNationalIdFile(int index) {
    if (index < 0 || index >= _nationalIdFiles.length) {
      return;
    }

    setState(() {
      _nationalIdFiles.removeAt(index);
      _updateNationalIdControllerText();
    });
  }

  void _updateNationalIdControllerText() {
    if (_nationalIdFiles.isEmpty) {
      _nationalIdController.clear();
      return;
    }

    final labels = <String>[];
    if (_nationalIdFiles.isNotEmpty) {
      labels.add('Front: ${_nationalIdFiles[0].name}');
    }
    if (_nationalIdFiles.length > 1) {
      labels.add('Back: ${_nationalIdFiles[1].name}');
    }

    _nationalIdController.text = labels.join(' | ');
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day / $month / $year';
  }

  Future<void> _onRegisterPressed() async {
    final name = _readRegistrationValue('name');
    final email = _readRegistrationValue('email');
    final phone = _readRegistrationValue('phone');
    final password = _readRegistrationValue('password');
    final confirmPassword = _readRegistrationValue('confirmPassword');
    final selectedRole =
        _readRegistrationValue('role') ?? _userSession.roleString ?? 'Patient';

    if (name == null ||
        email == null ||
        phone == null ||
        password == null ||
        confirmPassword == null) {
      CherryToast.error(
        title: const Text('Missing information'),
        description: const Text('Missing registration information'),
      ).show(context);
      return;
    }

    if (_selectedGender == null || _selectedGender!.isEmpty) {
      CherryToast.error(
        title: const Text('Validation'),
        description: const Text('Please choose a gender'),
      ).show(context);
      return;
    }

    if (_dobController.text.isEmpty) {
      CherryToast.error(
        title: const Text('Validation'),
        description: const Text('Please enter your birth date'),
      ).show(context);
      return;
    }

    final birthDateForApi = _formatBirthDateForApi(_dobController.text);
    if (birthDateForApi == null) {
      CherryToast.error(
        title: const Text('Validation'),
        description: const Text(
          'Birth date format is invalid. Please pick the date again.',
        ),
      ).show(context);
      return;
    }

    if (_nationalIdFiles.length != 2) {
      CherryToast.error(
        title: const Text('Files required'),
        description: const Text(
          'Please upload exactly 2 files for National ID (front and back).',
        ),
      ).show(context);
      return;
    }

    final nationalIdFront = _nationalIdFileFromPlatformFile(
      _nationalIdFiles[0],
    );
    final nationalIdBack = _nationalIdFileFromPlatformFile(_nationalIdFiles[1]);

    if (nationalIdFront == null || nationalIdBack == null) {
      CherryToast.error(
        title: const Text('Files invalid'),
        description: const Text(
          'Selected National ID files must have valid file paths.',
        ),
      ).show(context);
      return;
    }

    final patientModel = PatientRegisterRequestModel(
      fullName: name,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
      birthDate: birthDateForApi,
      gender: _selectedGender!,
      bloodGroup: _bloodTypeController.text,
      address: _addressController.text,
      nationalIdFront: nationalIdFront,
      nationalIdBack: nationalIdBack,
    );

    context.read<RegisterCubit>().setSelectedRole(selectedRole);
    await _userSession.saveRole(selectedRole);
    await _userSession.clearUserId();
    if (!mounted) {
      return;
    }

    context.read<RegisterCubit>().emitRegisterPatient(patientModel);
  }

  String? _extractUserId(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is Map<String, dynamic>) {
      final direct =
          data['userId'] ??
          data['user_id'] ??
          data['id'] ??
          data['patientId'] ??
          data['patient_id'];
      if (direct != null && direct.toString().trim().isNotEmpty) {
        return direct.toString();
      }

      for (final value in data.values) {
        final nested = _extractUserId(value);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
      return null;
    }

    if (data is List) {
      for (final item in data) {
        final nested = _extractUserId(item);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }

    return null;
  }

  String? _readRegistrationValue(String key) {
    final value = _registrationArgs[key];
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  File? _nationalIdFileFromPlatformFile(PlatformFile file) {
    final path = file.path?.trim();
    if (path == null || path.isEmpty) {
      return null;
    }

    return File(path);
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

  String _resolveHomeRoute(String role) {
    final roleEnum = getRoleEnum(role);
    if (roleEnum.isDoctor) {
      return AppRoutes.home;
    }
    if (roleEnum.isHospital) {
      return AppRoutes.hospitalhome;
    }
    return AppRoutes.home;
  }
}
