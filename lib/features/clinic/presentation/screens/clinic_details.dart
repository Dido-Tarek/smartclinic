import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/auth_header.dart';
import 'package:smartclinic/core/widgets/custom_button.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartclinic/core/widgets/map_location_picker.dart';

class ClinicDetailsPage extends StatefulWidget {
  const ClinicDetailsPage({super.key});

  @override
  State<ClinicDetailsPage> createState() => _ClinicDetailsPageState();
}

class _ClinicDetailsPageState extends State<ClinicDetailsPage> {
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

  static const List<String> _egyptianGovernorates = <String>[
    'Alexandria',
    'Aswan',
    'Assiut',
    'Beheira',
    'Beni Suef',
    'Cairo',
    'Dakahlia',
    'Damietta',
    'Faiyum',
    'Gharbia',
    'Giza',
    'Ismailia',
    'Kafr El-Sheikh',
    'Luxor',
    'Matrouh',
    'Minya',
    'Monufia',
    'New Valley',
    'North Sinai',
    'Port Said',
    'Qalyubia',
    'Qena',
    'Red Sea',
    'Sharqia',
    'Sohag',
    'South Sinai',
    'Suez',
  ];

  final TextEditingController _facilityNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _facilityImageController =
      TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();

  bool _argsLoaded = false;
  bool _isOwner = true;
  File? _legalDocument1;
  File? _legalDocument2;
  File? _legalDocument3;
  File? _clinicImage;
  double? _latitude;
  double? _longitude;
  bool _isSpecializationPickerOpen = false;
  bool _isApplyingSpecializationSelection = false;
  Timer? _specializationTypingDebounce;
  bool _isCityPickerOpen = false;
  bool _isApplyingCitySelection = false;
  Timer? _cityTypingDebounce;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final normalized = args.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      _isOwner = normalized['isOwner'] as bool? ?? true;
      _legalDocument1 = normalized['legalDocument1'] as File?;
      _legalDocument2 = normalized['legalDocument2'] as File?;
      _legalDocument3 = normalized['legalDocument3'] as File?;
    }

    _argsLoaded = true;
  }

  @override
  void dispose() {
    _specializationTypingDebounce?.cancel();
    _cityTypingDebounce?.cancel();
    _facilityNameController.dispose();
    _contactController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _facilityImageController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AuthHeader(
                      title: localizations.translate('clinic_details_title'),
                      subTitle: localizations.translate(
                        'clinic_details_subtitle',
                      ),
                    ),
                    const SizedBox(height: 26),
                    _buildLabel(localizations.translate('facility_name_title')),
                    const SizedBox(height: 8),
                    AppTextFormField(
                      controller: _facilityNameController,
                      hintText: localizations.translate(
                        'facility_name_subtitle',
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildLabel(
                      localizations.translate('facility_contact_title'),
                    ),
                    const SizedBox(height: 8),
                    AppTextFormField(
                      controller: _contactController,
                      hintText: localizations.translate(
                        'facility_contact_subtitle',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    _buildLabel(
                      localizations.translate('facility_location_title'),
                    ),
                    const SizedBox(height: 8),
                    AppTextFormField(
                      controller: _locationController,
                      hintText: localizations.translate(
                        'facility_location_subtitle',
                      ),
                      type: TextFormFieldType.location,
                      onTap: _onOpenMap,
                    ),
                    const SizedBox(height: 14),
                    _buildLabel(
                      localizations.translate('facility_address_title'),
                    ),
                    const SizedBox(height: 8),
                    AppTextFormField(
                      controller: _addressController,
                      hintText: localizations.translate(
                        'facility_address_subtitle',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                localizations.translate('facility_city_title'),
                              ),
                              const SizedBox(height: 8),
                              AppTextFormField(
                                controller: _cityController,
                                hintText: localizations.translate(
                                  'facility_city_subtitle',
                                ),
                                type: TextFormFieldType.speciality,
                                onSuffixTap: _showGovernoratesPicker,
                                onChanged: _onCityChanged,
                                keyboardType: TextInputType.name,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                localizations.translate('facility_area_title'),
                              ),
                              const SizedBox(height: 8),
                              AppTextFormField(
                                controller: _areaController,
                                hintText: localizations.translate(
                                  'facility_area_subtitle',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                localizations.translate('facility_image_title'),
                              ),
                              const SizedBox(height: 8),
                              AppTextFormField(
                                controller: _facilityImageController,
                                hintText: localizations.translate(
                                  'facility_image_subtitle',
                                ),
                                type: TextFormFieldType.fileUpload,
                                onSuffixTap: _pickClinicImage,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(
                                localizations.translate(
                                  'facility_specialization_title',
                                ),
                              ),
                              const SizedBox(height: 8),
                              AppTextFormField(
                                controller: _specializationController,
                                hintText: localizations.translate(
                                  'facility_specialization_subtitle',
                                ),
                                type: TextFormFieldType.speciality,
                                onSuffixTap: _showSpecializationPicker,
                                onChanged: _onSpecializationChanged,
                                keyboardType: TextInputType.name,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: CustomButton(
                text: localizations.translate('Save'),
                width: double.infinity,
                onPressed: _onSavePressed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Future<void> _pickClinicImage() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg'],
    );

    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    final path = result.files.single.path;
    if (path == null || path.trim().isEmpty) {
      return;
    }

    setState(() {
      _clinicImage = File(path);
      _facilityImageController.text = result.files.single.name;
    });
  }

  Future<void> _onOpenMap() async {
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

    if (result != null && mounted) {
      setState(() {
        _latitude = result['latitude'] as double?;
        _longitude = result['longitude'] as double?;
        _locationController.text =
            '${_latitude?.toStringAsFixed(6)}, ${_longitude?.toStringAsFixed(6)}';
      });
    }
  }

  void _onSavePressed() {
    Navigator.pushNamed(
      context,
      AppRoutes.appointmentDetails,
      arguments: <String, dynamic>{
        'isOwner': _isOwner,
        'name': _facilityNameController.text.trim(),
        'phoneNumber': _contactController.text.trim(),
        'location': _locationController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'area': _areaController.text.trim(),
        'specialization': _specializationController.text.trim(),
        'clinicImage': _clinicImage,
        'latitude': _latitude,
        'longitude': _longitude,
        'legalDocument1': _legalDocument1,
        'legalDocument2': _legalDocument2,
        'legalDocument3': _legalDocument3,
      },
    );
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

  List<String> get _filteredGovernorates {
    final query = _cityController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _egyptianGovernorates;
    }

    return _egyptianGovernorates.where((item) {
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

  void _onCityChanged(String value) {
    if (_isApplyingCitySelection) {
      return;
    }

    _cityTypingDebounce?.cancel();

    if (_isCityPickerOpen || value.trim().isEmpty) {
      return;
    }

    _cityTypingDebounce = Timer(const Duration(milliseconds: 550), () {
      if (!mounted || _isCityPickerOpen) {
        return;
      }
      _showGovernoratesPicker();
    });
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

  Future<void> _showGovernoratesPicker() async {
    if (_isCityPickerOpen) {
      return;
    }

    final currentList = _filteredGovernorates;
    if (currentList.isEmpty) {
      return;
    }

    _isCityPickerOpen = true;

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

    _isCityPickerOpen = false;

    if (selected == null || selected.trim().isEmpty) {
      return;
    }
    _selectCity(selected);
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

  void _selectCity(String city) {
    _isApplyingCitySelection = true;
    _cityController.text = city;
    _cityController.selection = TextSelection.fromPosition(
      TextPosition(offset: _cityController.text.length),
    );
    _isApplyingCitySelection = false;
    if (mounted) {
      setState(() {});
    }
  }
}
