import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../success/view/payment_success_screen.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../features/transactions/controller/transactions_controller.dart'; // Import Transactions
import '../../../../features/transactions/model/transaction_model.dart';
import '../../../home/controller/home_controller.dart'; // Import Home Provider

class NFCPaymentScreen extends ConsumerStatefulWidget {
  const NFCPaymentScreen({super.key});

  @override
  ConsumerState<NFCPaymentScreen> createState() => _NFCPaymentScreenState();
}

class _NFCPaymentScreenState extends ConsumerState<NFCPaymentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isScanning = false;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _startScanning() {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText);

    // Server-side validation simulation
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final currentBalance = ref.read(homeProvider).balance;
    if (amount > currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (amount > 50000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Amount exceeds daily NFC limit of ₹50,000'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isScanning = true;
    });

    // Simulate payment after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // 1. Deduct Balance
        ref.read(homeProvider.notifier).updateBalance(currentBalance - amount);

        // 2. Add Transaction
        final txnId = 'TXN-${DateTime.now().millisecondsSinceEpoch}';
        final newTransaction = TransactionModel(
          id: txnId,
          title: 'Starbucks NFC',
          category: 'Shopping',
          amount: -amount,
          date: DateTime.now(),
          type: 'sent',
          iconKey: 'shopping',
          colorKey: 'textDark',
        );
        ref.read(transactionsProvider.notifier).addTransaction(newTransaction);

        // 3. Navigate to Success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              amount: amount,
              recipientName: 'Starbucks NFC',
              details: {
                'Transaction ID': txnId,
                'Date & Time': DateFormatter.display(DateTime.now()),
                'Payment Method': 'NFC Contactless',
              },
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Amount Input
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDarkTeal,
                        ),
                        decoration: const InputDecoration(
                          prefixText: '₹ ',
                          prefixStyle: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDarkTeal,
                          ),
                          hintText: '0.00',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // NFC Animation
                Expanded(
                  child: Center(
                    child: _isScanning
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Animated Rings
                                  AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      return Container(
                                        width: 200 + (_controller.value * 100),
                                        height: 200 + (_controller.value * 100),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppTheme.primaryTeal
                                                .withOpacity(
                                              1 - _controller.value,
                                            ),
                                            width: 2,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      final delayedValue =
                                          (_controller.value + 0.3) % 1.0;
                                      return Container(
                                        width: 200 + (delayedValue * 100),
                                        height: 200 + (delayedValue * 100),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppTheme.primaryDarkTeal
                                                .withOpacity(1 - delayedValue),
                                            width: 2,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // NFC Icon
                                  Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: AppTheme.primaryGradient,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryDarkTeal
                                              .withOpacity(0.3),
                                          blurRadius: 40,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.contactless,
                                      size: 100,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              const Text(
                                'Hold your phone near the terminal',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryDarkTeal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Processing payment...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.primaryDarkTeal
                                          .withOpacity(0.1),
                                    ),
                                    child: const Icon(
                                      Icons.contactless,
                                      size: 100,
                                      color: AppTheme.primaryDarkTeal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              const Text(
                                'Tap to pay with NFC',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                ),
                // Pay Button
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
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Start NFC Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
