import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../model/contact_model.dart';
import 'amount_input_screen.dart';

class ContactSelectionScreen extends StatelessWidget {
  const ContactSelectionScreen({super.key});

  // Mock Data
  static const List<ContactModel> _contacts = [
    ContactModel(
      id: '1',
      name: 'Alice Johnson',
      maskedAccount: '**** 1234',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
    ),
    ContactModel(
      id: '2',
      name: 'Bob Smith',
      maskedAccount: '**** 5678',
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
    ),
    ContactModel(
      id: '3',
      name: 'Charlie Davis',
      maskedAccount: '**** 9012',
      avatarUrl: null, // Test initials fallback
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Send Money'),
        leading: const BackButton(),
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: _contacts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final contact = _contacts[index];
            return _ContactTile(
              contact: contact,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AmountInputScreen(recipient: contact),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final ContactModel contact;
  final VoidCallback onTap;

  const _ContactTile({required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentLime,
              ),
              clipBehavior: Clip.antiAlias,
              child: contact.avatarUrl != null
                  ? Image.network(
                      contact.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            contact.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryDarkGreen,
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        contact.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDarkGreen,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact.maskedAccount,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }
}
