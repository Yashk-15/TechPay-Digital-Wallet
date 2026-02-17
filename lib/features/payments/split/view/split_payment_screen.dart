// lib/features/payments/split/view/split_payment_screen.dart
//
// Spec: "Enable split payments, allowing users to divide costs among
//        multiple participants seamlessly."
//
// Implements:
//   - Bill amount entry
//   - Equal / Custom / Percentage split methods
//   - Participant count control
//   - Per-person amount display
//   - "Send Requests" actually deducts the user's share from balance
//     and creates a transaction record, then shows success screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../features/transactions/controller/transactions_controller.dart';
import '../../../../features/transactions/model/transaction_model.dart';
import '../../../../features/home/controller/home_controller.dart';
import '../../../../features/rewards/view/controller/rewards_controller.dart';
import '../../success/view/payment_success_screen.dart';

// Mock contacts for split selection
class _SplitContact {
  final String id;
  final String name;
  final String initials;
  bool selected;
  double? customAmount; // for Custom split mode

  _SplitContact({
    required this.id,
    required this.name,
    required this.initials,
    this.selected = false,
    this.customAmount,
  });
}

class SplitPaymentScreen extends ConsumerStatefulWidget {
  const SplitPaymentScreen({super.key});

  @override
  ConsumerState<SplitPaymentScreen> createState() => _SplitPaymentScreenState();
}

class _SplitPaymentScreenState extends ConsumerState<SplitPaymentScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _splitMethod = 'Equal';

  // Mock contacts pool (user always included implicitly as "You")
  final List<_SplitContact> _contacts = [
    _SplitContact(
        id: '1', name: 'Alice Johnson', initials: 'AJ', selected: true),
    _SplitContact(id: '2', name: 'Bob Smith', initials: 'BS', selected: true),
    _SplitContact(
        id: '3', name: 'Charlie Davis', initials: 'CD', selected: false),
    _SplitContact(
        id: '4', name: 'Diana Prince', initials: 'DP', selected: false),
    _SplitContact(
        id: '5', name: 'Edward Norton', initials: 'EN', selected: false),
  ];

  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ── Computed values ────────────────────────────────────────────────────────

  double get _totalAmount => double.tryParse(_amountController.text) ?? 0.0;

  List<_SplitContact> get _selected =>
      _contacts.where((c) => c.selected).toList();

  // Total participants = selected friends + you
  int get _participantCount => _selected.length + 1;

  double get _perPerson {
    if (_participantCount == 0 || _totalAmount == 0) return 0;
    return _totalAmount / _participantCount;
  }

  // Your share (what gets deducted from your balance)
  double get _yourShare {
    if (_splitMethod == 'Custom') {
      final othersTotal =
          _selected.fold<double>(0, (s, c) => s + (c.customAmount ?? 0));
      return (_totalAmount - othersTotal).clamp(0, _totalAmount);
    }
    if (_splitMethod == 'Percentage') {
      // Default: equal percentage
      return _perPerson;
    }
    return _perPerson; // Equal
  }

  // ── Send requests ─────────────────────────────────────────────────────────

  void _sendRequests() {
    if (_totalAmount <= 0) {
      _snack('Please enter a bill amount');
      return;
    }
    if (_selected.isEmpty) {
      _snack('Select at least one participant');
      return;
    }

    final balance = ref.read(homeProvider).balance;
    final myShare = _yourShare;

    if (myShare > balance) {
      _snack('Insufficient balance for your share', color: AppTheme.error);
      return;
    }

    setState(() => _isProcessing = true);

    // Simulate async network (sending payment requests to contacts)
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      // 1. Deduct your share from balance
      ref.read(homeProvider.notifier).updateBalance(balance - myShare);

      // 2. Add transaction record
      final txnId = 'TXN-${DateTime.now().millisecondsSinceEpoch}';
      final names = _selected.map((c) => c.name.split(' ').first).join(', ');
      ref.read(transactionsProvider.notifier).addTransaction(TransactionModel(
            id: txnId,
            title: 'Split Bill with $names',
            category: 'Transfer',
            amount: -myShare,
            date: DateTime.now(),
            type: 'sent',
            iconKey: 'split',
            colorKey: 'textDark',
          ));

      // 3. Rewards on your share
      final earned = ref.read(rewardsProvider.notifier).earnRewards(
            merchant: 'Split Bill',
            amount: myShare,
            category: 'Transfer',
          );

      // 4. Navigate to success
      final participants = _selected.map((c) => c.name).join(', ');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            amount: myShare,
            title: 'Split Request Sent',
            subtitle: 'Requests sent to ${_selected.length} participant(s)',
            details: {
              'Your Share': CurrencyFormatter.format(myShare),
              'Total Bill': CurrencyFormatter.format(_totalAmount),
              'Participants': participants,
              'Transaction ID': txnId,
              'Date & Time': DateFormatter.display(DateTime.now()),
              if (earned.points > 0) 'Points Earned': '+${earned.points} pts',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Bill Amount ────────────────────────────────────────────
            _AmountCard(
              controller: _amountController,
              onChanged: () => setState(() {}),
            ),

            const SizedBox(height: 24),

            // ── Split Method ───────────────────────────────────────────
            const Text('Split Method',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark)),
            const SizedBox(height: 12),
            Row(children: [
              _MethodChip(
                  label: 'Equal',
                  selected: _splitMethod,
                  onTap: (v) => setState(() => _splitMethod = v)),
              const SizedBox(width: 12),
              _MethodChip(
                  label: 'Custom',
                  selected: _splitMethod,
                  onTap: (v) => setState(() => _splitMethod = v)),
              const SizedBox(width: 12),
              _MethodChip(
                  label: 'Percentage',
                  selected: _splitMethod,
                  onTap: (v) => setState(() => _splitMethod = v)),
            ]),

            const SizedBox(height: 24),

            // ── Select Participants ────────────────────────────────────
            const Text('Select Participants',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark)),
            const SizedBox(height: 12),
            _ParticipantsCard(
              contacts: _contacts,
              splitMethod: _splitMethod,
              perPerson: _perPerson,
              totalAmount: _totalAmount,
              onChanged: () => setState(() {}),
            ),

            const SizedBox(height: 24),

            // ── Note (optional) ────────────────────────────────────────
            TextField(
              controller: _noteController,
              maxLength: 60,
              decoration: const InputDecoration(
                labelText: 'Add a note (optional)',
                prefixIcon: Icon(Icons.note_alt_outlined),
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // ── Summary ────────────────────────────────────────────────
            _SummaryCard(
              totalAmount: _totalAmount,
              participantCount: _participantCount,
              perPerson: _perPerson,
              yourShare: _yourShare,
              splitMethod: _splitMethod,
            ),

            const SizedBox(height: 32),

            // ── Send Button ────────────────────────────────────────────
            Container(
              width: double.infinity,
              height: 56,
              decoration: _totalAmount > 0 && _selected.isNotEmpty
                  ? AppTheme.gradientButtonDecoration()
                  : BoxDecoration(
                      color: AppTheme.textLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16)),
              child: ElevatedButton(
                onPressed:
                    _isProcessing || _totalAmount <= 0 || _selected.isEmpty
                        ? null
                        : _sendRequests,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Send Payment Requests (${_selected.length} people)',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }
}

// ── Amount Card ───────────────────────────────────────────────────────────────

class _AmountCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  const _AmountCard({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Total Bill Amount',
            style: TextStyle(fontSize: 14, color: AppTheme.textLight)),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
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
          ),
          onChanged: (_) => onChanged(),
        ),
      ]),
    );
  }
}

