// File: lib/screens/home_screen.dart
// Kaam: App ka main screen — check-in, stats, earn more grid, drawer menu
// Firebase se real-time user data stream karta hai

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../services/unity_ads_service.dart';
import '../widgets/coin_balance_widget.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'tasks_screen.dart';
import 'invite_screen.dart';
import 'withdrawal_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'review_screen.dart';
import 'survey_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firebase = FirebaseService();
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  bool _checkinLoading = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _firebase.userStream(_uid),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: _buildDrawer(user),
          appBar: _buildAppBar(user),
          body: user == null
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _buildBody(user),
        );
      },
    );
  }

  // ─── App Bar ────────────────────────────────────────────────────────────────
  AppBar _buildAppBar(UserModel? user) {
    return AppBar(
      backgroundColor: AppColors.background,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: const Text(AppStrings.appName,
          style: TextStyle(fontWeight: FontWeight.w700)),
      actions: [
        if (user != null)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CoinBalanceWidget(coins: user.coins),
          ),
      ],
    );
  }

  // ─── Drawer ─────────────────────────────────────────────────────────────────
  Widget _buildDrawer(UserModel? user) {
    return Drawer(
      backgroundColor: AppColors.cardBg,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFF4c1d95)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      Helpers.getInitials(user?.username ?? '?'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.username ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                        Text(user?.email ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _drawerItem(Icons.home_rounded, 'Home', () => Navigator.pop(context)),
                  _drawerItem(Icons.task_alt_rounded, 'Tasks', () => _navigate(const TasksScreen())),
                  _drawerItem(Icons.people_outline_rounded, 'Invite', () => _navigate(InviteScreen(user: user!))),
                  _drawerItem(Icons.account_balance_wallet_outlined, 'Withdrawal', () => _navigate(WithdrawalScreen(user: user!))),
                  _drawerItem(Icons.person_outline_rounded, 'Profile', () => _navigate(ProfileScreen(user: user!))),
                  _drawerItem(Icons.settings_outlined, 'Settings', () => _navigate(const SettingsScreen())),
                  _drawerItem(Icons.star_outline_rounded, 'Review', () => _navigate(const ReviewScreen())),
                  _drawerItem(Icons.info_outline_rounded, 'About', () => _showAbout()),
                  const Divider(color: AppColors.divider),
                  _drawerItem(Icons.logout_rounded, 'Logout', _logout, color: AppColors.error),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary, size: 22),
      title: Text(label, style: TextStyle(color: color ?? Colors.white, fontSize: 15)),
      onTap: onTap,
      dense: true,
    );
  }

  // ─── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(UserModel user) {
    final today = Helpers.todayString();
    final alreadyCheckedIn = user.lastCheckin == today;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.cardBg,
      onRefresh: () async => setState(() {}),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Daily Check-in card
          _buildCheckinCard(user, alreadyCheckedIn),

          const SizedBox(height: 16),

          // Stats
          Row(
            children: [
              Expanded(child: CoinStatCard(label: AppStrings.totalBalance, value: user.coins)),
              const SizedBox(width: 12),
              Expanded(child: CoinStatCard(label: AppStrings.todayEarning, value: user.todayEarning, color: AppColors.success)),
            ],
          ),

          const SizedBox(height: 16),

          // Banner ad
          UnityAdsService().buildBannerAd(),

          const SizedBox(height: 16),

          // Earn More section
          const Text(
            AppStrings.earnMore,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 12),

          // Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _earnCard(
                icon: '📋',
                title: 'Complete Survey',
                desc: AppStrings.surveyDesc,
                onTap: () => _navigate(const SurveyScreen()),
              ),
              _earnCard(
                icon: '✅',
                title: 'Tasks',
                desc: 'Watch ads, spin & more',
                onTap: () => _navigate(const TasksScreen()),
              ),
              _earnCard(
                icon: '👥',
                title: 'Invite Friends',
                desc: AppStrings.inviteEarnDesc,
                onTap: () => _navigate(InviteScreen(user: user)),
              ),
              _earnCard(
                icon: '🎡',
                title: 'Spin Wheel',
                desc: AppStrings.spinWheelDesc,
                onTap: () => _navigate(const TasksScreen()),
              ),
              _earnCard(
                icon: '🎴',
                title: 'Scratch Card',
                desc: AppStrings.scratchCardDesc,
                onTap: () => _navigate(const TasksScreen()),
              ),
              _earnCard(
                icon: '💰',
                title: 'Withdraw',
                desc: 'Withdraw your coins',
                onTap: () => _navigate(WithdrawalScreen(user: user)),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCheckinCard(UserModel user, bool alreadyCheckedIn) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: alreadyCheckedIn
              ? [AppColors.cardBg, AppColors.cardBg]
              : [AppColors.primary, const Color(0xFF5b21b6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: alreadyCheckedIn
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
      ),
      child: Row(
        children: [
          // Streak
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(AppStrings.dailyCheckin,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    '${user.checkinStreak} day streak',
                    style: TextStyle(
                      color: alreadyCheckedIn ? AppColors.textSecondary : Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Check-in button
          GestureDetector(
            onTap: alreadyCheckedIn || _checkinLoading ? null : _doCheckin,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: alreadyCheckedIn
                    ? AppColors.divider
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: alreadyCheckedIn ? Colors.transparent : Colors.white.withOpacity(0.4),
                ),
              ),
              child: _checkinLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      alreadyCheckedIn ? AppStrings.alreadyCheckedIn : AppStrings.checkIn,
                      style: TextStyle(
                        color: alreadyCheckedIn ? AppColors.textSecondary : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _earnCard({
    required String icon,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Actions ────────────────────────────────────────────────────────────────

  Future<void> _doCheckin() async {
    setState(() => _checkinLoading = true);
    final result = await _firebase.dailyCheckin(_uid);
    setState(() => _checkinLoading = false);

    if (!mounted) return;
    if (result['success'] == true) {
      Helpers.showSnackBar(context,
          '✅ Check-in done! +${result['coins_added']} coins | Streak: ${result['streak']} days');
    } else {
      Helpers.showSnackBar(context, 'Already checked in today!', isError: true);
    }
  }

  void _navigate(Widget screen) {
    Navigator.pop(context); // Close drawer
    NavCounter.increment();
    if (NavCounter.shouldShowInterstitial()) {
      UnityAdsService().showInterstitialAd();
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _logout() async {
    Navigator.pop(context);
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showAbout() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('About Nex Earn Pro', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Nex Earn Pro is your daily earning companion.\n\nComplete tasks, watch ads, invite friends, and withdraw your earnings!\n\nVersion: 1.0.0',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
