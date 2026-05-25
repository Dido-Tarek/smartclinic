import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/doctor_view_card.dart';
import 'package:smartclinic/features/appointments/presentation/manager/appointment_cubit.dart';
import 'package:smartclinic/features/appointments/presentation/manager/appointment_state.dart';

class BookingDetailsPage extends StatefulWidget {
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
  final Set<String> enabledAppointmentTypes;

  const BookingDetailsPage({
    super.key,
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
    this.enabledAppointmentTypes = const {
      'clinic',
      'online',
      'homeVisit',
      'emergency',
    },
  });

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  String? _selectedConsultationType;

  List<DateTime> get _weekDates =>
      List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

  String _weekdayShort(DateTime d) {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return names[d.weekday % 7];
  }

  String _formatDateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _selectedConsultationType = _availableConsultationTypes.isNotEmpty
        ? _availableConsultationTypes.first
        : null;
    // If we have doctor/clinic info, fetch slots for today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.doctorId != null && widget.clinicId != null) {
        context.read<AppointmentsCubit>().getAvailableSlots(
          doctorId: widget.doctorId!,
          clinicId: widget.clinicId!,
          date: _formatDateKey(_selectedDate),
        );
      }
    });
  }

  void _onDateSelected(DateTime d) {
    setState(() {
      _selectedDate = d;
      _selectedTime = null;
    });

    if (widget.doctorId != null && widget.clinicId != null) {
      context.read<AppointmentsCubit>().getAvailableSlots(
        doctorId: widget.doctorId!,
        clinicId: widget.clinicId!,
        date: _formatDateKey(d),
      );
    }
  }

  List<String> get _availableConsultationTypes => _consultationTypeLabels.keys
      .where(widget.enabledAppointmentTypes.contains)
      .toList();

  @override
  Widget build(BuildContext context) {
    final image = widget.doctorImage ?? AppImages.imagesDoctorDRMaiElKady;
    final name = widget.doctorName ?? 'Dr. Mai ElKady';
    final specialization = widget.specialization ?? 'Physician';
    final clinicName = widget.clinicName ?? 'Good Health Care';
    final rating = widget.rating ?? 4.8;
    final reviewsCount = widget.reviewsCount ?? 0;
    final yearsOfExperience = widget.yearsOfExperience ?? 6;
    final patientsCount = widget.patientsCount ?? 2000;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const CustomAppBar(
        title: 'Book Appointment',
        showNotification: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DoctorViewCard(
                doctorName: name,
                specialization: specialization,
                clinicName: clinicName,
                rating: rating,
                reviewsCount: reviewsCount,
                doctorImagePath: image,
                yearsOfExperience: yearsOfExperience,
                patientsCount: patientsCount,
              ),

              const SizedBox(height: 20),

              // Select Date
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) _onDateSelected(picked);
                      },
                      child: Text(
                        'Set Manual',
                        style: TextStyle(color: AppColors.skyBlue),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                height: 84,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _weekDates.length,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final d = _weekDates[index];
                    final selected =
                        d.year == _selectedDate.year &&
                        d.month == _selectedDate.month &&
                        d.day == _selectedDate.day;
                    return GestureDetector(
                      onTap: () => _onDateSelected(d),
                      child: Container(
                        width: 68,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.skyBlue : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.skyBlue
                                : Colors.grey.shade200,
                          ),
                          boxShadow: [
                            if (!selected)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _weekdayShort(d),
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              d.day.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? Colors.white
                                    : AppColors.deepNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Consultation Type',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _availableConsultationTypes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final typeKey = _availableConsultationTypes[index];
                    final title = _consultationTypeLabels[typeKey] ?? typeKey;
                    final selected = _selectedConsultationType == typeKey;

                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedConsultationType = typeKey;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.skyBlue : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.skyBlue
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          title,
                          style: TextStyle(
                            color: selected ? Colors.white : AppColors.deepNavy,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // Available times
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Available time',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              BlocBuilder<AppointmentsCubit, AppointmentsState>(
                builder: (context, state) {
                  if (state is GetAvailableSlotsLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  List<Widget> slotWidgets = [];
                  if (state is GetAvailableSlotsSuccess) {
                    final slots = state.response.slots;
                    slotWidgets = slots.map((s) {
                      final available = s.isAvailable == true;
                      final isSelected = _selectedTime == s.time;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 6.0,
                        ),
                        child: GestureDetector(
                          onTap: available
                              ? () {
                                  setState(() => _selectedTime = s.time);
                                }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.skyBlue
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: available
                                    ? (isSelected
                                          ? AppColors.skyBlue
                                          : Colors.green)
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Text(
                              s.time ?? '',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (available
                                          ? AppColors.deepNavy
                                          : AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList();
                  } else {
                    // fallback mock slots
                    final mock = [
                      '09:00 AM',
                      '10:00 AM',
                      '11:00 AM',
                      '01:00 PM',
                      '02:00 PM',
                      '03:00 PM',
                      '04:00 PM',
                      '07:00 PM',
                    ];
                    slotWidgets = mock.map((t) {
                      final isSelected = _selectedTime == t;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 6.0,
                        ),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTime = t),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.skyBlue
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.skyBlue
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Text(
                              t,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.deepNavy,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList();
                  }

                  return SizedBox(
                    height: 58,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: slotWidgets.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => slotWidgets[index],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _selectedTime == null
                ? null
                : () {
                    // Navigate to booking information to gather patient details
                    Navigator.pushNamed(
                      context,
                      AppRoutes.bookingInformation,
                      arguments: {
                        'doctorId': widget.doctorId,
                        'clinicId': widget.clinicId,
                        'doctorName': widget.doctorName,
                        'consultationType': _selectedConsultationType,
                        'selectedDate': _formatDateKey(_selectedDate),
                        'selectedTime': _selectedTime,
                      },
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Make An Appointment',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

const Map<String, String> _consultationTypeLabels = {
  'clinic': 'Clinic Consultation',
  'online': 'Online Consultation',
  'homeVisit': 'Home Visit',
  'emergency': 'Emergency Case',
};
