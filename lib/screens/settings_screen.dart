// File: lib/screens/settings_screen.dart
// Kaam: Change Password, Delete Account (password confirm), FAQ, Privacy Policy
// Dangerous actions (delete) ke liye confirm dialog dikhata hai

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'login_screen.dart';
import 'survey_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('Account'),
          _settingsTile(
            context,
            icon: Icons.lock_reset_outlined,
            title: 'Change Password',
            subtitle: 'Update your login password',
            onTap: () => _showChangePasswordDialog(context),
          ),
          _settingsTile(
            context,
            icon: Icons.bar_chart_outlined,
            title: 'Earning Details',
            subtitle: 'View your earning history',
            onTap: () => _showEarningDetails(context),
          ),
          _settingsTile(
            context,
            icon: Icons.people_outline_rounded,
            title: 'Referral Stats',
            subtitle: 'See invite performance',
            onTap: () => _showReferralStats(context),
          ),

          const SizedBox(height: 16),
          _sectionHeader('Support'),
          _settingsTile(
            context,
            icon: Icons.quiz_outlined,
            title: 'FAQ',
            subtitle: 'Frequently asked questions',
            onTap: () => _showFAQ(context),
          ),
          _settingsTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we use your data',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SurveyScreen(
                  url: 'https://nexearnpro.vercel.app/privacy-policy',
                  title: 'Privacy Policy',
                ),
              ),
            ),
          ),
          _settingsTile(
            context,
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'App usage terms',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SurveyScreen(
                  url: 'https://nexearnpro.vercel.app/terms',
                  title: 'Terms of Service',
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          _sectionHeader('App Info'),
          _settingsTile(
            context,
            icon: Icons.info_outline_rounded,
            title: 'App Version',
            subtitle: 'v1.0.0',
            onTap: null,
            showArrow: false,
          ),

          const SizedBox(height: 16),
          _sectionHeader('Danger Zone', color: AppColors.error),
          _settingsTile(
            context,
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account and data',
            onTap: () => _showDeleteAccountDialog(context),
            color: AppColors.error,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: color ?? AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Color? color,
    bool showArrow = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: (color ?? AppColors.accent).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color ?? AppColors.accent, size: 20),
        ),
        title: Text(title,
            style: TextStyle(
                color: color ?? Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        trailing: showArrow && onTap != null
            ? const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textSecondary)
            : null,
        onTap: onTap,
      ),
    );
  }

  // ─── Change Password Dialog ────────────────────────────────────────────────
  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool loading = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: const Text('Change Password',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock_outline,
                      color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_open_outlined,
                      color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock_open_outlined,
                      color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (newCtrl.text != confirmCtrl.text) {
                        Helpers.showSnackBar(
                            context, 'Passwords do not match',
                            isError: true);
                        return;
                      }
                      if (!Helpers.isValidPassword(newCtrl.text)) {
                        Helpers.showSnackBar(
                            context, AppStrings.weakPassword,
                            isError: true);
                        return;
                      }
                      setS(() => loading = true);
                      final result = await AuthService().changePassword(
                          currentCtrl.text, newCtrl.text);
                      setS(() => loading = false);
                      Navigator.pop(ctx);
                      Helpers.showSnackBar(
                        context,
                        result.isSuccess
                            ? '✅ Password changed successfully!'
                            : result.errorMessage!,
                        isError: !result.isSuccess,
                      );
                    },
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Delete Account Dialog ─────────────────────────────────────────────────
  void _showDeleteAccountDialog(BuildContext context) {
    final passwordCtrl = TextEditingController();
    bool loading = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: const Text('Delete Account',
              style: TextStyle(
                  color: AppColors.error, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⚠️ This action is permanent!\n\nAll your coins, earning history, and account data will be deleted forever.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Enter your password to confirm',
                  prefixIcon: Icon(Icons.lock_outline,
                      color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error),
              onPressed: loading
                  ? null
                  : () async {
                      if (passwordCtrl.text.isEmpty) return;
                      setS(() => loading = true);
                      final result = await AuthService()
                          .deleteAccount(passwordCtrl.text);
                      setS(() => loading = false);
                      if (result.isSuccess) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (r) => false,
                        );
                      } else {
                        Navigator.pop(ctx);
                        Helpers.showSnackBar(
                            context, result.errorMessage!,
                            isError: true);
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Delete Forever'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── FAQ Dialog ────────────────────────────────────────────────────────────
  void _showFAQ(BuildContext context) {
    final faqs = [
      {
        'q': 'How do I earn coins?',
        'a':
            'Watch ads (+30 coins), daily check-in (+50), spin wheel, scratch card, invite friends (+500), and complete surveys.'
      },
      {
        'q': 'What is the minimum withdrawal?',
        'a': 'Minimum ${CoinValues.minWithdrawal} coins are needed to request a withdrawal.'
      },
      {
        'q': 'How long does withdrawal take?',
        'a': 'Withdrawals are processed within 24-48 business hours.'
      },
      {
        'q': 'How does referral work?',
        'a':
            'Share your referral code. When your friend makes their FIRST withdrawal, you earn 500 coins!'
      },
      {
        'q': 'Why is my spin wheel locked?',
        'a':
            'You need at least ${CoinValues.invitesNeededForSpin} verified referrals to unlock the spin wheel.'
      },
      {
        'q': 'Can I have multiple accounts?',
        'a':
            'No. Maximum 2 accounts are allowed per device. Multiple accounts may lead to banning.'
      },
      {
        'q': 'When do daily limits reset?',
        'a': 'All daily limits (ads, spin, scratch, check-in) reset at midnight (12:00 AM).'
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (_, sc) => ListView(
          controller: sc,
          padding: const EdgeInsets.all(20),
          children: [
            const Center(
              child: Text('FAQ',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18)),
            ),
            const SizedBox(height: 16),
            ...faqs.map((faq) => _faqTile(faq['q']!, faq['a']!)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _faqTile(String q, String a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ExpansionTile(
        iconColor: AppColors.accent,
        collapsedIconColor: AppColors.textSecondary,
        title: Text(q,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text(a,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showEarningDetails(BuildContext context) {
    // TODO: Show earning history from Firebase
    Helpers.showSnackBar(context, 'Earning history coming soon!');
  }

  void _showReferralStats(BuildContext context) {
    // TODO: Show referral stats
    Helpers.showSnackBar(context, 'Referral stats coming soon!');
  }
}
