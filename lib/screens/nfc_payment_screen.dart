import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'payment_success_screen.dart';

class NFCPaymentScreen extends StatefulWidget {
  const NFCPaymentScreen({super.key});

  @override
  State<NFCPaymentScreen> createState() => _NFCPaymentScreenState();
}

class _NFCPaymentScreenState extends State<NFCPaymentScreen>
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
    setState(() {
      _isScanning = true;
    });
    // Simulate payment after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              amount: _amountController.text.isEmpty
                  ? '0.00'
                  : _amountController.text,
              merchant: 'Merchant Name',
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
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDarkTeal,
                        ),
                        decoration: const InputDecoration(
                          prefixText: '\? ',
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Animated Rings
                            if (_isScanning) ...[
                              AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  return Container(
                                    width: 200 + (_controller.value * 100),
                                    height: 200 + (_controller.value * 100),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.primaryTeal.withOpacity(
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
                            ],
                            // NFC Icon
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: _isScanning
                                    ? AppTheme.primaryGradient
                                    : null,
                                color: _isScanning
                                    ? null
                                    : AppTheme.primaryDarkTeal.withOpacity(0.1),
                                boxShadow: _isScanning
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryDarkTeal
                                              .withOpacity(0.3),
                                          blurRadius: 40,
                                          spreadRadius: 10,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                Icons.contactless,
                                size: 100,
                                color: _isScanning
                                    ? Colors.white
                                    : AppTheme.primaryDarkTeal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          _isScanning
                              ? 'Hold your phone near the terminal'
                              : 'Tap to pay with NFC',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _isScanning
                                ? AppTheme.primaryDarkTeal
                                : AppTheme.textLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_isScanning) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Processing payment...',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
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
                      onPressed: _amountController.text.isEmpty
                          ? null
                          : _startScanning,
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
