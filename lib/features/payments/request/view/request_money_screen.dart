import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../features/home/controller/home_controller.dart';
import '../../split/view/split_payment_screen.dart';
import '../../success/view/payment_success_screen.dart';

// ── Mock contacts ──────────────────────────────────────────────────────────────
class _RequestContact {
  final String id;
  final String name;
  final String initials;
  final Color color;
  final String upiHandle;

  const _RequestContact({
    required this.id,
    required this.name,
    required this.initials,
    required this.color,
    required this.upiHandle,
  });
}

const List<_RequestContact> _defaultContacts = [
  _RequestContact(
    id: '1',
    name: 'Alice Johnson',
    initials: 'AJ',
    color: Color(0xFF6C63FF),
    upiHandle: 'alice@techpay',
  ),
  _RequestContact(
    id: '2',
    name: 'Bob Smith',
    initials: 'BS',
    color: Color(0xFF00BFA5),
    upiHandle: 'bobsmith@techpay',
  ),
  _RequestContact(
    id: '3',
    name: 'Charlie Davis',
    initials: 'CD',
    color: Color(0xFFFF7043),
    upiHandle: 'charlie@techpay',
  ),
  _RequestContact(
    id: '4',
    name: 'Diana Prince',
    initials: 'DP',
    color: Color(0xFFEC407A),
    upiHandle: 'diana@techpay',
  ),
  _RequestContact(
    id: '5',
    name: 'Edward Norton',
    initials: 'EN',
    color: Color(0xFF42A5F5),
    upiHandle: 'edward@techpay',
  ),
];

// ── Screen ─────────────────────────────────────────────────────────────────────
class RequestMoneyScreen extends ConsumerStatefulWidget {
  const RequestMoneyScreen({super.key});

  @override
  ConsumerState<RequestMoneyScreen> createState() => _RequestMoneyScreenState();
}

