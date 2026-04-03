// File: lib/screens/invite_screen.dart
// Kaam: Referral code dikhana, share karna, invited users ki list

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class InviteScreen extends StatefulWidget {
  final UserModel user;
  const InviteScreen({super.key, required this.user});

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final _firebase = FirebaseService();
  List<Map<String, dynamic>> _invites = [];
  bool _loadingInvites = true;

  @override
  void initState() {
    super.initState();
    _loadInvites();
  }

  Future<void> _loadInvites() async {
    final list = await _firebase.getInvites(widget.user.uid);
    setState(() {
      _invites = list;
      _loadingInvites = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final referralLink = '${AppStrings.referralBase}${widget.user.referralCode}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Invite & Earn')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Invite banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF5b21b6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('🎁', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                const Text(
                  'Invite Friends & Earn',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
                ),
                const SizedBox(height: 6),
                const Text(
                  '+500 coins when your friend makes their first withdrawal!',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Referral Code
          const Text('Your Referral Code', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.user.referralCode,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: AppColors.accent),
                  onPressed: () => Helpers.copyToClipboard(
                      context, widget.user.referralCode, 'Referral code'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Referral Link
          const Text('Referral Link', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    referralLink,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: AppColors.accent, size: 18),
                  onPressed: () => Helpers.copyToClipboard(context, referralLink, 'Referral link'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Share buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share'),
                  onPressed: _shareAll,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Text('💬', style: TextStyle(fontSize: 16)),
                  label: const Text('WhatsApp', style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF25D366)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _shareWhatsApp,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stats
          Row(
            children: [
              _statChip('Total Invited', widget.user.totalInvites.toString(), AppColors.primary),
              const SizedBox(width: 10),
              _statChip('Verified', widget.user.verifiedInvites.toString(), AppColors.success),
              const SizedBox(width: 10),
              _statChip('Pending', (widget.user.totalInvites - widget.user.verifiedInvites).toString(), AppColors.warning),
            ],
          ),

          const SizedBox(height: 20),

          // How it works
          _buildHowItWorks(),

          const SizedBox(height: 20),

          // Invited users list
          const Text('Invited Users', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),

          _loadingInvites
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _invites.isEmpty
                  ? _buildEmptyInvites()
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _invites.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _inviteRow(_invites[i]),
                    ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 20)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
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
          const Text('How it works', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),
          _step('1', 'Share your referral code or link with friends'),
          _step('2', 'Friend registers using your referral code'),
          _step('3', 'When friend makes their first withdrawal...'),
          _step('4', 'You earn 500 coins! 🎉'),
        ],
      ),
    );
  }

  Widget _step(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _inviteRow(Map<String, dynamic> invite) {
    final verified = invite['verified'] == true;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: verified ? AppColors.success.withOpacity(0.2) : AppColors.warning.withOpacity(0.2),
            child: Text(
              (invite['username'] ?? '?').toString().substring(0, 1).toUpperCase(),
              style: TextStyle(color: verified ? AppColors.success : AppColors.warning, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              invite['username'] ?? invite['uid'] ?? 'User',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: verified ? AppColors.success.withOpacity(0.15) : AppColors.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              verified ? '✓ Verified' : '⏳ Pending',
              style: TextStyle(
                color: verified ? AppColors.success : AppColors.warning,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyInvites() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          children: [
            Text('👥', style: TextStyle(fontSize: 36)),
            SizedBox(height: 8),
            Text('No invites yet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('Share your code to start earning!', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _shareAll() {
    Share.share(
      '💰 Earn daily rewards on Nex Earn Pro!\n\nUse my referral code: ${widget.user.referralCode}\n\nJoin here: ${AppStrings.referralBase}${widget.user.referralCode}',
      subject: 'Join Nex Earn Pro',
    );
  }

  void _shareWhatsApp() {
    // Share.share will open WhatsApp on most devices if preferred
    _shareAll();
  }
}
