import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';
import 'package:poemapp/models/poem.dart';
import 'package:poemapp/services/api_service.dart';
import 'package:poemapp/features/home/providers/api_service_provider.dart';
import 'package:poemapp/services/connectivity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final selectedPoemIdProvider = StateProvider<String?>((ref) => null);

// Provider to track if poem data has been loaded at least once
final poemDataLoadedProvider = StateProvider<bool>((ref) => false);

// Provider to keep track of the most recent poem loading error
final poemLoadErrorProvider = StateProvider<String?>((ref) => null);

// Provider to check if poem data is loading at app startup
final poemStartupLoadingProvider = StateProvider<bool>((ref) => false);

// Function to reset refresh flag safely
void resetPoemRefreshFlag(ProviderRef ref) {
  try {
    ref.read(refreshDataProvider.notifier).state = false;
  } catch (e) {
    print("❌ Refresh flag sıfırlanırken hata: $e");
  }
}

// Önbelleğe alınmış tüm şiirleri içeren provider
final poemProvider = FutureProvider<List<Poem>>((ref) async {
  try {
    // Store references to notifiers before any potential dependency changes
    final errorNotifier = ref.read(poemLoadErrorProvider.notifier);
    final dataLoadedNotifier = ref.read(poemDataLoadedProvider.notifier);

    // Watch the refresh provider to trigger refresh when needed
    final shouldRefresh = ref.watch(refreshDataProvider);

    print("⚡ Şiir Provider'ı çağrıldı");
    final apiService = ref.read(apiServiceProvider);

    // Veri yenileme bayrakları ayarlandıysa
    if (shouldRefresh) {
      print("⚡ Yenileme bayrağı aktif, veriler yeniden yüklenecek");
      // DON'T reset the flag here - it will be reset after this provider completes
    }

    // Şiirleri yükle (ApiService artık SharedPreferences'ı kontrol edecek)
    final poems = await apiService.fetchPoems();
    print("⚡ ${poems.length} şiir başarıyla yüklendi");

    // Veri yüklendi olarak işaretle - güvenli şekilde
    try {
      dataLoadedNotifier.state = true;
    } catch (e) {
      print("❌ dataLoadedNotifier güncellenirken hata: $e");
    }

    // Hata mesajını temizle - güvenli şekilde
    try {
      errorNotifier.state = null;
    } catch (e) {
      print("❌ errorNotifier güncellenirken hata: $e");
    }

    return poems;
  } catch (e) {
    print("❌ Şiirler yüklenirken hata: $e");

    // Use try-catch to safely update the error state
    try {
      ref.read(poemStartupLoadingProvider.notifier).state = false;
    } catch (stateError) {
      print("❌ poemStartupLoadingProvider güncellenirken hata: $stateError");
    }

    try {
      ref.read(poemLoadErrorProvider.notifier).state = e.toString();
    } catch (stateError) {
      print("❌ Hata durumu güncellenirken hata: $stateError");
    }

    // Boş liste dön hata dönme
    return [];
  }
});

// Auto-reset refresh flag after poem provider completes
final poemProviderListener = Provider<void>((ref) {
  ref.listen<AsyncValue<List<Poem>>>(
    poemProvider,
    (previous, next) {
      // Reset the refresh flag when the provider is done (either success or error)
      if (previous?.isLoading == true && !next.isLoading) {
        resetPoemRefreshFlag(ref);
      }
    },
  );
  return;
});

// Seçilen şaire ait şiirleri getiren provider
final poetPoemsProvider = Provider<AsyncValue<List<Poem>>>((ref) {
  try {
    final selectedPoetId = ref.watch(selectedPoetIdProvider);
    final poemsAsync = ref.watch(poemProvider);

    return poemsAsync.when(
      data: (poems) {
        if (selectedPoetId == null) return const AsyncValue.data([]);
        final poetPoems =
            poems.where((poem) => poem.poetId == selectedPoetId).toList();
        print(
            "⚡ Şair ID $selectedPoetId için ${poetPoems.length} şiir bulundu");
        return AsyncValue.data(poetPoems);
      },
      loading: () => const AsyncValue.loading(),
      error: (err, stack) => AsyncValue.error(err, stack),
    );
  } catch (e) {
    print("❌ poetPoemsProvider hatası: $e");
    return const AsyncValue.data([]);
  }
});

// Seçilen şiiri getiren provider
final selectedPoemProvider = Provider<AsyncValue<Poem?>>((ref) {
  try {
    final selectedId = ref.watch(selectedPoemIdProvider);
    final poemsAsync = ref.watch(poemProvider);

    return poemsAsync.when(
      data: (poems) {
        if (selectedId == null) return const AsyncValue.data(null);

        try {
          final poem = poems.firstWhere(
            (p) => p.id == selectedId,
            orElse: () => throw Exception('Şiir bulunamadı: $selectedId'),
          );
          return AsyncValue.data(poem);
        } catch (e) {
          print("❌ Şiir bulunamadı: $e");
          return const AsyncValue.data(null);
        }
      },
      loading: () => const AsyncValue.loading(),
      error: (err, stack) => AsyncValue.data(null),
    );
  } catch (e) {
    print("❌ selectedPoemProvider hatası: $e");
    return const AsyncValue.data(null);
  }
});

// Belirli bir şaire ait şiirleri getiren provider - filters already loaded poems
final poemsByPoetProvider = Provider.family<List<Poem>, String>((ref, poetId) {
  try {
    final poemsAsync = ref.watch(poemProvider);

    return poemsAsync.when(
      data: (poems) {
        final poetPoems = poems.where((poem) => poem.poetId == poetId).toList();
        return poetPoems;
      },
      loading: () => [],
      error: (err, stack) {
        print("❌ Şair ID $poetId için şiirler yüklenirken hata: $err");
        return [];
      },
    );
  } catch (e) {
    print("❌ poemsByPoetProvider hatası: $e");
    return [];
  }
});

// Provider for poem info (version and count)
final poemInfoProvider = FutureProvider<Map<String, int>>((ref) async {
  try {
    final apiService = ref.read(apiServiceProvider);
    return await apiService.getCachedPoemInfo();
  } catch (e) {
    print("❌ Şiir bilgisi alınırken hata: $e");
    return {'version': 0, 'count': 0};
  }
});
