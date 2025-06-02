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
    print("🚀 AdServiceNotifier constructor called");
    initializeAds();
  }

  /// Initialize Google Mobile Ads SDK
  Future<void> initializeAds() async {
    print("🚀 AdService: Starting initialization...");
    try {
      print("🚀 AdService: Initializing MobileAds SDK...");
      await MobileAds.instance.initialize();
      print("✅ AdService: MobileAds SDK initialized");

      print("🚀 AdService: Fetching ad data from Firebase...");
      await _fetchAdData();

      state = state.copyWith(isInitialized: true);
      print("✅ AdService: Initialization completed successfully");
    } catch (e) {
      print('❌ AdService: Error initializing ads: $e');
      log('Error initializing ads: $e');
    }
  }

  /// Firestore'dan reklam verisini al
  Future<void> _fetchAdData() async {
    log("🔥 _fetchAdData: Starting to fetch ad data from Firestore");
    try {
      print("🔥 Fetching ad document from Firestore...");
      DocumentSnapshot adDoc =
          await _firestore.collection('Ads').doc('ad_1').get();

      if (adDoc.exists) {
        print("✅ Ad document found in Firestore");
        log("adDoc data: ${adDoc.data()}");

        int maxImpressions = adDoc['maxImpression'];
        print("📊 Max impressions: $maxImpressions");

        // Test ve gerçek reklam ID'lerini al
        String testBannerAdUnitId = adDoc['testBannerAdUnitId'];
        String realBannerAdUnitId = adDoc['realBannerAdUnitId'];
        String testInterstitialAdUnitId = adDoc['testInterstitialAdUnitId'];
        String realInterstitialAdUnitId = adDoc['realInterstitialAdUnitId'];
        String testRewardedAdUnitId = adDoc['testRewardedAdUnitId'];
        String realRewardedAdUnitId = adDoc['realRewardedAdUnitId'];
        String platform = adDoc['platform'];

        print("🎯 Platform setting: $platform");

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

        print('✅ Ad configuration loaded successfully');
        print('📱 Platform: ${Platform.isAndroid ? "Android" : "iOS"}');
        print('🎯 Using ${platform} ad IDs');
        print('🔥 Banner Ad Unit ID: $bannerAdUnitId');
        print('🔥 Interstitial Ad Unit ID: $interstitialAdUnitId');
        print('🔥 Rewarded Ad Unit ID: $rewardedAdUnitId');
        print('📊 Max impressions: $maxImpressions');

        // Preload initial ads
        print("🚀 Preloading initial ads...");
        loadInterstitialAd();
        loadRewardedAd();
      } else {
        print("❌ Ad document not found in Firestore");
        log("Ad data not found in Firestore");
      }
    } catch (e) {
      print('❌ Firebase error while fetching ad data: $e');
      print('❌ Stack trace: ${StackTrace.current}');
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
  Future<void> loadInterstitialAd() async {
    final config = state.config;
    if (config == null) {
      print("❌ LoadInterstitialAd: Config is null, cannot load ad");
      return;
    }

    if (state.isInterstitialAdLoading || state.interstitialAd != null) {
      print("⏭️ LoadInterstitialAd: Ad already loading or loaded, skipping");
      return;
    }

    print("🚀 LoadInterstitialAd: Starting to load interstitial ad...");
    print("🔥 Using ad unit ID: ${config.interstitialAdUnitId}");

    state = state.copyWith(isInterstitialAdLoading: true);

    await InterstitialAd.load(
      adUnitId: config.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          state = state.copyWith(
            interstitialAd: ad,
            isInterstitialAdLoading: false,
          );
          print('✅ LoadInterstitialAd: Interstitial ad loaded successfully!');
        },
        onAdFailedToLoad: (error) {
          print('❌ LoadInterstitialAd: Interstitial ad failed to load: $error');
          state = state.copyWith(isInterstitialAdLoading: false);
        },
      ),
    );
  }

  /// Show the interstitial ad if it's loaded
  Future<void> showInterstitialAd() async {
    if (state.interstitialAd == null) {
      print('❌ Interstitial ad not ready to show');
      return;
    }

    try {
      state.interstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          log("onAdDismissedFullScreenContent");
          ad.dispose();
          state = state.copyWith(interstitialAd: null);
          loadInterstitialAd(); // Load the next ad
        },
        onAdShowedFullScreenContent: (ad) {
          log("onAdShowedFullScreenContent");
          state = state.copyWith(
            currentImpressionCount: state.currentImpressionCount + 1,
          );
          log("currentImpressionCount: ${state.currentImpressionCount}");
        },
        onAdImpression: (ad) {
          log("onAdImpression");
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('❌ Interstitial ad failed to show: $error');
          ad.dispose();
          state = state.copyWith(interstitialAd: null);
          loadInterstitialAd();
        },
      );

      await state.interstitialAd!.show();
    } catch (e) {
      print('❌ Error showing interstitial ad: $e');
      state.interstitialAd?.dispose();
      state = state.copyWith(interstitialAd: null);
      loadInterstitialAd();
    }
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

  /// Show rewarded ad for special actions (like downloading card) without impression limit
  Future<bool> showRewardedAdForSpecialAction({
    required ValueChanged<bool?> rewardEarnedChanged,
    String actionType = "download",
  }) async {
    if (state.rewardedAd == null) {
      await loadRewardedAd();
      // Wait a bit for the ad to load if it wasn't ready
      await Future.delayed(const Duration(milliseconds: 500));

      // If still not loaded, return false
      if (state.rewardedAd == null) {
        print('Rewarded ad not ready for special action: $actionType');
        return false;
      }
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
        print('Rewarded ad failed to show for $actionType: $error');
        ad.dispose();
        state = state.copyWith(rewardedAd: null);
        completer.complete(false);
      },
      onAdShowedFullScreenContent: (ad) {
        log("Rewarded ad shown for action: $actionType");
      },
    );

    state.rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        log("User earned reward for $actionType: ${reward.amount} ${reward.type}");
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