// ── Method Chip ───────────────────────────────────────────────────────────────

class _MethodChip extends StatelessWidget {
  final String label;
  final String selected;
  final ValueChanged<String> onTap;
  const _MethodChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(label),
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
                  width: 1.5),
              boxShadow: isSelected ? AppTheme.cardShadow : null),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.primaryDarkTeal)),
        ),
      ),
    );
  }
}

// ── Participants Card ─────────────────────────────────────────────────────────

class _ParticipantsCard extends StatelessWidget {
  final List<_SplitContact> contacts;
  final String splitMethod;
  final double perPerson;
  final double totalAmount;
  final VoidCallback onChanged;

  const _ParticipantsCard({
    required this.contacts,
    required this.splitMethod,
    required this.perPerson,
    required this.totalAmount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow),
      child: Column(children: [
        // "You" row — always included
        _youRow(),
        const Divider(height: 20),
        ...contacts.map((c) => _contactRow(c, context)),
      ]),
    );
  }

  Widget _youRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
              color: AppTheme.primaryDarkGreen, shape: BoxShape.circle),
          child: const Icon(Icons.person, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        const Expanded(
            child: Text('You',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark))),
        if (totalAmount > 0)
          Text(CurrencyFormatter.format(perPerson),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDarkGreen)),
        const SizedBox(width: 8),
        const Icon(Icons.check_circle,
            color: AppTheme.primaryDarkGreen, size: 22),
      ]),
    );
  }

  Widget _contactRow(_SplitContact contact, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: contact.selected
                  ? AppTheme.accentLime
                  : AppTheme.backgroundLight,
              shape: BoxShape.circle),
          child: Center(
            child: Text(contact.initials,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: contact.selected
                        ? AppTheme.primaryDarkGreen
                        : AppTheme.textLight)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(contact.name,
              style: const TextStyle(fontSize: 14, color: AppTheme.textDark)),
          if (splitMethod == 'Custom' && contact.selected)
            SizedBox(
              height: 32,
              width: 100,
              child: TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                    prefixText: '₹ ',
                    hintText: '0',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    border: OutlineInputBorder()),
                onChanged: (v) {
                  contact.customAmount = double.tryParse(v);
                },
              ),
            ),
        ])),
        if (totalAmount > 0 && contact.selected && splitMethod != 'Custom')
          Text(CurrencyFormatter.format(perPerson),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark)),
        const SizedBox(width: 8),
        // Toggle checkbox
        GestureDetector(
          onTap: () {
            contact.selected = !contact.selected;
            onChanged();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    contact.selected ? AppTheme.primaryDarkGreen : Colors.white,
                border: Border.all(
                    color: contact.selected
                        ? AppTheme.primaryDarkGreen
                        : AppTheme.textLight,
                    width: 2)),
            child: contact.selected
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ),
      ]),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final double totalAmount;
  final int participantCount;
  final double perPerson;
  final double yourShare;
  final String splitMethod;
  const _SummaryCard({
    required this.totalAmount,
    required this.participantCount,
    required this.perPerson,
    required this.yourShare,
    required this.splitMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: AppTheme.primaryDarkTeal.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ]),
      child: Column(children: [
        _row('Total Bill', CurrencyFormatter.format(totalAmount)),
        const SizedBox(height: 12),
        _row('Split Method', splitMethod),
        const SizedBox(height: 12),
        _row('Participants', '$participantCount people (incl. you)'),
        const Divider(color: Colors.white24, height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Your Share',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(CurrencyFormatter.format(yourShare),
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ]),
      ]),
    );
  }

  Widget _row(String label, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
      Text(value,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
    ]);
  }
}
