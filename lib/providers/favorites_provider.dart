import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/models/poem.dart';
import 'package:poemapp/services/favorites_service.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';

// Provider for all favorite poems
final favoritePoemsProvider =
    StateNotifierProvider<FavoritePoemsNotifier, List<Poem>>((ref) {
  return FavoritePoemsNotifier(ref);
});

// Provider to check if a poem is favorite
final isPoemFavoriteProvider = Provider.family<bool, String>((ref, poemId) {
  final favorites = ref.watch(favoritePoemsProvider);
  return favorites.any((poem) => poem.id == poemId);
});

class FavoritePoemsNotifier extends StateNotifier<List<Poem>> {
  final Ref _ref;

  FavoritePoemsNotifier(this._ref) : super([]) {
    _loadFavorites();
  }

  // Load all favorites from Hive
  Future<void> _loadFavorites() async {
    final favoritePoems = FavoritesService.getAllFavorites();
    state = favoritePoems;
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Poem poem) async {
    final isFavorite = state.any((p) => p.id == poem.id);

    if (isFavorite) {
      await FavoritesService.removeFromFavorites(poem.id);
      state = state.where((p) => p.id != poem.id).toList();
    } else {
      // Şair ID'sine göre şair adını almaya çalış
      String poetName = poem.poetId; // varsayılan olarak ID kullan

      // Şair bilgisi API'den alındıysa:
      try {
        final poetsAsync = _ref.read(poetProvider);
        poetsAsync.whenData((poets) {
          final poet = poets.firstWhere(
            (p) => p.id == poem.poetId,
            orElse: () => throw Exception('Şair bulunamadı'),
          );

          // Şair adını kaydet
          FavoritesService.savePoetName(poem.poetId, poet.name);
          poetName = poet.name;
        });
      } catch (e) {
        // Şair bilgisi alınamazsa ID kullanmaya devam et
        print('Şair bilgisi alınamadı: $e');
      }

      await FavoritesService.addToFavorites(poem, poetName: poetName);
      state = [...state, poem.copyWith(isFavorite: true, poetId: poetName)];
    }
  }

  // Check if a poem is favorite
  bool isPoemFavorite(String poemId) {
    return state.any((poem) => poem.id == poemId);
  }
}
