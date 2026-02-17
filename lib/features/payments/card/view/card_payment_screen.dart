// lib/features/payments/card/view/card_payment_screen.dart

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

class CardPaymentScreen extends ConsumerStatefulWidget {
  const CardPaymentScreen({super.key});

  @override
  ConsumerState<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends ConsumerState<CardPaymentScreen> {
  int _selectedCardIndex = 0;
  bool _isLoading = false;
  final _amountController = TextEditingController();
  final _recipientController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rewards = ref.watch(rewardsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Pay via Card'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 20, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Payment Details ──────────────────────────────────────────
          const Text('Payment Details',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.cardShadow),
            child: Column(children: [
              TextField(
                controller: _recipientController,
                decoration: const InputDecoration(
                    labelText: 'Recipient Name / Merchant',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.store)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_rupee)),
              ),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.auto_awesome,
                    size: 13, color: AppTheme.success),
                const SizedBox(width: 4),
                Text(
                  'Earn cashback ≥ ₹100 · ${rewards.tier.label} tier · ${rewards.tier.multiplier}× pts',
                  style: const TextStyle(fontSize: 12, color: AppTheme.success),
                ),
              ]),
            ]),
          ),

          const SizedBox(height: 32),

          // ── Select Card ──────────────────────────────────────────────
          const Text('Select Card',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: PageView.builder(
              itemCount: 2,
              controller: PageController(viewportFraction: 0.9),
              onPageChanged: (i) => setState(() => _selectedCardIndex = i),
              itemBuilder: (_, index) {
                // PCI DSS Req. 3.3: Display masked PAN only (last 4 digits)
                final isVisa = index == 1;
                final gradient = isVisa
                    ? const LinearGradient(
                        colors: [Color(0xFF1A5C58), Color(0xFF2D8B7A)])
                    : AppTheme.primaryGradient;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: _selectedCardIndex == index
                          ? AppTheme.cardShadow
                          : []),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(isVisa ? 'Visa Gold' : 'Mastercard Platinum',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                            const Icon(Icons.contactless, color: Colors.white),
                          ]),
                      // Masked PAN — PCI DSS Req. 3.3
                      Text(
                          SecurityService.maskPan(
                              isVisa ? '8765432109878765' : '4582159635744582'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2)),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(isVisa ? '08/26' : '12/25',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            // CVV masked per PCI DSS Req. 3.3
                            Text('CVV ${SecurityService.maskCvv()}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13)),
                          ]),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: AppTheme.primaryDarkTeal),
              label: const Text('Add New Card',
                  style: TextStyle(color: AppTheme.primaryDarkTeal)),
            ),
          ),

          const SizedBox(height: 40),

          // ── Pay Button ───────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDarkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Pay Now',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Payment Processing ────────────────────────────────────────────────────

  void _processPayment() {
    final recipient = _recipientController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (recipient.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter valid recipient and amount')));
      return;
    }

    final balance = ref.read(homeProvider).balance;
    if (amount > balance) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Insufficient balance'),
          backgroundColor: AppTheme.error));
      return;
    }

    setState(() => _isLoading = true);

    // PCI DSS Req. 10 — log attempt
    SecurityService().logEvent(SecurityEventType.paymentAttempted,
        'Card merchant=$recipient amount=${amount.toStringAsFixed(2)}');

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      // 1. Deduct balance
      ref.read(homeProvider.notifier).updateBalance(balance - amount);

      // 2. Transaction record
      final txnId = 'TXN-${DateTime.now().millisecondsSinceEpoch}';
      ref.read(transactionsProvider.notifier).addTransaction(TransactionModel(
            id: txnId,
            title: 'Card Payment to $recipient',
            category: 'Shopping',
            amount: -amount,
            date: DateTime.now(),
            type: 'sent',
            iconKey: 'credit_card',
            colorKey: 'textDark',
          ));

      // 3. Rewards (gamification spec)
      final earned = ref.read(rewardsProvider.notifier).earnRewards(
            merchant: recipient,
            amount: amount,
            category: 'Shopping',
          );

      // 4. Audit success
      SecurityService().logEvent(SecurityEventType.paymentSucceeded,
          'Card txnId=$txnId cashback=${earned.cashback} pts=${earned.points}');

      // 5. Navigate
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            amount: amount,
            recipientName: recipient,
            details: {
              'Transaction ID': txnId,
              'Date & Time': DateFormatter.display(DateTime.now()),
              'Payment Method': 'Credit Card',
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
}
