import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/models/poet.dart';
import 'package:poemapp/services/api_service.dart';
import 'package:poemapp/features/home/providers/api_service_provider.dart';
import 'package:poemapp/services/connectivity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final selectedPoetIdProvider = StateProvider<String?>((ref) => null);

// Boolean provider to track when data should be refreshed
final refreshDataProvider = StateProvider<bool>((ref) => false);

// Provider to keep track if data has been loaded at least once
final dataLoadedProvider = StateProvider<bool>((ref) => false);

// Provider to keep track of the most recent error
final loadErrorProvider = StateProvider<String?>((ref) => null);

// Provider to check if poet data is loading at app startup
final poetStartupLoadingProvider = StateProvider<bool>((ref) => false);

// Provider for poet info (version and count)
final poetInfoProvider = FutureProvider<Map<String, int>>((ref) async {
  try {
    final apiService = ref.read(apiServiceProvider);
    return await apiService.getCachedPoetInfo();
  } catch (e) {
    print("❌ Şair bilgisi alınırken hata: $e");
    return {'version': 0, 'count': 0};
  }
});

// Function to reset refresh flag safely
void resetRefreshFlag(ProviderRef ref) {
  try {
    ref.read(refreshDataProvider.notifier).state = false;
  } catch (e) {
    print("❌ Refresh flag sıfırlanırken hata: $e");
  }
}

// Önbelleğe alınmış tüm şairleri içeren provider
final poetProvider = FutureProvider<List<Poet>>((ref) async {
  try {
    // Watch the refresh provider to trigger refresh when needed
    final shouldRefresh = ref.watch(refreshDataProvider);

    // Store references to notifiers before any potential dependency changes
    final dataLoadedNotifier = ref.read(dataLoadedProvider.notifier);
    final loadErrorNotifier = ref.read(loadErrorProvider.notifier);

    print("⚡ Şair Provider'ı çağrıldı");
    final apiService = ref.read(apiServiceProvider);

    // Veri yenileme bayrakları ayarlandıysa
    if (shouldRefresh) {
      print("⚡ Yenileme bayrağı aktif, veriler yeniden yüklenecek");
      // DON'T reset the flag here - it will be reset after this provider completes
    }

    // Şairleri yükle (ApiService artık SharedPreferences'ı kontrol edecek)
    final poets = await apiService.fetchPoets();
    print("⚡ ${poets.length} şair başarıyla yüklendi");

    // Veri yüklendi olarak işaretle - güvenli şekilde
    try {
      dataLoadedNotifier.state = true;
    } catch (e) {
      print("❌ dataLoadedNotifier güncellenirken hata: $e");
    }

    // Hata mesajını temizle - güvenli şekilde
    try {
      loadErrorNotifier.state = null;
    } catch (e) {
      print("❌ errorNotifier güncellenirken hata: $e");
    }

    return poets;
  } catch (e) {
    print("❌ Şairler yüklenirken hata: $e");

    // Safely update the error state
    try {
      ref.read(poetStartupLoadingProvider.notifier).state = false;
    } catch (stateError) {
      print("❌ poetStartupLoadingProvider güncellenirken hata: $stateError");
    }

    try {
      ref.read(loadErrorProvider.notifier).state = e.toString();
    } catch (stateError) {
      print("❌ Hata durumu güncellenirken hata: $stateError");
    }

    // Boş liste dön hata dönme
    return [];
  }
});

// Auto-reset refresh flag after poet provider completes
final poetProviderListener = Provider<void>((ref) {
  ref.listen<AsyncValue<List<Poet>>>(
    poetProvider,
    (previous, next) {
      // Reset the refresh flag when the provider is done (either success or error)
      if (previous?.isLoading == true && !next.isLoading) {
        resetRefreshFlag(ref);
      }
    },
  );
  return;
});

// Seçilen şairi getiren provider
final selectedPoetProvider = Provider<AsyncValue<Poet?>>((ref) {
  try {
    final selectedId = ref.watch(selectedPoetIdProvider);
    final poetsAsync = ref.watch(poetProvider);

    return poetsAsync.when(
      data: (poets) {
        if (selectedId == null) return const AsyncValue.data(null);

        try {
          final poet = poets.firstWhere(
            (p) => p.id == selectedId,
            orElse: () => throw Exception('Şair bulunamadı: $selectedId'),
          );
          return AsyncValue.data(poet);
        } catch (e) {
          print("❌ Şair bulunamadı: $e");
          return const AsyncValue.data(null);
        }
      },
      loading: () => const AsyncValue.loading(),
      error: (err, stack) => AsyncValue.data(null),
    );
  } catch (e) {
    print("❌ selectedPoetProvider hatası: $e");
    return const AsyncValue.data(null);
  }
});

// Tüm şairleri getiren provider - arama ve filtreleme için kullanılabilir
final filteredPoetsProvider = Provider<AsyncValue<List<Poet>>>((ref) {
  try {
    final poetListAsync = ref.watch(poetProvider);
    // Burada arama/filtreleme mantığı eklenebilir
    return poetListAsync;
  } catch (e) {
    print("❌ filteredPoetsProvider hatası: $e");
    return const AsyncValue.data([]);
  }
});
