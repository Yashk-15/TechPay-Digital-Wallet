import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../view/controller/rewards_controller.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewards = ref.watch(rewardsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Rewards & Cashback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Tier Status Card ──────────────────────────────────────
            _TierCard(rewards: rewards),
            const SizedBox(height: 24),

            // ── 2. Points & Redeem ───────────────────────────────────────
            _PointsCard(rewards: rewards, ref: ref),
            const SizedBox(height: 24),

            // ── 3. Cashback Balance ──────────────────────────────────────
            _CashbackCard(rewards: rewards, ref: ref),
            const SizedBox(height: 24),

            // ── 4. Cashback Rates by Category ────────────────────────────
            _RatesCard(tier: rewards.tier),
            const SizedBox(height: 24),

            // ── 5. Monthly Stats ─────────────────────────────────────────
            const Text('This Month',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark)),
            const SizedBox(height: 16),
            _MonthlyStats(rewards: rewards),
            const SizedBox(height: 24),

            // ── 6. Recent Cashback Entries ───────────────────────────────
            const Text('Recent Cashback',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark)),
            const SizedBox(height: 16),
            rewards.recentRewards.isEmpty
                ? const _EmptyHint()
                : Column(
                    children: rewards.recentRewards
                        .map((e) => _CashbackItem(entry: e))
                        .toList(),
                  ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// ── Tier Card ─────────────────────────────────────────────────────────────────

class _TierCard extends StatelessWidget {
  final RewardsState rewards;
  const _TierCard({required this.rewards});

  IconData get _icon {
    switch (rewards.tier) {
      case RewardTier.silver:
        return Icons.workspace_premium_outlined;
      case RewardTier.gold:
        return Icons.stars_rounded;
      case RewardTier.platinum:
        return Icons.diamond_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primaryDarkTeal.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${rewards.tier.label} Tier',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  rewards.tier == RewardTier.platinum
                      ? 'Maximum tier — enjoy 3× points!'
                      : '${rewards.pointsToNextTier} pts to ${rewards.tier.nextLabel}',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ]),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle),
                child: Icon(_icon, color: AppTheme.accentMintGreen, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${rewards.totalPoints} pts',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
              if (rewards.tier != RewardTier.platinum)
                Text('${rewards.tier.ceiling} pts',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: rewards.tierProgress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.accentMintGreen),
            ),
          ),
          const SizedBox(height: 12),
          // Active multiplier badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20)),
            child: Text(
              '${rewards.tier.multiplier}× Points Multiplier Active',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Points Card ───────────────────────────────────────────────────────────────

class _PointsCard extends ConsumerStatefulWidget {
  final RewardsState rewards;
  final WidgetRef ref;
  const _PointsCard({required this.rewards, required this.ref});

  @override
  ConsumerState<_PointsCard> createState() => _PointsCardState();
}

class _PointsCardState extends ConsumerState<_PointsCard> {
  double _sliderValue = 100;

  @override
  Widget build(BuildContext context) {
    final maxPoints = widget.rewards.totalPoints.toDouble();
    // 100 pts = ₹1 cashback
    final cashbackForSlider = _sliderValue / 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Redeem Points',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: AppTheme.primaryDarkGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                  '${widget.rewards.totalPoints} pts available',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDarkGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('100 pts = ₹1 cashback credited to wallet',
              style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_sliderValue.toInt()} pts',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDarkGreen),
              ),
              const Text('  →  ',
                  style: TextStyle(fontSize: 18, color: AppTheme.textLight)),
              Text(
                '₹${cashbackForSlider.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.success),
              ),
            ],
          ),
          Slider(
            value: _sliderValue,
            min: 100,
            max: maxPoints > 100 ? maxPoints : 100,
            divisions: maxPoints > 100 ? ((maxPoints - 100) / 100).round() : 1,
            activeColor: AppTheme.primaryDarkGreen,
            onChanged: maxPoints >= 100
                ? (v) =>
                    setState(() => _sliderValue = (v / 100).round() * 100.0)
                : null,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.rewards.totalPoints < 100
                  ? null
                  : () {
                      final pts = _sliderValue.toInt();
                      widget.ref
                          .read(rewardsProvider.notifier)
                          .redeemPoints(pts);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '$pts pts redeemed → ₹${(pts / 100).toStringAsFixed(2)} added to wallet!'),
                          backgroundColor: AppTheme.primaryDarkGreen,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDarkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Redeem Points',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cashback Card ─────────────────────────────────────────────────────────────

class _CashbackCard extends StatelessWidget {
  final RewardsState rewards;
  final WidgetRef ref;
  const _CashbackCard({required this.rewards, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Available Cashback',
                style: TextStyle(fontSize: 14, color: AppTheme.textLight)),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(rewards.cashbackBalance),
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentMintGreen),
            ),
            const SizedBox(height: 4),
            const Text('Min. ₹100 spend per txn to earn',
                style: TextStyle(fontSize: 11, color: AppTheme.textLight)),
          ]),
          GestureDetector(
            onTap: () {
              if (rewards.cashbackBalance <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('No cashback available to redeem')));
                return;
              }
              final amount = rewards.cashbackBalance;
              ref.read(rewardsProvider.notifier).redeemCashback();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    '${CurrencyFormatter.format(amount)} added to wallet!'),
                backgroundColor: AppTheme.primaryDarkGreen,
              ));
            },
            child: AnimatedOpacity(
              opacity: rewards.cashbackBalance > 0 ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                    gradient: AppTheme.successGradient,
                    borderRadius: BorderRadius.circular(12)),
                child: const Text('Redeem',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rates by Category Card ────────────────────────────────────────────────────

class _RatesCard extends StatelessWidget {
  final RewardTier tier;
  const _RatesCard({required this.tier});

  static const _categories = [
    _Cat('Food & Drink', Icons.local_cafe_outlined, 0.05),
    _Cat('Shopping', Icons.shopping_bag_outlined, 0.03),
    _Cat('Transportation', Icons.directions_car_outlined, 0.10),
    _Cat('Entertainment', Icons.movie_outlined, 0.02),
    _Cat('Transfers', Icons.swap_horiz_outlined, 0.01),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(
              color: AppTheme.accentLime.withOpacity(0.5), width: 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.info_outline,
                size: 18, color: AppTheme.primaryDarkGreen),
            const SizedBox(width: 8),
            Text('Your ${tier.label} Cashback Rates',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark)),
          ]),
          const SizedBox(height: 4),
          const Text(
            'Earn cashback on every spend ≥ ₹100',
            style: TextStyle(fontSize: 12, color: AppTheme.textLight),
          ),
          const SizedBox(height: 16),
          ..._categories.map((c) {
            final effectiveRate =
                ((c.base + tier.cashbackBonus) * 100).toStringAsFixed(0);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Icon(c.icon, size: 16, color: AppTheme.primaryDarkGreen),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(c.label,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textLight))),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('$effectiveRate%',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.success)),
                ),
              ]),
            );
          }),
          if (tier != RewardTier.silver) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppTheme.primaryDarkGreen.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.auto_awesome,
                    size: 14, color: AppTheme.primaryDarkGreen),
                const SizedBox(width: 6),
                Text(
                  '${tier.label} bonus: +${(tier.cashbackBonus * 100).toStringAsFixed(0)}% on all categories',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryDarkGreen,
                      fontWeight: FontWeight.w600),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

