// lib/services/admob_service.dart

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  // ✅ Tes vrais IDs AdMob
  static const String _bannerAdUnitId =
      'ca-app-pub-5356415354329243/7610640786';
  static const String _interstitialAdUnitId =
      'ca-app-pub-5356415354329243/2408483247';
  static const String _rewardedAdUnitId =
      'ca-app-pub-5356415354329243/5540713934';

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  static Future<void> initialize() async {
    if (!kIsWeb) {
      await MobileAds.instance.initialize();
    }
  }

  // ───── BANNIÈRE ─────
  BannerAd? createBannerAd() {
    if (kIsWeb) return null;
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('Banner chargé'),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
  }

  // ───── INTERSTITIEL (Enregistrer) ─────
  void loadInterstitialAd({VoidCallback? onLoaded}) {
    if (kIsWeb) return;
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          onLoaded?.call();
        },
        onAdFailedToLoad: (error) =>
            debugPrint('Interstitiel erreur: $error'),
      ),
    );
  }

  void showInterstitialAd({VoidCallback? onComplete}) {
    if (kIsWeb || _interstitialAd == null) {
      onComplete?.call();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onComplete?.call();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  // ───── REWARDED (Télécharger) ─────
  void loadRewardedAd({VoidCallback? onLoaded}) {
    if (kIsWeb) return;
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          onLoaded?.call();
        },
        onAdFailedToLoad: (error) =>
            debugPrint('Rewarded erreur: $error'),
      ),
    );
  }

  void showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onFailed,
  }) {
    if (kIsWeb || _rewardedAd == null) {
      onFailed?.call();
      return;
    }
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded();
      },
    );
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
    );
    _rewardedAd = null;
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}