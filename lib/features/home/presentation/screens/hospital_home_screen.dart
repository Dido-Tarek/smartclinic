import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/features/clinic_admin/data/model/clinic_admin_response_model.dart';
import 'package:smartclinic/features/clinic_admin/presentation/manager/clinic_admin_cubit.dart';
import 'package:smartclinic/features/clinic_admin/presentation/manager/clinic_admin_state.dart';
import 'package:smartclinic/injection_dependency.dart';


// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────
class HospitalHomePage extends StatelessWidget {
  final int clinicId;

  // Admin info — pass from your auth/session layer
  final String adminName;
  final String adminRole;
  final String? adminImageUrl;

  const HospitalHomePage({
    super.key,
    required this.clinicId,
    this.adminName = 'Admin',
    this.adminRole = 'Clinic Manager',
    this.adminImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ClinicAdminCubit>()..getFullDashboard(clinicId),
      child: HospitalHomeScreen(
        clinicId: clinicId,
        adminName: adminName,
        adminRole: adminRole,
        adminImageUrl: adminImageUrl,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class HospitalHomeScreen extends StatefulWidget {
  final int clinicId;
  final String adminName;
  final String adminRole;
  final String? adminImageUrl;

  const HospitalHomeScreen({
    super.key,
    required this.clinicId,
    required this.adminName,
    required this.adminRole,
    this.adminImageUrl,
  });

  @override
  State<HospitalHomeScreen> createState() => _HospitalHomeScreenState();
}

class _HospitalHomeScreenState extends State<HospitalHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _invoiceController = TextEditingController();

  // Locally cached dashboard so UI stays visible during refreshes
  ClinicDashboardModel? _dashboard;

  @override
  void dispose() {
    _searchController.dispose();
    _invoiceController.dispose();
    super.dispose();
  }

  void _refresh() =>
      context.read<ClinicAdminCubit>().getFullDashboard(widget.clinicId);

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : AppColors.skyBlue,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Dialogs
  // ─────────────────────────────────────────────────────────────────────────
  void _showFindDoctorSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BlocProvider.value(
        value: context.read<ClinicAdminCubit>(),
        child: _FindDoctorSheet(controller: _searchController),
      ),
    );
  }

  void _showCollectPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BlocProvider.value(
        value: context.read<ClinicAdminCubit>(),
        child: _CollectPaymentSheet(controller: _invoiceController),
      ),
    );
  }

  void _showRemoveDoctorSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BlocProvider.value(
        value: context.read<ClinicAdminCubit>(),
        child: _RemoveDoctorSheet(clinicId: widget.clinicId),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClinicAdminCubit, ClinicAdminState>(
      listener: (context, state) {
        if (state is GetFullDashboardSuccess) {
          setState(() => _dashboard = state.dashboard);
        }
        if (state is GetFullDashboardFailure) {
          _showSnackBar(state.errorMessage, isError: true);
        }
        if (state is CollectPaymentSuccess) {
          _showSnackBar(
              state.response.message ?? 'Payment collected successfully!');
        }
        if (state is CollectPaymentFailure) {
          _showSnackBar(state.errorMessage, isError: true);
        }
        if (state is RemoveDoctorSuccess) {
          _showSnackBar('Doctor removed successfully');
        }
        if (state is RemoveDoctorFailure) {
          _showSnackBar(state.errorMessage, isError: true);
        }
      },
      builder: (context, state) {
        final isLoading = state is GetFullDashboardLoading;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.scaffoldBg,
          drawer: _HospitalDrawer(
            adminName: widget.adminName,
            adminRole: widget.adminRole,
            adminImageUrl: widget.adminImageUrl,
          ),

          // ── AppBar ───────────────────────────────────────────────────────
          appBar: _buildAppBar(),

          body: RefreshIndicator(
            color: AppColors.skyBlue,
            onRefresh: () async => _refresh(),
            child: isLoading && _dashboard == null
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Welcome header ────────────────────────
                              _WelcomeHeader(
                                name: widget.adminName,
                                clinicName:
                                    _dashboard?.clinicName ?? 'Your Clinic',
                              ),
                              const SizedBox(height: 20),

                              // ── Stats grid ────────────────────────────
                              _StatsGrid(dashboard: _dashboard),
                              const SizedBox(height: 24),

                              // ── Quick actions ─────────────────────────
                              _SectionTitle('Quick Actions'),
                              const SizedBox(height: 12),
                              _QuickActionsRow(
                                onFindDoctor: _showFindDoctorSheet,
                                onCollectPayment: _showCollectPaymentSheet,
                                onRemoveDoctor: _showRemoveDoctorSheet,
                                onViewStaff: () =>
                                    context
                                        .read<ClinicAdminCubit>()
                                        .getClinicStaff(widget.clinicId),
                              ),
                              const SizedBox(height: 24),

                              // ── Today's queue ─────────────────────────
                              _SectionTitle("Today's Queue"),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),

                      // Queue list
                      if (_dashboard?.todayQueue.isEmpty ?? true)
                        const SliverToBoxAdapter(child: _EmptyQueue())
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => _QueueTile(
                              entry: _dashboard!.todayQueue[i],
                              onCollect: (id) =>
                                  context
                                      .read<ClinicAdminCubit>()
                                      .collectPayment(id),
                            ),
                            childCount: _dashboard!.todayQueue.length,
                          ),
                        ),

                      // Staff section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: _SectionTitle('Staff Members'),
                        ),
                      ),

                      if (_dashboard?.staff.isEmpty ?? true)
                        const SliverToBoxAdapter(child: _EmptyStaff())
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => _StaffTile(
                              member: _dashboard!.staff[i],
                              onRemove: () => _showRemoveDoctorSheet(),
                            ),
                            childCount: _dashboard!.staff.length,
                          ),
                        ),

                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    // TODO: Replace inner content with your CustomAppBar widget
    // return CustomAppBar(title: 'Dashboard', showNotification: true,
    //   leading: IconButton(icon: Icon(Icons.menu), onPressed: () => _scaffoldKey.currentState?.openDrawer()));
    return AppBar(
      backgroundColor: AppColors.scaffoldBg,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.menu_rounded, color: AppColors.deepNavy),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text(
        'Dashboard',
        style: TextStyle(
          color: AppColors.deepNavy,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: AppColors.deepNavy),
          onPressed: () {
            // TODO: navigate to notifications
          },
        ),
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: AppColors.deepNavy),
          onPressed: _refresh,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Drawer
