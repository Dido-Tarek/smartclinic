import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/features/appointments/presentation/manager/appointment_cubit.dart';
import 'package:smartclinic/features/appointments/presentation/manager/appointment_state.dart';
import 'package:smartclinic/features/prescriptions/data/model/prescription_request_model.dart';
import 'package:smartclinic/features/prescriptions/data/model/prescriptions_resoponse_model.dart';
import 'package:smartclinic/features/prescriptions/presentation/manager/prescriptions_cubit.dart';
import 'package:smartclinic/features/prescriptions/presentation/manager/prescriptions_state.dart';
import 'package:smartclinic/injection_dependency.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final UserSession _userSession;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _userSession = getIt<UserSession>();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchController.addListener(() {
      if (mounted) setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PrescriptionsCubit>().getMyPrescriptions();
      context.read<AppointmentsCubit>().getMyAppointments();
    });
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool _isPrescriptionActive(PrescriptionModel p) {
    if (p.createdAt == null || p.medicines.isEmpty) return true;
    final created = DateTime.tryParse(p.createdAt!) ?? DateTime.now();
    final maxDays = p.medicines.fold<int>(0, (prev, m) => m.days > prev ? m.days : prev);
    return DateTime.now().isBefore(created.add(Duration(days: maxDays)));
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  int _resolveUpcomingCount(AppointmentsState state) {
    if (state is! GetMyAppointmentsSuccess) return 0;
    return state.response.appointments.where((a) {
      final s = (a.status ?? '').trim().toLowerCase();
      return s.isEmpty ||
          s.contains('upcoming') ||
          s.contains('scheduled') ||
          s.contains('pending') ||
          s.contains('confirmed') ||
          s.contains('booked') ||
          s.contains('accepted');
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = _userSession.userRole.isDoctor;
    final isPatient = _userSession.userRole.isPatient;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CustomAppBar(
        title: 'Prescriptions',
        showBackButton: true,
        showNotification: true,
        onNotificationTap: () =>
            Navigator.pushNamed(context, AppRoutes.notifications),
      ),
      floatingActionButton: _buildFab(isDoctor, isPatient),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveTab(),
                _buildHistoryTab(isDoctor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFab(bool isDoctor, bool isPatient) {
    if (_tabController.index != 1 || !isDoctor) return null;
    return FloatingActionButton(
      backgroundColor: AppColors.deepNavy,
      onPressed: () {
        // Navigator.pushNamed(context, AppRoutes.addPrescription);
      },
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.scaffoldBg,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.deepNavy,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.deepNavy,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        tabs: const [
          Tab(text: 'Active'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  // ── Active tab ──────────────────────────────────────────────────────────────

  Widget _buildActiveTab() {
    return BlocBuilder<PrescriptionsCubit, PrescriptionsState>(
      builder: (context, prescState) {
        return BlocBuilder<AppointmentsCubit, AppointmentsState>(
          builder: (context, apptState) {
            final fullName = _userSession.fullName?.trim() ?? '';
            final upcomingCount = _resolveUpcomingCount(apptState);
            final greeting = _getGreeting();

            final isLoading = prescState is GetMyPrescriptionsLoading;
            List<PrescriptionModel> activePrescriptions = [];

            if (prescState is GetMyPrescriptionsSuccess) {
              activePrescriptions = prescState.response.prescriptions
                  .where(_isPrescriptionActive)
                  .toList()
                ..sort((a, b) {
                  final aDate =
                      DateTime.tryParse(a.createdAt ?? '') ?? DateTime(2000);
                  final bDate =
                      DateTime.tryParse(b.createdAt ?? '') ?? DateTime(2000);
                  return bDate.compareTo(aDate);
                });
              if (activePrescriptions.length > 3) {
                activePrescriptions = activePrescriptions.sublist(0, 3);
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGoodMorningCard(greeting, fullName, upcomingCount),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Recent Activity'),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (activePrescriptions.isEmpty)
                    _buildEmptyState()
                  else
                    ...activePrescriptions.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPrescriptionCard(p),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── History tab ─────────────────────────────────────────────────────────────

  Widget _buildHistoryTab(bool isDoctor) {
    return BlocBuilder<PrescriptionsCubit, PrescriptionsState>(
      builder: (context, state) {
        if (state is GetMyPrescriptionsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<PrescriptionModel> allPrescriptions = [];
        if (state is GetMyPrescriptionsSuccess) {
          allPrescriptions = List<PrescriptionModel>.from(
            state.response.prescriptions,
          )..sort((a, b) {
            final aDate =
                DateTime.tryParse(a.createdAt ?? '') ?? DateTime(2000);
            final bDate =
                DateTime.tryParse(b.createdAt ?? '') ?? DateTime(2000);
            return bDate.compareTo(aDate); // newest first
          });
        }

        if (allPrescriptions.isEmpty && state is! GetMyPrescriptionsLoading) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _buildSearchBar(),
              ),
              Expanded(child: _buildEmptyState()),
            ],
          );
        }

        final filtered = _searchQuery.isEmpty
            ? allPrescriptions
            : allPrescriptions.where((p) {
                final name = _userSession.userRole.isDoctor
                    ? (p.patientName ?? '').toLowerCase()
                    : (p.doctorName ?? '').toLowerCase();
                return name.contains(_searchQuery);
              }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildSearchBar(),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      children: [
                        ...filtered.map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildPrescriptionCard(p),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildEndOfListContainer(),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  // ── Shared widgets ──────────────────────────────────────────────────────────

  Widget _buildGoodMorningCard(
    String greeting,
    String fullName,
    int appointmentsCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.deepNavy,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wb_sunny_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, ${fullName.isEmpty ? 'Doctor' : fullName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You have $appointmentsCount appointment${appointmentsCount != 1 ? 's' : ''} today.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.appointments),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
              ),
              child: const Text(
                'View Appointments',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: _userSession.userRole.isDoctor
            ? 'Search by patient name...'
            : 'Search by doctor name...',
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                onPressed: () => _searchController.clear(),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.skyBlue.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.skyBlue.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.skyBlue),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppImages.emptyPrescriptions,
            width: 180,
            height: 180,
          ),
          const SizedBox(height: 16),
          const Text(
            'No prescriptions found',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndOfListContainer() {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: const Radius.circular(12),
        color: AppColors.textSecondary.withValues(alpha: 0.4),
        strokeWidth: 1.5,
        dashPattern: const [6, 4],
        padding: EdgeInsets.zero,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 40,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'End of list. Use the search bar above to find\nolder patient records.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ── Prescription card ───────────────────────────────────────────────────────

  Widget _buildPrescriptionCard(PrescriptionModel p) {
    final isActive = _isPrescriptionActive(p);
    final isDoctor = _userSession.userRole.isDoctor;
    final displayName = isDoctor
        ? (p.patientName ?? 'Patient')
        : (p.doctorName ?? 'Doctor');

    final statusColor =
        isActive ? AppColors.success : const Color(0xFF247CFF);
    final statusText = isActive ? 'Active' : 'Completed';

    return GestureDetector(
      onTap: () {
        if (p.id != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.prescriptionDetail,
            arguments: {'id': p.id},
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepNavy.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrayBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isDoctor
                          ? Icons.person_outline
                          : Icons.medical_services_outlined,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (p.diagnosis?.isNotEmpty == true)
                          Text(
                            'Diagnosis: ${p.diagnosis}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
              // Medicines
              if (p.medicines.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  'Medicines',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ...p.medicines.map((m) => _buildMedicineItem(m)),
              ],
              // General instructions
              if (p.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GENERAL INSTRUCTIONS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.deepNavy,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.notes!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineItem(MedicineItemModel medicine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.lightGrayBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${medicine.medicineName} ${medicine.dosage}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                'Every ${medicine.frequency} hours',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Duration: ${medicine.days} day${medicine.days != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              if (medicine.notes?.isNotEmpty == true) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Note: ${medicine.notes}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
