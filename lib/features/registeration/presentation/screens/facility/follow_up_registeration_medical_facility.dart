import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:latlong2/latlong.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/auth_header.dart';
import 'package:smartclinic/core/widgets/custom_button.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:smartclinic/core/widgets/custom_small_text_field.dart';
import 'package:smartclinic/core/widgets/map_location_picker.dart';
import 'package:smartclinic/features/auth/presentation/manager/register_cubit.dart';
import 'package:smartclinic/features/auth/presentation/manager/register_state.dart';
import 'package:smartclinic/features/registeration/data/model/medical_facility_register_model.dart';
import 'package:smartclinic/injection_dependency.dart';

class FollowUpRegisterDoctorScreen extends StatefulWidget {
  const FollowUpRegisterDoctorScreen({super.key});

  @override
  State<FollowUpRegisterDoctorScreen> createState() =>
      _FollowUpRegisterScreenDoctorState();
}

class _FollowUpRegisterScreenDoctorState
    extends State<FollowUpRegisterDoctorScreen> {
  static const List<String> _commonSpecializations = <String>[
    'Cardiology',
    'Dermatology',
    'Endocrinology',
    'Family Medicine',
    'Gastroenterology',
    'General Surgery',
    'Gynecology',
    'Internal Medicine',
    'Neurology',
    'Oncology',
    'Ophthalmology',
    'Orthopedics',
    'Otolaryngology (ENT)',
    'Pediatrics',
    'Psychiatry',
    'Pulmonology',
    'Radiology',
    'Urology',
  ];

  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _specializationController = TextEditingController();
  final UserSession _userSession = getIt<UserSession>();
  double? _latitude;
  double? _longitude;
  String? _selectedGender;
  final List<PlatformFile> _nationalIdFiles = [];
  bool _isSpecializationPickerOpen = false;
  bool _isApplyingSpecializationSelection = false;
  Timer? _specializationTypingDebounce;
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
    _specializationTypingDebounce?.cancel();
    _dobController.dispose();
    _addressController.dispose();
    _specializationController.dispose();
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
              description: Text(
                localizations.translate("register_facility_loading"),
              ),
            ).show(context);
          },
          success: (data) async {
            final navigator = Navigator.of(context);
            final selectedRole = _normalizeFacilityRole(
              context.read<RegisterCubit>().selectedRole,
            );
            final userId = _extractUserId(data);
            final email = _readRegistrationValue('email');
            if (userId == null || userId.trim().isEmpty) {
              CherryToast.error(
                title: const Text('Registration'),
                description: Text(
                  localizations.translate("register_facility_user_id_missing"),
                ),
              ).show(context);
              return;
            }

            await _userSession.clearSession();
            await _userSession.saveUserId(userId.trim());
            await _userSession.saveRole(selectedRole);
            if (!mounted) {
              return;
            }

            CherryToast.success(
              title: const Text('Success'),
              description: Text(
                localizations.translate("register_facility_success"),
              ),
            ).show(context);
            if (getRoleEnum(selectedRole).isDoctor ||
                getRoleEnum(selectedRole).isHospital) {
              navigator.pushReplacementNamed(
                AppRoutes.verifyDoctor,
                arguments: {
                  'email': email,
                  'registrationEmail': email,
                  'registrationData': data,
                  'userId': userId.trim(),
                  'role': selectedRole,
                  'selectedRole': selectedRole,
                },
              );
            } else {
              navigator.pushReplacementNamed(_resolveHomeRoute(selectedRole));
            }
          },
          error: (message) {
            CherryToast.error(
              title: const Text('Error'),
              description: Text(
                '${localizations.translate("register_facility_failed")}$message',
              ),
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

                _buildLabel(localizations.translate("facility_location_title")),
                AppTextFormField(
                  hintText: localizations.translate(
                    "facility_location_subtitle",
                  ),
                  controller: _addressController,
                  type: TextFormFieldType.location,
                  onTap: _pickLocation,
                ),
                const SizedBox(height: 18),
                _buildLabel(localizations.translate("Specialization_title")),
                AppTextFormField(
                  hintText: localizations.translate("Specialization_hint"),
                  controller: _specializationController,
                  type: TextFormFieldType.speciality,
                  onSuffixTap: _showSpecializationPicker,
                  onChanged: _onSpecializationChanged,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 18),
                _buildLabel(localizations.translate("National_ID_title")),
                _buildNationalIdField(localizations),
                const SizedBox(height: 18),
                _buildLabel(localizations.translate("Gender_title")),
                GenderSelectionField(
                  onGenderChanged: (gender) {
                    setState(() {
                      _selectedGender = gender;
                    });
                  },
                ),

                const SizedBox(height: 30),

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

  Future<void> _pickLocation() async {
    final initialLocation = _latitude != null && _longitude != null
        ? LatLng(_latitude!, _longitude!)
        : const LatLng(30.0444, 31.2357);

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MapLocationPickerScreen(initialLocation: initialLocation),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    final pickedLatitude = (result['latitude'] as num?)?.toDouble();
    final pickedLongitude = (result['longitude'] as num?)?.toDouble();
    if (pickedLatitude == null || pickedLongitude == null) {
      return;
    }

    setState(() {
      _latitude = pickedLatitude;
      _longitude = pickedLongitude;
      _addressController.text =
          '${pickedLatitude.toStringAsFixed(6)}, ${pickedLongitude.toStringAsFixed(6)}';
    });
  }

  List<String> get _filteredSpecializations {
    final query = _specializationController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _commonSpecializations;
    }

    return _commonSpecializations.where((item) {
      return item.toLowerCase().contains(query);
    }).toList();
  }

  void _onSpecializationChanged(String value) {
    if (_isApplyingSpecializationSelection) {
      return;
    }

    _specializationTypingDebounce?.cancel();

    if (_isSpecializationPickerOpen || value.trim().isEmpty) {
      return;
    }

    _specializationTypingDebounce = Timer(
      const Duration(milliseconds: 550),
      () {
        if (!mounted || _isSpecializationPickerOpen) {
          return;
        }
        _showSpecializationPicker();
      },
    );
  }

  Future<void> _showSpecializationPicker() async {
    if (_isSpecializationPickerOpen) {
      return;
    }

    final currentList = _filteredSpecializations;
    if (currentList.isEmpty) {
      return;
    }

    _isSpecializationPickerOpen = true;

    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: currentList.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final value = currentList[index];
              return ListTile(
                title: Text(value),
                onTap: () => Navigator.pop(context, value),
              );
            },
          ),
        );
      },
    );

    _isSpecializationPickerOpen = false;

    if (selected == null || selected.trim().isEmpty) {
      return;
    }
    _selectSpecialization(selected);
  }

  void _selectSpecialization(String specialization) {
    _isApplyingSpecializationSelection = true;
    _specializationController.text = specialization;
    _specializationController.selection = TextSelection.fromPosition(
      TextPosition(offset: _specializationController.text.length),
    );
    _isApplyingSpecializationSelection = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickNationalIdFile() async {
    if (_nationalIdFiles.length >= 2) {
      final localizations = AppLocalizations.of(context)!;
      CherryToast.error(
        title: const Text('Files limit'),
        description: Text(
          localizations.translate("register_facility_max_files_reached"),
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
    });
  }

  void _removeNationalIdFile(int index) {
    if (index < 0 || index >= _nationalIdFiles.length) {
      return;
    }

    setState(() {
      _nationalIdFiles.removeAt(index);
    });
  }

  Widget _buildNationalIdField(AppLocalizations localizations) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _pickNationalIdFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textPrimary),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _nationalIdFiles.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        localizations.translate("National_ID_hint"),
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: 2,
                      runSpacing: 2,
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
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _pickNationalIdFile,
              icon: const Icon(
                Icons.cloud_upload_outlined,
                color: AppColors.textPrimary,
              ),
              tooltip: localizations.translate("National_ID_title"),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day / $month / $year';
  }

  Future<void> _onRegisterPressed() async {
    final localizations = AppLocalizations.of(context)!;
    final name = _readRegistrationValue('name');
    final email = _readRegistrationValue('email');
    final phone = _readRegistrationValue('phone');
    final password = _readRegistrationValue('password');
    final confirmPassword = _readRegistrationValue('confirmPassword');
    final selectedRole = _normalizeFacilityRole(
      _readRegistrationValue('role') ?? _userSession.roleString ?? 'Patient',
    );

    if (name == null ||
        email == null ||
        phone == null ||
        password == null ||
        confirmPassword == null) {
      CherryToast.error(
        title: const Text('Missing info'),
        description: Text(
          localizations.translate("register_facility_missing_info"),
        ),
      ).show(context);
      return;
    }

    if (_selectedGender == null || _selectedGender!.isEmpty) {
      CherryToast.error(
        title: const Text('Validation'),
        description: Text(
          localizations.translate("register_facility_choose_gender"),
        ),
      ).show(context);
      return;
    }

    if (_dobController.text.isEmpty) {
      CherryToast.error(
        title: const Text('Validation'),
        description: Text(
          localizations.translate("register_facility_enter_birth_date"),
        ),
      ).show(context);
      return;
    }

    if (_specializationController.text.trim().isEmpty) {
      CherryToast.error(
        title: const Text('Validation'),
        description: Text(
          localizations.translate("register_facility_choose_specialization"),
        ),
      ).show(context);
      return;
    }

    if (_latitude == null || _longitude == null) {
      CherryToast.error(
        title: const Text('Validation'),
        description: const Text(
          'Please select the clinic location on the map.',
        ),
      ).show(context);
      return;
    }

    final birthDateForApi = _formatBirthDateForApi(_dobController.text);
    if (birthDateForApi == null) {
      CherryToast.error(
        title: const Text('Invalid date'),
        description: Text(
          localizations.translate("register_facility_birth_date_invalid"),
        ),
      ).show(context);
      return;
    }

    if (_nationalIdFiles.length != 2) {
      CherryToast.error(
        title: const Text('Missing files'),
        description: Text(
          localizations.translate(
            "register_facility_national_id_files_required",
          ),
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
        title: const Text('Invalid files'),
        description: Text(
          localizations.translate(
            "register_facility_national_id_invalid_paths",
          ),
        ),
      ).show(context);
      return;
    }

    final facilityModel = MedicalFacilityRequestModel(
      fullname: name,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
      birthDate: birthDateForApi,
      gender: _selectedGender!,
      specialization: _specializationController.text,
      address: _addressController.text,
      latitude: _latitude!,
      longitude: _longitude!,
      nationalIdFront: nationalIdFront,
      nationalIdBack: nationalIdBack,
    );

    context.read<RegisterCubit>().setSelectedRole(selectedRole);
    await _userSession.saveRole(selectedRole);
    await _userSession.clearUserId();
    if (!mounted) {
      return;
    }

    context.read<RegisterCubit>().emitRegisterFacility(facilityModel);
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

  String _normalizeFacilityRole(String role) {
    final normalized = role.trim();
    if (normalized.isEmpty) {
      return 'Hospital';
    }

    switch (normalized) {
      case 'MedicalFacility':
      case 'ClinicAdmin':
      case 'Hospital':
        return 'Hospital';
      case 'Doctor':
        return 'Doctor';
      default:
        return normalized;
    }
  }
}
