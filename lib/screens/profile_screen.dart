// File: lib/screens/profile_screen.dart
// Kaam: User ka profile — avatar, username, stats, account details
// Firebase se real-time data stream karta hai

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar + name section
          _buildAvatarSection(),

          const SizedBox(height: 24),

          // Stats row
          _buildStatsRow(),

          const SizedBox(height: 24),

          // Account details
          _buildAccountDetails(context),

          const SizedBox(height: 24),

          // Referral card
          _buildReferralCard(context),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        // Avatar with gradient
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Text(
              Helpers.getInitials(user.username),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.username,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Joined ${_formatDate(user.joinedDate)}',
            style: const TextStyle(
                color: AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statBox('₵ ${Helpers.formatCoins(user.coins)}', 'Total Coins',
            AppColors.gold),
        const SizedBox(width: 10),
        _statBox('🔥 ${user.checkinStreak}', 'Day Streak',
            AppColors.warning),
        const SizedBox(width: 10),
        _statBox('👥 ${user.totalInvites}', 'Invites', AppColors.success),
      ],
    );
  }

  Widget _statBox(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 16),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDetails(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Account Details',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ),
          const Divider(color: AppColors.divider, height: 1),
          _detailRow(Icons.person_outline, 'Username', user.username),
          const Divider(color: AppColors.divider, height: 1, indent: 54),
          _detailRow(Icons.email_outlined, 'Email', user.email),
          const Divider(color: AppColors.divider, height: 1, indent: 54),
          _detailRow(Icons.monetization_on_outlined, 'Total Balance',
              '${Helpers.formatCoins(user.coins)} coins'),
          const Divider(color: AppColors.divider, height: 1, indent: 54),
          _detailRow(Icons.today_outlined, "Today's Earning",
              '${user.todayEarning} coins'),
          const Divider(color: AppColors.divider, height: 1, indent: 54),
          _detailRow(Icons.local_fire_department_outlined, 'Check-in Streak',
              '${user.checkinStreak} days'),
          const Divider(color: AppColors.divider, height: 1, indent: 54),
          _detailRow(Icons.verified_user_outlined, 'Verified Invites',
              '${user.verifiedInvites} friends'),
          const Divider(color: AppColors.divider, height: 1, indent: 54),
          _detailRow(Icons.calendar_today_outlined, 'Member Since',
              _formatDate(user.joinedDate)),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Referral Code',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.4)),
                  ),
                  child: Text(
                    user.referralCode,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Helpers.copyToClipboard(
                    context, user.referralCode, 'Referral code'),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.copy_rounded,
                      color: AppColors.primary, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${user.totalInvites} total invited • ${user.verifiedInvites} verified',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'N/A';
    final d = DateTime.tryParse(dateStr);
    if (d == null) return dateStr;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
