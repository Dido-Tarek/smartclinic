import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_request_model.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_response_model.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_cubit.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_state.dart';

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
  int? _clinicId;
  bool _isOwner = false;
  String? _currentDoctorId;
  bool _initialized = false;

  // Doctor list from employment requests (for dropdown)
  List<EmploymentRequestModel> _doctors = [];
  String? _selectedDoctorId;

  // Loaded schedules for the selected doctor
  List<ScheduleModel> _schedules = [];

  // Session-level cache: survives page navigation within the same app session.
  // Key = '${clinicId}_${scheduleId}'. Populated on AddScheduleSuccess so that
  // the correct maxPatientsPerShift / time / doctor values are merged back into
  // whatever getDoctorAvailability returns (which may omit those fields).
  static final Map<String, Map<String, Object>> _scheduleCache = {};

  static String _cacheKey(int? clinicId, int? scheduleId) =>
      '${clinicId}_$scheduleId';

  // Add-form
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  String _selectedDay = 'Monday';
  double _maxPatients = 20;

  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _clinicId = widget.clinicId;
    _isOwner = widget.isOwner ?? false;
    _currentDoctorId = widget.currentDoctorId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    if (_clinicId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _clinicId ??= args['clinicId'] as int?;
        _isOwner = args['isOwner'] as bool? ?? _isOwner;
        _currentDoctorId ??= args['currentDoctorId'] as String?;
      }
    }

    // Load doctor list first; schedules load after a doctor is auto-selected.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ClinicManagementCubit>().getMyEmploymentRequests();
    });
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  String? get _selectedDoctorName {
    if (_selectedDoctorId == null) return null;
    for (final d in _doctors) {
      if (d.doctorId == _selectedDoctorId) return d.doctorName;
    }
    return null;
  }

  void _loadSchedules() {
    if (_selectedDoctorId != null && mounted) {
      context.read<ClinicManagementCubit>().getDoctorAvailability(
        _selectedDoctorId!,
      );
    }
  }

  void _onDoctorSelected(String? doctorId) {
    if (doctorId == null || doctorId == _selectedDoctorId) return;
    setState(() => _selectedDoctorId = doctorId);
    context.read<ClinicManagementCubit>().getDoctorAvailability(doctorId);
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      final hh = picked.hour.toString().padLeft(2, '0');
      final mm = picked.minute.toString().padLeft(2, '0');
      ctrl.text = '$hh:$mm';
    }
  }

  void _submit() {
    if (_clinicId == null) {
      _snack('No clinic selected', error: true);
      return;
    }
    if (_startCtrl.text.isEmpty || _endCtrl.text.isEmpty) {
      _snack('Pick start and end time', error: true);
      return;
    }
    context.read<ClinicManagementCubit>().addSchedule(
      AddScheduleRequestModel(
        clinicId: _clinicId!,
        dayOfWeek: _selectedDay,
        startTime: _startCtrl.text,
        endTime: _endCtrl.text,
        maxPatientsPerShift: _maxPatients.round(),
      ),
    );
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.error : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClinicManagementCubit, ClinicManagementState>(
      listener: (context, state) {
        if (state is GetMyEmploymentRequestsSuccess) {
          final all = state.response.requests.toList();
          debugPrint('[Schedule] total requests from API: ${all.length}');
          for (final r in all) {
            debugPrint(
              '[Schedule]  → doctorId=${r.doctorId}  clinicId=${r.clinicId}  name=${r.doctorName}',
            );
          }
          debugPrint(
            '[Schedule] _clinicId=$_clinicId  _isOwner=$_isOwner  _currentDoctorId=$_currentDoctorId',
          );

          // Step 1: clinic filter — fall back to full list when clinicId is
          // absent from the API response (all nulls).
          var list = all;
          if (_clinicId != null) {
            final byClinic = all.where((r) => r.clinicId == _clinicId).toList();
            debugPrint('[Schedule] after clinicId filter: ${byClinic.length}');
            if (byClinic.isNotEmpty) list = byClinic;
          }

          // Step 2: staff see only themselves — fall back if the doctorId
          // in the request doesn't match (avoids an empty list on ID mismatch).
          if (!_isOwner && _currentDoctorId != null) {
            final selfOnly = list
                .where((r) => r.doctorId == _currentDoctorId)
                .toList();
            debugPrint('[Schedule] after staff filter: ${selfOnly.length}');
            if (selfOnly.isNotEmpty) list = selfOnly;
          }

          // Step 3: deduplicate — use doctorName as fallback key when
          // doctorId is absent from the API response.
          final seen = <String>{};
          final unique = list.where((r) {
            final key = r.doctorId ?? r.doctorName ?? '';
            return key.isNotEmpty && seen.add(key);
          }).toList();

          // Step 4: patch null doctorIds. The API sometimes omits doctorId on
          // employment requests. For staff the session userId IS their doctorId.
          final doctors = unique.map((r) {
            if (r.doctorId != null) return r;
            final fallbackId = !_isOwner ? _currentDoctorId : null;
            if (fallbackId == null) return r;
            return EmploymentRequestModel(
              id: r.id,
              doctorId: fallbackId,
              doctorName: r.doctorName,
              clinicId: r.clinicId ?? _clinicId,
              clinicName: r.clinicName,
              status: r.status,
              feedback: r.feedback,
              inClinicFee: r.inClinicFee,
              homeVisitFee: r.homeVisitFee,
              onlineFee: r.onlineFee,
              followUpFee: r.followUpFee,
              emergencyFee: r.emergencyFee,
              sessionDuration: r.sessionDuration,
              schedules: r.schedules,
              createdAt: r.createdAt,
            );
          }).toList();

          debugPrint(
            '[Schedule] final doctors: ${doctors.map((d) => '${d.doctorName}(${d.doctorId})').toList()}',
          );

          setState(() {
            _doctors = doctors;
            if (_selectedDoctorId == null && doctors.isNotEmpty) {
              _selectedDoctorId = doctors.first.doctorId;
            }
          });
          if (_selectedDoctorId != null) _loadSchedules();
        }

        if (state is GetMyEmploymentRequestsFailure) {
          debugPrint(
            '[Schedule] getMyEmploymentRequests FAILED: ${state.errorMessage}',
          );
          _snack('Failed to load doctors: ${state.errorMessage}', error: true);
        }

        if (state is GetDoctorAvailabilitySuccess) {
          final docName = _selectedDoctorName;
          final enriched = state.response.schedules.map((s) {
            final cached = _scheduleCache[_cacheKey(_clinicId, s.id)];
            final start = (s.startTime != null && s.startTime!.isNotEmpty)
                ? s.startTime
                : cached?['startTime'] as String?;
            final end = (s.endTime != null && s.endTime!.isNotEmpty)
                ? s.endTime
                : cached?['endTime'] as String?;
            final day = (s.dayOfWeek != null && s.dayOfWeek!.isNotEmpty)
                ? s.dayOfWeek
                : cached?['dayOfWeek'] as String?;
            final max =
                (s.maxPatientsPerShift != null && s.maxPatientsPerShift! > 0)
                ? s.maxPatientsPerShift
                : (cached?['maxPatientsPerShift'] as int?);
            final name = docName ?? cached?['doctorName'] as String?;
            // Refresh cache entry with best-known values
            if (s.id != null) {
              _scheduleCache[_cacheKey(_clinicId, s.id)] = {
                if (start != null) 'startTime': start,
                if (end != null) 'endTime': end,
                if (day != null) 'dayOfWeek': day,
                if (max != null) 'maxPatientsPerShift': max,
                if (name != null) 'doctorName': name,
              };
            }
            return ScheduleModel(
              id: s.id,
              clinicId: s.clinicId ?? _clinicId,
              dayOfWeek: day,
              startTime: start,
              endTime: end,
              maxPatientsPerShift: max,
              doctorName: name,
            );
          }).toList();
          setState(() => _schedules = enriched);
        }

        if (state is AddScheduleSuccess) {
          _snack('Schedule added');
          final r = state.response;
          final start = (r.startTime != null && r.startTime!.isNotEmpty)
              ? r.startTime!
              : _startCtrl.text;
          final end = (r.endTime != null && r.endTime!.isNotEmpty)
              ? r.endTime!
              : _endCtrl.text;
          final day = (r.dayOfWeek != null && r.dayOfWeek!.isNotEmpty)
              ? r.dayOfWeek!
              : _selectedDay;
          final max =
              (r.maxPatientsPerShift != null && r.maxPatientsPerShift! > 0)
              ? r.maxPatientsPerShift!
              : _maxPatients.round();
          final docName = _selectedDoctorName;
          // Persist so the next getDoctorAvailability call can fill in missing fields
          if (r.id != null) {
            _scheduleCache[_cacheKey(_clinicId, r.id)] = {
              'startTime': start,
              'endTime': end,
              'dayOfWeek': day,
              'maxPatientsPerShift': max,
              if (docName != null) 'doctorName': docName,
            };
          }
          final newSchedule = ScheduleModel(
            id: r.id,
            clinicId: r.clinicId ?? _clinicId,
            dayOfWeek: day,
            startTime: start,
            endTime: end,
            maxPatientsPerShift: max,
            doctorName: docName,
          );
          setState(() {
            _schedules = [..._schedules, newSchedule];
            _startCtrl.clear();
            _endCtrl.clear();
          });
        }
        if (state is AddScheduleFailure)
          _snack(state.errorMessage, error: true);

        if (state is DeleteScheduleSuccess) {
          _snack('Schedule deleted');
          _scheduleCache.remove(_cacheKey(_clinicId, state.deletedId));
          setState(() {
            _schedules = _schedules
                .where((s) => s.id != state.deletedId)
                .toList();
          });
        }
        if (state is DeleteScheduleFailure)
          _snack(state.errorMessage, error: true);
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: CustomAppBar(
            title: 'Shift Control',
            onNotificationTap: () {},
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _AddScheduleCard(
                doctors: _doctors,
                selectedDoctorId: _selectedDoctorId,
                loadingDoctors: state is GetMyEmploymentRequestsLoading,
                startCtrl: _startCtrl,
                endCtrl: _endCtrl,
                selectedDay: _selectedDay,
                days: _days,
                maxPatients: _maxPatients,
                addingSchedule: state is AddScheduleLoading,
                onDoctorSelected: _onDoctorSelected,
                onDaySelected: (d) => setState(() => _selectedDay = d),
                onPickStart: () => _pickTime(_startCtrl),
                onPickEnd: () => _pickTime(_endCtrl),
                onMaxPatientsChanged: (v) => setState(() => _maxPatients = v),
                onSubmit: _submit,
              ),
              const SizedBox(height: 24),
              _ScheduleListSection(
                schedules: _schedules,
                loadingSchedules: state is GetDoctorAvailabilityLoading,
                state: state,
                onDelete: (id) =>
                    context.read<ClinicManagementCubit>().deleteSchedule(id),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Schedule Card
// ─────────────────────────────────────────────────────────────────────────────

class _AddScheduleCard extends StatelessWidget {
  final List<EmploymentRequestModel> doctors;
  final String? selectedDoctorId;
  final bool loadingDoctors;
  final TextEditingController startCtrl;
  final TextEditingController endCtrl;
  final String selectedDay;
  final List<String> days;
  final double maxPatients;
  final bool addingSchedule;
  final ValueChanged<String?> onDoctorSelected;
  final ValueChanged<String> onDaySelected;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final ValueChanged<double> onMaxPatientsChanged;
  final VoidCallback onSubmit;

  const _AddScheduleCard({
    required this.doctors,
    required this.selectedDoctorId,
    required this.loadingDoctors,
    required this.startCtrl,
    required this.endCtrl,
    required this.selectedDay,
    required this.days,
    required this.maxPatients,
    required this.addingSchedule,
    required this.onDoctorSelected,
    required this.onDaySelected,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onMaxPatientsChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: AppColors.blueAction,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Add New Schedule',
                style: TextStyle(
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Doctor selector
          const Text(
            'Select Doctor',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          _DoctorDropdown(
            doctors: doctors,
            selectedDoctorId: selectedDoctorId,
            loading: loadingDoctors,
            onChanged: onDoctorSelected,
          ),
          const SizedBox(height: 16),

          // Day selector
          const Text(
            'Day of Week',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: days.map((day) {
              final short = day.substring(0, 3);
              final sel = selectedDay == day;
              return GestureDetector(
                onTap: () => onDaySelected(day),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.blueAction : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: sel
                          ? AppColors.blueAction
                          : AppColors.textSecondary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    short,
                    style: TextStyle(
                      color: sel ? Colors.white : AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Time pickers
          Row(
            children: [
              Expanded(
                child: _TimeField(
                  label: 'Start Time',
                  controller: startCtrl,
                  onTap: onPickStart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeField(
                  label: 'End Time',
                  controller: endCtrl,
                  onTap: onPickEnd,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Max patients
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Max Patients Per Shift',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${maxPatients.round()}',
                style: const TextStyle(
                  color: AppColors.blueAction,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Slider(
            value: maxPatients,
            min: 1,
            max: 60,
            divisions: 59,
            activeColor: AppColors.blueAction,
            inactiveColor: AppColors.textSecondary.withValues(alpha: 0.2),
            onChanged: onMaxPatientsChanged,
          ),
          const SizedBox(height: 8),

          // Submit
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: addingSchedule ? null : onSubmit,
              icon: addingSchedule
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline, size: 18),
              label: const Text(
                'Create Schedule',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepNavy,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.deepNavy.withValues(
                  alpha: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Doctor dropdown with live search
// ─────────────────────────────────────────────────────────────────────────────

class _DoctorDropdown extends StatefulWidget {
  final List<EmploymentRequestModel> doctors;
  final String? selectedDoctorId;
  final bool loading;
  final ValueChanged<String?> onChanged;

  const _DoctorDropdown({
    required this.doctors,
    required this.selectedDoctorId,
    required this.loading,
    required this.onChanged,
  });

  @override
  State<_DoctorDropdown> createState() => _DoctorDropdownState();
}

class _DoctorDropdownState extends State<_DoctorDropdown> {
  final _searchCtrl = TextEditingController();
  final _layerLink = LayerLink();
  OverlayEntry? _overlay;
  List<EmploymentRequestModel> _filtered = [];
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _filtered = widget.doctors;
  }

  @override
  void didUpdateWidget(_DoctorDropdown old) {
    super.didUpdateWidget(old);
    if (old.doctors != widget.doctors) {
      _filtered = widget.doctors;
      _searchCtrl.clear();
      _overlay?.markNeedsBuild();
    }
  }

  @override
  void dispose() {
    _closeOverlay();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter(String q) {
    final query = q.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? widget.doctors
          : widget.doctors
                .where(
                  (d) => (d.doctorName ?? '').toLowerCase().contains(query),
                )
                .toList();
    });
    _overlay?.markNeedsBuild();
  }

  void _openOverlay() {
    if (_open) return;
    _open = true;
    _filtered = widget.doctors;

    _overlay = OverlayEntry(
      builder: (_) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _closeOverlay,
          child: Stack(
            children: [
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(0, 54),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.textSecondary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: _filtered.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No doctors found',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) {
                              final doc = _filtered[i];
                              final selected =
                                  doc.doctorId == widget.selectedDoctorId;
                              return InkWell(
                                onTap: () {
                                  widget.onChanged(doc.doctorId);
                                  _closeOverlay();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  color: selected
                                      ? AppColors.blueAction.withValues(
                                          alpha: 0.08,
                                        )
                                      : Colors.transparent,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.person_outline,
                                        size: 18,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          doc.doctorName ?? 'Unknown Doctor',
                                          style: TextStyle(
                                            color: selected
                                                ? AppColors.blueAction
                                                : AppColors.textPrimary,
                                            fontWeight: selected
                                                ? FontWeight.w700
                                                : FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (selected)
                                        const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: AppColors.blueAction,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlay!);
  }

  void _closeOverlay() {
    _overlay?.remove();
    _overlay = null;
    _open = false;
    _searchCtrl.clear();
    if (mounted) setState(() => _filtered = widget.doctors);
  }

  String get _displayName {
    if (widget.selectedDoctorId == null) return '';
    final match = widget.doctors
        .where((d) => d.doctorId == widget.selectedDoctorId)
        .toList();
    return match.isNotEmpty ? (match.first.doctorName ?? '') : '';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _open ? _closeOverlay : _openOverlay,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: _open
                  ? AppColors.blueAction
                  : AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: _open
              ? Row(
                  children: [
                    const Icon(
                      Icons.search,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        onChanged: _filter,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search doctors...',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _closeOverlay,
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _displayName.isNotEmpty
                            ? _displayName
                            : 'Select a medical professional...',
                        style: TextStyle(
                          color: _displayName.isNotEmpty
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Time field
// ─────────────────────────────────────────────────────────────────────────────

class _TimeField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;

  const _TimeField({
    required this.label,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: '--:--',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            suffixIcon: const Icon(Icons.access_time, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Schedule list section
// ─────────────────────────────────────────────────────────────────────────────

class _ScheduleListSection extends StatelessWidget {
  final List<ScheduleModel> schedules;
  final bool loadingSchedules;
  final ClinicManagementState state;
  final ValueChanged<int> onDelete;

  const _ScheduleListSection({
    required this.schedules,
    required this.loadingSchedules,
    required this.state,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Existing Schedules',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (!loadingSchedules)
              Text(
                '${schedules.length} shift${schedules.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (loadingSchedules)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (schedules.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 48,
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No schedules yet.\nSelect a doctor and add shifts above.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...schedules.map(
            (s) => _ScheduleCard(
              schedule: s,
              doctorName: s.doctorName,
              deleting:
                  state is DeleteScheduleLoading &&
                  (state as DeleteScheduleLoading).deletingId == s.id,
              onDelete: () => onDelete(s.id ?? 0),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Schedule card
// ─────────────────────────────────────────────────────────────────────────────

class _ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final bool deleting;
  final VoidCallback onDelete;
  final String? doctorName;

  const _ScheduleCard({
    required this.schedule,
    required this.deleting,
    required this.onDelete,
    this.doctorName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          // Day badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.blueAction.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              (schedule.dayOfWeek ?? '').length >= 3
                  ? schedule.dayOfWeek!.substring(0, 3)
                  : (schedule.dayOfWeek ?? ''),
              style: const TextStyle(
                color: AppColors.blueAction,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${schedule.startTime ?? '--:--'}  →  ${schedule.endTime ?? '--:--'}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                if (doctorName != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          doctorName!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Max ${schedule.maxPatientsPerShift ?? 0} patients',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Delete
          if (deleting)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 22,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
