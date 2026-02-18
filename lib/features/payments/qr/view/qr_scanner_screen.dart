// lib/features/payments/qr/view/qr_scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/security/security_service.dart';
import '../../../../features/transactions/controller/transactions_controller.dart';
import '../../../../features/transactions/model/transaction_model.dart';
import '../../../../features/home/controller/home_controller.dart';
import '../../../../features/rewards/view/controller/rewards_controller.dart';
import '../../success/view/payment_success_screen.dart';

class QRScannerScreen extends ConsumerWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.flash_on_outlined), onPressed: () {}),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryDarkTeal, AppTheme.primaryTeal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            // Scanner frame
            const Spacer(),
            Center(child: _ScannerFrame()),

            const SizedBox(height: 24),
            const Text('Align QR code within frame',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              'Earn cashback rewards on every QR payment',
              style:
                  TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                // Simulate scan
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 1.5)),
                  child: ElevatedButton.icon(
                    onPressed: () => _simulateQRPayment(context, ref),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Simulate QR Scan (Demo)'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                  ),
                ),
                const SizedBox(height: 16),
                // Show my QR
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: AppTheme.gradientButtonDecoration(),
                  child: ElevatedButton.icon(
                    onPressed: () => _showMyQRCode(context),
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text('Show My QR Code'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  void _showMyQRCode(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('My QR Code',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.qr_code_2,
                  size: 160, color: AppTheme.textDark),
            ),
          ),
          const SizedBox(height: 24),
          const Text('john.doe@techpay.com',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark)),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  void _simulateQRPayment(BuildContext context, WidgetRef ref) {
    const double amount = 150.00;
    const String merchant = 'Merchant QR';
    const String category = 'Shopping';

    final balance = ref.read(homeProvider).balance;
    if (amount > balance) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Insufficient balance')));
      return;
    }

    // Audit log (PCI DSS Req. 10)
    SecurityService().logEvent(SecurityEventType.paymentAttempted,
        'QR amount=${amount.toStringAsFixed(2)}');

    // 1. Deduct
    ref.read(homeProvider.notifier).updateBalance(balance - amount);

    // 2. Transaction record
    final txnId = 'TXN-${DateTime.now().millisecondsSinceEpoch}';
    ref.read(transactionsProvider.notifier).addTransaction(TransactionModel(
          id: txnId,
          title: merchant,
          category: category,
          amount: -amount,
          date: DateTime.now(),
          type: 'sent',
          iconKey: 'qr_code',
          colorKey: 'textDark',
        ));

    // 3. Rewards (gamification spec)
    final earned = ref.read(rewardsProvider.notifier).earnRewards(
          merchant: merchant,
          amount: amount,
          category: category,
        );

    // 4. Audit success
    SecurityService().logEvent(SecurityEventType.paymentSucceeded,
        'QR txnId=$txnId cashback=${earned.cashback}');

    // 5. Navigate
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(
          amount: amount,
          recipientName: merchant,
          details: {
            'Transaction ID': txnId,
            'Date & Time': DateFormatter.display(DateTime.now()),
            'Payment Method': 'QR Code',
            if (earned.cashback > 0)
              'Cashback Earned':
                  '+${CurrencyFormatter.format(earned.cashback)}',
            'Points Earned': '+${earned.points} pts',
          },
        ),
      ),
    );
  }
}

// ── Scanner Frame Widget ──────────────────────────────────────────────────────

class _ScannerFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(children: [
        // Outer border
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryTeal, width: 3),
              borderRadius: BorderRadius.circular(20)),
        ),
        // Corner accents
        const _Corner(top: 0, left: 0, tl: true),
        const _Corner(top: 0, right: 0, tr: true),
        const _Corner(bottom: 0, left: 0, bl: true),
        const _Corner(bottom: 0, right: 0, br: true),
      ]),
    );
  }
}

class _Corner extends StatelessWidget {
  final double? top, bottom, left, right;
  final bool tl, tr, bl, br;
  const _Corner(
      {this.top,
      this.bottom,
      this.left,
      this.right,
      this.tl = false,
      this.tr = false,
      this.bl = false,
      this.br = false});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: tl ? const Radius.circular(17) : Radius.zero,
            topRight: tr ? const Radius.circular(17) : Radius.zero,
            bottomLeft: bl ? const Radius.circular(17) : Radius.zero,
            bottomRight: br ? const Radius.circular(17) : Radius.zero,
          ),
          border: Border(
            top: (tl || tr)
                ? const BorderSide(color: AppTheme.accentMintGreen, width: 4)
                : BorderSide.none,
            bottom: (bl || br)
                ? const BorderSide(color: AppTheme.accentMintGreen, width: 4)
                : BorderSide.none,
            left: (tl || bl)
                ? const BorderSide(color: AppTheme.accentMintGreen, width: 4)
                : BorderSide.none,
            right: (tr || br)
                ? const BorderSide(color: AppTheme.accentMintGreen, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
