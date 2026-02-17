import 'package:flutter/material.dart';
import 'features/onboarding/view/welcome_screen.dart';
import 'features/home/view/home_screen.dart';
import 'features/home/view/balance_overview_screen.dart';
import 'features/transactions/view/transactions_screen.dart';
import 'features/rewards/view/rewards_screen.dart';
import 'features/profile/view/settings_screen.dart';
import 'features/payments/nfc/view/nfc_payment_screen.dart';
import 'features/payments/qr/view/qr_scanner_screen.dart';
import 'features/payments/split/view/split_payment_screen.dart';
import 'features/wallet/view/cards_screen.dart';
import 'features/onboarding/view/create_account_screen.dart';
import 'features/transfer/view/contact_selection_screen.dart';
import 'features/onboarding/view/post_login_welcome_screen.dart';
import 'features/payments/card/view/card_payment_screen.dart';

class AppRouter {
  static const String welcome = '/';
  static const String home = '/home';
  static const String dashboard = home; // Alias
  static const String balanceOverview = '/balance_overview';
  static const String transactions = '/transactions';
  static const String rewards = '/rewards';
  static const String settings = '/settings';
  static const String nfcPayment = '/payment/nfc';
  static const String qrScanner = '/payment/qr';
  static const String splitPayment = '/payment/split';
  static const String cards = '/cards';
  static const String createAccount = '/create_account';
  static const String contactSelection = '/transfer/contact_selection';
  static const String deposit = '/deposit';
  static const String postLoginWelcome = '/welcome_success';
  static const String cardPayment = '/payment/card';

  static Map<String, WidgetBuilder> get routes => {
        welcome: (context) => const WelcomeScreen(),
        home: (context) => const HomeScreen(),
        // NOTE: do NOT register 'dashboard' separately — it has the same value as 'home'
        balanceOverview: (context) => const BalanceOverviewScreen(),
        transactions: (context) => const TransactionsScreen(),
        rewards: (context) => const RewardsScreen(),
        settings: (context) => const SettingsScreen(),
        nfcPayment: (context) => const NFCPaymentScreen(),
        qrScanner: (context) => const QRScannerScreen(),
        splitPayment: (context) => const SplitPaymentScreen(),
        cards: (context) => const CardsScreen(),
        createAccount: (context) => const CreateAccountScreen(),
        contactSelection: (context) => const ContactSelectionScreen(),
        deposit: (context) => const DepositPlaceholderScreen(),
        postLoginWelcome: (context) => const PostLoginWelcomeScreen(),
        cardPayment: (context) => const CardPaymentScreen(),
        // Aliases for legacy/broken links
        '/payments': (context) =>
            const NFCPaymentScreen(), // Default to NFC or a menu?
        '/scanner': (context) => const QRScannerScreen(),
      };
}

/// Placeholder until real Deposit feature is built.
class DepositPlaceholderScreen extends StatelessWidget {
  const DepositPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Up')),
      body: const Center(child: Text('Deposit feature coming soon')),
    );
  }
}
