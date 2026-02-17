import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../app_router.dart';
import '../model/contact_model.dart';

class SuccessScreen extends StatelessWidget {
  final double amount;
  final ContactModel recipient;
  final String partialTxnId;
  final DateTime timestamp;
  final String? note;

  const SuccessScreen({
    super.key,
    required this.amount,
    required this.recipient,
    required this.partialTxnId,
    required this.timestamp,
    this.note,
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    _SuccessIcon(),
                    const SizedBox(height: 24),
                    const Text(
                      'Transfer Successful',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your money is on its way',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      CurrencyFormatter.format(amount),
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryDarkGreen,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _ReceiptCard(
                      recipient: recipient,
                      partialTxnId: partialTxnId,
                      timestamp: timestamp,
                      note: note,
                    ),
                    const SizedBox(height: 24),
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
                    context,
                    AppRouter.home, // Use standardized route
                    (route) => false,
                  ),
                  child: const Text('Back to Home'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.success.withOpacity(0.12),
      ),
      child: Center(
        child: Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.success,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final ContactModel recipient;
  final String partialTxnId;
  final DateTime timestamp;
  final String? note;

  const _ReceiptCard({
    required this.recipient,
    required this.partialTxnId,
    required this.timestamp,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          _ReceiptRow('To', recipient.name),
          const _ReceiptDivider(),
          _ReceiptRow('Account', recipient.maskedAccount),
          const _ReceiptDivider(),
          _ReceiptRow('Reference', '#${partialTxnId.toUpperCase()}'),
          const _ReceiptDivider(),
          _ReceiptRow('Date & Time', DateFormatter.display(timestamp)),
          if (note != null && note!.isNotEmpty) ...[
            const _ReceiptDivider(),
            _ReceiptRow('Note', note!),
          ],
          const _ReceiptDivider(),
          const _ReceiptRow('Status', 'Completed',
              valueColor: AppTheme.success),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ReceiptRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppTheme.textLight),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}

class _ReceiptDivider extends StatelessWidget {
  const _ReceiptDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Divider(height: 1, color: Color(0xFFF0F0F0)),
    );
  }
}
