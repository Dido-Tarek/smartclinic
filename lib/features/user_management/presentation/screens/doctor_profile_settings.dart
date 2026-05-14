import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cherry_toast/cherry_toast.dart';

import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/features/user_management/presentation/manager/user_management_cubit.dart';
import 'package:smartclinic/features/user_management/presentation/manager/user_management_state.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';

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

  File? _pickedImageFile;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _bioController.dispose();
    _yearsController.dispose();
    super.dispose();
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

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'FullName': _nameController.text.trim(),
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
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Profile Settings',
        showNotification: false,
        showBackButton: true,
      ),
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: BlocConsumer<UserManagementCubit, UserManagementState>(
          listener: (context, state) {
            if (state is UserManagementSuccess) {
              CherryToast.success(
                title: const Text('Profile updated'),
                description: const Text(
                  'Your profile was updated successfully.',
                ),
              ).show(context);
            }

            if (state is UserManagementError) {
              CherryToast.error(
                title: const Text('Update failed'),
                description: Text(state.message),
              ).show(context);
            }
          },
          builder: (context, state) {
            final isLoading = state is UserManagementLoading;
            return SingleChildScrollView(
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
                              child: _pickedImageFile != null
                                  ? Image.file(
                                      _pickedImageFile!,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      AppImages.imagesDoctorDRMahmoudAboLeila,
                                      fit: BoxFit.cover,
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
                        onPressed: isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepNavy,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
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
            );
          },
        ),
      ),
    );
  }
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