// ─────────────────────────────────────────────────────────────────────────────
class _HospitalDrawer extends StatelessWidget {
  final String adminName;
  final String adminRole;
  final String? adminImageUrl;

  const _HospitalDrawer({
    required this.adminName,
    required this.adminRole,
    this.adminImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile header ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.deepNavy,
                    AppColors.deepNavy.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 34,
                    backgroundColor:
                        AppColors.skyBlue.withValues(alpha: 0.3),
                    backgroundImage: adminImageUrl != null
                        ? NetworkImage(adminImageUrl!)
                        : null,
                    child: adminImageUrl == null
                        ? Text(
                            adminName.isNotEmpty
                                ? adminName[0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    adminName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    adminRole,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Menu items ─────────────────────────────────────────────
            _DrawerItem(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerItem(
              icon: Icons.person_outline_rounded,
              label: 'My Profile',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigator.pushNamed(context, AppRoutes.profile);
              },
            ),
            _DrawerItem(
              icon: Icons.local_hospital_outlined,
              label: 'Clinic Settings',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigator.pushNamed(context, AppRoutes.clinicSettings);
              },
            ),
            _DrawerItem(
              icon: Icons.schedule_outlined,
              label: 'Manage Schedules',
              onTap: () {
                Navigator.pop(context);
                // TODO: navigate to schedule management
              },
            ),
            _DrawerItem(
              icon: Icons.people_outline_rounded,
              label: 'Staff Management',
              onTap: () {
                Navigator.pop(context);
                // TODO: navigate to staff screen
              },
            ),
            _DrawerItem(
              icon: Icons.receipt_long_outlined,
              label: 'Appointments',
              onTap: () {
                Navigator.pop(context);
                // TODO: navigate to appointments
              },
            ),
            _DrawerItem(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () {
                Navigator.pop(context);
                // TODO: navigate to notifications
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                  color: AppColors.textSecondary.withValues(alpha: 0.15)),
            ),

            _DrawerItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {
                Navigator.pop(context);
                // TODO: navigate to settings
              },
            ),
            _DrawerItem(
              icon: Icons.help_outline_rounded,
              label: 'Help & Support',
              onTap: () {
                Navigator.pop(context);
                // TODO: navigate to help
              },
            ),

            const Spacer(),

            // ── Logout ──────────────────────────────────────────────────
            _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Logout',
              color: Colors.redAccent,
              onTap: () {
                Navigator.pop(context);
                // TODO: clear session then navigate
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.login, (r) => false);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.deepNavy;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: c,
        ),
      ),
      onTap: onTap,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      horizontalTitleGap: 8,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.deepNavy,
        ),
      );
}

