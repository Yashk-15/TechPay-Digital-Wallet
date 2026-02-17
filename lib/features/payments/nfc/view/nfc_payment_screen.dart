// lib/features/payments/nfc/view/nfc_payment_screen.dart

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

class NFCPaymentScreen extends ConsumerStatefulWidget {
  const NFCPaymentScreen({super.key});

  @override
  ConsumerState<NFCPaymentScreen> createState() => _NFCPaymentScreenState();
}

class _NFCPaymentScreenState extends ConsumerState<NFCPaymentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isScanning = false;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this)
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ── Payment Logic ──────────────────────────────────────────────────────────

  void _startScanning() {
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));

    if (amount == null || amount <= 0) {
      _snack('Please enter a valid amount');
      return;
    }

    final balance = ref.read(homeProvider).balance;

    if (amount > balance) {
      _snack('Insufficient balance', color: AppTheme.error);
      return;
    }

    if (amount > 50000) {
      _snack('Amount exceeds daily NFC limit of ₹50,000',
          color: AppTheme.error);
      return;
    }

    // PCI DSS Req. 10 — log payment attempt before processing
    SecurityService().logEvent(
      SecurityEventType.paymentAttempted,
      'NFC amount=${amount.toStringAsFixed(2)}',
    );

    setState(() => _isScanning = true);

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      const merchant = 'Starbucks NFC';
      const category = 'Food & Drink';

      // 1. Deduct balance
      ref.read(homeProvider.notifier).updateBalance(balance - amount);

      // 2. Log transaction
      final txnId = 'TXN-${DateTime.now().millisecondsSinceEpoch}';
      ref.read(transactionsProvider.notifier).addTransaction(
            TransactionModel(
              id: txnId,
              title: merchant,
              category: category,
              amount: -amount,
              date: DateTime.now(),
              type: 'sent',
              iconKey: 'shopping',
              colorKey: 'textDark',
            ),
          );

      // 3. Earn rewards (gamification spec)
      final earned = ref.read(rewardsProvider.notifier).earnRewards(
            merchant: merchant,
            amount: amount,
            category: category,
          );

      // 4. Audit log — success (PCI DSS Req. 10)
      SecurityService().logEvent(
        SecurityEventType.paymentSucceeded,
        'NFC txnId=$txnId amount=${amount.toStringAsFixed(2)} cashback=${earned.cashback}',
      );

      // 5. Navigate to success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            amount: amount,
            recipientName: merchant,
            details: {
              'Transaction ID': txnId,
              'Date & Time': DateFormatter.display(DateTime.now()),
              'Payment Method': 'NFC Contactless',
              if (earned.cashback > 0)
                'Cashback Earned':
                    '+${CurrencyFormatter.format(earned.cashback)}',
              'Points Earned': '+${earned.points} pts',
            },
          ),
        ),
      );
    });
  }

  void _snack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final rewards = ref.watch(rewardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryDarkTeal.withOpacity(0.05),
              AppTheme.primaryTeal.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              // Amount input
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Enter Amount',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDarkTeal),
                        decoration: const InputDecoration(
                          prefixText: '₹ ',
                          prefixStyle: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryDarkTeal),
                          hintText: '0.00',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.auto_awesome,
                            size: 13, color: AppTheme.success),
                        const SizedBox(width: 4),
                        Text(
                          'Earn cashback ≥ ₹100 · ${rewards.tier.label} tier active',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.success),
                        ),
                      ]),
                    ]),
              ),

              const SizedBox(height: 40),

              // NFC animation area
              Expanded(
                child: Center(
                  child: _isScanning
                      ? _ScanningAnimation(controller: _controller)
                      : _IdleAnimation(),
                ),
              ),

              // CTA
              if (!_isScanning)
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: AppTheme.gradientButtonDecoration(),
                  child: ElevatedButton(
                    onPressed: _startScanning,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    child: const Text('Start NFC Payment',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ScanningAnimation extends StatelessWidget {
  final AnimationController controller;
  const _ScanningAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Stack(alignment: Alignment.center, children: [
        AnimatedBuilder(
            animation: controller,
            builder: (_, __) => Container(
                  width: 200 + (controller.value * 100),
                  height: 200 + (controller.value * 100),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.primaryTeal
                              .withOpacity(1 - controller.value),
                          width: 2)),
                )),
        AnimatedBuilder(
            animation: controller,
            builder: (_, __) {
              final d = (controller.value + 0.3) % 1.0;
              return Container(
                width: 200 + (d * 100),
                height: 200 + (d * 100),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppTheme.primaryDarkTeal.withOpacity(1 - d),
                        width: 2)),
              );
            }),
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                    color: AppTheme.primaryDarkTeal.withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 10)
              ]),
          child: const Icon(Icons.contactless, size: 100, color: Colors.white),
        ),
      ]),
      const SizedBox(height: 32),
      const Text('Hold your phone near the terminal',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryDarkTeal),
          textAlign: TextAlign.center),
      const SizedBox(height: 12),
      const Text('Processing payment...',
          style: TextStyle(fontSize: 14, color: AppTheme.textLight)),
    ]);
  }
}

class _IdleAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryDarkTeal.withOpacity(0.1)),
        child: const Icon(Icons.contactless,
            size: 100, color: AppTheme.primaryDarkTeal),
      ),
      const SizedBox(height: 32),
      const Text('Tap to pay with NFC',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textLight),
          textAlign: TextAlign.center),
    ]);
  }
}
