import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/auth_header.dart';
import 'package:smartclinic/core/widgets/custom_button.dart';
import 'package:smartclinic/core/widgets/custom_card.dart';
import 'package:smartclinic/core/constants/assets.dart';
import 'package:smartclinic/features/family_members/data/models/family_member_model.dart';
import 'package:smartclinic/features/family_members/presentation/manager/family_member_cubit.dart';
import 'package:smartclinic/features/family_members/presentation/manager/family_member_state.dart';

class FamilyMember extends StatefulWidget {
  const FamilyMember({super.key});

  @override
  State<FamilyMember> createState() => _FamilyMemberState();
}

class _FamilyMemberState extends State<FamilyMember> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FamilyCubit>().emitGetFamily();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    return BlocConsumer<FamilyCubit, FamilyState>(
      listener: (context, state) {
        state.whenOrNull(
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.error,
              ),
            );
          },
        );
      },
      builder: (context, state) {
        final familyMembers = state.maybeWhen(
          success: (data) =>
              data is List<FamilyMemberModel> ? data : <FamilyMemberModel>[],
          orElse: () => <FamilyMemberModel>[],
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
                    title: localizations.translate("family_member_title"),
                    subTitle: localizations.translate("family_member_subtitle"),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: width * 0.5,
                      child: CustomButton(
                        text: localizations.translate("New"),
                        color: AppColors.skyBlue,
                        onPressed: () {
                          final familyCubit = context.read<FamilyCubit>();
                          Navigator.pushNamed(
                            context,
                            AppRoutes.addFamilyMember,
                          ).then((result) {
                            if (!mounted) {
                              return;
                            }
                            if (result == true) {
                              familyCubit.emitGetFamily();
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : familyMembers.isEmpty
                        ? _buildEmptyState(localizations)
                        : ListView.builder(
                            itemCount: familyMembers.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final record = familyMembers[index];
                              return MedicalRecordCard(
                                title: record.name,
                                description: record.bloodType,
                                relation: record.relation,
                                isActive: true,
                                onEditPressed: () {
                                  debugPrint('Editing ${record.name}');
                                },
                                onDeletePressed: () {
                                  if (record.id == null) {
                                    return;
                                  }
                                  context.read<FamilyCubit>().emitDeleteMember(
                                    record.id!,
                                  );
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
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.patienthome,
                          (route) => false,
                        );
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
          AppImages.imagesIconsFamily,
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.width * 0.4,
        ),
        const SizedBox(height: 24),
        Text(
          localizations.translate("empty_family_member_title"),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          localizations.translate("empty_family_member_subtitle"),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 18),
        ),
      ],
    );
  }
}
