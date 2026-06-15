import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/core/widgets/doctor_view_card.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_response_model.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_cubit.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_state.dart';

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
  final double? clinicFee;
  final double? onlineFee;
  final double? homeVisitFee;
  final double? followUpFee;
  final double? emergencyFee;

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
      'InClinic',
      'VideoCall',
      'HomeVisit',
      'FollowUp',
      'Emergency',
    },
    this.clinicFee,
    this.onlineFee,
    this.homeVisitFee,
    this.followUpFee,
    this.emergencyFee,
  });

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  DateTime? _selectedDate;
  String? _selectedTime;
  String? _selectedConsultationType;
  List<ScheduleModel> _schedules = [];

  static const _dayToWeekday = {
    'monday': 1,
    'tuesday': 2,
    'wednesday': 3,
    'thursday': 4,
    'friday': 5,
    'saturday': 6,
    'sunday': 7,
  };

  Set<int> get _availableWeekdays => _schedules
      .map((s) => _dayToWeekday[(s.dayOfWeek ?? '').toLowerCase()])
      .whereType<int>()
      .toSet();

  List<DateTime> get _availableDates {
    if (_availableWeekdays.isEmpty) return [];
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final result = <DateTime>[];
    for (int i = 0; i < 90 && result.length < 30; i++) {
      final d = today.add(Duration(days: i));
      if (_availableWeekdays.contains(d.weekday)) result.add(d);
    }
    return result;
  }

  ScheduleModel? _scheduleForDate(DateTime date) {
    final dayName = _weekdayToName(date.weekday);
    for (final s in _schedules) {
      if ((s.dayOfWeek ?? '').toLowerCase() == dayName) return s;
    }
    return null;
  }

  String _weekdayToName(int weekday) {
    const names = [
      '',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return weekday >= 1 && weekday <= 7 ? names[weekday] : '';
  }

  List<String> _generateTimeSlots(ScheduleModel schedule) {
    final start = _parseTime(schedule.startTime);
    final end = _parseTime(schedule.endTime);

    if (start == null || end == null) return [];
    final totalMinutes = end.difference(start).inMinutes;
    if (totalMinutes < 20) return [];

    // When the API provides maxPatientsPerShift use it to set the interval;
    // otherwise fill the window with 30-minute slots.
    final maxPatients = schedule.maxPatientsPerShift;
    final slotMinutes = maxPatients != null && maxPatients > 0
        ? (totalMinutes / maxPatients).round().clamp(20, 30)
        : 30;

    final slots = <String>[];
    var current = start;
    while (true) {
      // Respect the patient cap when provided
      if (maxPatients != null && slots.length >= maxPatients) break;

      // Drop the slot if less than the 20-minute minimum remains
      final remaining = end.difference(current).inMinutes;
      if (remaining < 20) break;

      slots.add(_formatTime12h(current));
      current = current.add(Duration(minutes: slotMinutes));
    }
    return slots;
  }

  DateTime? _parseTime(String? time) {
    if (time == null || time.trim().isEmpty) return null;
    try {
      final parts = time.trim().split(':');
      final now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0].trim()),
        int.parse(parts[1].trim()),
      );
    } catch (_) {
      return null;
    }
  }

  String _formatTime12h(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$displayH:$m $period';
  }

  String _weekdayShort(DateTime d) {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return names[d.weekday % 7];
  }

  String _formatDateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  List<String> get _availableConsultationTypes => _consultationTypeLabels.keys
      .where(widget.enabledAppointmentTypes.contains)
      .toList();

  double? _feeForType(String? type) {
    switch (type) {
      case 'InClinic': return widget.clinicFee;
      case 'VideoCall': return widget.onlineFee;
      case 'HomeVisit': return widget.homeVisitFee;
      case 'FollowUp': return widget.followUpFee;
      case 'Emergency': return widget.emergencyFee;
      default: return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedConsultationType = _availableConsultationTypes.isNotEmpty
        ? _availableConsultationTypes.first
        : null;
    if (widget.doctorId != null && widget.doctorId!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context
              .read<ClinicManagementCubit>()
              .getDoctorAvailability(widget.doctorId!.trim());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.doctorImage ?? AppImages.imagesDoctorDRMaiElKady;
    final name = widget.doctorName ?? 'Dr. Mai ElKady';
    final specialization = widget.specialization ?? 'Physician';
    final clinicName = widget.clinicName ?? 'Good Health Care';
    final rating = widget.rating ?? 4.8;
    final reviewsCount = widget.reviewsCount ?? 0;
    final yearsOfExperience = widget.yearsOfExperience ?? 0;
    final patientsCount = widget.patientsCount ?? 0;

    return BlocConsumer<ClinicManagementCubit, ClinicManagementState>(
      listener: (context, state) {
        if (state is GetDoctorAvailabilitySuccess) {
          setState(() {
            _schedules = state.response.schedules;
            final dates = _availableDates;
            if (dates.isNotEmpty && _selectedDate == null) {
              _selectedDate = dates.first;
            }
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is GetDoctorAvailabilityLoading;
        final dates = _availableDates;
        final currentSchedule =
            _selectedDate != null ? _scheduleForDate(_selectedDate!) : null;
        final timeSlots = currentSchedule != null
            ? _generateTimeSlots(currentSchedule)
            : <String>[];

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

                  // ── Select Date ──────────────────────────────────────────
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
                        if (dates.isNotEmpty)
                          TextButton(
                            onPressed: () async {
                              final dateSet = dates
                                  .map(
                                    (d) => DateTime(d.year, d.month, d.day),
                                  )
                                  .toSet();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate ?? dates.first,
                                firstDate: dates.first,
                                lastDate: dates.last,
                                selectableDayPredicate: (d) => dateSet.any(
                                  (sd) =>
                                      sd.year == d.year &&
                                      sd.month == d.month &&
                                      sd.day == d.day,
                                ),
                              );
                              if (picked != null) {
                                setState(() {
                                  _selectedDate = picked;
                                  _selectedTime = null;
                                });
                              }
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

                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (dates.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: Text(
                        'No available dates for this doctor.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    SizedBox(
                      height: 84,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: dates.length,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final d = dates[index];
                          final selected =
                              _selectedDate != null &&
                              d.year == _selectedDate!.year &&
                              d.month == _selectedDate!.month &&
                              d.day == _selectedDate!.day;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedDate = d;
                              _selectedTime = null;
                            }),
                            child: Container(
                              width: 68,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.skyBlue
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.skyBlue
                                      : Colors.grey.shade200,
                                ),
                                boxShadow: [
                                  if (!selected)
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.03,
                                      ),
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
                                      fontSize: 12,
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

                  // ── Consultation Type ────────────────────────────────────
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
                        final title =
                            _consultationTypeLabels[typeKey] ?? typeKey;
                        final selected = _selectedConsultationType == typeKey;
                        return GestureDetector(
                          onTap: () => setState(
                            () => _selectedConsultationType = typeKey,
                          ),
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
                                color: selected
                                    ? Colors.white
                                    : AppColors.deepNavy,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Available Time ───────────────────────────────────────
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

                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_selectedDate == null || timeSlots.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Text(
                        _selectedDate == null
                            ? 'Select a date to see available times.'
                            : 'No time slots available for this day.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: timeSlots.map((t) {
                          final isSelected = _selectedTime == t;
                          return GestureDetector(
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
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
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
                onPressed: _selectedTime == null || _selectedDate == null
                    ? null
                    : () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.bookingInformation,
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
                            'consultationFee': _feeForType(_selectedConsultationType),
                            'consultationType': _selectedConsultationType,
                            'selectedDate': _formatDateKey(_selectedDate!),
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
      },
    );
  }
}

const Map<String, String> _consultationTypeLabels = {
  'InClinic': 'Clinic Consultation',
  'VideoCall': 'Online Consultation',
  'HomeVisit': 'Home Visit',
  'FollowUp': 'Follow Up',
  'Emergency': 'Emergency Case',
};
