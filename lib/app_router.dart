// lib/app_router.dart

import 'package:flutter/material.dart';
import 'features/onboarding/view/welcome_screen.dart';
import 'features/onboarding/view/login_screen.dart';
import 'features/onboarding/view/signup_screen.dart';
import 'features/onboarding/view/post_login_welcome_screen.dart';
import 'features/home/view/home_screen.dart';
import 'features/home/view/balance_overview_screen.dart';
import 'features/transactions/view/transactions_screen.dart';
import 'features/rewards/view/rewards_screen.dart';
import 'features/profile/view/settings_screen.dart';
import 'features/payments/nfc/view/nfc_payment_screen.dart';
import 'features/payments/qr/view/qr_scanner_screen.dart';
import 'features/payments/split/view/split_payment_screen.dart';
import 'features/wallet/view/cards_screen.dart';
import 'features/transfer/view/contact_selection_screen.dart';
import 'features/payments/card/view/card_payment_screen.dart';

class AppRouter {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String postLoginWelcome = '/welcome_success';

  // ── App ───────────────────────────────────────────────────────────────────
  static const String home = '/home';
  static const String dashboard = home; // alias
  static const String balanceOverview = '/balance_overview';
  static const String transactions = '/transactions';
  static const String rewards = '/rewards';
  static const String settings = '/settings';

  // ── Payments ──────────────────────────────────────────────────────────────
  static const String nfcPayment = '/payment/nfc';
  static const String qrScanner = '/payment/qr';
  static const String splitPayment = '/payment/split';
  static const String cardPayment = '/payment/card';

  // ── Wallet / Transfer ─────────────────────────────────────────────────────
  static const String cards = '/cards';
  static const String contactSelection = '/transfer/contact_selection';
  static const String deposit = '/deposit';

  static Map<String, WidgetBuilder> get routes => {
        // Auth
        welcome: (_) => const WelcomeScreen(),
        login: (_) => const LoginScreen(),
        signup: (_) => const SignupScreen(),
        postLoginWelcome: (_) => const PostLoginWelcomeScreen(),

        // App
        home: (_) => const HomeScreen(),
        balanceOverview: (_) => const BalanceOverviewScreen(),
        transactions: (_) => const TransactionsScreen(),
        rewards: (_) => const RewardsScreen(),
        settings: (_) => const SettingsScreen(),

        // Payments
        nfcPayment: (_) => const NFCPaymentScreen(),
        qrScanner: (_) => const QRScannerScreen(),
        splitPayment: (_) => const SplitPaymentScreen(),
        cardPayment: (_) => const CardPaymentScreen(),

        // Wallet / Transfer
        cards: (_) => const CardsScreen(),
        contactSelection: (_) => const ContactSelectionScreen(),
        deposit: (_) => const DepositPlaceholderScreen(),

        // Legacy aliases
        '/payments': (_) => const NFCPaymentScreen(),
        '/scanner': (_) => const QRScannerScreen(),
      };
}

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
