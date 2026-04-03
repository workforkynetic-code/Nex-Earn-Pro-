# 💰 Nex Earn Pro — Flutter Android App

> Daily earning app — Watch ads, spin wheel, invite friends, withdraw coins!

---

## 📁 PROJECT STRUCTURE — Har File Ka Kaam

```
nex_earn_pro/
│
├── 📄 pubspec.yaml                    → Dependencies (Firebase, Unity Ads, etc.)
├── 📄 README.md                       → Yeh file — project documentation
│
├── 📁 lib/
│   ├── 📄 main.dart                   → App start point, dark theme, routing
│   ├── 📄 firebase_options.dart       → Firebase config (API keys)
│   │
│   ├── 📁 models/
│   │   └── 📄 user_model.dart         → User data class (Firebase ↔ Dart)
│   │
│   ├── 📁 services/
│   │   ├── 📄 auth_service.dart       → Login, Register, Google Sign-In, Logout
│   │   ├── 📄 firebase_service.dart   → Firebase DB — coins, checkin, withdrawal
│   │   ├── 📄 unity_ads_service.dart  → Unity Ads — rewarded, banner, interstitial
│   │   └── 📄 security_service.dart   → Device fingerprint, anti-cheat
│   │
│   ├── 📁 models/
│   │   └── 📄 user_model.dart         → User data structure
│   │
│   ├── 📁 screens/
│   │   ├── 📄 splash_screen.dart      → Logo animation + auth check
│   │   ├── 📄 login_screen.dart       → Email login + Google Sign-In
│   │   ├── 📄 register_screen.dart    → Registration + referral code
│   │   ├── 📄 home_screen.dart        → Main screen + drawer + check-in
│   │   ├── 📄 tasks_screen.dart       → Watch Ad, Spin, Scratch, Bonus
│   │   ├── 📄 invite_screen.dart      → Referral code + share + invites list
│   │   ├── 📄 withdrawal_screen.dart  → Payment methods + withdraw + history
│   │   ├── 📄 profile_screen.dart     → User profile + stats
│   │   ├── 📄 settings_screen.dart    → Change password, delete account, FAQ
│   │   ├── 📄 review_screen.dart      → Star rating + reviews + replies
│   │   └── 📄 survey_screen.dart      → WebView (survey, privacy policy, terms)
│   │
│   ├── 📁 widgets/
│   │   ├── 📄 coin_balance_widget.dart → AppBar mein coins display
│   │   ├── 📄 spin_wheel_widget.dart   → Canvas-based animated spin wheel
│   │   └── 📄 scratch_card_widget.dart → Touch-to-scratch card
│   │
│   └── 📁 utils/
│       ├── 📄 constants.dart           → Colors, strings, config, coin values
│       └── 📄 helpers.dart             → Date check, validation, format, snackbar
│
├── 📁 android/
│   ├── 📄 build.gradle                → Root Android build (Firebase plugin)
│   └── 📁 app/
│       ├── 📄 build.gradle            → App build config (package name, SDK)
│       ├── 📄 google-services.json    → Firebase Android config ⚠️ REPLACE THIS
│       └── 📁 src/main/
│           └── 📄 AndroidManifest.xml → Permissions + activities
│
└── 📁 .github/
    └── 📁 workflows/
        └── 📄 build.yml               → CI/CD — auto APK build on push
```

---

## 🔥 Firebase Database Structure

```
Firebase Realtime Database
│
├── users/{uid}/
│   ├── uid, username, email
│   ├── coins: 100
│   ├── today_earning: 0
│   ├── checkin_streak: 0, last_checkin: ""
│   ├── referral_code: "JOHN1234"
│   ├── referred_by: "", referred_by_uid: ""
│   ├── total_invites: 0, verified_invites: 0
│   ├── ads_watched_today: 0, last_ad_date: ""
│   ├── spin_count_today: 3, last_spin_date: ""
│   ├── last_scratch_date: ""
│   └── joined_date: "2024-01-01"
│
├── usernames/{username} → uid          (username uniqueness)
│
├── payment_methods/{uid}/{id}/
│   └── type, value, name, id
│
├── withdrawals/{uid}/{id}/
│   └── coins, payment_type, status, created_at
│
├── invites/{referrerUid}/{invitedUid}/
│   └── verified: true/false
│
├── reviews/{id}/
│   └── uid, username, rating, categories, text, created_at
│
├── review_replies/{reviewId}/{replyId}/
│   └── uid, text, created_at
│
└── _fp/{deviceId}/uids/{uid}           (device fingerprinting)
```

---

## 🚀 Setup Guide — Step by Step

### 1. Firebase Setup
```bash
# Firebase Console → https://console.firebase.google.com
# Project: nex-earn-pro-d89be → Add Android App
# Package: com.nexearnpro.app
# Download google-services.json → android/app/ mein rakho
```

### 2. Unity Ads Setup
```dart
// lib/utils/constants.dart mein:
static const String gameId = 'YOUR_UNITY_GAME_ID';  // Replace karo
static const bool testMode = false;  // Production mein false karo
```

### 3. Run Locally
```bash
flutter pub get
flutter run
```

### 4. Build APK Manually
```bash
flutter build apk --release
# APK milega: build/app/outputs/flutter-apk/app-release.apk
```

### 5. GitHub Actions Setup
```
1. GitHub pe repo banao
2. Code push karo
3. Actions → "Build & Release APK" automatically chalta hai
4. Artifacts section se APK download karo
5. Release ke liye: git tag v1.0.0 && git push origin v1.0.0
```

---

## 💡 Important Notes

| Feature | Notes |
|---------|-------|
| **Daily Limits** | Midnight pe reset hote hain (YYYY-MM-DD check) |
| **Spin Wheel** | 3 verified invites ke baad unlock hota hai |
| **Referral Bonus** | Friend ke pehle withdrawal pe +500 coins |
| **Anti-Cheat** | Duplicate transactions Firebase mein check hoti hain |
| **Device Limit** | Max 2 accounts per device |
| **Atomic Coins** | Sab coin operations Firebase transactions se hote hain |

---

## 🎨 Design System

| Token | Value |
|-------|-------|
| Primary | `#7c3aed` (Purple) |
| Background | `#080510` (Dark) |
| Card | `#0f0c22` |
| Accent | `#a78bfa` |
| Gold (coins) | `#fbbf24` |
| Success | `#10b981` |
| Error | `#ef4444` |
| Font | Inter (Google Fonts) |
