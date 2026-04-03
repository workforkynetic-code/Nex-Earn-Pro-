// File: lib/services/firebase_service.dart
// Kaam: Firebase Realtime Database ke saare read/write operations yahan hain
// Coin update, checkin, withdrawal, invites sab kuch yahan se hota hai

import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // ─── User CRUD ─────────────────────────────────────────────────────────────

  /// User ko Firebase mein save karo (registration ke time)
  Future<void> saveUser(UserModel user) async {
    await _db.ref(FirebasePaths.user(user.uid)).set(user.toMap());
    // Username index save karo (uniqueness check ke liye)
    await _db
        .ref(FirebasePaths.username(user.username))
        .set(user.uid);
  }

  /// User data fetch karo
  Future<UserModel?> getUser(String uid) async {
    final snap = await _db.ref(FirebasePaths.user(uid)).get();
    if (!snap.exists) return null;
    return UserModel.fromMap(uid, snap.value as Map<dynamic, dynamic>);
  }

  /// Real-time user stream (live updates ke liye)
  Stream<UserModel?> userStream(String uid) {
    return _db.ref(FirebasePaths.user(uid)).onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return UserModel.fromMap(
          uid, event.snapshot.value as Map<dynamic, dynamic>);
    });
  }

  /// Check karo username already liya hua hai ya nahi
  Future<bool> isUsernameTaken(String username) async {
    final snap =
        await _db.ref(FirebasePaths.username(username)).get();
    return snap.exists;
  }

  // ─── Coin Operations (Atomic) ──────────────────────────────────────────────

  /// Coins add karo atomically + today_earning bhi update karo
  Future<bool> addCoins(String uid, int amount, String reason) async {
    try {
      final today = Helpers.todayString();
      final ref = _db.ref(FirebasePaths.user(uid));

      // Transaction use karo for atomicity
      final result = await ref.runTransaction((current) {
        if (current == null) return Transaction.abort();
        final data = Map<String, dynamic>.from(current as Map);

        // Reset today_earning agar naya din hai
        final lastEarnDate = data['last_earn_date'] ?? '';
        if (lastEarnDate != today) {
          data['today_earning'] = 0;
          data['last_earn_date'] = today;
        }

        data['coins'] = (data['coins'] ?? 0) + amount;
        data['today_earning'] = (data['today_earning'] ?? 0) + amount;
        return Transaction.success(data);
      });

      return result.committed;
    } catch (e) {
      return false;
    }
  }

  /// Coins deduct karo (withdrawal ke liye)
  Future<bool> deductCoins(String uid, int amount) async {
    try {
      final ref = _db.ref(FirebasePaths.user(uid));
      final result = await ref.runTransaction((current) {
        if (current == null) return Transaction.abort();
        final data = Map<String, dynamic>.from(current as Map);
        final currentCoins = (data['coins'] ?? 0) as int;
        if (currentCoins < amount) return Transaction.abort();
        data['coins'] = currentCoins - amount;
        return Transaction.success(data);
      });
      return result.committed;
    } catch (e) {
      return false;
    }
  }

  // ─── Daily Check-in ────────────────────────────────────────────────────────

  /// Daily checkin — +50 coins, streak update
  Future<Map<String, dynamic>> dailyCheckin(String uid) async {
    final today = Helpers.todayString();
    final yesterday = Helpers.yesterdayString();
    final ref = _db.ref(FirebasePaths.user(uid));

    int newStreak = 0;
    bool success = false;

    final result = await ref.runTransaction((current) {
      if (current == null) return Transaction.abort();
      final data = Map<String, dynamic>.from(current as Map);

      // Already checked in today?
      if (data['last_checkin'] == today) return Transaction.abort();

      // Streak logic
      int streak = (data['checkin_streak'] ?? 0) as int;
      if (data['last_checkin'] == yesterday) {
        streak += 1; // Consecutive day
      } else {
        streak = 1; // Streak broke
      }

      data['last_checkin'] = today;
      data['checkin_streak'] = streak;
      data['coins'] = (data['coins'] ?? 0) + CoinValues.dailyCheckin;
      data['today_earning'] =
          (data['today_earning'] ?? 0) + CoinValues.dailyCheckin;

      newStreak = streak;
      success = true;
      return Transaction.success(data);
    });

    return {
      'success': result.committed,
      'streak': newStreak,
      'coins_added': CoinValues.dailyCheckin,
    };
  }

  // ─── Ad Reward ─────────────────────────────────────────────────────────────

  /// Ad dekhne ke baad +30 coins (max 5/day)
  Future<bool> claimAdReward(String uid) async {
    final today = Helpers.todayString();
    final ref = _db.ref(FirebasePaths.user(uid));

    final result = await ref.runTransaction((current) {
      if (current == null) return Transaction.abort();
      final data = Map<String, dynamic>.from(current as Map);

      // Reset agar naya din
      if (data['last_ad_date'] != today) {
        data['ads_watched_today'] = 0;
        data['last_ad_date'] = today;
      }

      int watched = (data['ads_watched_today'] ?? 0) as int;
      if (watched >= CoinValues.maxAdsPerDay) return Transaction.abort();

      data['ads_watched_today'] = watched + 1;
      data['coins'] = (data['coins'] ?? 0) + CoinValues.watchAd;
      data['today_earning'] =
          (data['today_earning'] ?? 0) + CoinValues.watchAd;
      return Transaction.success(data);
    });

    return result.committed;
  }

  // ─── Spin Wheel ────────────────────────────────────────────────────────────

  /// Spin use karo + coins add karo
  Future<bool> claimSpinReward(String uid, int coins) async {
    final today = Helpers.todayString();
    final ref = _db.ref(FirebasePaths.user(uid));

    final result = await ref.runTransaction((current) {
      if (current == null) return Transaction.abort();
      final data = Map<String, dynamic>.from(current as Map);

      // Reset agar naya din
      if (data['last_spin_date'] != today) {
        data['spin_count_today'] = CoinValues.spinCountPerDay;
        data['last_spin_date'] = today;
      }

      int spins = (data['spin_count_today'] ?? 0) as int;
      if (spins <= 0) return Transaction.abort();

      data['spin_count_today'] = spins - 1;
      data['coins'] = (data['coins'] ?? 0) + coins;
      data['today_earning'] = (data['today_earning'] ?? 0) + coins;
      return Transaction.success(data);
    });

    return result.committed;
  }

  // ─── Scratch Card ──────────────────────────────────────────────────────────

  Future<bool> claimScratchReward(String uid, int coins) async {
    final today = Helpers.todayString();
    final ref = _db.ref(FirebasePaths.user(uid));

    final result = await ref.runTransaction((current) {
      if (current == null) return Transaction.abort();
      final data = Map<String, dynamic>.from(current as Map);

      if (data['last_scratch_date'] == today) return Transaction.abort();

      data['last_scratch_date'] = today;
      data['coins'] = (data['coins'] ?? 0) + coins;
      data['today_earning'] = (data['today_earning'] ?? 0) + coins;
      return Transaction.success(data);
    });

    return result.committed;
  }

  // ─── Daily Bonus (Share) ───────────────────────────────────────────────────

  Future<bool> claimDailyBonus(String uid) async {
    final today = Helpers.todayString();
    final ref = _db.ref(FirebasePaths.user(uid));

    final result = await ref.runTransaction((current) {
      if (current == null) return Transaction.abort();
      final data = Map<String, dynamic>.from(current as Map);

      if (data['last_daily_bonus_date'] == today) return Transaction.abort();

      data['last_daily_bonus_date'] = today;
      data['coins'] = (data['coins'] ?? 0) + CoinValues.dailyBonus;
      data['today_earning'] =
          (data['today_earning'] ?? 0) + CoinValues.dailyBonus;
      return Transaction.success(data);
    });

    return result.committed;
  }

  // ─── Withdrawal ────────────────────────────────────────────────────────────

  /// Withdrawal request save karo
  Future<String?> submitWithdrawal(
      String uid, Map<String, dynamic> data) async {
    try {
      final ref = _db.ref(FirebasePaths.withdrawal(uid)).push();
      await ref.set({
        ...data,
        'uid': uid,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'id': ref.key,
      });

      // Coins deduct karo
      await deductCoins(uid, data['coins'] as int);

      // Check: kya yeh user ka pehla withdrawal hai?
      await _checkFirstWithdrawal(uid);

      return ref.key;
    } catch (e) {
      return null;
    }
  }

  /// Pehla withdrawal: referrer ko 500 coins do
  Future<void> _checkFirstWithdrawal(String uid) async {
    final userData = await getUser(uid);
    if (userData == null || userData.referredByUid.isEmpty) return;

    final withdrawals = _db.ref(FirebasePaths.withdrawal(uid));
    final snap = await withdrawals.get();
    if (!snap.exists) return;

    final all = snap.value as Map<dynamic, dynamic>;
    if (all.length == 1) {
      // Pehla withdrawal — referrer ko reward do
      await addCoins(
          userData.referredByUid, CoinValues.referralBonus, 'referral_reward');

      // Invite ko verified mark karo
      await _db
          .ref('invites/${userData.referredByUid}/${userData.uid}/verified')
          .set(true);

      // Referrer ka verified_invites count badhao
      await _db
          .ref('${FirebasePaths.user(userData.referredByUid)}/verified_invites')
          .runTransaction((current) {
        return Transaction.success((current ?? 0) as int + 1);
      });
    }
  }

  /// Withdrawal history fetch karo
  Future<List<Map<String, dynamic>>> getWithdrawals(String uid) async {
    final snap = await _db.ref(FirebasePaths.withdrawal(uid)).get();
    if (!snap.exists) return [];

    final map = snap.value as Map<dynamic, dynamic>;
    return map.values
        .map((v) => Map<String, dynamic>.from(v as Map))
        .toList()
      ..sort((a, b) =>
          (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''));
  }

  // ─── Payment Methods ───────────────────────────────────────────────────────

  Future<void> savePaymentMethod(
      String uid, Map<String, dynamic> method) async {
    final ref =
        _db.ref(FirebasePaths.paymentMethods(uid)).push();
    await ref.set({...method, 'id': ref.key});
  }

  Future<List<Map<String, dynamic>>> getPaymentMethods(String uid) async {
    final snap = await _db.ref(FirebasePaths.paymentMethods(uid)).get();
    if (!snap.exists) return [];
    final map = snap.value as Map<dynamic, dynamic>;
    return map.values
        .map((v) => Map<String, dynamic>.from(v as Map))
        .toList();
  }

  Future<void> deletePaymentMethod(String uid, String methodId) async {
    await _db
        .ref('${FirebasePaths.paymentMethods(uid)}/$methodId')
        .remove();
  }

  // ─── Invites ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getInvites(String uid) async {
    final snap = await _db.ref(FirebasePaths.invites(uid)).get();
    if (!snap.exists) return [];
    final map = snap.value as Map<dynamic, dynamic>;
    return map.entries
        .map((e) => {
              'uid': e.key,
              ...Map<String, dynamic>.from(e.value as Map),
            })
        .toList();
  }

  // ─── Reviews ───────────────────────────────────────────────────────────────

  Future<void> submitReview(Map<String, dynamic> review) async {
    final ref = _db.ref(FirebasePaths.reviews()).push();
    await ref.set({...review, 'id': ref.key});
  }

  Future<List<Map<String, dynamic>>> getReviews() async {
    final snap = await _db.ref(FirebasePaths.reviews()).get();
    if (!snap.exists) return [];
    final map = snap.value as Map<dynamic, dynamic>;
    final all = map.values
        .map((v) => Map<String, dynamic>.from(v as Map))
        .toList()
      ..sort((a, b) =>
          (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''));
    // Last 7 days only
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return all
        .where((r) =>
            DateTime.tryParse(r['created_at'] ?? '')?.isAfter(cutoff) ?? false)
        .toList();
  }

  Future<void> replyToReview(
      String reviewId, Map<String, dynamic> reply) async {
    final ref =
        _db.ref(FirebasePaths.reviewReplies(reviewId)).push();
    await ref.set({...reply, 'id': ref.key});
  }
}
