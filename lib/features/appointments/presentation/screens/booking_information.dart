import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:smartclinic/features/family_members/data/models/family_member_response_model.dart';
import 'package:smartclinic/features/family_members/presentation/manager/family_member_cubit.dart';
import 'package:smartclinic/features/family_members/presentation/manager/family_member_state.dart';
import 'package:smartclinic/features/user_management/presentation/manager/user_management_cubit.dart';
import 'package:smartclinic/features/user_management/presentation/manager/user_management_state.dart';
import 'package:smartclinic/injection_dependency.dart';
import 'package:cherry_toast/cherry_toast.dart';

class BookingInformationPage extends StatefulWidget {
  final String? patientName;
  final String? patientGender;
  final String? patientAge;
  final String? doctorId;
  final int? clinicId;
  final String? doctorName;
  final String? doctorImage;
  final String? specialization;
  final String? clinicName;
  final double? rating;
  final int? reviewsCount;
  final int? yearsOfExperience;
  final int? patientsCount;
  final double? consultationFee;
  final String? consultationType;
  final String? selectedDate;
  final String? selectedTime;

  const BookingInformationPage({
    super.key,
    this.patientName,
    this.patientGender,
    this.patientAge,
    this.doctorId,
    this.clinicId,
    this.doctorName,
    this.doctorImage,
    this.specialization,
    this.clinicName,
    this.rating,
    this.reviewsCount,
    this.yearsOfExperience,
    this.patientsCount,
    this.consultationFee,
    this.consultationType,
    this.selectedDate,
    this.selectedTime,
  });

  @override
  State<BookingInformationPage> createState() => _BookingInformationPageState();
}

