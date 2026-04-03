// File: lib/screens/tasks_screen.dart
// Kaam: Sabhi earning tasks yahan hain — Watch Ad, Spin, Scratch, Daily Bonus, Survey
// Each task ka daily limit Firebase se check hota hai

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/unity_ads_service.dart';
import '../widgets/spin_wheel_widget.dart';
import '../widgets/scratch_card_widget.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'survey_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  final _firebase = FirebaseService();
  final _ads = UnityAdsService();
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _firebase.userStream(_uid),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Tasks & Earn'),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(text: 'Daily Tasks'),
                Tab(text: 'Games'),
              ],
            ),
          ),
          body: user == null
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDailyTasks(user),
                    _buildGames(user),
                  ],
                ),
        );
      },
    );
  }

  // ─── Daily Tasks Tab ────────────────────────────────────────────────────────
  Widget _buildDailyTasks(UserModel user) {
    final today = Helpers.todayString();
    final adsLeft = today == user.lastAdDate
        ? (CoinValues.maxAdsPerDay - user.adsWatchedToday).clamp(0, CoinValues.maxAdsPerDay)
        : CoinValues.maxAdsPerDay;
    final dailyBonusDone = user.lastDailyBonusDate == today;
    final scratchDone = user.lastScratchDate == today;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Watch Ad
        _taskCard(
          icon: '📺',
          title: AppStrings.watchAd,
          desc: AppStrings.watchAdDesc,
          badge: '$adsLeft left today',
          badgeColor: adsLeft > 0 ? AppColors.success : AppColors.error,
          enabled: adsLeft > 0,
          onTap: () => _watchAd(),
        ),

        const SizedBox(height: 12),

        // Invite & Earn
        _taskCard(
          icon: '👥',
          title: AppStrings.inviteEarn,
          desc: AppStrings.inviteEarnDesc,
          badge: '${user.totalInvites} invited',
          badgeColor: AppColors.primary,
          enabled: true,
          onTap: () => _shareReferral(user),
        ),

        const SizedBox(height: 12),

        // Daily Bonus
        _taskCard(
          icon: '🎁',
          title: AppStrings.dailyBonus,
          desc: AppStrings.dailyBonusDesc,
          badge: dailyBonusDone ? 'Done' : 'Available',
          badgeColor: dailyBonusDone ? AppColors.textSecondary : AppColors.success,
          enabled: !dailyBonusDone,
          onTap: () => _claimDailyBonus(user),
        ),

        const SizedBox(height: 12),

        // Survey
        _taskCard(
          icon: '📋',
          title: AppStrings.survey,
          desc: AppStrings.surveyDesc,
          badge: 'Unlimited',
          badgeColor: AppColors.accent,
          enabled: true,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SurveyScreen())),
        ),

        const SizedBox(height: 20),

        // Coming soon
        const Text('Coming Soon', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        _comingSoonCard('🎮', 'Play Games', 'Earn coins by playing mini games'),
        const SizedBox(height: 10),
        _comingSoonCard('📱', 'App Downloads', 'Download apps to earn'),
        const SizedBox(height: 10),
        _comingSoonCard('🛒', 'Shopping Tasks', 'Shop and earn cashback'),
      ],
    );
  }

  // ─── Games Tab ──────────────────────────────────────────────────────────────
  Widget _buildGames(UserModel user) {
    final today = Helpers.todayString();
    final spinsLeft = today == user.lastSpinDate
        ? user.spinCountToday
        : CoinValues.spinCountPerDay;
    final spinUnlocked = user.verifiedInvites >= CoinValues.invitesNeededForSpin;
    final scratchDone = user.lastScratchDate == today;
    final scratchPrize = 20 + Random().nextInt(81); // 20-100

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Spin Wheel
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(AppStrings.spinWheel, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: spinUnlocked ? AppColors.success.withOpacity(0.15) : AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      spinUnlocked ? '$spinsLeft spins left' : 'Need ${CoinValues.invitesNeededForSpin} invites',
                      style: TextStyle(
                        color: spinUnlocked ? AppColors.success : AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              if (!spinUnlocked) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text('🔒', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Invite ${CoinValues.invitesNeededForSpin} friends to unlock spin wheel! (${user.verifiedInvites}/${CoinValues.invitesNeededForSpin})',
                          style: const TextStyle(color: AppColors.warning, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              SpinWheelWidget(
                canSpin: spinUnlocked && spinsLeft > 0,
                onSpinComplete: (prize) => _claimSpin(prize),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Scratch Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(AppStrings.scratchCard, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: scratchDone ? AppColors.textSecondary.withOpacity(0.15) : AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      scratchDone ? 'Used today' : '1 available',
                      style: TextStyle(
                        color: scratchDone ? AppColors.textSecondary : AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              const Text(AppStrings.scratchCardDesc, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),

              const SizedBox(height: 20),

              if (!scratchDone)
                Center(
                  child: ScratchCardWidget(
                    prize: scratchPrize,
                    onFullyScratch: () => _claimScratch(scratchPrize),
                  ),
                )
              else
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Come back tomorrow for your scratch card! 🎴',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Task Card Builder ─────────────────────────────────────────────────────
  Widget _taskCard({
    required String icon,
    required String title,
    required String desc,
    required String badge,
    required Color badgeColor,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.6,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 6),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: enabled ? Colors.white : AppColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _comingSoonCard(String icon, String title, String desc) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(AppStrings.comingSoon, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Task Actions ──────────────────────────────────────────────────────────

  void _watchAd() {
    _ads.showRewardedAd(
      onRewarded: () async {
        final success = await _firebase.claimAdReward(_uid);
        if (!mounted) return;
        if (success) {
          Helpers.showSnackBar(context, '🎉 +${CoinValues.watchAd} coins earned!');
        } else {
          Helpers.showSnackBar(context, 'Daily limit reached!', isError: true);
        }
      },
      onFailed: () {
        Helpers.showSnackBar(context, 'Ad not available. Try again later.', isError: true);
      },
    );
  }

  void _shareReferral(UserModel user) {
    final link = '${AppStrings.referralBase}${user.referralCode}';
    Share.share(
      '💰 Join Nex Earn Pro and earn daily rewards!\n\nUse my referral code: ${user.referralCode}\n\nDownload: $link',
      subject: 'Join Nex Earn Pro',
    );
  }

  Future<void> _claimDailyBonus(UserModel user) async {
    final success = await _firebase.claimDailyBonus(_uid);
    if (!mounted) return;
    if (success) {
      await Share.share(
        '💰 I\'m earning daily on Nex Earn Pro!\n\nJoin now: ${AppStrings.referralBase}${user.referralCode}',
        subject: 'Nex Earn Pro',
      );
      Helpers.showSnackBar(context, '🎁 +${CoinValues.dailyBonus} bonus coins!');
    } else {
      Helpers.showSnackBar(context, 'Daily bonus already claimed!', isError: true);
    }
  }

  Future<void> _claimSpin(int prize) async {
    final success = await _firebase.claimSpinReward(_uid, prize);
    if (!mounted) return;
    if (success) {
      _showPrizeDialog('🎡 Spin Reward!', '+$prize Coins', 'Congratulations!');
    }
  }

  Future<void> _claimScratch(int prize) async {
    final success = await _firebase.claimScratchReward(_uid, prize);
    if (!mounted) return;
    if (success) {
      _showPrizeDialog('🎴 Scratch Card!', '+$prize Coins', 'You won!');
    }
  }

  void _showPrizeDialog(String title, String amount, String subtitle) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 4),
            Text(amount, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w800, fontSize: 28)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
