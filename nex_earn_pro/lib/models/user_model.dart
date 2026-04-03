// File: lib/models/user_model.dart
// Kaam: Firebase se aane wala user data is class mein store hota hai
// Map/JSON se convert karna aur Firebase mein save karna yahan handle hota hai

class UserModel {
  final String uid;
  final String username;
  final String email;
  int coins;
  int todayEarning;
  int checkinStreak;
  String lastCheckin;
  final String referralCode;
  String referredBy;
  String referredByUid;
  int totalInvites;
  int verifiedInvites;
  int adsWatchedToday;
  String lastAdDate;
  int spinCountToday;
  String lastSpinDate;
  String lastScratchDate;
  final String joinedDate;
  bool dailyBonusClaimed;
  String lastDailyBonusDate;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.coins = 100,
    this.todayEarning = 0,
    this.checkinStreak = 0,
    this.lastCheckin = '',
    required this.referralCode,
    this.referredBy = '',
    this.referredByUid = '',
    this.totalInvites = 0,
    this.verifiedInvites = 0,
    this.adsWatchedToday = 0,
    this.lastAdDate = '',
    this.spinCountToday = 3,
    this.lastSpinDate = '',
    this.lastScratchDate = '',
    required this.joinedDate,
    this.dailyBonusClaimed = false,
    this.lastDailyBonusDate = '',
  });

  // ─── Factory: Firebase Map → UserModel ─────────────────────────────────────
  factory UserModel.fromMap(String uid, Map<dynamic, dynamic> map) {
    return UserModel(
      uid: uid,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      coins: (map['coins'] ?? 100) as int,
      todayEarning: (map['today_earning'] ?? 0) as int,
      checkinStreak: (map['checkin_streak'] ?? 0) as int,
      lastCheckin: map['last_checkin'] ?? '',
      referralCode: map['referral_code'] ?? '',
      referredBy: map['referred_by'] ?? '',
      referredByUid: map['referred_by_uid'] ?? '',
      totalInvites: (map['total_invites'] ?? 0) as int,
      verifiedInvites: (map['verified_invites'] ?? 0) as int,
      adsWatchedToday: (map['ads_watched_today'] ?? 0) as int,
      lastAdDate: map['last_ad_date'] ?? '',
      spinCountToday: (map['spin_count_today'] ?? 3) as int,
      lastSpinDate: map['last_spin_date'] ?? '',
      lastScratchDate: map['last_scratch_date'] ?? '',
      joinedDate: map['joined_date'] ?? '',
      dailyBonusClaimed: map['daily_bonus_claimed'] ?? false,
      lastDailyBonusDate: map['last_daily_bonus_date'] ?? '',
    );
  }

  // ─── UserModel → Firebase Map ───────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'coins': coins,
      'today_earning': todayEarning,
      'checkin_streak': checkinStreak,
      'last_checkin': lastCheckin,
      'referral_code': referralCode,
      'referred_by': referredBy,
      'referred_by_uid': referredByUid,
      'total_invites': totalInvites,
      'verified_invites': verifiedInvites,
      'ads_watched_today': adsWatchedToday,
      'last_ad_date': lastAdDate,
      'spin_count_today': spinCountToday,
      'last_spin_date': lastSpinDate,
      'last_scratch_date': lastScratchDate,
      'joined_date': joinedDate,
      'daily_bonus_claimed': dailyBonusClaimed,
      'last_daily_bonus_date': lastDailyBonusDate,
    };
  }

  // ─── Copy with updated fields ───────────────────────────────────────────────
  UserModel copyWith({
    int? coins,
    int? todayEarning,
    int? checkinStreak,
    String? lastCheckin,
    String? referredBy,
    String? referredByUid,
    int? totalInvites,
    int? verifiedInvites,
    int? adsWatchedToday,
    String? lastAdDate,
    int? spinCountToday,
    String? lastSpinDate,
    String? lastScratchDate,
    bool? dailyBonusClaimed,
    String? lastDailyBonusDate,
  }) {
    return UserModel(
      uid: uid,
      username: username,
      email: email,
      coins: coins ?? this.coins,
      todayEarning: todayEarning ?? this.todayEarning,
      checkinStreak: checkinStreak ?? this.checkinStreak,
      lastCheckin: lastCheckin ?? this.lastCheckin,
      referralCode: referralCode,
      referredBy: referredBy ?? this.referredBy,
      referredByUid: referredByUid ?? this.referredByUid,
      totalInvites: totalInvites ?? this.totalInvites,
      verifiedInvites: verifiedInvites ?? this.verifiedInvites,
      adsWatchedToday: adsWatchedToday ?? this.adsWatchedToday,
      lastAdDate: lastAdDate ?? this.lastAdDate,
      spinCountToday: spinCountToday ?? this.spinCountToday,
      lastSpinDate: lastSpinDate ?? this.lastSpinDate,
      lastScratchDate: lastScratchDate ?? this.lastScratchDate,
      joinedDate: joinedDate,
      dailyBonusClaimed: dailyBonusClaimed ?? this.dailyBonusClaimed,
      lastDailyBonusDate: lastDailyBonusDate ?? this.lastDailyBonusDate,
    );
  }
}
