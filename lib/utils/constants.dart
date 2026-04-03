// File: lib/utils/constants.dart
// Kaam: Poore app ke colors, strings, aur constants ek jagah store hain
// Agar koi color ya text change karna ho to sirf yahan se karo

import 'package:flutter/material.dart';

// ========================
// APP COLORS (Dark Theme)
// ========================
class AppColors {
  static const Color primary = Color(0xFF7c3aed);       // Purple - main brand color
  static const Color accent = Color(0xFFa78bfa);         // Light purple - accents
  static const Color background = Color(0xFF080510);     // Near black - screen bg
  static const Color cardBg = Color(0xFF0f0c22);         // Dark purple - card bg
  static const Color success = Color(0xFF10b981);        // Green - success states
  static const Color error = Color(0xFFef4444);          // Red - error states
  static const Color warning = Color(0xFFf59e0b);        // Orange - warnings
  static const Color textPrimary = Color(0xFFffffff);    // White - main text
  static const Color textSecondary = Color(0xFF9ca3af);  // Grey - secondary text
  static const Color divider = Color(0xFF1f1b38);        // Subtle divider
  static const Color gold = Color(0xFFfbbf24);           // Gold - coins
  static const Color shimmer = Color(0xFF1e1a35);        // Shimmer base
}

// ========================
// APP STRINGS
// ========================
class AppStrings {
  static const String appName = 'Nex Earn Pro';
  static const String tagline = 'Earn Daily Rewards';
  static const String backendUrl = 'https://nexearnpro.vercel.app';
  static const String surveyUrl = 'https://nexearnpro.vercel.app/survey-tasks';
  static const String referralBase = 'https://nexearnpro.vercel.app/register?ref=';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String username = 'Username';
  static const String referralCode = 'Referral Code (Optional)';
  static const String continueWithGoogle = 'Continue with Google';
  static const String alreadyHaveAccount = 'Already have an account? Login';
  static const String dontHaveAccount = "Don't have an account? Register";

  // Home
  static const String dailyCheckin = 'Daily Check-in';
  static const String checkIn = 'Check In (+50 coins)';
  static const String alreadyCheckedIn = 'Already Checked In Today ✓';
  static const String totalBalance = 'Total Balance';
  static const String todayEarning = "Today's Earnings";
  static const String earnMore = 'Earn More';

  // Tasks
  static const String watchAd = 'Watch Ad & Earn';
  static const String watchAdDesc = '+30 coins per ad (5/day)';
  static const String inviteEarn = 'Invite & Earn';
  static const String inviteEarnDesc = '+500 coins when friend withdraws';
  static const String spinWheel = 'Spin Wheel';
  static const String spinWheelDesc = '3 spins/day (unlock: 3 invites)';
  static const String scratchCard = 'Scratch Card';
  static const String scratchCardDesc = 'Scratch & win daily (1/day)';
  static const String dailyBonus = 'Daily Bonus';
  static const String dailyBonusDesc = 'Share app +20 coins (1/day)';
  static const String survey = 'Complete Survey';
  static const String surveyDesc = 'Earn coins for surveys';
  static const String comingSoon = 'Coming Soon';

  // Withdrawal
  static const String withdrawal = 'Withdrawal';
  static const String minWithdrawal = 'Minimum 1000 coins required';
  static const String upi = 'UPI / GPay';
  static const String paytm = 'Paytm';
  static const String bankTransfer = 'Bank Transfer';
  static const String amazonPay = 'Amazon Pay';

  // Errors
  static const String usernameInvalid = 'Username: 3-20 lowercase letters/numbers only';
  static const String usernameTaken = 'Username already taken';
  static const String weakPassword = 'Password must be at least 6 characters';
  static const String genericError = 'Something went wrong. Try again.';
  static const String noInternet = 'No internet connection';
  static const String deviceLimit = 'Max 2 accounts allowed per device';
}

// ========================
// UNITY ADS CONFIG
// ========================
class UnityAdsConfig {
  // TODO: Replace with your actual Unity Ads Game ID from Unity Dashboard
  static const String gameId = 'YOUR_UNITY_GAME_ID';
  static const bool testMode = true; // Set false in production

  static const String rewardedVideoAdUnitId = 'Rewarded_Android';
  static const String interstitialAdUnitId = 'Interstitial_Android';
  static const String bannerAdUnitId = 'Banner_Android';

  // Coins earned per rewarded ad
  static const int coinsPerAd = 30;
  static const int maxAdsPerDay = 5;
}

// ========================
// COIN VALUES
// ========================
class CoinValues {
  static const int dailyCheckin = 50;
  static const int watchAd = 30;
  static const int referralBonus = 500;    // When friend withdraws
  static const int dailyBonus = 20;
  static const int newUserBonus = 100;
  static const int spinMin = 10;
  static const int spinMax = 100;
  static const int minWithdrawal = 1000;
  static const int maxScratch = 100;
  static const int spinCountPerDay = 3;
  static const int scratchCountPerDay = 1;
  static const int maxAdsPerDay = 5;
  static const int invitesNeededForSpin = 3; // Unlock spin after 3 invites
}

// ========================
// SPIN WHEEL PRIZES
// ========================
class SpinPrizes {
  static const List<int> prizes = [10, 20, 30, 50, 75, 100];
  // Weights: higher = more common
  static const List<int> weights = [30, 25, 20, 15, 7, 3];
  static const List<Color> colors = [
    Color(0xFF7c3aed),
    Color(0xFF059669),
    Color(0xFFd97706),
    Color(0xFF2563eb),
    Color(0xFFdc2626),
    Color(0xFFfbbf24),
  ];
}

// ========================
// FIREBASE PATHS
// ========================
class FirebasePaths {
  static String user(String uid) => 'users/$uid';
  static String username(String name) => 'usernames/$name';
  static String paymentMethods(String uid) => 'payment_methods/$uid';
  static String withdrawal(String uid) => 'withdrawals/$uid';
  static String invites(String referrerUid) => 'invites/$referrerUid';
  static String reviews() => 'reviews';
  static String reviewReplies(String reviewId) => 'review_replies/$reviewId';
  static String deviceFingerprint(String deviceId) => '_fp/$deviceId';
  static String adTransaction(String txnId) => '_adgem_txns/$txnId';
}

// ========================
// NAVIGATION COUNTER
// ========================
// Used for interstitial ad logic (show every 3 navigations)
class NavCounter {
  static int _count = 0;
  static int get count => _count;
  static void increment() => _count++;
  static bool shouldShowInterstitial() {
    if (_count > 0 && _count % 3 == 0) return true;
    return false;
  }
}