class _WelcomeHeader extends StatelessWidget {
  final String name;
  final String clinicName;
  const _WelcomeHeader({required this.name, required this.clinicName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good Morning, $name 👋',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.deepNavy,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          clinicName,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ── Stats grid ────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final ClinicDashboardModel? dashboard;
  const _StatsGrid({this.dashboard});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          icon: Icons.calendar_today_outlined,
          label: "Today's Appointments",
          value: '${dashboard?.todayAppointmentsCount ?? '-'}',
          color: AppColors.skyBlue,
        ),
        _StatCard(
          icon: Icons.people_alt_outlined,
          label: 'Total Patients',
          value: '${dashboard?.totalPatientsCount ?? '-'}',
          color: const Color(0xFF62C47E),
        ),
        _StatCard(
          icon: Icons.medical_services_outlined,
          label: 'Active Doctors',
          value: '${dashboard?.activeDoctorsCount ?? '-'}',
          color: const Color(0xFFE67E22),
        ),
        _StatCard(
          icon: Icons.attach_money_rounded,
          label: "Today's Revenue",
          value: dashboard?.todayRevenue != null
              ? 'EGP ${dashboard!.todayRevenue!.toStringAsFixed(0)}'
              : '-',
          color: const Color(0xFF9B59B6),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepNavy,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick actions row ─────────────────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onFindDoctor;
  final VoidCallback onCollectPayment;
  final VoidCallback onRemoveDoctor;
  final VoidCallback onViewStaff;

  const _QuickActionsRow({
    required this.onFindDoctor,
    required this.onCollectPayment,
    required this.onRemoveDoctor,
    required this.onViewStaff,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.person_search_outlined,
            label: 'Find Doctor',
            color: AppColors.skyBlue,
            onTap: onFindDoctor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.payments_outlined,
            label: 'Collect Payment',
            color: const Color(0xFF62C47E),
            onTap: onCollectPayment,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.person_remove_outlined,
            label: 'Remove Doctor',
            color: Colors.redAccent,
            onTap: onRemoveDoctor,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Queue tile ────────────────────────────────────────────────────────────────
class _QueueTile extends StatelessWidget {
  final QueueEntryModel entry;
  final ValueChanged<int> onCollect;

  const _QueueTile({required this.entry, required this.onCollect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Position badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.skyBlue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${entry.queuePosition ?? '-'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.skyBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Patient info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.patientName ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.appointmentTime ?? ''} • ${entry.type ?? ''}',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Status + collect button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusChip(status: entry.status),
              if (entry.status?.toLowerCase() != 'paid' && entry.id != null)
                GestureDetector(
                  onTap: () => onCollect(entry.id!),
                  child: Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF62C47E).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFF62C47E)
                              .withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      'Collect',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String? status;
  const _StatusChip({this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status?.toLowerCase()) {
      case 'paid':
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        break;
      case 'pending':
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE67E22);
        break;
      case 'arrived':
        bg = AppColors.skyBlue.withValues(alpha: 0.12);
        fg = AppColors.skyBlue;
        break;
      default:
        bg = Colors.grey.shade100;
        fg = AppColors.textSecondary;
    }
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status ?? 'Unknown',
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

// ── Staff tile ────────────────────────────────────────────────────────────────
class _StaffTile extends StatelessWidget {
  final StaffMemberModel member;
  final VoidCallback onRemove;

  const _StaffTile({required this.member, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.skyBlue.withValues(alpha: 0.15),
            backgroundImage: member.imageUrl != null
                ? NetworkImage(member.imageUrl!)
                : null,
            child: member.imageUrl == null
                ? Text(
                    member.name?.isNotEmpty == true
                        ? member.name![0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.skyBlue),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepNavy,
                  ),
                ),
                Text(
                  '${member.role ?? ''} • ${member.specialization ?? ''}',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            color: AppColors.textSecondary,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

// ── Empty states ──────────────────────────────────────────────────────────────
class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(
          child: Text(
            'No patients in the queue today',
            style: TextStyle(
                fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
      );
}

class _EmptyStaff extends StatelessWidget {
  const _EmptyStaff();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(
          child: Text(
            'No staff members found',
            style: TextStyle(
                fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheets
// ─────────────────────────────────────────────────────────────────────────────

class _FindDoctorSheet extends StatelessWidget {
  final TextEditingController controller;
  const _FindDoctorSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          const SizedBox(height: 16),
          Text('Find Doctor',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepNavy)),
          const SizedBox(height: 4),
          Text('Search by phone number or email',
              style:
                  TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          _SheetTextField(
            controller: controller,
            hint: 'Enter phone or email',
            icon: Icons.search_rounded,
          ),
          const SizedBox(height: 16),

          // Results
          BlocBuilder<ClinicAdminCubit, ClinicAdminState>(
            builder: (context, state) {
              if (state is FindDoctorLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is FindDoctorSuccess &&
                  state.response.doctors.isNotEmpty) {
                return Column(
                  children: state.response.doctors
                      .map((d) => ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.skyBlue
                                  .withValues(alpha: 0.15),
                              child: Text(d.name?[0] ?? '?',
                                  style: TextStyle(
                                      color: AppColors.skyBlue,
                                      fontWeight: FontWeight.w700)),
                            ),
                            title: Text(d.name ?? ''),
                            subtitle: Text(d.specialization ?? ''),
                            trailing: Icon(Icons.arrow_forward_ios,
                                size: 14,
                                color: AppColors.textSecondary),
                          ))
                      .toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.skyBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: () =>
                  context.read<ClinicAdminCubit>().findDoctor(controller.text),
              child: const Text('Search',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectPaymentSheet extends StatelessWidget {
  final TextEditingController controller;
  const _CollectPaymentSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          const SizedBox(height: 16),
          Text('Collect Payment',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepNavy)),
          const SizedBox(height: 20),
          _SheetTextField(
            controller: controller,
            hint: 'Enter Invoice ID',
            icon: Icons.receipt_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          BlocBuilder<ClinicAdminCubit, ClinicAdminState>(
            builder: (_, state) {
              final isLoading = state is CollectPaymentLoading;
              return SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF62C47E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          final id = int.tryParse(controller.text.trim());
                          if (id == null) return;
                          context
                              .read<ClinicAdminCubit>()
                              .collectPayment(id);
                          Navigator.pop(context);
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Collect',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RemoveDoctorSheet extends StatelessWidget {
  final int clinicId;
  final _doctorIdController = TextEditingController();

  _RemoveDoctorSheet({required this.clinicId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          const SizedBox(height: 16),
          Text('Remove Doctor',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepNavy)),
          const SizedBox(height: 4),
          Text('Enter the Doctor ID to remove them from this clinic',
              style:
                  TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          _SheetTextField(
            controller: _doctorIdController,
            hint: 'Doctor ID',
            icon: Icons.person_remove_outlined,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: () {
                final doctorId = _doctorIdController.text.trim();
                if (doctorId.isEmpty) return;
                context.read<ClinicAdminCubit>().removeDoctor(
                      clinicId: clinicId,
                      doctorId: doctorId,
                    );
                Navigator.pop(context);
              },
              child: const Text('Remove',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared sheet helpers ──────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _SheetTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.deepNavy.withValues(alpha: 0.12)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: AppColors.deepNavy, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5)),
          prefixIcon:
              Icon(icon, color: AppColors.skyBlue, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}