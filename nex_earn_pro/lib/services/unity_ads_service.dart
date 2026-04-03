// File: lib/services/unity_ads_service.dart
// Kaam: Unity Ads initialize karna, rewarded/banner/interstitial dikhana
// Rewarded ad ke baad Firebase mein coins add karna

import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import '../utils/constants.dart';

class UnityAdsService {
  static final UnityAdsService _instance = UnityAdsService._internal();
  factory UnityAdsService() => _instance;
  UnityAdsService._internal();

  bool _isInitialized = false;
  bool _rewardedAdReady = false;
  bool _interstitialReady = false;

  // ─── Initialize ────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_isInitialized) return;

    await UnityAds.init(
      gameId: UnityAdsConfig.gameId,
      testMode: UnityAdsConfig.testMode,
      onComplete: () {
        _isInitialized = true;
        _loadAds();
      },
      onFailed: (error, message) {
        debugPrint('Unity Ads init failed: $error - $message');
      },
    );
  }

  void _loadAds() {
    // Rewarded ad preload
    UnityAds.load(
      placementId: UnityAdsConfig.rewardedVideoAdUnitId,
      onComplete: (placementId) => _rewardedAdReady = true,
      onFailed: (placementId, error, message) =>
          debugPrint('Rewarded load failed: $message'),
    );

    // Interstitial preload
    UnityAds.load(
      placementId: UnityAdsConfig.interstitialAdUnitId,
      onComplete: (placementId) => _interstitialReady = true,
      onFailed: (placementId, error, message) =>
          debugPrint('Interstitial load failed: $message'),
    );
  }

  // ─── Rewarded Ad ───────────────────────────────────────────────────────────

  /// Rewarded video dikhao — onRewarded callback mein coins do
  Future<void> showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onFailed,
  }) async {
    if (!_isInitialized || !_rewardedAdReady) {
      debugPrint('Rewarded ad not ready');
      onFailed?.call();
      return;
    }

    UnityAds.showVideoAd(
      placementId: UnityAdsConfig.rewardedVideoAdUnitId,
      onComplete: (placementId) {
        _rewardedAdReady = false;
        onRewarded();
        // Next ad preload karo
        _loadRewardedAd();
      },
      onFailed: (placementId, error, message) {
        debugPrint('Rewarded ad failed: $message');
        onFailed?.call();
      },
      onSkipped: (placementId) {
        debugPrint('Rewarded ad skipped — no reward');
      },
    );
  }

  void _loadRewardedAd() {
    UnityAds.load(
      placementId: UnityAdsConfig.rewardedVideoAdUnitId,
      onComplete: (id) => _rewardedAdReady = true,
      onFailed: (id, error, message) {},
    );
  }

  // ─── Interstitial Ad ───────────────────────────────────────────────────────

  Future<void> showInterstitialAd({VoidCallback? onComplete}) async {
    if (!_isInitialized || !_interstitialReady) return;

    UnityAds.showVideoAd(
      placementId: UnityAdsConfig.interstitialAdUnitId,
      onComplete: (id) {
        _interstitialReady = false;
        onComplete?.call();
        // Reload
        UnityAds.load(
          placementId: UnityAdsConfig.interstitialAdUnitId,
          onComplete: (id) => _interstitialReady = true,
          onFailed: (id, error, message) {},
        );
      },
      onFailed: (id, error, message) {},
      onSkipped: (id) {},
    );
  }

  // ─── Banner Ad Widget ──────────────────────────────────────────────────────

  /// Home screen ke neeche banner dikhane ke liye widget
  Widget buildBannerAd() {
    if (!_isInitialized) {
      return Container(
        height: 50,
        color: AppColors.cardBg,
        child: const Center(
          child: Text('Ad Loading...', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return UnityBannerAd(
      placementId: UnityAdsConfig.bannerAdUnitId,
      onLoad: (placementId) => debugPrint('Banner loaded'),
      onClick: (placementId) => debugPrint('Banner clicked'),
      onFailed: (placementId, error, message) =>
          debugPrint('Banner failed: $message'),
    );
  }

  bool get isRewardedReady => _rewardedAdReady;
  bool get isInitialized => _isInitialized;
}
