import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/features/wallet/data/model/wallet_response_model.dart';
import 'package:smartclinic/features/wallet/presentation/manager/wallet_cubit.dart';
import 'package:smartclinic/features/wallet/presentation/manager/wallet_state.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double? _cachedBalance;
  String _currency = 'EGP';
  List<WalletTransactionModel> _cachedTransactions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletCubit>().initWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'My Wallet',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<WalletCubit, WalletState>(
        listener: (context, state) {
          if (state is GetBalanceSuccess) {
            setState(() {
              _cachedBalance = (state.response.balance ?? 0).toDouble();
              _currency = state.response.currency ?? 'EGP';
            });
          }

          if (state is GetHistorySuccess) {
            setState(() {
              _cachedTransactions = state.response.transactions;
            });
          }

          if (state is TopUpSuccess) {
            _showSuccessDialog(context);
          }

          if (state is CreatePaymentIntentFailure) {
            _showErrorSnackBar(context, state.errorMessage);
          } else if (state is TopUpFailure) {
            _showErrorSnackBar(context, state.errorMessage);
          } else if (state is GetBalanceFailure) {
            _showErrorSnackBar(context, state.errorMessage);
          } else if (state is GetHistoryFailure) {
            _showErrorSnackBar(context, state.errorMessage);
          }

          if (state is CreatePaymentIntentSuccess) {
            _showSuccessDialog(context);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildBalanceCard(state),
                  const SizedBox(height: 30),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTopUpButton(context),
                  const SizedBox(height: 30),
                  const Text(
                    'Payment History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentHistory(state),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(WalletState state) {
    final bool isLoading = state is GetBalanceLoading && _cachedBalance == null;
    final String balance = (_cachedBalance ?? 0).toStringAsFixed(2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.blueAction, AppColors.skyBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueAction.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: TextStyle(color: AppColors.textLight, fontSize: 14),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.cardBg,
              ),
            ],
          ),
          const SizedBox(height: 12),
          isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.cardBg,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  '$_currency $balance',
                  style: const TextStyle(
                    color: AppColors.cardBg,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Opacity(
                opacity: 0.9,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.cardBg,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopUpButton(BuildContext context) {
    return InkWell(
      onTap: () => _showTopUpDialog(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.accentBlue.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.35)),
        ),
        child: const Column(
          children: [
            Icon(Icons.add_circle_outline_rounded, color: AppColors.blueAction, size: 28),
            SizedBox(height: 8),
            Text(
              'Top Up',
              style: TextStyle(
                color: AppColors.blueAction,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistory(WalletState state) {
    if (state is GetHistoryLoading && _cachedTransactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_cachedTransactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: AppColors.accentBlue.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(Icons.receipt_long_outlined, color: AppColors.skyBlue, size: 40),
            SizedBox(height: 12),
            Text(
              'No transactions yet',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _cachedTransactions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return _buildTransactionTile(_cachedTransactions[index]);
      },
    );
  }

  Widget _buildTransactionTile(WalletTransactionModel tx) {
    final double amount = (tx.amount ?? 0).toDouble();
    final bool isCredit = amount >= 0;
    final Color amountColor = isCredit ? AppColors.success : Colors.red;
    final String amountPrefix = isCredit ? '+' : '-';
    final String formattedDate = _formatDate(tx.date);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: amountColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: amountColor,
            size: 22,
          ),
        ),
        title: Text(
          _formatType(tx.type),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tx.description != null && tx.description!.isNotEmpty)
              Text(
                tx.description!,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        trailing: Text(
          '$amountPrefix$_currency ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ),
    );
  }

  String _formatType(String? type) {
    if (type == null || type.isEmpty) return 'Transaction';
    return type
        .split(RegExp(r'[-_\s]'))
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $hour:$minute $period';
    } catch (_) {
      return dateStr;
    }
  }

  void _showTopUpDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Top Up Amount'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter amount in EGP',
            prefixText: 'EGP ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                context.read<WalletCubit>().topUp(amount);
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueAction,
              foregroundColor: AppColors.cardBg,
            ),
            child: const Text('Top Up Wallet'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 56,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Success!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.blueAction,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your wallet balance has been updated.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueAction,
                  foregroundColor: AppColors.cardBg,
                ),
                child: const Text('Back to Wallet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    CherryToast.error(
      title: const Text('Wallet Error'),
      description: Text(message),
    ).show(context);
  }
}
