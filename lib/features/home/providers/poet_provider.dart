import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/models/poet.dart';
import 'package:poemapp/services/api_service.dart';
import 'package:poemapp/features/home/providers/api_service_provider.dart';

final selectedPoetIdProvider = StateProvider<String?>((ref) => null);

// Boolean provider to track when data should be refreshed
final refreshDataProvider = StateProvider<bool>((ref) => false);

final poetProvider = FutureProvider<List<Poet>>((ref) async {
  try {
    // Watch the refresh provider to trigger refresh when needed
    final shouldRefresh = ref.watch(refreshDataProvider);

    if (shouldRefresh) {
      // Clear cache if refresh is requested
      print("⚡ Refreshing data, clearing cache...");
      final apiService = ref.read(apiServiceProvider);
      await apiService.clearCache();
      // Reset the refresh flag
      ref.read(refreshDataProvider.notifier).state = false;
    }

    print("⚡ Fetching poets from API...");
    final apiService = ref.read(apiServiceProvider);
    final poets = await apiService.fetchPoets();
    print("⚡ Successfully fetched ${poets.length} Poet objects");
    return poets;
  } catch (e) {
    print("❌ Error loading poets: $e");
    rethrow;
  }
});

// Seçilen şairi getiren provider
final selectedPoetProvider = Provider<AsyncValue<Poet?>>((ref) {
  final selectedId = ref.watch(selectedPoetIdProvider);
  final poetsAsync = ref.watch(poetProvider);

  return poetsAsync.when(
    data: (poets) {
      if (selectedId == null) return const AsyncValue.data(null);
      final poet = poets.firstWhere(
        (p) => p.id == selectedId,
        orElse: () => throw Exception('Şair bulunamadı: $selectedId'),
      );
      return AsyncValue.data(poet);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// Tüm şairleri getiren provider - arama ve filtreleme için kullanılabilir
final filteredPoetsProvider = Provider<AsyncValue<List<Poet>>>((ref) {
  final poetListAsync = ref.watch(poetProvider);
  // Burada arama/filtreleme mantığı eklenebilir
  return poetListAsync;
});
