import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/helper/user_roles.dart';
import 'package:smartclinic/core/helper/user_session.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/routes/app_routes.dart';
import 'package:smartclinic/core/widgets/auth_header.dart';
import 'package:smartclinic/core/widgets/custom_button.dart';
import 'package:smartclinic/core/widgets/custom_small_text_field.dart';
import 'package:smartclinic/features/clinic/data/model/add_clinic_request_model.dart';
import 'package:smartclinic/features/clinic/presentation/manager/add_clinic_cubit.dart';
import 'package:smartclinic/features/clinic/presentation/manager/add_clinic_state.dart';
import 'package:smartclinic/core/widgets/type_card.dart';
import 'package:smartclinic/injection_dependency.dart';

class AppointmentDetailsPage extends StatefulWidget {
  const AppointmentDetailsPage({
    super.key,
    this.enabledAppointmentTypes = const {'clinic', 'online', 'homeVisit'},
  });

  final Set<String> enabledAppointmentTypes;

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  final TextEditingController _clinicFeeController = TextEditingController();
  final TextEditingController _onlineFeeController = TextEditingController();
  final TextEditingController _homeVisitFeeController = TextEditingController();
  final TextEditingController _followUpFeeController = TextEditingController();
  final TextEditingController _emergencyFeeController = TextEditingController();

  late bool _clinicSelected;
  late bool _onlineSelected;
  late bool _homeVisitSelected;
  bool _argsLoaded = false;
  bool _isOwner = true;
  String _name = '';
  String _address = '';
  String _phoneNumber = '';
  String _city = '';
  String _area = '';
  String? _specialization;
  double? _latitude;
  double? _longitude;
  File? _clinicImage;
  File? _legalDocument1;
  File? _legalDocument2;
  File? _legalDocument3;

  @override
  void dispose() {
    _clinicFeeController.dispose();
    _onlineFeeController.dispose();
    _homeVisitFeeController.dispose();
    _followUpFeeController.dispose();
    _emergencyFeeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final types = widget.enabledAppointmentTypes;
    // initialize selected flags from incoming enabled types
    _clinicSelected = types.contains('clinic');
    _onlineSelected = types.contains('online');
    _homeVisitSelected = types.contains('homeVisit');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final normalized = args.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      _isOwner = normalized['isOwner'] as bool? ?? true;
      _name = (normalized['name'] as String? ?? '').trim();
      _address = (normalized['address'] as String? ?? '').trim();
      _phoneNumber = (normalized['phoneNumber'] as String? ?? '').trim();
      _city = (normalized['city'] as String? ?? '').trim();
      _area = (normalized['area'] as String? ?? '').trim();
      _specialization = (normalized['specialization'] as String?)?.trim();
      _latitude = normalized['latitude'] as double?;
      _longitude = normalized['longitude'] as double?;
      _clinicImage = normalized['clinicImage'] as File?;
      _legalDocument1 = normalized['legalDocument1'] as File?;
      _legalDocument2 = normalized['legalDocument2'] as File?;
      _legalDocument3 = normalized['legalDocument3'] as File?;

      if (normalized['clinic'] is bool ||
          normalized['online'] is bool ||
          normalized['homeVisit'] is bool) {
        _clinicSelected = normalized['clinic'] == true;
        _onlineSelected = normalized['online'] == true;
        _homeVisitSelected = normalized['homeVisit'] == true;
      }
    }

    _argsLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocConsumer<AddClinicCubit, AddClinicState>(
      listener: (context, state) async {
        state.whenOrNull(
          success: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.translate('clinic_added_success')),
              ),
            );

