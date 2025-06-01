import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Ad configuration model
class AdConfig {
  final int maxImpressions;
  final String bannerAdUnitId;
  final String interstitialAdUnitId;
  final String rewardedAdUnitId;
  final String platform;

  AdConfig({
    required this.maxImpressions,
    required this.bannerAdUnitId,
    required this.interstitialAdUnitId,
    required this.rewardedAdUnitId,
    required this.platform,
  });
}

// Ad service state
class AdServiceState {
  final bool isInitialized;
  final int currentImpressionCount;
  final AdConfig? config;
  final BannerAd? bannerAd;
  final InterstitialAd? interstitialAd;
  final RewardedAd? rewardedAd;
  final bool isRewardedAdLoading;
  final bool isInterstitialAdLoading;

  const AdServiceState({
    this.isInitialized = false,
    this.currentImpressionCount = 0,
    this.config,
    this.bannerAd,
    this.interstitialAd,
    this.rewardedAd,
    this.isRewardedAdLoading = false,
    this.isInterstitialAdLoading = false,
  });

  AdServiceState copyWith({
    bool? isInitialized,
    int? currentImpressionCount,
    AdConfig? config,
    BannerAd? bannerAd,
    InterstitialAd? interstitialAd,
    RewardedAd? rewardedAd,
    bool? isRewardedAdLoading,
    bool? isInterstitialAdLoading,
  }) {
    return AdServiceState(
      isInitialized: isInitialized ?? this.isInitialized,
      currentImpressionCount:
          currentImpressionCount ?? this.currentImpressionCount,
      config: config ?? this.config,
      bannerAd: bannerAd ?? this.bannerAd,
      interstitialAd: interstitialAd ?? this.interstitialAd,
      rewardedAd: rewardedAd ?? this.rewardedAd,
      isRewardedAdLoading: isRewardedAdLoading ?? this.isRewardedAdLoading,
      isInterstitialAdLoading:
          isInterstitialAdLoading ?? this.isInterstitialAdLoading,
    );
  }
}

