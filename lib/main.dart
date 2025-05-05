import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poemapp/core/theme/app_theme.dart';
import 'package:poemapp/core/theme/theme_provider.dart';
import 'package:poemapp/features/main/presentation/pages/main_page.dart';
import 'package:poemapp/services/favorites_service.dart';
import 'package:poemapp/services/connectivity_service.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';
import 'package:poemapp/features/home/providers/poem_provider.dart';
import 'package:poemapp/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Provider to track app startup time for connectivity banner delay
final appStartTimeProvider = Provider<int>((ref) {
  return DateTime.now().millisecondsSinceEpoch;
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await FavoritesService.init();

  // Uygulama başlatma
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
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

      // Önce cache'de veri var mı kontrol et
      final prefs = await SharedPreferences.getInstance();
      final hasCachedPoets = prefs.containsKey('cached_poets_data');
      final hasCachedPoems = prefs.containsKey('cached_poems_data');

      // Eğer cache'de veri yoksa, doğrudan verileri yükle
      if (!hasCachedPoets || !hasCachedPoems) {
        _safeSetState(refreshDataProvider, true);
        print("⚡ Cache'de veri bulunamadı, veriler yüklenecek");
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
      await apiService.getCachedPoetInfo();
      await apiService.getCachedPoemInfo();
    } catch (e) {
      print("❌ Veri kontrolünde hata: $e");
    } finally {
      // Her durumda loading göstergesini kapat
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _safeSetState(poetStartupLoadingProvider, false);
          _safeSetState(poemStartupLoadingProvider, false);
          print("⚡ Yükleme göstergesi kapatıldı");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Connectivity servisi başlat
    ref.read(connectivityServiceProvider);

    // Register the provider listeners to handle refresh state safely
    ref.read(poetProviderListener);
    ref.read(poemProviderListener);

    // ThemeMode provider'ı dinle
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Türk Şiirleri',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainPage(),
    );
  }
}
