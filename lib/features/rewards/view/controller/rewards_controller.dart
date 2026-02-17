// lib/features/rewards/controller/rewards_controller.dart
//
// Gamification & Engagement system:
//   - Tiered points multipliers (Silver / Gold / Platinum)
//   - Cashback based on spending thresholds (PCI DSS spec: min ₹100 per txn)
//   - Category-specific cashback rates
//   - Points redeemable for wallet cashback (per spec)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/controller/home_controller.dart';

// ── Tier ─────────────────────────────────────────────────────────────────────

enum RewardTier { silver, gold, platinum }

extension RewardTierX on RewardTier {
  String get label {
    switch (this) {
      case RewardTier.silver:
        return 'Silver';
      case RewardTier.gold:
        return 'Gold';
      case RewardTier.platinum:
        return 'Platinum';
    }
  }

  String get nextLabel {
    switch (this) {
      case RewardTier.silver:
        return 'Gold';
      case RewardTier.gold:
        return 'Platinum';
      case RewardTier.platinum:
        return 'Max Tier Reached';
    }
  }

  /// Minimum cumulative points to enter this tier
  int get threshold {
    switch (this) {
      case RewardTier.silver:
        return 0;
      case RewardTier.gold:
        return 2000;
      case RewardTier.platinum:
        return 6000;
    }
  }

  /// Points at which this tier ends (exclusive upper bound)
  int get ceiling {
    switch (this) {
      case RewardTier.silver:
        return 2000;
      case RewardTier.gold:
        return 6000;
      case RewardTier.platinum:
        return 999999;
    }
  }

  /// Points earned per ₹100 spent (multiplier)
  int get multiplier {
    switch (this) {
      case RewardTier.silver:
        return 1;
      case RewardTier.gold:
        return 2;
      case RewardTier.platinum:
        return 3;
    }
  }

  /// Tier-level bonus added on top of category cashback rate
  double get cashbackBonus {
    switch (this) {
      case RewardTier.silver:
        return 0.00;
      case RewardTier.gold:
        return 0.01; // +1%
      case RewardTier.platinum:
        return 0.03; // +3%
    }
  }
}

// ── Reward Entry (individual cashback record) ─────────────────────────────────

class RewardEntry {
  final String merchant;
  final double cashbackAmount;
  final String rateLabel;
  final DateTime date;

  const RewardEntry({
    required this.merchant,
    required this.cashbackAmount,
    required this.rateLabel,
    required this.date,
  });
}

// ── EarnResult (returned to UI so it can show earned reward) ─────────────────

class EarnResult {
  final int points;
  final double cashback;
  const EarnResult({required this.points, required this.cashback});
  bool get hasEarned => points > 0 || cashback > 0;
}

// ── Category cashback rates (base, before tier bonus) ────────────────────────
// PCI DSS–compliant spend segmentation

const Map<String, double> _baseCashbackRate = {
  'Food & Drink': 0.05, // 5%
  'Shopping': 0.03, // 3%
  'Transportation': 0.10, // 10%
  'Entertainment': 0.02, // 2%
  'Transfer': 0.01, // 1%
  'Income': 0.00,
  'Rewards': 0.00,
};

/// Minimum spend per transaction to qualify for cashback (spec requirement)
const double _minSpendForCashback = 100.0;

// ── State ─────────────────────────────────────────────────────────────────────

class RewardsState {
  final int totalPoints;
  final double cashbackBalance;
  final RewardTier tier;
  final int transactionsThisMonth;
  final double cashbackEarnedThisMonth;
  final int pointsEarnedThisMonth;
  final List<RewardEntry> recentRewards;

  const RewardsState({
    this.totalPoints = 3550,
    this.cashbackBalance = 127.50,
    this.tier = RewardTier.gold,
    this.transactionsThisMonth = 47,
    this.cashbackEarnedThisMonth = 32.50,
    this.pointsEarnedThisMonth = 1240,
    this.recentRewards = const [],
  });

  RewardsState copyWith({
    int? totalPoints,
    double? cashbackBalance,
    RewardTier? tier,
    int? transactionsThisMonth,
    double? cashbackEarnedThisMonth,
    int? pointsEarnedThisMonth,
    List<RewardEntry>? recentRewards,
  }) =>
      RewardsState(
        totalPoints: totalPoints ?? this.totalPoints,
        cashbackBalance: cashbackBalance ?? this.cashbackBalance,
        tier: tier ?? this.tier,
        transactionsThisMonth:
            transactionsThisMonth ?? this.transactionsThisMonth,
        cashbackEarnedThisMonth:
            cashbackEarnedThisMonth ?? this.cashbackEarnedThisMonth,
        pointsEarnedThisMonth:
            pointsEarnedThisMonth ?? this.pointsEarnedThisMonth,
        recentRewards: recentRewards ?? this.recentRewards,
      );

