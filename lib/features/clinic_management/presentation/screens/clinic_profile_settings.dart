import 'dart:io';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:smartclinic/core/widgets/map_location_picker.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_request_model.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_response_model.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_cubit.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_state.dart';

const String _remoteImageBaseUrl = 'http://smartclinicccc.runasp.net/';

class ClinicProfileSettingsPage extends StatefulWidget {
  final int clinicId;
  const ClinicProfileSettingsPage({super.key, required this.clinicId});

  @override
  State<ClinicProfileSettingsPage> createState() =>
      _ClinicProfileSettingsPageState();
}

class _ClinicProfileSettingsPageState
    extends State<ClinicProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  File? _pickedImageFile;
  ClinicModel? _clinicProfile;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ClinicManagementCubit>().getClinicProfile(widget.clinicId);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _fillFields(ClinicModel clinic) {
    _clinicProfile = clinic;
    _nameController.text = clinic.name ?? '';
    _phoneController.text = clinic.phoneNumber ?? '';
    _addressController.text = clinic.address ?? '';
    _cityController.text = clinic.city ?? '';
    _areaController.text = clinic.area ?? '';
    _latitude = clinic.latitude;
    _longitude = clinic.longitude;
    if (_latitude != null && _longitude != null) {
      _locationController.text =
          '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}';
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
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

    if (!mounted || result == null) return;

    final pickedLat = (result['latitude'] as num?)?.toDouble();
    final pickedLng = (result['longitude'] as num?)?.toDouble();
    if (pickedLat == null || pickedLng == null) return;

    final pickedAddress = result['address']?.toString().trim();
    setState(() {
      _latitude = pickedLat;
      _longitude = pickedLng;
      final displayAddress =
          pickedAddress == null || pickedAddress.isEmpty
              ? '${pickedLat.toStringAsFixed(6)}, ${pickedLng.toStringAsFixed(6)}'
              : pickedAddress;
      _locationController.text = displayAddress;
      _addressController.text = displayAddress;
    });
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final request = UpdateClinicProfileRequestModel(
      clinicId: widget.clinicId,
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      area: _areaController.text.trim().isEmpty
          ? null
          : _areaController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      clinicImagePath: _pickedImageFile?.path,
    );

    context.read<ClinicManagementCubit>().updateClinicProfile(request);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClinicManagementCubit, ClinicManagementState>(
      listener: (context, state) {
        if (state is GetClinicProfileSuccess) {
          setState(() => _fillFields(state.response));
        } else if (state is GetClinicProfileFailure) {
          CherryToast.error(
            title: const Text('Load failed'),
            description: Text(state.errorMessage),
          ).show(context);
        } else if (state is UpdateClinicProfileSuccess) {
          // Re-fetch from GET to get the full accurate data (PUT response
          // may omit fields like clinicPictureUrl)
          setState(() {
            _pickedImageFile = null;
          });
          CherryToast.success(
            title: const Text('Profile updated'),
            description:
                const Text('Clinic profile was updated successfully.'),
          ).show(context);
          context
              .read<ClinicManagementCubit>()
              .getClinicProfile(widget.clinicId);
        } else if (state is UpdateClinicProfileFailure) {
          CherryToast.error(
            title: const Text('Update failed'),
            description: Text(state.errorMessage),
          ).show(context);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is GetClinicProfileLoading && _clinicProfile == null;
        final isSaving = state is UpdateClinicProfileLoading;

        // The image path to display: locally picked file path, or the remote URL
        final String? pickedPath = _pickedImageFile?.path;
        final String? remotePath = _clinicProfile?.clinicImageUrl;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: const CustomAppBar(
            title: 'Clinic Profile',
            showNotification: false,
            showBackButton: true,
          ),
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
                          // ── Clinic Image ─────────────────────────────────
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.deepNavy,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: _buildAvatar(
                                      pickedPath ?? remotePath,
                                      AppImages.imagesIconsHospital,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -6,
                                  bottom: -6,
                                  child: Material(
                                    color: AppColors.deepNavy,
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
                          const SizedBox(height: 24),

                          // ── Clinic Name ──────────────────────────────────
                          _buildTextField(
                            controller: _nameController,
                            label: 'Clinic Name',
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Required'
                                    : null,
                          ),
                          const SizedBox(height: 14),

                          // ── Phone Number ─────────────────────────────────
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Required'
                                    : null,
                          ),
                          const SizedBox(height: 14),

                          // ── Address ──────────────────────────────────────
                          _buildTextField(
                            controller: _addressController,
                            label: 'Address',
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Required'
                                    : null,
                          ),
                          const SizedBox(height: 14),

                          // ── City & Area ──────────────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _cityController,
                                  label: 'City',
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Required'
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _areaController,
                                  label: 'Area',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // ── Location (map picker) ────────────────────────
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Location',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.deepNavy,
                                ),
                              ),
                              const SizedBox(height: 8),
                              AppTextFormField(
                                hintText: 'Tap to pick location on map',
                                controller: _locationController,
                                type: TextFormFieldType.location,
                                onSuffixTap: _pickLocation,
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // ── Save Button ──────────────────────────────────
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isSaving ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.deepNavy,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
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
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }

  /// Mirrors the exact same logic used in PatientProfileSettingsPage._buildAvatar
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
        errorBuilder: (_, __, ___) =>
            Image.asset(fallbackAsset, fit: BoxFit.cover),
      );
    }

    final remoteUrl =
        source.startsWith('http://') || source.startsWith('https://')
            ? source
            : '$_remoteImageBaseUrl${source.startsWith('/') ? source.substring(1) : source}';

    return Image.network(
      remoteUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          Image.asset(fallbackAsset, fit: BoxFit.cover),
    );
  }
}
