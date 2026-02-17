import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../app_router.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final double amount;
  final String recipient;
  final double? cashback;

  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.recipient,
    this.cashback,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    _SuccessIcon(),
                    const SizedBox(height: 24),
                    const Text('Payment Successful',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                            letterSpacing: -0.3)),
                    const SizedBox(height: 8),
                    Text('Paid to $recipient',
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.textLight)),
                    const SizedBox(height: 40),
                    Text(CurrencyFormatter.format(amount),
                        style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryDarkGreen,
                            letterSpacing: -1)),
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.cardShadow),
                      child: Column(
                        children: [
                          _buildDetailRow('Transaction ID',
                              'TXN-${DateTime.now().millisecondsSinceEpoch}'),
                          const Divider(height: 32),
                          _buildDetailRow('Date & Time',
                              DateFormatter.display(DateTime.now())),
                          const Divider(height: 32),
                          _buildDetailRow('Payment Method', 'TechPay Wallet'),
                          if (cashback != null) ...[
                            const Divider(height: 32),
                            _buildDetailRow('Cashback Earned',
                                CurrencyFormatter.format(cashback!),
                                valueColor: AppTheme.accentLime),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, AppRouter.home, (route) => false),
                  child: const Text('Back to Home'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _SuccessIcon() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: AppTheme.success.withOpacity(0.12)),
      child: Center(
        child: Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: AppTheme.success),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: AppTheme.textLight)),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppTheme.textDark)),
      ],
    );
  }
}
