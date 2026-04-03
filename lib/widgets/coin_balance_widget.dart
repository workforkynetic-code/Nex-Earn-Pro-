// File: lib/widgets/coin_balance_widget.dart
// Kaam: App bar mein coins dikhane wala widget — poore app mein reuse hota hai

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class CoinBalanceWidget extends StatelessWidget {
  final int coins;
  final bool showLabel;

  const CoinBalanceWidget({
    super.key,
    required this.coins,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Coin icon
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('₵', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            Helpers.formatCoins(coins),
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            const Text(
              'coins',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Large Coin Display (for stats cards) ─────────────────────────────────────

class CoinStatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color? color;

  const CoinStatCard({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: (color ?? AppColors.gold).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '₵',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color ?? AppColors.gold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                Helpers.formatCoins(value),
                style: TextStyle(
                  color: color ?? AppColors.gold,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