class _BookingInformationPageState extends State<BookingInformationPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _genderController;
  late TextEditingController _ageController;
  late TextEditingController _relationshipController;
  late TextEditingController _problemController;

  String? _selectedRelationship;
  List<FamilyMemberModel> _familyMembers = [];

  // Cached "me" values — updated when the API response arrives
  String _myName = '';
  String _myPhone = '';
  String _myGender = '';
  String _myAge = '';

  @override
  void initState() {
    super.initState();

    final userSession = getIt<UserSession>();
    _myName = widget.patientName ?? userSession.fullName ?? '';
    _myGender = widget.patientGender ?? userSession.gender ?? '';
    _myPhone = userSession.phone ?? '';
    _myAge = widget.patientAge ?? _calculateAge(userSession.birthDate ?? '');

    _nameController = TextEditingController(text: _myName);
    _phoneController = TextEditingController(text: _myPhone);
    _genderController = TextEditingController(text: _myGender);
    _ageController = TextEditingController(text: _myAge);
    _relationshipController = TextEditingController(text: 'Me');
    _problemController = TextEditingController();
    _selectedRelationship = 'me';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FamilyCubit>().getMyFamily();

      final role = userSession.userRole;
      if (role.isPatient) {
        context.read<UserManagementCubit>().getPatientProfile();
      } else if (role.isDoctor) {
        final userId = userSession.userId;
        if (userId != null) {
          context.read<UserManagementCubit>().getDoctorProfile(userId);
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _ageController.dispose();
    _relationshipController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  void _onRelationshipSelected(String? value) {
    if (value == null) return;

    setState(() {
      _selectedRelationship = value;
      if (value == 'me') {
        _nameController.text = _myName;
        _phoneController.text = _myPhone;
        _genderController.text = _myGender;
        _ageController.text = _myAge;
        _relationshipController.text = 'Me';
      } else {
        final familyMember = _familyMembers.firstWhere(
          (member) => member.id.toString() == value,
          orElse: () => _familyMembers.first,
        );
        _nameController.text = familyMember.name ?? '';
        _phoneController.text = '';
        _genderController.text = familyMember.gender ?? '';
        _ageController.text = _calculateAge(familyMember.birthDate ?? '');
        _relationshipController.text = familyMember.relation ?? '';
      }
    });
  }

  String _calculateAge(String birthDate) {
    try {
      final birth = DateTime.parse(birthDate);
      final today = DateTime.now();
      int age = today.year - birth.year;
      if (today.month < birth.month ||
          (today.month == birth.month && today.day < birth.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      return '';
    }
  }

  void _onBookAppointment() {
    if (_problemController.text.isEmpty) {
      CherryToast.error(
        title: const Text('Validation'),
        description: const Text('Please describe your problem'),
      ).show(context);
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.bookingSummary,
      arguments: {
        'doctorId': widget.doctorId,
        'clinicId': widget.clinicId,
        'doctorName': widget.doctorName,
        'doctorImage': widget.doctorImage,
        'specialization': widget.specialization,
        'clinicName': widget.clinicName,
        'rating': widget.rating,
        'reviewsCount': widget.reviewsCount,
        'yearsOfExperience': widget.yearsOfExperience,
        'patientsCount': widget.patientsCount,
        'consultationFee': widget.consultationFee,
        'consultationType': widget.consultationType,
        'selectedDate': widget.selectedDate,
        'selectedTime': widget.selectedTime,
        'patientName': _nameController.text,
        'familyMemberId': _selectedRelationship == null ||
                _selectedRelationship == 'me'
            ? null
            : int.tryParse(_selectedRelationship!),
        'notes': _problemController.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const CustomAppBar(
        title: 'Patient Details',
        showNotification: false,
      ),
      body: SafeArea(
        child: BlocListener<UserManagementCubit, UserManagementState>(
          listener: (context, state) {
            if (state is PatientProfileLoaded) {
              setState(() {
                _myName = state.profile.fullName;
                _myPhone = state.profile.phoneNumber ?? '';
                _myGender = state.profile.gender ?? _myGender;
                _myAge = _calculateAge(state.profile.birthDate ?? '') != ''
                    ? _calculateAge(state.profile.birthDate ?? '')
                    : _myAge;
                if (_selectedRelationship == 'me') {
                  _nameController.text = _myName;
                  _phoneController.text = _myPhone;
                  _genderController.text = _myGender;
                  _ageController.text = _myAge;
                }
              });
            } else if (state is ProfileLoaded) {
              setState(() {
                _myName = state.profile.fullName;
                _myPhone = state.profile.phoneNumber ?? '';
                if (_selectedRelationship == 'me') {
                  _nameController.text = _myName;
                  _phoneController.text = _myPhone;
                }
              });
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: BlocBuilder<FamilyCubit, FamilyState>(
              builder: (context, state) {
                if (state is GetMyFamilySuccess) {
                  _familyMembers = state.response.members;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    _buildLabel('Full Name'),
                    const SizedBox(height: 8),
                    AppTextFormField(
                      hintText: 'Full Name',
                      controller: _nameController,
                      type: TextFormFieldType.text,
                    ),
                    const SizedBox(height: 20),

                    // Phone Number
                    _buildLabel('Phone Number'),
                    const SizedBox(height: 8),
                    AppTextFormField(
                      hintText: 'Phone Number',
                      controller: _phoneController,
                      type: TextFormFieldType.text,
                    ),
                    const SizedBox(height: 20),

                    // Gender
                    _buildLabel('Gender'),
                    const SizedBox(height: 8),
                    AppTextFormField(
                      hintText: 'Gender',
                      controller: _genderController,
                      type: TextFormFieldType.text,
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),

                    // Age
                    _buildLabel('Your Age'),
                    const SizedBox(height: 8),
                    AppTextFormField(
                      hintText: 'Your Age',
                      controller: _ageController,
                      type: TextFormFieldType.text,
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),

                    // Relationship
                    _buildLabel('Relationship'),
                    const SizedBox(height: 8),
                    _buildRelationshipDropdown(),
                    const SizedBox(height: 20),

                    // Write Your Problem
                    _buildLabel('Write Your Problem'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _problemController,
                      maxLines: 5,
                      minLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe your problem here...',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        filled: true,
                        fillColor: AppColors.cardBg,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        border: _buildBorder(),
                        enabledBorder:
                            _buildBorder(color: AppColors.textPrimary),
                        focusedBorder: _buildBorder(
                          color: AppColors.skyBlue,
                          width: 1.5,
                        ),
                        errorBorder: _buildBorder(color: Colors.redAccent),
                      ),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _onBookAppointment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Continue', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Widget _buildRelationshipDropdown() {
    final relationships = <String, String>{
      'me': 'Me',
      ..._familyMembers.asMap().entries.fold(<String, String>{}, (map, entry) {
        map[entry.value.id.toString()] = entry.value.name ?? '';
        return map;
      }),
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textPrimary),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRelationship,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          items: relationships.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                entry.value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            );
          }).toList(),
          onChanged: _onRelationshipSelected,
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  OutlineInputBorder _buildBorder({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: color ?? AppColors.textPrimary,
        width: width,
      ),
    );
  }
}
