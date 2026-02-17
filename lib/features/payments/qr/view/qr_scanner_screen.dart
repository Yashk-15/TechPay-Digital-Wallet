import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../features/transactions/controller/transactions_controller.dart';
import '../../../../features/transactions/model/transaction_model.dart';
import '../../../../features/home/controller/home_controller.dart';
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
            icon: const Icon(Icons.flash_on_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryDarkTeal,
              AppTheme.primaryTeal,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Scanner Frame
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.primaryTeal,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          // Corner Highlights
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: AppTheme.accentMintGreen,
                                    width: 4,
                                  ),
                                  left: BorderSide(
                                    color: AppTheme.accentMintGreen,
                                    width: 4,
                                  ),
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(17),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: AppTheme.accentMintGreen,
                                    width: 4,
                                  ),
                                  right: BorderSide(
                                    color: AppTheme.accentMintGreen,
                                    width: 4,
                                  ),
                                ),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(17),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppTheme.accentMintGreen,
                                    width: 4,
                                  ),
                                  left: BorderSide(
                                    color: AppTheme.accentMintGreen,
                                    width: 4,
                                  ),
                                ),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(17),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppTheme.accentMintGreen,
                                    width: 4,
                                  ),
                                  right: BorderSide(
                                    color: AppTheme.accentMintGreen,
                                    width: 4,
                                  ),
                                ),
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(17),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Align QR code within frame',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The QR code will be scanned automatically',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Simulate QR Scan & Payment
                          _simulateQRPayment(context, ref);
                        },
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Simulate Scan (Demo)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: AppTheme.gradientButtonDecoration(),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showMyQRCode(context);
                        },
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text('Show My QR Code'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMyQRCode(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'My QR Code',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_2,
                  size: 160,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'john.doe@techpay.com',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _simulateQRPayment(BuildContext context, WidgetRef ref) {
    // Mock Payment Data
    const double amount = 150.00;
    const String recipientName = 'Merchant QR';

    // 1. Deduct Balance
    final currentBalance = ref.read(homeProvider).balance;
    if (amount > currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance')),
      );
      return;
    }
    ref.read(homeProvider.notifier).updateBalance(currentBalance - amount);

    // 2. Add Transaction
    final txnId = 'TXN-${DateTime.now().millisecondsSinceEpoch}';
    final newTransaction = TransactionModel(
      id: txnId,
      title: recipientName,
      category: 'Shopping',
      amount: -amount,
      date: DateTime.now(),
      type: 'sent',
      iconKey: 'qr_code',
      colorKey: 'textDark',
    );
    ref.read(transactionsProvider.notifier).addTransaction(newTransaction);

    // 3. Navigate
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(
          amount: amount,
          recipientName: recipientName,
          details: {
            'Transaction ID': txnId,
            'Date & Time': DateFormatter.display(DateTime.now()),
            'Payment Method': 'QR Code',
          },
        ),
      ),
    );
  }
}
