import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Test IDs (Google ke official)
  static String get bannerAdUnitId => "ca-app-pub-3940256099942544/6300978111";
  static String get interstitialAdUnitId => "ca-app-pub-3940256099942544/1033173712";

  // --- Full Screen Ad (Interstitial) Load karne ka logic ---
  static InterstitialAd? _interstitialAd;

  static void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  static void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      loadInterstitialAd(); // Agli baar ke liye load karo
    }
  }
}