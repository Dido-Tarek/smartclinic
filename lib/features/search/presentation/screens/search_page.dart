import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/doctor_card_widget.dart';
import 'package:smartclinic/core/widgets/search_engine.dart';
import 'package:smartclinic/core/widgets/specialization_widget.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CustomAppBar(
        title: 'Find Doctors',
        showBackButton: true,
        onBackTap: () => Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SearchEngineBar(),
              const SizedBox(height: 18),
              const Text(
                'Doctor Specialty',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _specialties.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = _specialties[index];
                    return SpecializationWidget(
                      specializationName: item.name,
                      iconPath: item.iconPath,
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _doctors.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.63,
                ),
                itemBuilder: (context, index) {
                  final doctor = _doctors[index];
                  return DoctorCardWidget(
                    doctorName: doctor.name,
                    specialization: doctor.specialization,
                    rating: doctor.rating,
                    imagePath: doctor.imagePath,
                    onTap: () {},
                    onFavoriteChanged: (_) {},
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecialtyItem {
  const _SpecialtyItem({required this.name, required this.iconPath});

  final String name;
  final String iconPath;
}

class _DoctorItem {
  const _DoctorItem({
    required this.name,
    required this.specialization,
    required this.rating,
    required this.imagePath,
  });

  final String name;
  final String specialization;
  final double rating;
  final String imagePath;
}

const List<_SpecialtyItem> _specialties = <_SpecialtyItem>[
  _SpecialtyItem(
    name: 'Neurologist',
    iconPath: AppImages.imagesSpecialityNeurologist,
  ),
  _SpecialtyItem(name: 'Dentistry', iconPath: AppImages.imagesSpecialityTooth),
  _SpecialtyItem(
    name: 'Cardiology',
    iconPath: AppImages.imagesSpecialityPhysician,
  ),
];

const List<_DoctorItem> _doctors = <_DoctorItem>[
  _DoctorItem(
    name: 'Dr. Mai El Kady',
    specialization: 'Dentist',
    rating: 3.8,
    imagePath: AppImages.imagesDoctorDRMaiElKady,
  ),
  _DoctorItem(
    name: 'Dr. Razan Hany',
    specialization: 'Dentist',
    rating: 4.0,
    imagePath: AppImages.imagesDoctorDRRazanHany,
  ),
  _DoctorItem(
    name: 'Dr. Khoulod Ashraf',
    specialization: 'Neurologist',
    rating: 4.2,
    imagePath: AppImages.imagesDoctorDRKhoulodAshraf,
  ),
  _DoctorItem(
    name: 'Dr. Hussien Shokry',
    specialization: 'Dentist',
    rating: 4.0,
    imagePath: AppImages.imagesDoctorDRHussienShokry,
  ),
];
