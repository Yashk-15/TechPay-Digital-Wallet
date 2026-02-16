import 'package:flutter/material.dart';
// import '../theme/app_theme.dart';
import '../screens/welcome_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/balance_overview_screen.dart';
import '../screens/transactions_screen.dart';
import '../screens/rewards_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/nfc_payment_screen.dart';
import '../screens/qr_scanner_screen.dart';
import '../screens/split_payment_screen.dart';
import '../screens/cards_screen.dart';
import '../screens/create_account_screen.dart';
// Add other screens as needed

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
        dashboard: (context) => const DashboardScreen(),
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