class _Cat {
  final String label;
  final IconData icon;
  final double base;
  const _Cat(this.label, this.icon, this.base);
}

// ── Monthly Stats ─────────────────────────────────────────────────────────────

class _MonthlyStats extends StatelessWidget {
  final RewardsState rewards;
  const _MonthlyStats({required this.rewards});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow),
      child: Column(children: [
        _row('Transactions', '${rewards.transactionsThisMonth}',
            Icons.receipt_long),
        const Divider(height: 24),
        _row(
            'Cashback Earned',
            CurrencyFormatter.format(rewards.cashbackEarnedThisMonth),
            Icons.paid),
        const Divider(height: 24),
        _row('Points Earned', '${rewards.pointsEarnedThisMonth}', Icons.stars),
      ]),
    );
  }

  Widget _row(String label, String value, IconData icon) {
    return Row(children: [
      Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: AppTheme.primaryDarkTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppTheme.primaryDarkTeal, size: 20)),
      const SizedBox(width: 16),
      Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 14, color: AppTheme.textLight))),
      Text(value,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark)),
    ]);
  }
}

// ── Cashback Item ─────────────────────────────────────────────────────────────

class _CashbackItem extends StatelessWidget {
  final RewardEntry entry;
  const _CashbackItem({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow),
      child: Row(children: [
        Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                gradient: AppTheme.successGradient,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.store, color: Colors.white, size: 24)),
        const SizedBox(width: 16),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(entry.merchant,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark)),
          const SizedBox(height: 4),
          Text(entry.rateLabel,
              style: const TextStyle(fontSize: 13, color: AppTheme.textLight)),
        ])),
        Text('+${CurrencyFormatter.format(entry.cashbackAmount)}',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.success)),
      ]),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow),
      child: Row(children: [
        Icon(Icons.emoji_events_outlined,
            color: AppTheme.primaryDarkGreen.withOpacity(0.4), size: 32),
        const SizedBox(width: 16),
        const Expanded(
            child: Text(
          'Make a payment of ₹100+ to start earning cashback rewards!',
          style: TextStyle(fontSize: 13, color: AppTheme.textLight),
        )),
      ]),
    );
  }
}
