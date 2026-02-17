import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_pill_button.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../controller/transfer_controller.dart';
import '../model/contact_model.dart';
import 'success_screen.dart';

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
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Confirm Transfer'),
        leading: const BackButton(),
        elevation: 0,
        backgroundColor: AppTheme.backgroundLight,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppTheme.accentLime,
                        child: recipient.avatarUrl == null
                            ? Text(
                                recipient.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryDarkGreen,
                                ),
                              )
                            : const Icon(Icons.person,
                                size: 40, color: AppTheme.primaryDarkGreen),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sending to ${recipient.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(amount),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                          letterSpacing: -1,
                        ),
                      ),
                      if (note?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '"$note"',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: AppTheme.textDark,
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
                child: CustomPillButton(
                  text: transferState.isLoading
                      ? 'Processing...'
                      : 'Confirm & Send',
                  icon: Icons.check,
                  isLight: false,
                  onTap: transferState.isLoading
                      ? () {}
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
                                builder: (_) => SuccessScreen(
                                  amount: amount,
                                  recipient: recipient,
                                  partialTxnId: 'XYZ789', // Mock ID
                                  timestamp: DateTime.now(),
                                  note: note,
                                ),
                              ),
                            );
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
