import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:smartclinic/features/prescriptions/data/model/prescription_request_model.dart';
import 'package:smartclinic/features/prescriptions/data/model/prescriptions_resoponse_model.dart';
import 'package:smartclinic/features/prescriptions/presentation/manager/prescriptions_cubit.dart';
import 'package:smartclinic/features/prescriptions/presentation/manager/prescriptions_state.dart';
import 'package:smartclinic/injection_dependency.dart';

class PrescriptionDetailScreen extends StatefulWidget {
  final int prescriptionId;

  const PrescriptionDetailScreen({super.key, required this.prescriptionId});

  @override
  State<PrescriptionDetailScreen> createState() =>
      _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState extends State<PrescriptionDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PrescriptionsCubit>().getPrescriptionById(
        widget.prescriptionId,
      );
    });
  }

  bool _isPrescriptionActive(PrescriptionModel p) {
    if (p.createdAt == null || p.medicines.isEmpty) return true;
    final created = DateTime.tryParse(p.createdAt!) ?? DateTime.now();
    final maxDays = p.medicines.fold<int>(
      0,
      (prev, m) => m.days > prev ? m.days : prev,
    );
    return DateTime.now().isBefore(created.add(Duration(days: maxDays)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CustomAppBar(
        title: 'Prescription Details',
        showBackButton: true,
        showNotification: true,
        onNotificationTap: () =>
            Navigator.pushNamed(context, AppRoutes.notifications),
      ),
      body: BlocBuilder<PrescriptionsCubit, PrescriptionsState>(
        builder: (context, state) {
          if (state is PrescriptionsInitial ||
              state is GetPrescriptionByIdLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GetPrescriptionByIdFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 56,
                    color: AppColors.error.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is GetPrescriptionByIdSuccess) {
            return _buildContent(state.prescription);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildContent(PrescriptionModel p) {
    final userSession = getIt<UserSession>();
    final isDoctor = userSession.userRole.isDoctor;
    final displayName = isDoctor
        ? (p.patientName ?? 'Patient')
        : (p.doctorName ?? 'Doctor');
    final oppositeLabel = isDoctor ? 'Patient' : 'Doctor';
    final isActive = _isPrescriptionActive(p);
    final statusColor = isActive ? AppColors.success : const Color(0xFF247CFF);
    final statusText = isActive ? 'Active' : 'Completed';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status + Name card ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepNavy.withValues(alpha: 0.07),
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
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrayBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isDoctor
                            ? Icons.person_outline
                            : Icons.medical_services_outlined,
                        color: AppColors.textSecondary,
                        size: 26,
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
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            oppositeLabel,
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
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (p.diagnosis?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.biotech_outlined,
                    'Diagnosis',
                    p.diagnosis!,
                  ),
                ],
                if (p.createdAt?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.calendar_today_outlined,
                    'Date',
                    _formatDate(p.createdAt!),
                  ),
                ],
              ],
            ),
          ),
          // ── Medicines ───────────────────────────────────────────────────
          if (p.medicines.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Medicines',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            ...p.medicines.map((m) => _buildMedicineCard(m)),
          ],
          // ── General Instructions ────────────────────────────────────────
          if (p.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GENERAL INSTRUCTIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepNavy,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.notes!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicineCard(MedicineItemModel m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${m.medicineName} ${m.dosage}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Every ${m.frequency} hours',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Duration: ${m.days} day${m.days != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (m.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    m.notes!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
