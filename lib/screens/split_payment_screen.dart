import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SplitPaymentScreen extends StatefulWidget {
  const SplitPaymentScreen({super.key});

  @override
  State<SplitPaymentScreen> createState() => _SplitPaymentScreenState();
}

class _SplitPaymentScreenState extends State<SplitPaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _splitMethod = 'Equal';
  int _participantCount = 2;

  @override
  Widget build(BuildContext context) {
    final double totalAmount = double.tryParse(_amountController.text) ?? 0.0;
    final double perPerson = totalAmount / _participantCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.accentMintGreen.withOpacity(0.05),
              AppTheme.accentMintGreen.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Amount Card
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
                        'Total Bill Amount',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDarkTeal,
                        ),
                        decoration: const InputDecoration(
                          prefixText: '? ',
                          prefixStyle: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDarkTeal,
                          ),
                          hintText: '0.00',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Split Method
                const Text(
                  'Split Method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildMethodChip('Equal'),
                    const SizedBox(width: 12),
                    _buildMethodChip('Custom'),
                    const SizedBox(width: 12),
                    _buildMethodChip('Percentage'),
                  ],
                ),
                const SizedBox(height: 24),
                // Participants
                const Text(
                  'Number of People',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _participantCount > 2
                            ? () => setState(() => _participantCount--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppTheme.primaryDarkTeal,
                        iconSize: 32,
                      ),
                      const Text(
                        '?_participantCount',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDarkTeal,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _participantCount++),
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppTheme.primaryDarkTeal,
                        iconSize: 32,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Per Person Amount
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryDarkTeal.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Per Person',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '₹${perPerson.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Send Request Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: AppTheme.gradientButtonDecoration(
                    gradient: AppTheme.accentGradient,
                  ),
                  child: ElevatedButton(
                    onPressed: totalAmount > 0 ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Send Payment Requests',
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

  Widget _buildMethodChip(String method) {
    final isSelected = _splitMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _splitMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : AppTheme.primaryDarkTeal.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: isSelected ? AppTheme.cardShadow : null,
          ),
          child: Text(
            method,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.primaryDarkTeal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
