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
import '../../../../features/wallet/controller/cards_controller.dart';
import '../../../../features/wallet/view/bank_card_widget.dart';
import '../../../../app_router.dart';
import '../../success/view/payment_success_screen.dart';

class CardPaymentScreen extends ConsumerStatefulWidget {
  const CardPaymentScreen({super.key});

  @override
  ConsumerState<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends ConsumerState<CardPaymentScreen> {
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
      backgroundColor: AppTheme.bgAbyss,
      appBar: AppBar(
        title: const Text('Pay via Card',
            style: TextStyle(color: AppTheme.text100)),
        backgroundColor: AppTheme.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 20, color: AppTheme.text100),
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
                  color: AppTheme.text100)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.bgBorder),
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
                  color: AppTheme.text100)),
          const SizedBox(height: 16),
          // Fetch cards from provider
          Consumer(
            builder: (context, ref, child) {
              final cardsState = ref.watch(cardsProvider);
              final cards = cardsState.cards;

              if (cards.isEmpty) {
                return Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppTheme.bgElevated,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.bgBorder),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.credit_card_off,
                            size: 48, color: AppTheme.text400),
                        const SizedBox(height: 8),
                        const Text('No cards added yet',
                            style: TextStyle(color: AppTheme.text400)),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRouter.cards),
                          child: const Text('Add Card',
                              style: TextStyle(color: AppTheme.coral)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 180,
                child: PageView.builder(
                  itemCount: cards.length,
                  controller: PageController(viewportFraction: 1.0),
                  itemBuilder: (_, index) {
                    return BankCardWidget(card: cards[index]);
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: AppTheme.coral),
              label: const Text('Add New Card',
                  style: TextStyle(color: AppTheme.coral)),
            ),
          ),

          const SizedBox(height: 40),

          // ── Pay Button ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16)),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Pay Now',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Payment Processing ────────────────────────────────────────────────────

  void _processPayment() {
    // Dismiss keyboard before showing loading
    FocusScope.of(context).unfocus();

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
