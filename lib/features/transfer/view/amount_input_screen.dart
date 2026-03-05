import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/validators.dart';
import '../controller/transfer_controller.dart';
import '../../home/controller/home_controller.dart';
import '../model/contact_model.dart';
import 'confirmation_screen.dart';

class AmountInputScreen extends ConsumerStatefulWidget {
  final ContactModel recipient;
  const AmountInputScreen({super.key, required this.recipient});

  @override
  ConsumerState<AmountInputScreen> createState() => _AmountInputScreenState();
}

class _AmountInputScreenState extends ConsumerState<AmountInputScreen> {
  final _controller = TextEditingController();
  final _noteController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final raw = _controller.text.trim();
    final validationError = Validators.validateAmount(raw);
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    setState(() => _error = null);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmationScreen(
          recipient: widget.recipient,
          amount: double.parse(raw),
          note: _noteController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transferState = ref.watch(transferProvider);
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgAbyss,
      appBar: AppBar(
        title:
            const Text('Send Money', style: TextStyle(color: AppTheme.text100)),
        leading: const BackButton(color: AppTheme.text100),
        elevation: 0,
        backgroundColor: AppTheme.bgSurface,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Recipient tile
                    _RecipientTile(recipient: widget.recipient),
                    const SizedBox(height: 40),
                    // Amount input
                    _AmountField(
                      controller: _controller,
                      error: _error,
                      onChanged: (_) => setState(() => _error = null),
                    ),
                    const SizedBox(height: 8),
                    // Available balance
                    Text(
                      'Available: ${CurrencyFormatter.format(homeState.balance)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.text400,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Note field
                    TextField(
                      controller: _noteController,
                      maxLength: 60,
                      decoration: const InputDecoration(
                        labelText: 'Add a note (optional)',
                        labelStyle: TextStyle(color: AppTheme.text400),
                        prefixIcon: Icon(Icons.note_alt_outlined,
                            color: AppTheme.text400),
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
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Quick amount chips
                    _QuickAmounts(
                      onSelect: (amt) {
                        _controller.text = amt.toStringAsFixed(0);
                        setState(() => _error = null);
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Bottom CTA — always above keyboard
            Padding(
              padding: EdgeInsets.fromLTRB(
                  24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: transferState.isLoading ? null : _onContinue,
                  child: transferState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Continue',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipientTile extends StatelessWidget {
  final ContactModel recipient;
  const _RecipientTile({required this.recipient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bgBorder),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.coralDim,
            // FIX: actually loads NetworkImage when URL is present
            backgroundImage: recipient.avatarUrl != null
                ? NetworkImage(recipient.avatarUrl!)
                : null,
            child: recipient.avatarUrl == null
                ? Text(recipient.name[0].toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppTheme.coral))
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipient.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.text100,
                  ),
                ),
                const SizedBox(height: 4),
                // MASKED account — never show full number
                Text(
                  recipient.maskedAccount,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.text400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              color: AppTheme.success, size: 20),
        ],
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final ValueChanged<String> onChanged;

  const _AmountField({
    required this.controller,
    required this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
            IntrinsicWidth(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 48,
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
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text400,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(
            error!,
            style: const TextStyle(fontSize: 13, color: AppTheme.error),
          ),
        ],
      ],
    );
  }
}

class _QuickAmounts extends StatelessWidget {
  final ValueChanged<double> onSelect;
  const _QuickAmounts({required this.onSelect});

  static const _amounts = [500.0, 1000.0, 2000.0, 5000.0];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _amounts.map((amt) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: () => onSelect(amt),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.coralDim,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.coral.withOpacity(0.3),
                ),
              ),
              child: Text(
                '₹${amt.toInt()}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.coral,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