class _RequestMoneyScreenState extends ConsumerState<RequestMoneyScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  _RequestContact? _selected;
  String? _amountError;
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text.trim()) ?? 0.0;

  // ── Send request ───────────────────────────────────────────────────────────

  void _sendRequest() {
    // Dismiss keyboard first
    FocusScope.of(context).unfocus();
    // Validate contact selection
    if (_selected == null) {
      _showSnack('Please select a contact to request from');
      return;
    }
    // Validate amount
    final raw = _amountController.text.trim();
    if (raw.isEmpty || _amount <= 0) {
      setState(() => _amountError = 'Enter a valid amount');
      return;
    }
    setState(() {
      _amountError = null;
      _isProcessing = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      final txnId = 'REQ-${DateTime.now().millisecondsSinceEpoch}';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            amount: _amount,
            title: 'Request Sent!',
            subtitle: 'Your request has been sent to ${_selected!.name}',
            details: {
              'Requested from': _selected!.name,
              'UPI ID': _selected!.upiHandle,
              'Amount': CurrencyFormatter.format(_amount),
              'Request ID': txnId,
              'Date & Time': DateFormatter.display(DateTime.now()),
              if (_noteController.text.trim().isNotEmpty)
                'Note': _noteController.text.trim(),
            },
          ),
        ),
      );
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(homeProvider).balance;
    final canSend = _selected != null && _amount > 0 && !_isProcessing;

    return Scaffold(
      backgroundColor: AppTheme.bgAbyss,
      appBar: AppBar(
        title: const Text('Request Money',
            style: TextStyle(color: AppTheme.text100)),
        leading: const BackButton(color: AppTheme.text100),
        backgroundColor: AppTheme.bgSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ── Section label ─────────────────────────────────────
                    const Text(
                      'Request from',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.text100,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Contact row ───────────────────────────────────────
                    _ContactRow(
                      contacts: _defaultContacts,
                      selected: _selected,
                      onSelect: (c) => setState(() => _selected = c),
                    ),

                    const SizedBox(height: 28),

                    // ── Selected contact chip ─────────────────────────────
                    if (_selected != null) ...[
                      _SelectedChip(contact: _selected!),
                      const SizedBox(height: 24),
                    ],

                    // ── Amount input ──────────────────────────────────────
                    _AmountSection(
                      controller: _amountController,
                      balance: balance,
                      error: _amountError,
                      onChanged: (_) => setState(() {
                        _amountError = null;
                      }),
                    ),

                    const SizedBox(height: 24),

                    // ── Note field ────────────────────────────────────────
                    TextField(
                      controller: _noteController,
                      maxLength: 60,
                      style: const TextStyle(color: AppTheme.text100),
                      decoration: const InputDecoration(
                        labelText: 'Add a note (optional)',
                        labelStyle: TextStyle(color: AppTheme.text400),
                        prefixIcon: Icon(Icons.sticky_note_2_outlined,
                            color: AppTheme.text400),
                        counterText: '',
                        filled: true,
                        fillColor: AppTheme.bgInput,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: AppTheme.bgBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: AppTheme.bgBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide:
                              BorderSide(color: AppTheme.coral, width: 1.5),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 32),

                    // ── Primary CTA: Send Request ─────────────────────────
                    _SendButton(
                      canSend: canSend,
                      isProcessing: _isProcessing,
                      label: _selected != null
                          ? 'Request from ${_selected!.name.split(' ').first}'
                          : 'Select a contact first',
                      onTap: _sendRequest,
                    ),

                    const SizedBox(height: 16),

                    // ── Divider with "OR" ─────────────────────────────────
                    Row(children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textLight.withOpacity(0.6),
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ]),

                    const SizedBox(height: 16),

                    // ── Secondary CTA: Split Bill ─────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SplitPaymentScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.call_split_rounded),
                        label: const Text(
                          'Split Bill with Multiple People',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.coral,
                          side: const BorderSide(
                              color: AppTheme.coral, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Contact Row ───────────────────────────────────────────────────────────────

class _ContactRow extends StatelessWidget {
  final List<_RequestContact> contacts;
  final _RequestContact? selected;
  final ValueChanged<_RequestContact> onSelect;

  const _ContactRow({
    required this.contacts,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: AppTheme.bgBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: contacts
            .map((c) => _ContactAvatar(
                  contact: c,
                  isSelected: selected?.id == c.id,
                  onTap: () => onSelect(c),
                ))
            .toList(),
      ),
    );
  }
}

class _ContactAvatar extends StatelessWidget {
  final _RequestContact contact;
  final bool isSelected;
  final VoidCallback onTap;

  const _ContactAvatar({
    required this.contact,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isSelected ? contact.color : contact.color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? contact.color : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: contact.color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Stack(alignment: Alignment.center, children: [
            Text(
              contact.initials,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : contact.color,
              ),
            ),
            if (isSelected)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppTheme.coral,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 10),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 54,
          child: Text(
            contact.name.split(' ').first,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppTheme.coral : AppTheme.text400,
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Selected Contact Chip ──────────────────────────────────────────────────────

class _SelectedChip extends StatelessWidget {
  final _RequestContact contact;
  const _SelectedChip({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: contact.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: contact.color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: contact.color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              contact.initials,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              contact.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.text100,
              ),
            ),
            Text(
              contact.upiHandle,
              style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
            ),
          ]),
        ),
        Icon(Icons.check_circle_rounded, color: contact.color, size: 20),
      ]),
    );
  }
}

// ── Amount Section ─────────────────────────────────────────────────────────────

class _AmountSection extends StatelessWidget {
  final TextEditingController controller;
  final double balance;
  final String? error;
  final ValueChanged<String> onChanged;

  const _AmountSection({
    required this.controller,
    required this.balance,
    required this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.bgBorder),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amount to Request',
            style: TextStyle(fontSize: 13, color: AppTheme.text400),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '₹',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.coral,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}$')),
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.coral,
                    letterSpacing: -1,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text400,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 6),
            Text(error!,
                style: const TextStyle(fontSize: 13, color: AppTheme.error)),
          ],
          const SizedBox(height: 8),
          Text(
            'Your balance: ${CurrencyFormatter.format(balance)}',
            style: const TextStyle(fontSize: 12, color: AppTheme.text400),
          ),
          // Quick amount chips
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [200.0, 500.0, 1000.0, 2000.0].map((amt) {
              return GestureDetector(
                onTap: () {
                  controller.text = amt.toInt().toString();
                  onChanged(controller.text);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryDark.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    '₹${amt.toInt()}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Send Button ───────────────────────────────────────────────────────────────

class _SendButton extends StatelessWidget {
  final bool canSend;
  final bool isProcessing;
  final String label;
  final VoidCallback onTap;

  const _SendButton({
    required this.canSend,
    required this.isProcessing,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: canSend
          ? AppTheme.gradientButtonDecoration()
          : BoxDecoration(
              color: AppTheme.textLight.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
      child: ElevatedButton.icon(
        onPressed: canSend ? onTap : null,
        icon: isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.send_rounded, size: 20),
        label: Text(
          isProcessing ? 'Sending Request…' : label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledForegroundColor: AppTheme.textLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