  /// Points still needed to reach the next tier
  int get pointsToNextTier =>
      tier == RewardTier.platinum ? 0 : tier.ceiling - totalPoints;

  /// Progress bar value (0.0 → 1.0) within the current tier's range
  double get tierProgress {
    if (tier == RewardTier.platinum) return 1.0;
    final span = tier.ceiling - tier.threshold;
    return ((totalPoints - tier.threshold) / span).clamp(0.0, 1.0);
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class RewardsNotifier extends StateNotifier<RewardsState> {
  final Ref _ref;

  RewardsNotifier(this._ref) : super(const RewardsState()) {
    _seedRecentRewards();
  }

  void _seedRecentRewards() {
    state = state.copyWith(recentRewards: [
      RewardEntry(
          merchant: 'Starbucks',
          cashbackAmount: 2.50,
          rateLabel: '5% cashback',
          date: DateTime.now().subtract(const Duration(hours: 2))),
      RewardEntry(
          merchant: 'Amazon',
          cashbackAmount: 12.00,
          rateLabel: '3% cashback',
          date: DateTime.now().subtract(const Duration(days: 1))),
      RewardEntry(
          merchant: 'Uber',
          cashbackAmount: 4.50,
          rateLabel: '10% cashback',
          date: DateTime.now().subtract(const Duration(days: 2))),
    ]);
  }

  static RewardTier _tierFor(int points) {
    if (points >= RewardTier.platinum.threshold) return RewardTier.platinum;
    if (points >= RewardTier.gold.threshold) return RewardTier.gold;
    return RewardTier.silver;
  }

  double _effectiveRate(String category) {
    final base = _baseCashbackRate[category] ?? 0.01;
    return base + state.tier.cashbackBonus;
  }

  /// Called after every outgoing payment.
  /// Returns [EarnResult] so the UI can display what was earned.
  EarnResult earnRewards({
    required String merchant,
    required double amount,
    required String category,
  }) {
    if (amount <= 0) return const EarnResult(points: 0, cashback: 0);

    // Points: tier multiplier × (amount / ₹100), clamped 1–500 per txn
    final int earnedPoints =
        ((amount / 100) * state.tier.multiplier).round().clamp(1, 500);

    // Cashback: only when spend ≥ minimum threshold (spec requirement)
    double earnedCashback = 0.0;
    String rateLabel = 'No cashback this transaction';
    if (amount >= _minSpendForCashback) {
      final rate = _effectiveRate(category);
      earnedCashback = double.parse((amount * rate).toStringAsFixed(2));
      final pct = (rate * 100).toStringAsFixed(0);
      rateLabel = '$pct% cashback';
    }

    final newPoints = state.totalPoints + earnedPoints;
    final newTier = _tierFor(newPoints);

    // Prepend to recent rewards list (max 10 entries)
    final updatedRewards = earnedCashback > 0
        ? [
            RewardEntry(
              merchant: merchant,
              cashbackAmount: earnedCashback,
              rateLabel: rateLabel,
              date: DateTime.now(),
            ),
            ...state.recentRewards,
          ].take(10).toList()
        : state.recentRewards;

    state = state.copyWith(
      totalPoints: newPoints,
      cashbackBalance: state.cashbackBalance + earnedCashback,
      tier: newTier,
      transactionsThisMonth: state.transactionsThisMonth + 1,
      cashbackEarnedThisMonth: state.cashbackEarnedThisMonth + earnedCashback,
      pointsEarnedThisMonth: state.pointsEarnedThisMonth + earnedPoints,
      recentRewards: updatedRewards,
    );

    return EarnResult(points: earnedPoints, cashback: earnedCashback);
  }

  /// Redeem all available cashback → credited directly to wallet balance.
  bool redeemCashback() {
    if (state.cashbackBalance <= 0) return false;
    final amount = state.cashbackBalance;
    _ref
        .read(homeProvider.notifier)
        .updateBalance(_ref.read(homeProvider).balance + amount);
    state = state.copyWith(cashbackBalance: 0.0);
    return true;
  }

  /// Redeem points: 100 pts = ₹1 cashback added to wallet
  bool redeemPoints(int pointsToRedeem) {
    if (pointsToRedeem <= 0 || pointsToRedeem > state.totalPoints) return false;
    final cashbackValue = pointsToRedeem / 100.0;
    _ref
        .read(homeProvider.notifier)
        .updateBalance(_ref.read(homeProvider).balance + cashbackValue);
    state = state.copyWith(
      totalPoints: state.totalPoints - pointsToRedeem,
      tier: _tierFor(state.totalPoints - pointsToRedeem),
    );
    return true;
  }
}

final rewardsProvider =
    StateNotifierProvider<RewardsNotifier, RewardsState>((ref) {
  return RewardsNotifier(ref);
});
