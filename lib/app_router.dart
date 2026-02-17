import 'package:flutter/material.dart';
import 'features/onboarding/view/welcome_screen.dart';
import 'features/dashboard/view/dashboard_view.dart';
import 'features/dashboard/view/balance_overview_screen.dart';
import 'features/transactions/view/transactions_screen.dart';
import 'features/rewards/view/rewards_screen.dart';
import 'features/profile/view/settings_screen.dart';
import 'features/payments/nfc/view/nfc_payment_screen.dart';
import 'features/payments/qr/view/qr_scanner_screen.dart';
import 'features/payments/split/view/split_payment_screen.dart';
import 'features/wallet/view/cards_screen.dart';
import 'features/onboarding/view/create_account_screen.dart';

class AppRouter {
  static const String welcome = '/';
  static const String dashboard = '/dashboard';
  static const String balanceOverview = '/balance_overview';
  static const String transactions = '/transactions';
  static const String rewards = '/rewards';
  static const String settings = '/settings';
  static const String nfcPayment = '/nfc_payment';
  static const String qrScanner = '/qr_scanner';
  static const String splitPayment = '/split_payment';
  static const String cards = '/cards';
  static const String createAccount = '/create_account';

  static Map<String, WidgetBuilder> get routes => {
        welcome: (context) => const WelcomeScreen(),
        dashboard: (context) => const DashboardView(),
        balanceOverview: (context) => const BalanceOverviewScreen(),
        transactions: (context) => const TransactionsScreen(),
        rewards: (context) => const RewardsScreen(),
        settings: (context) => const SettingsScreen(),
        nfcPayment: (context) => const NFCPaymentScreen(),
        qrScanner: (context) => const QRScannerScreen(),
        splitPayment: (context) => const SplitPaymentScreen(),
        cards: (context) => const CardsScreen(),
        createAccount: (context) => const CreateAccountScreen(),
      };
}