// Ad service notifier
class AdServiceNotifier extends StateNotifier<AdServiceState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdServiceNotifier() : super(const AdServiceState()) {
    initializeAds();
  }

  /// Initialize Google Mobile Ads SDK
  Future<void> initializeAds() async {
    try {
      await MobileAds.instance.initialize();
      await _fetchAdData();
      state = state.copyWith(isInitialized: true);
    } catch (e) {
      log('Error initializing ads: $e');
    }
  }

  /// Firestore'dan reklam verisini al
  Future<void> _fetchAdData() async {
    log("_fetchAdData* * * * * ");
    try {
      DocumentSnapshot adDoc =
          await _firestore.collection('Ads').doc('ad_1').get();

      if (adDoc.exists) {
        log("adDoc* * $adDoc");

        int maxImpressions = adDoc['maxImpression'];
        log("maxImpression* * $maxImpressions");

        // Test ve gerçek reklam ID'lerini al
        String testBannerAdUnitId = adDoc['testBannerAdUnitId'];
        String realBannerAdUnitId = adDoc['realBannerAdUnitId'];
        String testInterstitialAdUnitId = adDoc['testInterstitialAdUnitId'];
        String realInterstitialAdUnitId = adDoc['realInterstitialAdUnitId'];
        String testRewardedAdUnitId = adDoc['testRewardedAdUnitId'];
        String realRewardedAdUnitId = adDoc['realRewardedAdUnitId'];
        String platform = adDoc['platform'];

        // Platforma göre uygun reklam ID'sini seç
        String bannerAdUnitId = Platform.isAndroid
            ? (platform == 'test' ? testBannerAdUnitId : realBannerAdUnitId)
            : (platform == 'test' ? testBannerAdUnitId : realBannerAdUnitId);

        String interstitialAdUnitId = Platform.isAndroid
            ? (platform == 'test'
                ? testInterstitialAdUnitId
                : realInterstitialAdUnitId)
            : (platform == 'test'
                ? testInterstitialAdUnitId
                : realInterstitialAdUnitId);

        String rewardedAdUnitId = Platform.isAndroid
            ? (platform == 'test' ? testRewardedAdUnitId : realRewardedAdUnitId)
            : (platform == 'test'
                ? testRewardedAdUnitId
                : realRewardedAdUnitId);

        final config = AdConfig(
          maxImpressions: maxImpressions,
          bannerAdUnitId: bannerAdUnitId,
          interstitialAdUnitId: interstitialAdUnitId,
          rewardedAdUnitId: rewardedAdUnitId,
          platform: platform,
        );

        state = state.copyWith(config: config);

        print('Ad configuration loaded successfully');
        print('Banner Ad Unit ID: $bannerAdUnitId');
        print('Interstitial Ad Unit ID: $interstitialAdUnitId');
        print('Rewarded Ad Unit ID: $rewardedAdUnitId');

        // Preload initial ads
        loadInterstitialAd();
        loadRewardedAd();
      } else {
        log("Ad data not found in Firestore");
      }
    } catch (e) {
      print('Firebase error: $e');
    }
  }

  /// Load a banner ad
  void loadBannerAd() {
    final config = state.config;
    if (config == null) return;

    final bannerAd = BannerAd(
      adUnitId: config.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded.');
          state = state.copyWith(bannerAd: ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  /// Load an interstitial ad
  void loadInterstitialAd() {
    final config = state.config;
    if (config == null) return;

    if (state.isInterstitialAdLoading || state.interstitialAd != null) return;

    state = state.copyWith(isInterstitialAdLoading: true);

    InterstitialAd.load(
      adUnitId: config.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          state = state.copyWith(
            interstitialAd: ad,
            isInterstitialAdLoading: false,
          );
          print('Interstitial ad loaded.');
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
          state = state.copyWith(isInterstitialAdLoading: false);
        },
      ),
    );
  }

  /// Show interstitial ad
  void showInterstitialAd() async {
    final config = state.config;
    if (config == null) return;

    if (state.currentImpressionCount >= config.maxImpressions) {
      print('Maximum ad impressions reached');
      return;
    }

    if (state.interstitialAd == null) {
      loadInterstitialAd();
      return;
    }

    state.interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) async {
        ad.dispose();
        // Load next ad immediately
        loadInterstitialAd();
      },
      onAdWillDismissFullScreenContent: (ad) {
        log("onAdWillDismissFullScreenContent");
      },
      onAdShowedFullScreenContent: (ad) {
        log("onAdShowedFullScreenContent");
        state = state.copyWith(
          currentImpressionCount: state.currentImpressionCount + 1,
          interstitialAd: null,
        );
        log("currentImpressionCount: ${state.currentImpressionCount}");
      },
      onAdImpression: (ad) {
        log("onAdImpression");
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Interstitial ad failed to show: $error');
        ad.dispose();
        state = state.copyWith(interstitialAd: null);
        loadInterstitialAd();
      },
    );

    state.interstitialAd!.show();
  }

  /// Load a rewarded ad
  Future<void> loadRewardedAd() async {
    final config = state.config;
    if (config == null) return;

    if (state.isRewardedAdLoading) return;

    state = state.copyWith(isRewardedAdLoading: true);

    await RewardedAd.load(
      adUnitId: config.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          state = state.copyWith(
            rewardedAd: ad,
            isRewardedAdLoading: false,
          );
          print('Rewarded ad loaded.');
        },
        onAdFailedToLoad: (error) {
          print('Rewarded ad failed to load: $error');
          state = state.copyWith(isRewardedAdLoading: false);
        },
      ),
    );
  }

  /// Show a rewarded ad and return whether user earned the reward
  Future<bool> showRewardedAd(
      {required ValueChanged<bool?> rewardEarnedChanged}) async {
    if (state.rewardedAd == null) {
      await loadRewardedAd();
      return false;
    }

    final completer = Completer<bool>();
    bool rewardEarned = false;

    state.rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        state = state.copyWith(rewardedAd: null);
        loadRewardedAd(); // Load next rewarded ad
        completer.complete(rewardEarned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Rewarded ad failed to show: $error');
        ad.dispose();
        state = state.copyWith(rewardedAd: null);
        completer.complete(false);
      },
      onAdShowedFullScreenContent: (ad) {
        log("Rewarded ad shown");
      },
    );

    state.rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        log("User earned reward: ${reward.amount} ${reward.type}");
        rewardEarned = true;
        rewardEarnedChanged(true);
      },
    );

    return completer.future;
  }

  /// Check if rewarded ad is ready to show
  bool isRewardedAdReady() {
    return state.rewardedAd != null;
  }

  /// Check if interstitial ad is ready to show
  bool isInterstitialAdReady() {
    return state.interstitialAd != null;
  }

  /// Dispose the banner ad
  void disposeBannerAd() {
    state.bannerAd?.dispose();
    state = state.copyWith(bannerAd: null);
  }

  /// Dispose all ads
  void disposeAllAds() {
    state.bannerAd?.dispose();
    state.interstitialAd?.dispose();
    state.rewardedAd?.dispose();
    state = state.copyWith(
      bannerAd: null,
      interstitialAd: null,
      rewardedAd: null,
    );
  }

  @override
  void dispose() {
    disposeAllAds();
    super.dispose();
  }
}

// Provider for ad service
final adServiceProvider =
    StateNotifierProvider<AdServiceNotifier, AdServiceState>((ref) {
  return AdServiceNotifier();
});

// Convenience providers for specific ad states
final isInterstitialAdReadyProvider = Provider<bool>((ref) {
  final adState = ref.watch(adServiceProvider);
  return adState.interstitialAd != null;
});

final isRewardedAdReadyProvider = Provider<bool>((ref) {
  final adState = ref.watch(adServiceProvider);
  return adState.rewardedAd != null;
});

final adImpressionCountProvider = Provider<int>((ref) {
  final adState = ref.watch(adServiceProvider);
  return adState.currentImpressionCount;
});

final maxAdImpressionsProvider = Provider<int>((ref) {
  final adState = ref.watch(adServiceProvider);
  return adState.config?.maxImpressions ?? 0;
});
