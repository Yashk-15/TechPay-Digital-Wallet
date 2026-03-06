import 'package:flutter/material.dart';
import 'features/onboarding/view/welcome_screen.dart';
import 'features/onboarding/view/login_screen.dart';
import 'features/onboarding/view/signup_screen.dart';
import 'features/onboarding/view/post_login_welcome_screen.dart';
import 'features/onboarding/view/kyc_verification_screen.dart';
import 'features/home/view/home_screen.dart';
import 'features/home/view/balance_overview_screen.dart';
import 'features/transactions/view/transactions_screen.dart';
import 'features/rewards/view/rewards_screen.dart';
import 'features/profile/view/settings_screen.dart';
import 'features/payments/nfc/view/nfc_payment_screen.dart';
import 'features/payments/qr/view/qr_scanner_screen.dart';
import 'features/payments/split/view/split_payment_screen.dart';
import 'features/payments/request/view/request_money_screen.dart';
import 'features/wallet/view/cards_screen.dart';
import 'features/transfer/view/contact_selection_screen.dart';
import 'features/payments/card/view/card_payment_screen.dart';
import 'core/theme/app_theme.dart';

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
  static const String requestMoney = '/payment/request';
  static const String splitPayment = '/payment/split';
  static const String cardPayment = '/payment/card';

  // ── Wallet / Transfer ─────────────────────────────────────────────────────
  static const String cards = '/cards';
  static const String contactSelection = '/transfer/contact_selection';
  static const String deposit = '/deposit';
  static const String kyc = '/onboarding/kyc';

  static Map<String, WidgetBuilder> get routes => {
        // Auth
        welcome: (_) => const WelcomeScreen(),
        login: (_) => const LoginScreen(),
        signup: (_) => const SignupScreen(),
        postLoginWelcome: (_) => const PostLoginWelcomeScreen(),
        kyc: (_) => const KYCVerificationScreen(),

        // App
        home: (_) => const HomeScreen(),
        balanceOverview: (_) => const BalanceOverviewScreen(),
        transactions: (_) => const TransactionsScreen(),
        rewards: (_) => const RewardsScreen(),
        settings: (_) => const SettingsScreen(),

        // Payments
        nfcPayment: (_) => const NFCPaymentScreen(),
        qrScanner: (_) => const QRScannerScreen(),
        requestMoney: (_) => const RequestMoneyScreen(),
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
      backgroundColor: AppTheme.bgAbyss,
      appBar: AppBar(
        title: const Text('Top Up Wallet',
            style: TextStyle(color: AppTheme.text100)),
        backgroundColor: AppTheme.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.text100),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.coralDim,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.account_balance_rounded,
                    color: AppTheme.coral, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                'Bank Link Coming Soon',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.text100,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Link your bank account to top up your TechPay wallet instantly. This feature will be available soon.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.text400,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.coralDim,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.bgBorder),
                ),
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.notifications_none_rounded,
                      color: AppTheme.coral),
                  label: const Text(
                    'Notify Me When Available',
                    style: TextStyle(
                        color: AppTheme.coral, fontWeight: FontWeight.w600),
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
