import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final double amount;
  final String? recipientName;
  final Map<String, String> details;
  final String title;
  final String? subtitle;

  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    this.recipientName,
    this.details = const {},
    this.title = 'Payment Successful',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgAbyss,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    _buildSuccessIcon(),
                    const SizedBox(height: 24),
                    const Text('Payment Successful!',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.text100)),
                    const SizedBox(height: 8),
                    if (recipientName != null)
                      Text('Paid to $recipientName',
                          style: const TextStyle(
                              fontSize: 14, color: AppTheme.textLight))
                    else if (subtitle != null)
                      Text(subtitle!,
                          style: const TextStyle(
                              fontSize: 14, color: AppTheme.textLight)),
                    const SizedBox(height: 24),
                    Text(CurrencyFormatter.format(amount),
                        style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.coral)),
                    const SizedBox(height: 32),

                    // ── Details Card ───────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                          color: AppTheme.bgSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.bgBorder),
                          boxShadow: AppTheme.cardShadow),
                      child: Column(
                        children: [
                          ...details.entries.map((entry) {
                            final isLast = entry.key == details.keys.last;
                            return Column(
                              children: [
                                _buildDetailRow(entry.key, entry.value),
                                if (!isLast) const Divider(height: 32),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: () {
                  // Quick clear states or pop to absolute root
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Back to Home',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.coral)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: AppTheme.coral.withOpacity(0.12)),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: AppTheme.coral),
          child: const Icon(Icons.check, size: 40, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: AppTheme.text400)),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.text100)),
      ],
    );
  }
}
