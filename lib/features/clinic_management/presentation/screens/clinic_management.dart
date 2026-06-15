import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/injection_dependency.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_cubit.dart';
import 'package:smartclinic/features/clinic_management/presentation/manager/clinic_management_state.dart';
import 'package:smartclinic/features/clinic_management/data/model/clinic_response_model.dart';
import 'package:smartclinic/core/routes/app_routes.dart';

// Local lightweight view model is handled by ClinicModel from API

class ClinicManagementPage extends StatefulWidget {
  const ClinicManagementPage({super.key});

  @override
  State<ClinicManagementPage> createState() => _ClinicManagementPageState();
}

class _ClinicManagementPageState extends State<ClinicManagementPage> {
  final List<ClinicModel> _clinics = <ClinicModel>[];
  int _receivedEmploymentCount = 0;

  ClinicModel? _selectedClinic;
  late final ClinicManagementCubit _cubit;
  late final UserSession _userSession;

  @override
  void initState() {
    super.initState();
    _userSession = getIt<UserSession>();
    _cubit = getIt<ClinicManagementCubit>();
    _cubit.getMyClinics();
    _cubit.getMyEmploymentRequests();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure method symbol is available before heavy parsing by analyzer
    Widget _buildClinicInfoCardWrapper() => _buildClinicInfoCardImpl();
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<ClinicManagementCubit, ClinicManagementState>(
        listener: (context, state) {
          if (state is GetMyClinicsSuccess) {
            final fetched = List<ClinicModel>.from(state.response.clinics)
              ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
            final ids = fetched.map((c) => c.id).whereType<int>().toList();
            unawaited(_userSession.saveClinicIds(ids));
            setState(() {
              _clinics
                ..clear()
                ..addAll(fetched);
              if (_selectedClinic == null && _clinics.isNotEmpty) {
                _selectedClinic = _clinics.first;
              }
            });
          } else if (state is GetMyEmploymentRequestsSuccess) {
            setState(() {
              _receivedEmploymentCount = state.response.requests
                  .where((r) => r.roleInRequest?.toLowerCase() == 'receiver')
                  .length;
            });
          } else if (state is RemoveClinicSuccess) {
            // Refresh handled in cubit; show a brief message
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Clinic removed')));
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            appBar: const CustomAppBar(
              title: 'Clinic Management',
              showNotification: false,
              showBackButton: true,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildClinicInfoCardWrapper(),
                    const SizedBox(height: 18),
                    _buildSectionHeader(),
                    const SizedBox(height: 12),
                    _buildManagementGrid(),
                    const SizedBox(height: 10),
                    _InlineActionCard(
                      icon: Icons.shield_outlined,
                      title: 'Ownership Verification',
                      subtitle: 'Update legal clinic administrative rights',
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.medicalFacilityManagement,
                          arguments: <String, dynamic>{
                            'redirectOnExistingClinics': false,
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _InlineActionCard(
                      icon: Icons.delete_outline_rounded,
                      title: 'Remove Facility',
                      subtitle: 'Irreversible administrative action',
                      isDestructive: true,
                      onTap: () async {
                        if (_selectedClinic == null) return;
                        // Capture context-derived values before any await
                        final overlay = Overlay.of(context);
                        final renderBox =
                            context.findRenderObject() as RenderBox?;
                        final screenSize = MediaQuery.of(context).size;
                        final size = renderBox?.size ?? screenSize;
                        final center =
                            renderBox?.localToGlobal(
                              renderBox.size.center(Offset.zero),
                            ) ??
                            screenSize.center(Offset.zero);

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirm removal'),
                            content: const Text(
                              'Are you sure you want to remove this clinic?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Remove'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          if (!mounted) return;
                          final entry = OverlayEntry(
                            builder: (ctx) {
                              return Positioned.fill(
                                child: _DeletePulseOverlay(
                                  center: center,
                                  maxSize: size.shortestSide * 1.2,
                                ),
                              );
                            },
                          );
                          overlay.insert(entry);
                          await Future.delayed(
                            const Duration(milliseconds: 420),
                          );
                          entry.remove();

                          _cubit.removeClinic(_selectedClinic!.id!);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClinicInfoCardImpl() {
    final hasMultipleClinics = _clinics.length > 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A2D42), Color(0xFF102036)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepNavy.withValues(alpha: 0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.medical_services_outlined,
                      color: Colors.white,
                      size: 31,
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3AC272),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedClinic?.name ?? '',
                            style: const TextStyle(
                              color: AppColors.deepNavy,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (hasMultipleClinics)
                          PopupMenuButton<int>(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.deepNavy,
                            ),
                            onSelected: (id) {
                              setState(() {
                                _selectedClinic = _clinics.firstWhere(
                                  (clinic) => clinic.id == id,
                                  orElse: () => _selectedClinic!,
                                );
                              });
                            },
                            itemBuilder: (context) => _clinics
                                .map(
                                  (clinic) => PopupMenuItem<int>(
                                    value: clinic.id!,
                                    child: Text(clinic.name ?? ''),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _InfoLine(
                      icon: Icons.location_on_outlined,
                      text: _selectedClinic?.address ?? '',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.scaffoldBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ClinicCardActionButton(
                    icon: Icons.open_in_new_rounded,
                    label: 'Clinic Profile',
                    onTap: () {
                      if (_selectedClinic == null) return;
                      Navigator.pushNamed(
                        context,
                        AppRoutes.clinicDetails,
                        arguments: <String, dynamic>{
                          'isOwner': true,
                          'clinicId': _selectedClinic!.id,
                          'name': _selectedClinic!.name,
                          'phoneNumber': _selectedClinic!.phoneNumber,
                          'address': _selectedClinic!.address,
                          'city': _selectedClinic!.city,
                          'area': _selectedClinic!.area,
                          'specialization': _selectedClinic!.specialization,
                          'clinicImageUrl': _selectedClinic!.clinicImageUrl,
                          'latitude': _selectedClinic!.latitude,
                          'longitude': _selectedClinic!.longitude,
                          'sessionDuration': _selectedClinic!.sessionDuration,
                          'clinicFee': _selectedClinic!.clinicFee,
                          'onlineFee': _selectedClinic!.onlineFee,
                          'homeVisitFee': _selectedClinic!.homeVisitFee,
                          'followUpFee': _selectedClinic!.followUpFee,
                          'emergencyFee': _selectedClinic!.emergencyFee,
                        },
                      );
                    },
                  ),
                ),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: AppColors.textSecondary.withValues(alpha: 0.22),
                ),
                Expanded(
                  child: _ClinicCardActionButton(
                    icon: Icons.settings_outlined,
                    label: 'Clinic Appointments',
                    onTap: () {
                      if (_selectedClinic == null) return;
                      Navigator.pushNamed(
                        context,
                        AppRoutes.appointmentDetails,
                        arguments: <String, dynamic>{
                          'clinicId': _selectedClinic!.id,
                          'name': _selectedClinic!.name,
                          'phoneNumber': _selectedClinic!.phoneNumber,
                          'address': _selectedClinic!.address,
                          'city': _selectedClinic!.city,
                          'area': _selectedClinic!.area,
                          'specialization': _selectedClinic!.specialization,
                          'clinicImageUrl': _selectedClinic!.clinicImageUrl,
                          'latitude': _selectedClinic!.latitude,
                          'longitude': _selectedClinic!.longitude,
                          'sessionDuration': _selectedClinic!.sessionDuration,
                          'clinicFee': _selectedClinic!.clinicFee,
                          'onlineFee': _selectedClinic!.onlineFee,
                          'homeVisitFee': _selectedClinic!.homeVisitFee,
                          'followUpFee': _selectedClinic!.followUpFee,
                          'emergencyFee': _selectedClinic!.emergencyFee,
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Administrative Hub',
          style: TextStyle(
            color: AppColors.deepNavy,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Manage your clinic operations',
          style: TextStyle(
            color: AppColors.deepNavy,
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildManagementGrid() {
    return SizedBox(
      height: 230,
      child: Row(
        children: [
          Expanded(
            child: _GridToolCard(
              icon: Icons.person_add_alt_1_rounded,
              title: 'Employment',
              subtitle: 'Recruit medical specialists and staff',
              large: true,
              showBadge: true,
              badgeCount: _receivedEmploymentCount,
              onTap: () {
                final clinicId = _selectedClinic?.id;
                if (clinicId == null) return;
                Navigator.pushNamed(
                  context,
                  AppRoutes.employment,
                  arguments: <String, dynamic>{'clinicId': clinicId},
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _GridToolCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'Shift Control',
                    subtitle: '',
                    onTap: () {
                      final clinicId = _selectedClinic?.id;
                      if (clinicId == null) return;
                      final isOwner = _userSession.userRole.isHospital;
                      final currentDoctorId = _userSession.userRole.isDoctor
                          ? _userSession.doctorId
                          : null;

                      Navigator.pushNamed(
                        context,
                        AppRoutes.clinicSchedule,
                        arguments: {
                          'clinicId': clinicId,
                          'isOwner': isOwner,
                          'currentDoctorId': currentDoctorId,
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _GridToolCard(
                    icon: Icons.receipt_long_rounded,
                    title: 'Billing',
                    subtitle: '',
                    onTap: () {
                      final clinicId = _selectedClinic?.id;
                      if (clinicId != null) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.clinicPaymentSettings,
                          arguments: {'clinicId': clinicId},
                        );
                      } else {
                        Navigator.pushNamed(context, AppRoutes.wallet);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClinicCardActionButton extends StatelessWidget {
  const _ClinicCardActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _TapScaleAnimator(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.95),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TapScaleAnimator extends StatefulWidget {
  const _TapScaleAnimator({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_TapScaleAnimator> createState() => _TapScaleAnimatorState();
}

class _TapScaleAnimatorState extends State<_TapScaleAnimator>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(_) {
    setState(() => _scale = 0.96);
  }

  void _onTapUp(_) async {
    setState(() => _scale = 1.0);
    await Future.delayed(const Duration(milliseconds: 80));
    widget.onTap();
  }

  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _GridToolCard extends StatelessWidget {
  const _GridToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.large = false,
    this.showBadge = false,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool large;
  final bool showBadge;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: _TapScaleAnimator(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(14, large ? 14 : 12, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.textSecondary.withValues(alpha: 0.2),
            ),
          ),
          child: Stack(
            children: [
              if (large)
                Positioned(
                  top: -32,
                  right: -34,
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              if (showBadge)
                Positioned(
                  top: 10,
                  right: 0,
                  child: _BouncingCountBadge(count: badgeCount),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: AppColors.deepNavy),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.deepNavy,
                      fontSize: large ? 16 : 15,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.deepNavy,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineActionCard extends StatelessWidget {
  const _InlineActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final cardBorderColor = isDestructive
        ? AppColors.error.withValues(alpha: 0.15)
        : AppColors.textSecondary.withValues(alpha: 0.2);
    final cardColor = isDestructive
        ? AppColors.error.withValues(alpha: 0.03)
        : AppColors.cardBg;
    final iconColor = isDestructive ? AppColors.error : AppColors.deepNavy;
    final iconBg = isDestructive
        ? AppColors.error.withValues(alpha: 0.1)
        : AppColors.accentBlue.withValues(alpha: 0.42);
    final titleColor = isDestructive ? AppColors.error : AppColors.deepNavy;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.deepNavy,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            if (!isDestructive)
              Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: AppColors.deepNavy.withValues(alpha: 0.8),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 15, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _BouncingCountBadge extends StatefulWidget {
  const _BouncingCountBadge({required this.count});

  final int count;

  @override
  State<_BouncingCountBadge> createState() => _BouncingCountBadgeState();
}

class _DeletePulseOverlay extends StatefulWidget {
  const _DeletePulseOverlay({required this.center, required this.maxSize});
  final Offset center;
  final double maxSize;

  @override
  State<_DeletePulseOverlay> createState() => _DeletePulseOverlayState();
}

class _DeletePulseOverlayState extends State<_DeletePulseOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeOut.transform(_controller.value);
        final size = widget.maxSize * t;
        final opacity = (1.0 - t).clamp(0.0, 1.0);
        return IgnorePointer(
          child: Stack(
            children: [
              Positioned(
                left: widget.center.dx - size / 2,
                top: widget.center.dy - size / 2,
                width: size,
                height: size,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withValues(alpha: 0.9 * opacity),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BouncingCountBadgeState extends State<_BouncingCountBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      reverseDuration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        final dy = -3.0 * t;
        final scale = 1.0 + (0.04 * t);
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.blueAction.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '${widget.count} NEW',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
