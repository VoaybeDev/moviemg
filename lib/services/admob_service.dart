// lib/services/admob_service.dart

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  InterstitialAd? _interstitialAd;

  static Future<void> initialize() async {
    // AdMob fonctionne seulement sur Android/iOS
    if (!kIsWeb) {
      await MobileAds.instance.initialize();
    }
  }

  BannerAd? createBannerAd() {
    if (kIsWeb) return null;
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('Banner Ad chargé'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
  }

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
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial erreur: $error');
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (kIsWeb) return;
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      loadInterstitialAd();
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}