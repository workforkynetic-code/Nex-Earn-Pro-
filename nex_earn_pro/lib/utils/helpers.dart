// File: lib/utils/helpers.dart
// Kaam: Reusable helper functions — date check, coin format, toast, etc.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';

class Helpers {
  // ─── Date Helpers ──────────────────────────────────────────────────────────

  /// Aaj ki date YYYY-MM-DD format mein return karta hai
  static String todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Check karo kya last_date aaj ki date hai (limit reached)
  static bool isToday(String dateStr) {
    return dateStr == todayString();
  }

  /// Yesterday ki date return karo (streak check ke liye)
  static String yesterdayString() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }

  // ─── Coin Formatting ───────────────────────────────────────────────────────

  /// 1500 → "1,500"
  static String formatCoins(int coins) {
    if (coins >= 1000000) {
      return '${(coins / 1000000).toStringAsFixed(1)}M';
    } else if (coins >= 1000) {
      final s = coins.toString();
      final result = StringBuffer();
      int count = 0;
      for (int i = s.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) result.write(',');
        result.write(s[i]);
        count++;
      }
      return result.toString().split('').reversed.join('');
    }
    return coins.toString();
  }

  // ─── Random Helpers ────────────────────────────────────────────────────────

  /// 4-digit random number generate karo
  static String random4Digits() {
    final rng = Random();
    return (1000 + rng.nextInt(9000)).toString();
  }

  /// Referral code generate karo: USERNAME + 4 random digits
  static String generateReferralCode(String username) {
    return '${username.toUpperCase()}${random4Digits()}';
  }

  /// Weighted random pick for spin wheel
  static int weightedRandomIndex(List<int> weights) {
    final total = weights.reduce((a, b) => a + b);
    int r = Random().nextInt(total);
    for (int i = 0; i < weights.length; i++) {
      r -= weights[i];
      if (r < 0) return i;
    }
    return weights.length - 1;
  }

  // ─── Validation ────────────────────────────────────────────────────────────

  /// Username: lowercase letters, numbers, underscore, 3-20 chars
  static bool isValidUsername(String username) {
    return RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(username);
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // ─── UI Helpers ────────────────────────────────────────────────────────────

  /// Snackbar dikhao
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Clipboard mein copy karo
  static Future<void> copyToClipboard(
      BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      showSnackBar(context, '$label copied to clipboard!');
    }
  }

  /// Loading dialog dikhao
  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  /// Loading dialog band karo
  static void hideLoading(BuildContext context) {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  // ─── Avatar Initials ───────────────────────────────────────────────────────

  /// "john_doe" → "JD"
  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'[_\s]+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  // ─── Time Ago ──────────────────────────────────────────────────────────────

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
