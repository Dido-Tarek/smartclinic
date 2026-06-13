import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_cubit.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_state.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_request_model.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_response_model.dart';

// موديل محلي لتمثيل بيانات المواعيد الحالية
class DoctorScheduleItem {
  final int id;
  final String doctorName;
  final String day;
  final String timeRange;
  final int maxPatients;

  const DoctorScheduleItem({
    required this.id,
    required this.doctorName,
    required this.day,
    required this.timeRange,
    required this.maxPatients,
  });
}

class ClinicScheduleManagementView extends StatefulWidget {
  final int? clinicId;
  final bool? isOwner;
  final String? currentDoctorId;

  const ClinicScheduleManagementView({
    super.key,
    this.clinicId,
    this.isOwner,
    this.currentDoctorId,
  });

  @override
  State<ClinicScheduleManagementView> createState() =>
      _ClinicScheduleManagementViewState();
}

class _ClinicScheduleManagementViewState
    extends State<ClinicScheduleManagementView> {
  final TextEditingController _searchController = TextEditingController();

  // داتا تجريبية تحاكي الموجودة في السكتش المرفق
  final List<DoctorScheduleItem> _allSchedules = const [
    DoctorScheduleItem(
      id: 1,
      doctorName: 'Dr. Sarah Jenkins',
      day: 'Monday',
      timeRange: '08:00 AM - 02:00 PM',
      maxPatients: 24,
    ),
    DoctorScheduleItem(
      id: 2,
      doctorName: 'Dr. Michael Chen',
      day: 'Wednesday',
      timeRange: '01:00 PM - 07:00 PM',
      maxPatients: 18,
    ),
    DoctorScheduleItem(
      id: 3,
      doctorName: 'Dr. Elena Rodriguez',
      day: 'Tuesday',
      timeRange: '09:00 AM - 05:00 PM',
      maxPatients: 30,
    ),
    DoctorScheduleItem(
      id: 4,
      doctorName: 'Dr. Tarek Ahmed',
      day: 'Thursday',
      timeRange: '10:00 AM - 04:00 PM',
      maxPatients: 20,
    ),
  ];

  List<DoctorScheduleItem> _filteredSchedules = [];
  List<EmploymentRequestModel> _doctors = [];
  String? _selectedDoctorId;
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  int? _clinicId;
  bool _isOwner = false;
  String? _currentDoctorId;
  String _selectedDay = 'Tue';
  double _maxPatientsSlider = 20;

  @override
  void initState() {
    super.initState();
    _filteredSchedules = _allSchedules;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // prefer widget constructor values, fall back to route arguments
    _clinicId = widget.clinicId;
    _isOwner = widget.isOwner ?? false;
    _currentDoctorId = widget.currentDoctorId;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (_clinicId == null && args is Map) {
      _clinicId = args['clinicId'] as int?;
    }
    if (widget.isOwner == null && args is Map) {
      _isOwner = args['isOwner'] as bool? ?? _isOwner;
    }
    if (_currentDoctorId == null && args is Map) {
      _currentDoctorId = args['currentDoctorId'] as String?;
    }

    // request server-side employment/schedules
    if (_clinicId != null) {
      context.read<ClinicManagementCubit>().getMyEmploymentRequests();
    }
  }

  // ميثود الفلترة المحلية بناءً على الاسم المدخل في الـ Search Bar
  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredSchedules = _allSchedules;
      } else {
        _filteredSchedules = _allSchedules
            .where(
              (schedule) => schedule.doctorName.toLowerCase().contains(
                query.trim().toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClinicManagementCubit, ClinicManagementState>(
      listener: (context, state) {
        if (state is GetMyEmploymentRequestsSuccess) {
          // Map received employment requests into schedules list for display
          var requests = state.response.requests
              .where((r) => r.clinicId == _clinicId)
              .toList();

          // If user is staff (not owner) show only their records
          if (!_isOwner && _currentDoctorId != null) {
            requests = requests
                .where((r) => r.doctorId == _currentDoctorId)
                .toList();
          }

          _doctors = requests;

          final generated = <DoctorScheduleItem>[];
          for (final req in requests) {
            for (final s in req.schedules) {
              generated.add(
                DoctorScheduleItem(
                  id: 0,
                  doctorName: req.doctorName ?? 'Unknown',
                  day: s.dayOfWeek,
                  timeRange: '${s.startTime} - ${s.endTime}',
                  maxPatients: s.maxPatients,
                ),
              );
            }
          }

          setState(() {
            _filteredSchedules = generated.isNotEmpty
                ? generated
                : _allSchedules;
          });

          // auto-select first doctor and fetch availability (owner sees all; staff will only see one)
          if (_selectedDoctorId == null && _doctors.isNotEmpty) {
            _selectedDoctorId = _doctors.first.doctorId;
            if (_selectedDoctorId != null) {
              context.read<ClinicManagementCubit>().getDoctorAvailability(
                _selectedDoctorId!,
              );
            }
          }
        }

        if (state is GetDoctorAvailabilitySuccess) {
          final schedules = state.response.schedules;
          final items = schedules
              .map(
                (s) => DoctorScheduleItem(
                  id: s.id ?? 0,
                  doctorName:
                      _doctors
                          .firstWhere(
                            (d) => d.doctorId == _selectedDoctorId,
                            orElse: () => EmploymentRequestModel(
                              doctorId: _selectedDoctorId,
                              clinicId: _clinicId,
                              examinationFee: 0,
                              followUpFee: 0,
                              homeVisitFee: 0,
                              onlineFee: 0,
                              emergencyFee: 0,
                              sessionDuration: 0,
                              schedules: [],
                            ),
                          )
                          .doctorName ??
                      'Doctor',
                  day: s.dayOfWeek ?? '',
                  timeRange: '${s.startTime ?? ''} - ${s.endTime ?? ''}',
                  maxPatients: s.maxPatientsPerShift ?? 0,
                ),
              )
              .toList();

          setState(() {
            _filteredSchedules = items;
          });
        }

        if (state is AddScheduleSuccess) {
          CherryToast.success(
            title: const Text('Success'),
            description: Text('Schedule created successfully'),
          ).show(context);
          // refresh
          if (_clinicId != null)
            context.read<ClinicManagementCubit>().getMyEmploymentRequests();
        }

        if (state is AddScheduleFailure) {
          CherryToast.error(
            title: const Text('Error'),
            description: Text(state.errorMessage),
          ).show(context);
        }

        if (state is DeleteScheduleSuccess) {
          CherryToast.success(
            title: const Text('Deleted'),
            description: Text(state.response.message ?? 'Deleted'),
          ).show(context);
          if (_clinicId != null)
            context.read<ClinicManagementCubit>().getMyEmploymentRequests();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        // الـ AppBar المخصص يظهر متضمناً الـ Back والتنبيهات تلقائياً
        appBar: CustomAppBar(
          title: 'Clinic Admin',
          onNotificationTap: () {
            // فتح الإشعارات
          },
        ),
        body: LayoutBuilder(
          builder: (context, constraints) => SafeArea(
            child: SizedBox(
              height: constraints.maxHeight,
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------------
              // الجزء العلوي الثابت (Fixed Top Part): البحث والفلترة
              // ----------------------------------------------------
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Search Doctor Availability",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  hintText: 'Enter Doctor Name or ID...',
                                  hintStyle: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () =>
                                _onSearchChanged(_searchController.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.deepNavy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Filter'),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.tune,
                              color: AppColors.textPrimary,
                            ),
                            style: IconButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                  color: AppColors.skyBlue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // عنوان قائمة المواعيد الحالية
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Manage Existing Schedules",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "Showing ${_filteredSchedules.length} active shifts",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ----------------------------------------------------
              // الجزء القابل للتمرير (Scrollable Center List)
              // ----------------------------------------------------
              Expanded(
                child: BlocBuilder<ClinicManagementCubit, ClinicManagementState>(
                  builder: (context, state) {
                    if (state is GetDoctorAvailabilityLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    List<DoctorScheduleItem> display = _filteredSchedules;
                    if (state is GetDoctorAvailabilitySuccess) {
                      display = state.response.schedules
                          .map(
                            (s) => DoctorScheduleItem(
                              id: s.id ?? 0,
                              doctorName:
                                  _doctors
                                      .firstWhere(
                                        (d) => d.doctorId == _selectedDoctorId,
                                        orElse: () => EmploymentRequestModel(
                                          doctorId: _selectedDoctorId,
                                          clinicId: _clinicId,
                                          examinationFee: 0,
                                          followUpFee: 0,
                                          homeVisitFee: 0,
                                          onlineFee: 0,
                                          emergencyFee: 0,
                                          sessionDuration: 0,
                                          schedules: [],
                                        ),
                                      )
                                      .doctorName ??
                                  'Doctor',
                              day: s.dayOfWeek ?? '',
                              timeRange:
                                  '${s.startTime ?? ''} - ${s.endTime ?? ''}',
                              maxPatients: s.maxPatientsPerShift ?? 0,
                            ),
                          )
                          .toList();
                    } else if (state is GetMyEmploymentRequestsSuccess) {
                      final requests = state.response.requests
                          .where((r) => r.clinicId == _clinicId)
                          .toList();
                      final generated = <DoctorScheduleItem>[];
                      for (final req in requests) {
                        for (final s in req.schedules) {
                          generated.add(
                            DoctorScheduleItem(
                              id: 0,
                              doctorName: req.doctorName ?? 'Unknown',
                              day: s.dayOfWeek,
                              timeRange: '${s.startTime} - ${s.endTime}',
                              maxPatients: s.maxPatients,
                            ),
                          );
                        }
                      }
                      display = generated.isNotEmpty
                          ? generated
                          : _allSchedules;
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: display.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = display[index];
                        final deleting =
                            state is DeleteScheduleLoading &&
                            state.deletingId == item.id;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.textSecondary.withOpacity(0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.accentBlue
                                    .withOpacity(0.5),
                                child: const Icon(
                                  Icons.medical_services_outlined,
                                  color: AppColors.deepNavy,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.doctorName,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_month,
                                          size: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.day,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            item.timeRange,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 11,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    "Max Patients",
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    "${item.maxPatients}",
                                    style: const TextStyle(
                                      color: AppColors.blueAction,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              deleting
                                  ? const SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.error,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        if (item.id > 0) {
                                          context
                                              .read<ClinicManagementCubit>()
                                              .deleteSchedule(item.id);
                                        } else {
                                          CherryToast.error(
                                            title: const Text('Error'),
                                            description: const Text(
                                              'Unable to delete this schedule',
                                            ),
                                          ).show(context);
                                        }
                                      },
                                    ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // ----------------------------------------------------
              // الجزء السفلي الثابت (Fixed Bottom Section): نموذج الإضافة الجديد والمنطق
              // ----------------------------------------------------
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.add_circle,
                              color: AppColors.blueAction,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Add New Schedule",
                              style: TextStyle(
                                color: AppColors.deepNavy,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        const Text(
                          "Select Doctor",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.textSecondary.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text(
                                "Select a medical professional...",
                                style: TextStyle(fontSize: 13),
                              ),
                              value: _selectedDoctorId,
                              items: _doctors
                                  .map(
                                    (d) => DropdownMenuItem<String>(
                                      value: d.doctorId,
                                      child: Text(d.doctorName ?? 'Doctor'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                setState(() => _selectedDoctorId = v);
                                if (v != null)
                                  context
                                      .read<ClinicManagementCubit>()
                                      .getDoctorAvailability(v);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        const Text(
                          "Day of Week",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                              .map((day) {
                                final isSelected = _selectedDay == day;
                                return InkWell(
                                  onTap: () =>
                                      setState(() => _selectedDay = day),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.blueAction
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.blueAction
                                            : AppColors.textSecondary
                                                  .withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      day,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Start Time",
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextField(
                                    readOnly: true,
                                    controller: _startController,
                                    decoration: InputDecoration(
                                      hintText: '--:-- --',
                                      suffixIcon: const Icon(
                                        Icons.access_time,
                                        size: 18,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                    ),
                                    onTap: () async {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (time != null) {
                                        final formatted = time.format(context);
                                        _startController.text = formatted;
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "End Time",
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextField(
                                    readOnly: true,
                                    controller: _endController,
                                    decoration: InputDecoration(
                                      hintText: '--:-- --',
                                      suffixIcon: const Icon(
                                        Icons.access_time,
                                        size: 18,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                    ),
                                    onTap: () async {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (time != null) {
                                        final formatted = time.format(context);
                                        _endController.text = formatted;
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Max Patients Per Shift",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "${_maxPatientsSlider.round()}",
                              style: const TextStyle(
                                color: AppColors.blueAction,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _maxPatientsSlider,
                          min: 5,
                          max: 50,
                          activeColor: AppColors.blueAction,
                          inactiveColor: AppColors.textSecondary.withOpacity(
                            0.2,
                          ),
                          onChanged: (val) =>
                              setState(() => _maxPatientsSlider = val),
                        ),

                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // create schedule via cubit
                              if (_clinicId == null) {
                                CherryToast.error(
                                  title: const Text('Error'),
                                  description: const Text('No clinic selected'),
                                ).show(context);
                                return;
                              }

                              final start = _startController.text.trim();
                              final end = _endController.text.trim();
                              if (start.isEmpty || end.isEmpty) {
                                CherryToast.error(
                                  title: const Text('Error'),
                                  description: const Text(
                                    'Please pick start and end time',
                                  ),
                                ).show(context);
                                return;
                              }

                              final request = AddScheduleRequestModel(
                                clinicId: _clinicId!,
                                dayOfWeek: _mapDayToFullName(_selectedDay),
                                startTime: start,
                                endTime: end,
                                maxPatientsPerShift: _maxPatientsSlider.round(),
                              );

                              context.read<ClinicManagementCubit>().addSchedule(
                                request,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.deepNavy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.save, size: 18),
                            label: const Text(
                              "Create Schedule",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // بنية بطاقة الملاحظات التوضيحية لجدولة الفترات الزمنية
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accentBlue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.blueAction,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Scheduling Logic",
                                      style: TextStyle(
                                        color: AppColors.deepNavy,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      "Maximum patients are calculated based on 15-minute standard consultation intervals.",
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
        ),
    );
  }

  String _mapDayToFullName(String short) {
    switch (short.toLowerCase()) {
      case 'mon':
      case 'monday':
        return 'Monday';
      case 'tue':
      case 'tues':
      case 'tuesday':
        return 'Tuesday';
      case 'wed':
      case 'wednesday':
        return 'Wednesday';
      case 'thu':
      case 'thur':
      case 'thursday':
        return 'Thursday';
      case 'fri':
      case 'friday':
        return 'Friday';
      case 'sat':
      case 'saturday':
        return 'Saturday';
      case 'sun':
      case 'sunday':
        return 'Sunday';
      default:
        return short; // fallback to whatever was provided
    }
  }
}