            final role = getRoleEnum(getIt<UserSession>().roleString);
            Navigator.pushReplacementNamed(
              context,
              role.isDoctor
                  ? AppRoutes.doctorhome
                  : role.isHospital
                  ? AppRoutes.hospitalhome
                  : AppRoutes.patienthome,
            );
          },
          error: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error), backgroundColor: Colors.red),
            );
          },
        );
      },
      builder: (context, state) {
        final isSubmitting = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuthHeader(
                          title: localizations.translate(
                            'appointment_details_title',
                          ),
                          subTitle: localizations.translate(
                            "appointment_details_subtitle",
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: TypeCard(
                                title: localizations.translate(
                                  "clinic_appointment_title",
                                ),
                                icon: Icons.local_hospital_outlined,
                                isSelected: _clinicSelected,
                                onTap: () => setState(
                                  () => _clinicSelected = !_clinicSelected,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TypeCard(
                                title: localizations.translate(
                                  'online_appointment_title',
                                ),
                                icon: Icons.videocam_outlined,
                                isSelected: _onlineSelected,
                                onTap: () => setState(
                                  () => _onlineSelected = !_onlineSelected,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TypeCard(
                                title: localizations.translate(
                                  'home_visit_title',
                                ),
                                icon: Icons.home_outlined,
                                isSelected: _homeVisitSelected,
                                onTap: () => setState(
                                  () =>
                                      _homeVisitSelected = !_homeVisitSelected,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _buildFeeCard(
                          title: localizations.translate('clinic_fee_title'),
                          controller: _clinicFeeController,
                          enabled: _isEnabled('clinic'),
                          helperText: localizations.translate('fee_help_text'),
                        ),
                        const SizedBox(height: 12),
                        _buildFeeCard(
                          title: localizations.translate('online_fee_title'),
                          controller: _onlineFeeController,
                          enabled: _isEnabled('online'),
                          helperText: localizations.translate('fee_help_text'),
                        ),
                        const SizedBox(height: 12),
                        _buildFeeCard(
                          title: localizations.translate(
                            'home_visit_fee_title',
                          ),
                          controller: _homeVisitFeeController,
                          enabled: _isEnabled('homeVisit'),
                          helperText: localizations.translate('fee_help_text'),
                        ),
                        const SizedBox(height: 12),
                        _buildFeeCard(
                          title: localizations.translate('follow_up_fee_title'),
                          controller: _followUpFeeController,
                          enabled: _isEnabled([
                            'clinic',
                            'online',
                            'homeVisit',
                          ]),
                          helperText: localizations.translate('fee_help_text'),
                        ),
                        const SizedBox(height: 12),
                        _buildFeeCard(
                          title: localizations.translate('emergency_fee_title'),
                          controller: _emergencyFeeController,
                          enabled: _isEnabled(['clinic', 'online']),
                          helperText: localizations.translate('fee_help_text'),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                  child: CustomButton(
                    text: localizations.translate('launch_facility'),
                    width: double.infinity,
                    onPressed: isSubmitting ? () {} : _onLaunchFacility,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isEnabled(dynamic types) {
    // Accept a single String or an Iterable<String>.
    final List<String> checkTypes;
    if (types is String) {
      checkTypes = [types];
    } else if (types is Iterable<String>) {
      checkTypes = List<String>.from(types);
    } else {
      return false;
    }

    // Return true if any provided type is both allowed by the incoming
    // `enabledAppointmentTypes` and currently selected in the UI.
    return checkTypes.any((t) {
      final allowed = widget.enabledAppointmentTypes.contains(t);
      final selected = (t == 'clinic')
          ? _clinicSelected
          : (t == 'online')
          ? _onlineSelected
          : (t == 'homeVisit')
          ? _homeVisitSelected
          : false;
      return allowed && selected;
    });
  }

  Widget _buildFeeCard({
    required String title,
    required TextEditingController controller,
    required bool enabled,
    required String helperText,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: enabled
              ? AppColors.textPrimary
              : AppColors.skyBlue.withValues(alpha: 0.35),
          width: enabled ? 1 : 1.2,
        ),
        boxShadow: enabled
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!enabled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Locked',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            helperText,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Opacity(
            opacity: enabled ? 1 : 0.58,
            child: IgnorePointer(
              ignoring: !enabled,
              child: CustomSmallTextField(
                controller: controller,
                hintText: '0.00',
                suffixText: 'EGP',
                keyboardType: TextInputType.number,
                widthFactor: 1,
                readOnly: !enabled,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double? _parseFee(TextEditingController controller) {
    final raw = controller.text.trim();
    if (raw.isEmpty) {
      return null;
    }
    return double.tryParse(raw);
  }

  Future<void> _onLaunchFacility() async {
    final request = AddClinicRequestModel(
      name: _name,
      address: _address,
      phoneNumber: _phoneNumber,
      city: _city,
      area: _area,
      isOwner: _isOwner,
      clinicImage: _clinicImage,
      latitude: _latitude,
      longitude: _longitude,
      specialization: (_specialization == null || _specialization!.isEmpty)
          ? null
          : _specialization,
      legalDocument1: _legalDocument1,
      legalDocument2: _legalDocument2,
      legalDocument3: _legalDocument3,
      clinicFee: _isEnabled('clinic') ? _parseFee(_clinicFeeController) : null,
      onlineFee: _isEnabled('online') ? _parseFee(_onlineFeeController) : null,
      homeVisitFee: _isEnabled('homeVisit')
          ? _parseFee(_homeVisitFeeController)
          : null,
      followUpFee: _parseFee(_followUpFeeController),
      emergencyFee: _parseFee(_emergencyFeeController),
    );

    await context.read<AddClinicCubit>().emitAddClinicStates(request);
  }
}
