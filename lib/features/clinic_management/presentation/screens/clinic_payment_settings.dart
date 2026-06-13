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

class _ClinicPaymentSettingsViewState extends State<ClinicPaymentSettingsView> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedPaymentMethod;
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
                showNotification: true,
              ),

              // Fixed Input Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Amount to Charge input
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            localizations.translate('amount_to_charge'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '500 EGP',
                              hintStyle: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                              border: const OutlineInputBorder(),
                              isDense: true,
                              contentPadding: const EdgeInsets.all(8.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Payment Method Select
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Payment Method",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.all(8.0),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: const Text(
                                  'Visa',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                value: _selectedPaymentMethod,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedPaymentMethod = newValue;
                                  });
                                },
                                items:
                                    [
                                      'Visa',
                                      'MasterCard',
                                      'Cash',
                                      'Insurance',
                                    ].map((String method) {
                                      return DropdownMenuItem<String>(
                                        value: method,
                                        child: Text(method),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Charge Button — top up (dev/testing)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final val = num.tryParse(_amountController.text) ?? 0;
                          if (val > 0) {
                            context.read<WalletCubit>().topUp(val);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentBlue,
                          foregroundColor: AppColors.deepNavy,
                        ),
                        child: Text(localizations.translate('charge')),
                      ),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Divider(),
              ),

              // Info cards and report + history placeholder
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              color: AppColors.cardBg,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localizations.translate('clinic_balance'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    BlocBuilder<WalletCubit, WalletState>(
                                      builder: (context, state) {
                                        if (state is GetClinicBalanceSuccess) {
                                          return Text(
                                            '${state.response.balance ?? 0} ${state.response.currency ?? ''}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        }
                                        if (state is GetClinicBalanceLoading) {
                                          return const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          );
                                        }
                                        return Text('-');
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Card(
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
                                        return Text('-');
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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
