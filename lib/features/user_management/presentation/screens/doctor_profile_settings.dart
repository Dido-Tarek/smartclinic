import 'dart:io';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:smartclinic/features/user_management/data/model/doctor_profile_response_model.dart';
import 'package:smartclinic/features/user_management/presentation/manager/user_management_cubit.dart';
import 'package:smartclinic/features/user_management/presentation/manager/user_management_state.dart';
import 'package:smartclinic/injection_dependency.dart';

const String _remoteImageBaseUrl = 'http://smartclinicccc.runasp.net/';

class DoctorProfileSettingsPage extends StatefulWidget {
  const DoctorProfileSettingsPage({super.key});

  @override
  State<DoctorProfileSettingsPage> createState() =>
      _DoctorProfileSettingsPageState();
}

class _DoctorProfileSettingsPageState extends State<DoctorProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();

  final UserSession _userSession = getIt<UserSession>();

  File? _pickedImageFile;
  DoctorProfileModel? _doctorProfile;
  bool _requestedDoctorProfile = false;

  bool get _isDoctor => _userSession.userRole.isDoctor;

  @override
  void initState() {
    super.initState();
    _fillPatientFieldsFromSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isDoctor || _requestedDoctorProfile) {
        return;
      }

      final userId = _userSession.userId?.trim();
      if (userId == null || userId.isEmpty) {
        CherryToast.error(
          title: const Text('Error'),
          description: const Text('Missing doctor profile id.'),
        ).show(context);
        return;
      }

      _requestedDoctorProfile = true;
      context.read<UserManagementCubit>().getDoctorProfile(userId);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _bioController.dispose();
    _yearsController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _genderController.dispose();
    _bloodGroupController.dispose();
    super.dispose();
  }

  static String _normalizeDoctorFullName(String value) {
    var trimmed = value.trim();
    while (trimmed.isNotEmpty) {
      if (trimmed.startsWith('Dr.')) {
        trimmed = trimmed.substring(3).trim();
        continue;
      }
      if (trimmed.startsWith('Dr')) {
        trimmed = trimmed.substring(2).trim();
        continue;
      }
      if (trimmed.startsWith('د.')) {
        trimmed = trimmed.substring(2).trim();
        continue;
      }
      if (trimmed.startsWith('د')) {
        trimmed = trimmed.substring(1).trim();
        continue;
      }
      break;
    }
    return trimmed.isEmpty ? value.trim() : trimmed;
  }

  void _fillPatientFieldsFromSession() {
    if (_userSession.fullName != null) {
      _nameController.text = _normalizeDoctorFullName(_userSession.fullName!);
    }
    if (_userSession.phone != null) {
      _phoneController.text = _userSession.phone!;
    }
    if (_userSession.email != null) {
      _emailController.text = _userSession.email!;
    }
    if (_userSession.birthDate != null) {
      _birthDateController.text = _userSession.birthDate!;
    }
    if (_userSession.address != null) {
      _addressController.text = _userSession.address!;
    }
    if (_userSession.gender != null) {
      _genderController.text = _userSession.gender!;
    }
    if (_userSession.bloodGroup != null) {
      _bloodGroupController.text = _userSession.bloodGroup!;
    }
  }

  void _fillDoctorFields(DoctorProfileModel profile) {
    _doctorProfile = profile;
    _nameController.text = _normalizeDoctorFullName(profile.fullName);
    _phoneController.text = profile.phoneNumber ?? '';
    _specializationController.text = profile.specialization ?? '';
    _bioController.text = profile.bio ?? '';
    _yearsController.text = profile.yearsOfExperience?.toString() ?? '';
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        setState(() {
          _pickedImageFile = File(path);
        });
      }
    }
  }

  void _saveDoctorProfile() {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'FullName': _normalizeDoctorFullName(_nameController.text.trim()),
      'PhoneNumber': _phoneController.text.trim(),
      'Specialization': _specializationController.text.trim(),
      'Bio': _bioController.text.trim(),
      'YearsOfExperience': int.tryParse(_yearsController.text.trim()) ?? 0,
    };

    context.read<UserManagementCubit>().updateDoctorProfile(
      data,
      _pickedImageFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDoctor) {
      return _buildPatientScaffold();
    }

    return BlocConsumer<UserManagementCubit, UserManagementState>(
      listener: (context, state) async {
        if (state is ProfileLoaded) {
          _fillDoctorFields(state.profile);
          final profileImage = state.profile.profileImage;
          if (profileImage != null && profileImage.isNotEmpty) {
            await _userSession.saveProfileImage(profileImage);
          }
          return;
        }

        if (state is UserManagementSuccess) {
          CherryToast.success(
            title: const Text('Profile updated'),
            description: const Text('Your profile was updated successfully.'),
          ).show(context);
          if (_pickedImageFile != null) {
            await _userSession.saveProfileImage(_pickedImageFile!.path);
          }
          if (_isDoctor) {
            await context.read<UserManagementCubit>().getDoctorProfile(
              _userSession.userId!.trim(),
            );
          }
        }

        if (state is UserManagementError) {
          CherryToast.error(
            title: const Text('Update failed'),
            description: Text(state.message),
          ).show(context);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is UserManagementLoading && _doctorProfile == null;
        final profileImage = _pickedImageFile?.path;
        final fallbackImage =
            _doctorProfile?.profileImage ?? _userSession.profileImage;

        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Profile Settings',
            showNotification: false,
            showBackButton: true,
          ),
          backgroundColor: AppColors.scaffoldBg,
          body: SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.deepNavy,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: _buildAvatar(
                                      profileImage ?? fallbackImage,
                                      AppImages.imagesDoctorDRMahmoudAboLeila,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -6,
                                  bottom: -6,
                                  child: Material(
                                    color: AppColors.softLavender,
                                    shape: const CircleBorder(),
                                    child: IconButton(
                                      onPressed: _pickImage,
                                      icon: const Icon(Icons.edit, size: 18),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full name',
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone number',
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _specializationController,
                            label: 'Specialization',
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _bioController,
                            label: 'Bio',
                            maxLines: 5,
                            validator: (v) => null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _yearsController,
                            label: 'Years of experience',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              final n = int.tryParse(v);
                              if (n == null) return 'Invalid number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state is UserManagementLoading
                                  ? null
                                  : _saveDoctorProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.deepNavy,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: state is UserManagementLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Save changes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
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

  Widget _buildPatientScaffold() {
    final profileImage = _userSession.profileImage;
    final imageIsNetwork =
        profileImage != null &&
        profileImage.trim().isNotEmpty &&
        !profileImage.trim().startsWith('assets/');

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Profile Settings',
        showNotification: false,
        showBackButton: true,
      ),
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.deepNavy, width: 2),
                  ),
                  child: ClipOval(
                    child: imageIsNetwork
                        ? Image.network(
                            profileImage!.trim(),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              AppImages.imagesIconsPatient,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            AppImages.imagesIconsPatient,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _buildReadOnlyField(
                controller: _nameController,
                label: 'Full name',
              ),
              const SizedBox(height: 12),
              _buildReadOnlyField(
                controller: _phoneController,
                label: 'Phone number',
              ),
              const SizedBox(height: 12),
              _buildReadOnlyField(controller: _emailController, label: 'Email'),
              const SizedBox(height: 12),
              _buildReadOnlyField(
                controller: _birthDateController,
                label: 'Birth date',
              ),
              const SizedBox(height: 12),
              _buildReadOnlyField(
                controller: _addressController,
                label: 'Address',
              ),
              const SizedBox(height: 12),
              _buildReadOnlyField(
                controller: _genderController,
                label: 'Gender',
              ),
              const SizedBox(height: 12),
              _buildReadOnlyField(
                controller: _bloodGroupController,
                label: 'Blood group',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        AppTextFormField(
          hintText: 'Not provided',
          controller: controller,
          readOnly: true,
        ),
      ],
    );
  }

  Widget _buildAvatar(String? imagePath, String fallbackAsset) {
    final source = imagePath?.trim();
    if (source == null || source.isEmpty) {
      return Image.asset(fallbackAsset, fit: BoxFit.cover);
    }

    if (source.startsWith('assets/')) {
      return Image.asset(source, fit: BoxFit.cover);
    }

    final file = File(source);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          fallbackAsset,
          fit: BoxFit.cover,
        ),
      );
    }

    final remoteUrl = source.startsWith('http://') || source.startsWith('https://')
        ? source
        : '${_remoteImageBaseUrl}${source.startsWith('/') ? source.substring(1) : source}';

    return Image.network(
      remoteUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        fallbackAsset,
        fit: BoxFit.cover,
      ),
    );
  }
}
