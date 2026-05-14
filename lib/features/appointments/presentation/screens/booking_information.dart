import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/custom_text_field.dart';
import 'package:smartclinic/features/family_members/data/models/family_member_model.dart';
import 'package:smartclinic/features/family_members/presentation/manager/family_member_cubit.dart';
import 'package:smartclinic/features/family_members/presentation/manager/family_member_state.dart';
import 'package:cherry_toast/cherry_toast.dart';

class BookingInformationPage extends StatefulWidget {
  final String? patientName;
  final String? patientGender;
  final String? patientAge;
  final String? doctorId;
  final int? clinicId;
  final String? doctorName;
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
    this.consultationType,
    this.selectedDate,
    this.selectedTime,
  });

  @override
  State<BookingInformationPage> createState() => _BookingInformationPageState();
}

class _BookingInformationPageState extends State<BookingInformationPage> {
  late TextEditingController _nameController;
  late TextEditingController _genderController;
  late TextEditingController _ageController;
  late TextEditingController _relationshipController;
  late TextEditingController _problemController;

  String? _selectedRelationship;
  List<FamilyMemberModel> _familyMembers = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.patientName ?? '');
    _genderController = TextEditingController(text: widget.patientGender ?? '');
    _ageController = TextEditingController(text: widget.patientAge ?? '');
    _relationshipController = TextEditingController();
    _problemController = TextEditingController();

    _selectedRelationship = 'me';
    _relationshipController.text = 'Me';

    // Fetch family members
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FamilyCubit>().emitGetFamily();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
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
        _nameController.text = widget.patientName ?? '';
        _genderController.text = widget.patientGender ?? '';
        _ageController.text = widget.patientAge ?? '';
        _relationshipController.text = 'Me';
      } else {
        // Find the family member
        final familyMember = _familyMembers.firstWhere(
          (member) => member.id.toString() == value,
          orElse: () => _familyMembers.first,
        );
        _nameController.text = familyMember.name;
        _genderController.text = familyMember.gender;
        // Calculate age from birth date
        _ageController.text = _calculateAge(familyMember.birthDate);
        _relationshipController.text = familyMember.relation;
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

    // Navigate to booking summary with all booking details
    Navigator.pushNamed(
      context,
      AppRoutes.bookingSummary,
      arguments: {
        'doctorId': widget.doctorId,
        'clinicId': widget.clinicId,
        'doctorName': widget.doctorName,
        'consultationType': widget.consultationType,
        'selectedDate': widget.selectedDate,
        'selectedTime': widget.selectedTime,
        'patientName': _nameController.text,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: BlocBuilder<FamilyCubit, FamilyState>(
            builder: (context, state) {
              // Get family members from state
              state.whenOrNull(
                success: (data) {
                  if (data is List<FamilyMemberModel>) {
                    _familyMembers = data;
                  }
                },
              );

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

                  // Gender
                  _buildLabel('Gender'),
                  const SizedBox(height: 8),
                  AppTextFormField(
                    hintText: 'Gender',
                    controller: _genderController,
                    type: TextFormFieldType.text,
                  ),
                  const SizedBox(height: 20),

                  // Age
                  _buildLabel('Your Age'),
                  const SizedBox(height: 8),
                  AppTextFormField(
                    hintText: 'Your Age',
                    controller: _ageController,
                    type: TextFormFieldType.text,
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
                      enabledBorder: _buildBorder(color: AppColors.textPrimary),
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
        map[entry.value.id.toString()] = entry.value.name;
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
