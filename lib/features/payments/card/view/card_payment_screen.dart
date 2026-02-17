import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../success/view/payment_success_screen.dart';

class CardPaymentScreen extends StatefulWidget {
  const CardPaymentScreen({super.key});

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  int _selectedCardIndex = 0;
  bool _isLoading = false;
  final _amountController = TextEditingController();
  final _recipientController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Recipient & Amount
            const Text(
              'Payment Details',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _recipientController,
                    decoration: const InputDecoration(
                      labelText: 'Recipient Name / Merchant',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.store),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 2. Select Card
            const Text(
              'Select Card',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PageView.builder(
                itemCount: 2, // Mock 2 cards
                controller: PageController(viewportFraction: 0.9),
                onPageChanged: (index) {
                  setState(() {
                    _selectedCardIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  // Mock Card Data
                  final isVisa = index == 1;
                  final color = isVisa
                      ? const LinearGradient(
                          colors: [Color(0xFF1A5C58), Color(0xFF2D8B7A)])
                      : AppTheme.primaryGradient;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: color,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: _selectedCardIndex == index
                          ? AppTheme.cardShadow
                          : [],
                    ),
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
                          ],
                        ),
                        Text(isVisa ? '•••• 8765' : '•••• 4582',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(isVisa ? '08/26' : '12/25',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            const Icon(Icons.check_circle,
                                color: Colors.white,
                                size: 28), // Selected Indicator
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Add New Card Button (Placeholder)
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: AppTheme.primaryDarkTeal),
                label: const Text('Add New Card',
                    style: TextStyle(color: AppTheme.primaryDarkTeal)),
              ),
            ),

            const SizedBox(height: 40),

            // Pay Button
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
                  elevation: 4,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Pay Now',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment() {
    if (_amountController.text.isEmpty || _recipientController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter valid amount and recipient')));
      return;
    }

    setState(() => _isLoading = true);

    // Simulate Network Delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        // Navigate to Success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              amount: double.parse(_amountController.text),
              recipient: _recipientController.text,
            ),
          ),
        );
      }
    });
  }
}
