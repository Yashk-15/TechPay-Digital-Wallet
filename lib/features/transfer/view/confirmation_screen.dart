import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../controller/transfer_controller.dart';
import '../model/contact_model.dart';
import '../../payments/success/view/payment_success_screen.dart';
import '../../../core/utils/date_formatter.dart';

class ConfirmationScreen extends ConsumerWidget {
  final ContactModel recipient;
  final double amount;
  final String? note;

  const ConfirmationScreen({
    super.key,
    required this.recipient,
    required this.amount,
    this.note,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transferState = ref.watch(transferProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgAbyss,
      appBar: AppBar(
        title: const Text('Confirm Transfer',
            style: TextStyle(color: AppTheme.text100)),
        leading: const BackButton(color: AppTheme.text100),
        elevation: 0,
        backgroundColor: AppTheme.bgSurface,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // FIX: Show error state when transfer fails
              if (transferState.error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 114, 92, 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.coral.withOpacity(0.3)),
                  ),
                  child: Text(transferState.error!,
                      style:
                          const TextStyle(color: AppTheme.coral, fontSize: 14)),
                ),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.bgBorder),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppTheme.coralDim,
                        // FIX: loads image when URL present
                        backgroundImage: recipient.avatarUrl != null
                            ? NetworkImage(recipient.avatarUrl!)
                            : null,
                        child: recipient.avatarUrl == null
                            ? Text(
                                recipient.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.coral,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sending to ${recipient.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.text400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(amount),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.text100,
                          letterSpacing: -1,
                        ),
                      ),
                      if (note?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.bgElevated,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '"$note"',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: AppTheme.text100,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: transferState.isLoading
                      ? null
                      : () async {
                          final success = await ref
                              .read(transferProvider.notifier)
                              .initiateTransfer(
                                recipientId: recipient.id,
                                amount: amount,
                                note: note,
                              );

                          if (success && context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentSuccessScreen(
                                  amount: amount,
                                  recipientName: recipient.name,
                                  title: 'Transfer Successful',
                                  subtitle: 'Your money is on its way',
                                  details: {
                                    'To': recipient.name,
                                    'Account': recipient.maskedAccount,
                                    'Reference':
                                        '#TXN-${DateTime.now().millisecondsSinceEpoch}', // Mock ID or retrieve from controller
                                    'Date & Time':
                                        DateFormatter.display(DateTime.now()),
                                    if (note != null && note!.isNotEmpty)
                                      'Note': note!,
                                  },
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.coral,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: transferState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Confirm & Send',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
