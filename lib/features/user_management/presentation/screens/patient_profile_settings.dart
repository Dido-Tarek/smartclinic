import 'dart:io';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:smartclinic/features/user_management/data/model/patient_profile_response_model.dart';
import 'package:smartclinic/features/user_management/presentation/manager/user_management_cubit.dart';
import 'package:smartclinic/features/user_management/presentation/manager/user_management_state.dart';
import 'package:smartclinic/injection_dependency.dart';

const String _remoteImageBaseUrl = 'http://smartclinicccc.runasp.net/';

class PatientProfileSettingsPage extends StatefulWidget {
  const PatientProfileSettingsPage({super.key});

  @override
  State<PatientProfileSettingsPage> createState() =>
      _PatientProfileSettingsPageState();
}

class _PatientProfileSettingsPageState
    extends State<PatientProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bloodGroupController = TextEditingController();

  final UserSession _userSession = getIt<UserSession>();

  File? _pickedImageFile;
  PatientProfileModel? _patientProfile;
  bool _requestedPatientProfile = false;

  @override
  void initState() {
    super.initState();
    _fillFieldsFromSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _requestedPatientProfile) {
        return;
      }
      _requestedPatientProfile = true;
      context.read<UserManagementCubit>().getPatientProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bloodGroupController.dispose();
    super.dispose();
  }

  void _fillFieldsFromSession() {
    if (_userSession.fullName != null) {
      _nameController.text = _userSession.fullName!;
    }
    if (_userSession.phone != null) {
      _phoneController.text = _userSession.phone!;
    }
    if (_userSession.address != null) {
      _addressController.text = _userSession.address!;
    }
    if (_userSession.bloodGroup != null) {
      _bloodGroupController.text = _userSession.bloodGroup!;
    }
  }

  void _fillFields(PatientProfileModel profile) {
    _patientProfile = profile;
    _nameController.text = profile.fullName;
    _phoneController.text = profile.phoneNumber ?? '';
    _addressController.text = profile.address ?? '';
    _bloodGroupController.text = profile.bloodGroup ?? '';
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

  void _savePatientProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final data = <String, dynamic>{
      'FullName': _nameController.text.trim(),
      'PhoneNumber': _phoneController.text.trim(),
      'Address': _addressController.text.trim(),
      'BloodGroup': _bloodGroupController.text.trim(),
    };

    context.read<UserManagementCubit>().updatePatientProfile(
      data,
      _pickedImageFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserManagementCubit, UserManagementState>(
      listener: (context, state) async {
        if (state is PatientProfileLoaded) {
          _fillFields(state.profile);
          final profilePicture = state.profile.profilePicture;
          if (profilePicture != null && profilePicture.isNotEmpty) {
            await _userSession.saveProfileImage(profilePicture);
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
          await context.read<UserManagementCubit>().getPatientProfile();
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
            state is UserManagementLoading && _patientProfile == null;
        final profileImage = _pickedImageFile?.path;
        final fallbackImage =
            _patientProfile?.profilePicture ?? _userSession.profileImage;

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
                                      AppImages.imagesIconsPatient,
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
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone number',
                            keyboardType: TextInputType.phone,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _addressController,
                            label: 'Address',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _bloodGroupController,
                            label: 'Blood group',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state is UserManagementLoading
                                  ? null
                                  : _savePatientProfile,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
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
        AppTextFormField(
          hintText: label,
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
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
