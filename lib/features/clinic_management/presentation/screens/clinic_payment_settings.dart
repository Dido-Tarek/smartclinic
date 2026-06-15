import 'package:flutter/material.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/localization/app_localization.dart';
import 'package:smartclinic/core/widgets/custom_appbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartclinic/features/wallet/presentation/manager/wallet_cubit.dart';
import 'package:smartclinic/features/wallet/presentation/manager/wallet_state.dart';
import 'package:smartclinic/features/invoices/presentation/manager/invoices_cubit.dart';
import 'package:smartclinic/features/invoices/presentation/manager/invoices_state.dart';
import 'package:cherry_toast/cherry_toast.dart';

class ClinicPaymentSettingsView extends StatefulWidget {
  const ClinicPaymentSettingsView({super.key});

  @override
  State<ClinicPaymentSettingsView> createState() =>
      _ClinicPaymentSettingsViewState();
}

class _ClinicPayLogo extends StatelessWidget {
  const _ClinicPayLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF243548),
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomPaint(painter: _ClinicPayLogoPainter()),
    );
  }
}

class _ClinicPayLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final arcPaint = Paint()
      ..color = const Color(0xFF6B8EAA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final arcRect = Rect.fromCircle(center: center, radius: size.width * 0.3);
    canvas.drawArc(arcRect, -0.55, 5.55, false, arcPaint);

    final dotPaint = Paint()
      ..color = const Color(0xFF6B8EAA)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ClinicPaymentSettingsViewState extends State<ClinicPaymentSettingsView> {
  bool _argsLoaded = false;
  int? _clinicId;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // read route args once
    if (!_argsLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _clinicId = args['clinicId'] as int?;
      }
      _argsLoaded = true;
      // trigger initial loads
      if (_clinicId != null) {
        // ignore: cascade_invocations
        context.read<WalletCubit>().getClinicBalance(_clinicId!);
        // ignore: cascade_invocations
        context.read<InvoicesCubit>().getClinicReport(_clinicId!);
      }
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<WalletCubit, WalletState>(
          listener: (context, state) {
            if (state is TopUpSuccess) {
              CherryToast.success(
                title: const Text('Success'),
                description: Text(
                  localizations.translate(
                    'Your wallet balance has been updated.',
                  ),
                ),
              ).show(context);
            }
          },
        ),
        BlocListener<InvoicesCubit, InvoicesState>(
          listener: (context, state) {
            if (state is MarkAsPaidSuccess) {
              CherryToast.success(
                title: const Text('Success'),
                description: Text(
                  state.response.message ?? localizations.translate('paid'),
                ),
              ).show(context);
              // refresh report
              if (_clinicId != null) {
                context.read<InvoicesCubit>().getClinicReport(_clinicId!);
              }
            } else if (state is MarkAsPaidFailure) {
              CherryToast.error(
                title: const Text('Error'),
                description: Text(state.errorMessage),
              ).show(context);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: SafeArea(
          child: Column(
            children: [
              // Fixed Custom AppBar with Back and Notifications showing
              CustomAppBar(
                title: localizations.translate('clinic_payment_settings'),
                showBackButton: true,
              ),

              // Clinic Wallet Balance Card
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: BlocBuilder<WalletCubit, WalletState>(
                  builder: (context, state) {
                    String balanceText = '0.00';
                    String currency = '';
                    final bool isLoading = state is GetClinicBalanceLoading;
                    if (state is GetClinicBalanceSuccess) {
                      balanceText = '${state.response.balance ?? 0}';
                      currency = state.response.currency ?? '';
                    }
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations.translate('clinic_balance'),
                                    style: const TextStyle(
                                      color: Color(0xFF8BA5C2),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  isLoading
                                      ? const SizedBox(
                                          height: 32,
                                          width: 32,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          '\$$balanceText $currency',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ],
                              ),
                              const _ClinicPayLogo(),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Row(
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                color: Color(0xFF8BA5C2),
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Funds secured and verified by ClinicPay System',
                                style: TextStyle(
                                  color: Color(0xFF8BA5C2),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Info cards and report + history placeholder
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Card(
                        color: AppColors.cardBg,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations.translate('invoices_total'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              BlocBuilder<InvoicesCubit, InvoicesState>(
                                builder: (context, state) {
                                  if (state is GetClinicReportSuccess) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${localizations.translate('total_revenue')}: ${state.response.totalRevenue ?? 0}',
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${localizations.translate('payment_history')}: ${state.response.totalInvoices ?? 0}',
                                        ),
                                      ],
                                    );
                                  }
                                  if (state is GetClinicReportLoading) {
                                    return const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    );
                                  }
                                  return const Text('-');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // History placeholder (detailed invoices endpoint not available)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                          child: Text(
                            localizations.translate('payment_history'),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: Center(
                          child: Text(
                            'Detailed invoice list is not available from the API.',
                            style: TextStyle(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
