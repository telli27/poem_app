import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poemapp/core/theme/app_theme.dart';
import 'package:poemapp/core/theme/theme_provider.dart';
import 'package:poemapp/features/main/presentation/pages/main_page.dart';
import 'package:poemapp/services/favorites_service.dart';
import 'package:poemapp/services/daily_poem_service.dart';
import 'package:poemapp/services/notification_service.dart';
import 'package:poemapp/services/connectivity_service.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';
import 'package:poemapp/features/home/providers/poem_provider.dart';
import 'package:poemapp/services/api_service.dart';
import 'package:poemapp/features/poem/presentation/pages/poem_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'firebase_options.dart';
import 'package:poemapp/providers/ad_service_provider.dart';

// Global navigator key for navigation from notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Provider to track app startup time for connectivity banner delay
final appStartTimeProvider = Provider<int>((ref) {
  return DateTime.now().millisecondsSinceEpoch;
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    // Continue running without Firebase for now
  }

  // Initialize services with error handling
  try {
    await FavoritesService.init();
    print('✅ FavoritesService initialized successfully');
  } catch (e) {
    print('❌ FavoritesService initialization failed: $e');
  }

  try {
    await DailyPoemService.init();
    print('✅ DailyPoemService initialized successfully');
  } catch (e) {
    print('❌ DailyPoemService initialization failed: $e');
  }

  try {
    await NotificationService.init();
    print('✅ NotificationService initialized successfully');
  } catch (e) {
    print('❌ NotificationService initialization failed: $e');
  }

  // Setup notification tap handler
  DailyPoemService.onNotificationTap = (String? payload) {
    print("📱 Notification tapped with payload: $payload");
    if (payload != null) {
      _handleNotificationTap(payload);
    }
  };

  // Uygulama başlatma
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Handle notification tap navigation
void _handleNotificationTap(String payload) async {
  print("📱 ===== NOTIFICATION TAP HANDLER CALLED =====");
  print("📱 Raw payload: $payload");

  try {
    final payloadData = json.decode(payload) as Map<String, dynamic>;
    print("📱 Parsed notification payload: $payloadData");
    print("📱 Payload type: ${payloadData['type']}");

    if (payloadData['type'] == 'daily_poem') {
      final poemId = payloadData['poem_id'] as String?;
      final poetId = payloadData['poet_id'] as String?;

      print("📱 Poem ID: $poemId");
      print("📱 Poet ID: $poetId");

      if (poemId != null && poetId != null) {
        print("📱 Attempting to navigate to poem detail...");

        // Simple approach: wait a bit then try navigation
        await Future.delayed(const Duration(milliseconds: 500));

        // Check if navigator is available
        if (navigatorKey.currentState == null) {
          print("❌ Navigator state is null!");
          return;
        }

        print("📱 Navigator state is available, fetching poem...");

        // Get the poem from daily poem service first (faster)
        try {
          final todaysPoem = await DailyPoemService.getTodaysPoemService();
          if (todaysPoem != null && todaysPoem.id == poemId) {
            print("📱 Found today's poem, navigating...");
            navigatorKey.currentState!.push(
              MaterialPageRoute(
                builder: (context) => PoemDetailPage(
                  poem: todaysPoem,
                ),
              ),
            );
            return;
          }
        } catch (e) {
          print("❌ Error getting today's poem: $e");
        }

        // Fallback: get from last notification poem
        try {
          final lastPoem = await DailyPoemService.getLastNotificationPoem();
          if (lastPoem != null) {
            print("📱 Using last notification poem, navigating...");
            navigatorKey.currentState!.push(
              MaterialPageRoute(
                builder: (context) => PoemDetailPage(
                  poem: lastPoem,
                ),
              ),
            );
            return;
          }
        } catch (e) {
          print("❌ Error getting last notification poem: $e");
        }

        // Final fallback: try to fetch from API
        try {
          print("📱 Final fallback: fetching from API...");
          final apiService = ApiService();
          final allPoems = await apiService.fetchPoems();

          final poem = allPoems.firstWhere((p) => p.id == poemId);
          print("📱 Found poem from API, navigating...");

          navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (context) => PoemDetailPage(
                poem: poem,
              ),
            ),
          );
        } catch (e) {
          print("❌ All fallbacks failed: $e");
          // Show a simple message to user
          if (navigatorKey.currentState?.context != null) {
            ScaffoldMessenger.of(navigatorKey.currentState!.context)
                .showSnackBar(
              const SnackBar(
                content: Text(
                    "Şiir detayı açılamadı. Lütfen uygulamayı açıp tekrar deneyin."),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        print("❌ Missing poem ID or poet ID in payload");
      }
    } else {
      print("❌ Unknown notification type: ${payloadData['type']}");
    }
  } catch (e) {
    print("❌ Error handling notification tap: $e");
    print("❌ Stack trace: ${StackTrace.current}");
  }

  print("📱 ===== NOTIFICATION TAP HANDLER END =====");
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Widget oluşturulduktan sonra veri kontrolü yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quickDataCheck();
    });
  }

  // Güvenli şekilde provider state'ini güncelleme
  void _safeSetState(StateProvider<bool> provider, bool value) {
    try {
      // Eğer hala güncellemek mümkünse güncelle
      if (mounted) {
        ref.read(provider.notifier).state = value;
      }
    } catch (e) {
      print('⚠️ Provider güncellenirken hata: $e');
    }
  }

  // Hızlı veri kontrolü
  Future<void> _quickDataCheck() async {
    if (!mounted) return;

    try {
      // Loading göstergesini aç
      _safeSetState(poetStartupLoadingProvider, true);
      _safeSetState(poemStartupLoadingProvider, true);

      print("⚡ Veri kontrolü başlıyor...");

      // ApiService ile data kontrolü
      final apiService = ApiService();

      // Timeout ile sınırlı veri kontrolü
      await _performDataCheck().timeout(
        const Duration(seconds: 10), // 10 saniye timeout
      );
    } on TimeoutException {
      print("⚠️ Veri kontrolü zaman aşımı - uygulama yine de açılacak");
    } catch (e) {
      print("❌ Veri kontrolünde hata: $e");
      // Uygulama yine de açılabilir, sadece varsayılan verilerle
    } finally {
      // Her durumda loading göstergesini kapat
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _safeSetState(poetStartupLoadingProvider, false);
            _safeSetState(poemStartupLoadingProvider, false);
            print("⚡ Yükleme göstergesi kapatıldı");
          }
        });
      }
    }
  }

  Future<void> _performDataCheck() async {
    // ApiService ile data kontrolü
    final apiService = ApiService();

    // Önce cache'de veri var mı kontrol et
    final prefs = await SharedPreferences.getInstance();
    final hasCachedPoets = prefs.containsKey('cached_poets_data');
    final hasCachedPoems = prefs.containsKey('cached_poems_data');

    // Check if last data load was too long ago (more than 1 day)
    final lastUpdated = prefs.getInt('data_last_updated') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final dayInMillis = 24 * 60 * 60 * 1000;
    final forceRefresh = (now - lastUpdated) > dayInMillis;

    if (forceRefresh) {
      print("⚡ Son güncelleme çok eski, veriler yenilenecek");
    }

    // Check if there might be corrupted data
    bool potentiallyCorruptedData = false;
    if (hasCachedPoets || hasCachedPoems) {
      try {
        // Try to parse cached data to check for corruption
        if (hasCachedPoets) {
          final poetData = prefs.getString('cached_poets_data');
          if (poetData != null) {
            json.decode(poetData);
          }
        }
        if (hasCachedPoems) {
          final poemData = prefs.getString('cached_poems_data');
          if (poemData != null) {
            json.decode(poemData);
          }
        }
      } catch (e) {
        print("❌ Cache verisi bozulmuş olabilir: $e");
        potentiallyCorruptedData = true;
      }
    }

    // Eğer cache'de veri yoksa, veri bozulmuşsa veya cebri yenileme gerekiyorsa
    if (!hasCachedPoets ||
        !hasCachedPoems ||
        potentiallyCorruptedData ||
        forceRefresh) {
      if (potentiallyCorruptedData) {
        print("⚡ Bozuk cache tespit edildi, veriler temizlenecek");
        await apiService.clearCache();
      }

      if (mounted) {
        _safeSetState(refreshDataProvider, true);
        print("⚡ Cache'de veri bulunamadı, veriler yüklenecek");
      }
    } else {
      // Var olan veriler üzerinde güncellemeler kontrol ediliyor
      final needsUpdate = await apiService.checkAndUpdateData();

      if (needsUpdate && mounted) {
        _safeSetState(refreshDataProvider, true);
        print("⚡ Veri güncellendi, yenileme tetiklendi");
      } else {
        print("⚡ Veriler güncel, yenileme gerekmiyor");
      }
    }

    // Perform an update of poet and poem count metadata
    try {
      await apiService.getCachedPoetInfo();
      await apiService.getCachedPoemInfo();
    } catch (e) {
      print("⚠️ Metadata güncelleme hatası: $e");
    }

    // Force refresh the info providers after data is potentially loaded
    if (mounted) {
      // Invalidate info providers to get updated counts
      ref.invalidate(poetInfoProvider);
      ref.invalidate(poemInfoProvider);
      print("⚡ Info provider'ları yenilendi");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Connectivity servisi başlat
    ref.read(connectivityServiceProvider);

    // Initialize ad service
    ref.read(adServiceProvider);

    // Register the provider listeners to handle refresh state safely
    ref.read(poetProviderListener);
    ref.read(poemProviderListener);

    // ThemeMode provider'ı dinle
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'ŞiirArt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      navigatorKey: navigatorKey,
      home: const MainPage(),
    );
  }
}
