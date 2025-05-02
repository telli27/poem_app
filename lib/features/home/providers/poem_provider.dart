import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';
import 'package:poemapp/models/poem.dart';
import 'package:poemapp/services/api_service.dart';
import 'package:poemapp/features/home/providers/api_service_provider.dart';

final selectedPoemIdProvider = StateProvider<String?>((ref) => null);

// Tüm şiirleri getiren provider
final poemProvider = FutureProvider<List<Poem>>((ref) async {
  try {
    // Watch the refresh provider to trigger refresh when needed
    final shouldRefresh = ref.watch(refreshDataProvider);

    print("⚡ Fetching poems from API...");
    final apiService = ref.read(apiServiceProvider);

    // We don't need to call clearCache here as it's already done in poetProvider if needed

    final poems = await apiService.fetchPoems();
    print("⚡ Successfully fetched ${poems.length} Poem objects");
    return poems;
  } catch (e) {
    print("❌ Error loading poems: $e");
    rethrow;
  }
});

// Seçilen şaire ait şiirleri getiren provider
final poetPoemsProvider = Provider<AsyncValue<List<Poem>>>((ref) {
  final selectedPoetId = ref.watch(selectedPoetIdProvider);
  final poemsAsync = ref.watch(poemProvider);

  return poemsAsync.when(
    data: (poems) {
      if (selectedPoetId == null) return const AsyncValue.data([]);
      final poetPoems =
          poems.where((poem) => poem.poetId == selectedPoetId).toList();
      return AsyncValue.data(poetPoems);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// Seçilen şiiri getiren provider
final selectedPoemProvider = Provider<AsyncValue<Poem?>>((ref) {
  final selectedId = ref.watch(selectedPoemIdProvider);
  final poemsAsync = ref.watch(poemProvider);

  return poemsAsync.when(
    data: (poems) {
      if (selectedId == null) return const AsyncValue.data(null);
      final poem = poems.firstWhere(
        (p) => p.id == selectedId,
        orElse: () => throw Exception('Şiir bulunamadı: $selectedId'),
      );
      return AsyncValue.data(poem);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// Belirli bir şaire ait şiirleri getiren provider
final poemsByPoetProvider = Provider.family<List<Poem>, String>((ref, poetId) {
  final poemsAsync = ref.watch(poemProvider);

  return poemsAsync.when(
    data: (poems) {
      final poetPoems = poems.where((poem) => poem.poetId == poetId).toList();
      print("⚡ Found ${poetPoems.length} poems for poet ID: $poetId");
      if (poetPoems.isEmpty) {
        print("❌ No poems found for poet ID: $poetId");
      } else {
        print("✅ First poem title: ${poetPoems.first.name}");
      }
      return poetPoems;
    },
    loading: () => [],
    error: (err, stack) {
      print("❌ Error fetching poems for poet ID $poetId: $err");
      return [];
    },
  );
});
