import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/doctor_card_widget.dart';
import 'package:smartclinic/core/widgets/search_engine.dart';
import 'package:smartclinic/core/widgets/specialization_widget.dart';
import 'package:smartclinic/features/search/data/model/search_doctors_response_model.dart';
import 'package:smartclinic/features/search/presentation/manager/search_doctors_cubit.dart';
import 'package:smartclinic/features/search/presentation/manager/search_doctors_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<DoctorsCubit>().searchDoctors(pageSize: 20, pageNumber: 1);
    });
  }

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
              BlocBuilder<DoctorsCubit, DoctorsState>(
                builder: (context, state) {
                  final doctors = _resolveDoctors(state);
                  final isLoading =
                      state is SearchDoctorsLoading && doctors.isEmpty;

                  if (isLoading) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 36),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: doctors.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.63,
                        ),
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      final imageSource =
                          doctor.resolvedImageUrl ??
                          _fallbackDoctorImage(doctor);
                      final rating = _resolveDoctorRating(doctor);

                      return DoctorCardWidget(
                        doctorName: doctor.name ?? 'Doctor',
                        specialization: doctor.specialization ?? 'Doctor',
                        rating: rating,
                        reviewsCount: doctor.reviewsCount,
                        imagePath: imageSource,
                        imageUrl: doctor.resolvedImageUrl,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.doctorProfileView,
                          arguments: {
                            'name': doctor.name,
                            'doctorId': doctor.id,
                            'clinicId': doctor.clinicId,
                            'doctorImage': doctor.resolvedImageUrl,
                            'specialization': doctor.specialization,
                            'rating': rating,
                            'reviewsCount': doctor.reviewsCount,
                            'clinicFee': doctor.consultationPrice,
                            'clinicName': doctor.clinicName,
                            'clinicAddress': doctor.clinicAddress,
                            'clinicPhone': doctor.clinicPhone,
                            'clinicWorkingHours': doctor.clinicWorkingHours,
                          },
                        ),
                        onFavoriteChanged: (_) {},
                      );
                    },
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

List<DoctorModel> _resolveDoctors(DoctorsState state) {
  if (state is SearchDoctorsSuccess && state.response.doctors.isNotEmpty) {
    return state.response.doctors;
  }

  return _fallbackDoctors;
}

double _resolveDoctorRating(DoctorModel doctor) {
  return doctor.rating ?? 0.0;
}

String _fallbackDoctorImage(DoctorModel doctor) {
  final specialization = (doctor.specialization ?? '').toLowerCase();
  final name = (doctor.name ?? '').toLowerCase();

  if (name.contains('razan')) {
    return AppImages.imagesDoctorDRRazanHany;
  }

  if (specialization.contains('neuro')) {
    return AppImages.imagesDoctorDRKhoulodAshraf;
  }

  if (specialization.contains('cardio')) {
    return AppImages.imagesDoctorDRAhmedAlaa;
  }

  if (specialization.contains('dent')) {
    return AppImages.imagesDoctorDRMaiElKady;
  }

  return AppImages.imagesDoctorDRHussienShokry;
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

const List<DoctorModel> _fallbackDoctors = <DoctorModel>[
  DoctorModel(
    id: '1',
    name: 'Mai El Kady',
    specialization: 'Dentist',
    city: 'Cairo',
    area: 'Nasr City',
    consultationType: 0,
    consultationPrice: 250,
    reviewsCount: 380,
    rating: 3.8,
    imageUrl: AppImages.imagesDoctorDRMaiElKady,
  ),
  DoctorModel(
    id: '2',
    name: 'Razan Hany',
    specialization: 'Dentist',
    city: 'Giza',
    area: 'Maadi',
    consultationType: 1,
    consultationPrice: 300,
    reviewsCount: 400,
    rating: 4.0,
    imageUrl: AppImages.imagesDoctorDRRazanHany,
  ),
  DoctorModel(
    id: '3',
    name: 'Khoulod Ashraf',
    specialization: 'Neurologist',
    city: 'Alexandria',
    area: 'Heliopolis',
    consultationType: 2,
    consultationPrice: 350,
    reviewsCount: 420,
    rating: 4.2,
    imageUrl: AppImages.imagesDoctorDRKhoulodAshraf,
  ),
  DoctorModel(
    id: '4',
    name: 'Hussien Shokry',
    specialization: 'Dentist',
    city: 'Cairo',
    area: 'Nasr City',
    consultationType: 0,
    consultationPrice: 275,
    reviewsCount: 410,
    rating: 4.0,
    imageUrl: AppImages.imagesDoctorDRHussienShokry,
  ),
];
