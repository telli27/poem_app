import 'package:hive_flutter/hive_flutter.dart';
import 'package:poemapp/models/poem.dart';

class FavoritesService {
  static const String _boxName = 'favorites';
  static const String _poetsBoxName = 'poets_map';

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
    await Hive.openBox(_poetsBoxName);
  }

  // Add poem to favorites
  static Future<void> addToFavorites(Poem poem, {String? poetName}) async {
    final box = Hive.box(_boxName);
    final poetsBox = Hive.box(_poetsBoxName);

    // Şair adını sakla (eğer verilmişse)
    if (poetName != null) {
      await poetsBox.put(poem.poetId, poetName);
    }

    await box.put(poem.id, poem.toJson());
  }

  // Remove poem from favorites
  static Future<void> removeFromFavorites(String poemId) async {
    final box = Hive.box(_boxName);
    await box.delete(poemId);
  }

  // Check if poem is in favorites
  static bool isFavorite(String poemId) {
    final box = Hive.box(_boxName);
    return box.containsKey(poemId);
  }

  // Get all favorite poems
  static List<Poem> getAllFavorites() {
    final box = Hive.box(_boxName);
    final poetsBox = Hive.box(_poetsBoxName);
    final favorites = <Poem>[];

    for (var key in box.keys) {
      final poemMap = box.get(key) as Map;
      final poem = Poem.fromJson(Map<String, dynamic>.from(poemMap));

      // Şair adını getir (varsa)
      final poetName = poetsBox.get(poem.poetId);
      if (poetName != null) {
        // Bu şekilde poetId yerine şair adını kullanarak Poem nesnesini oluştur
        favorites.add(poem.copyWith(isFavorite: true, poetId: poetName));
      } else {
        favorites.add(poem.copyWith(isFavorite: true));
      }
    }

    return favorites;
  }

  // Şair adını kaydet
  static Future<void> savePoetName(String poetId, String poetName) async {
    final poetsBox = Hive.box(_poetsBoxName);
    await poetsBox.put(poetId, poetName);
  }

  // Şair adını getir
  static String? getPoetName(String poetId) {
    final poetsBox = Hive.box(_poetsBoxName);
    return poetsBox.get(poetId);
  }
}
