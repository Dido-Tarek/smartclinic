import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/auth_header.dart';
import 'package:smartclinic/core/widgets/custom_button.dart';
import 'package:smartclinic/core/widgets/custom_card.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/features/health_issues/data/models/health_issues_model.dart';
import 'package:smartclinic/features/health_issues/presentation/manager/health_issues_cubit.dart';
import 'package:smartclinic/features/health_issues/presentation/manager/health_issues_state.dart';

class HealthIssues extends StatefulWidget {
  const HealthIssues({super.key});

  @override
  State<HealthIssues> createState() => _HealthIssuesState();
}

class _HealthIssuesState extends State<HealthIssues> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HealthIssuesCubit>().emitGetPatientHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    return BlocBuilder<HealthIssuesCubit, HealthIssuesState>(
      builder: (context, state) {
        final List<HealthIssueModel> healthIssues = state.maybeWhen(
          success: (data) =>
              data is List<HealthIssueModel> ? data : <HealthIssueModel>[],
          orElse: () => <HealthIssueModel>[],
        );
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  AuthHeader(
                    title: localizations.translate("past_records_title"),
                    subTitle: localizations.translate("past_records_subtitle"),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: width * 0.5,
                      child: CustomButton(
                        text: localizations.translate("New"),
                        color: AppColors.skyBlue,
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.addHealthIssue,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : healthIssues.isEmpty
                        ? _buildEmptyState(localizations)
                        : ListView.builder(
                            itemCount: healthIssues.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final record = healthIssues[index];
                              return MedicalRecordCard(
                                title: record.name,
                                description: record.notes ?? record.status,
                                isActive:
                                    record.status.toLowerCase() == 'active',
                                onEditPressed: () {
                                  debugPrint('Editing ${record.name}');
                                },
                                onDeletePressed: () {
                                  debugPrint('Deleting ${record.name}');
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: CustomButton(
                      text: localizations.translate("Save"),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.familyMember);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Widget حالة القائمة فارغة (سيتم إضافة الأيقونة والنص لاحقاً) ---
  Widget _buildEmptyState(AppLocalizations localizations) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          AppImages.imagesIconsMedicalCheckup,
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.width * 0.4,
        ),
        const SizedBox(height: 24),
        Text(
          localizations.translate("empty_health_issues_title"),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          localizations.translate("empty_health_issues_subtitle"),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 18),
        ),
      ],
    );
  }
}
