import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:poemapp/models/poet.dart';
import 'package:poemapp/models/poem.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // API endpoints
  static const String poetsUrl =
      'https://raw.githubusercontent.com/OrtakProje-1/poetry_app_datas/refs/heads/master/poets/poets.json';
  static const String poemsUrl =
      'https://raw.githubusercontent.com/OrtakProje-1/poetry_app_datas/refs/heads/master/poems/poems.json';

  // Info API endpoints - small payloads that return version and count info
  static const String poetsInfoUrl =
      'https://raw.githubusercontent.com/OrtakProje-1/poetry_app_datas/refs/heads/master/poets/info.json';
  static const String poemsInfoUrl =
      'https://raw.githubusercontent.com/OrtakProje-1/poetry_app_datas/refs/heads/master/poems/info.json';

  // Cache keys
  static const String POETS_CACHE_KEY = 'cached_poets_data';
  static const String POEMS_CACHE_KEY = 'cached_poems_data';
  static const String POETS_INFO_CACHE_KEY = 'cached_poets_info';
  static const String POETS_VERSION_KEY = 'poets_version';
  static const String POETS_COUNT_KEY = 'poets_count';
  static const String POEMS_INFO_CACHE_KEY = 'cached_poems_info';
  static const String POEMS_VERSION_KEY = 'poems_version';
  static const String POEMS_COUNT_KEY = 'poems_count';
  static const String DATA_LAST_UPDATED_KEY = 'data_last_updated';

  // Fetch poets from API or cache
  Future<List<Poet>> fetchPoets() async {
    try {
      print('⚡ fetchPoets() çağrıldı');
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(POETS_CACHE_KEY);

      // Data cached in SharedPreferences
      if (cachedData != null) {
        print('⚡ SharedPreferences\'ta şair verisi bulundu');
        try {
          final List<dynamic> data = json.decode(cachedData);
          final poets =
              data.map((poetData) => Poet.fromJson(poetData)).toList();
          print('⚡ Cached veriden ${poets.length} şair yüklendi');
          return poets;
        } catch (e) {
          print('❌ Cached şair verisi parse edilemedi: $e');
          // Parsing error, need to fetch from network
        }
      }

      // No cache or parsing error, fetch from network
      print('⚡ Şairler ağdan yükleniyor...');

      // Increased timeout for Android
      final response = await http
          .get(Uri.parse(poetsUrl))
          .timeout(const Duration(seconds: 20), // Increased from 5 seconds
              onTimeout: () {
        print('⚠️ Şairler yüklenirken zaman aşımı');
        throw Exception('İnternet bağlantısı yavaş, lütfen tekrar deneyin');
      });

      if (response.statusCode == 200) {
        // Save to SharedPreferences
        await prefs.setString(POETS_CACHE_KEY, response.body);
        // Also store the current time
        await prefs.setInt(
            DATA_LAST_UPDATED_KEY, DateTime.now().millisecondsSinceEpoch);
        print('⚡ Şairler verisi cache\'e kaydedildi');

        // Update metadata
        await updatePoetsMetadata();

        final List<dynamic> data = json.decode(response.body);
        final poets = data.map((poetData) => Poet.fromJson(poetData)).toList();
        print('⚡ Ağdan ${poets.length} şair yüklendi');
        return poets;
      } else {
        print('❌ HTTP Hata: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception('Şairler yüklenemedi: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Şairler yüklenirken hata: $e');
      // More descriptive error message
      if (e.toString().contains('SocketException') ||
          e.toString().contains('timed out')) {
        throw Exception(
            'İnternet bağlantısı zayıf. Lütfen bağlantınızı kontrol edin ve tekrar deneyin.');
      }
      throw Exception('Şairler yüklenirken hata: $e');
    }
  }

  // Update poets metadata without full data download
  Future<void> updatePoetsMetadata() async {
    try {
      final response = await http.get(Uri.parse(poetsInfoUrl));

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final Map<String, dynamic> infoData = json.decode(response.body);

        await prefs.setString(POETS_INFO_CACHE_KEY, response.body);

        if (infoData.containsKey('version')) {
          await prefs.setInt(POETS_VERSION_KEY, infoData['version']);
        }
        if (infoData.containsKey('count')) {
          await prefs.setInt(POETS_COUNT_KEY, infoData['count']);
        }

        print(
            '⚡ Şairler metadatası güncellendi: Versiyon ${infoData['version']}, Sayı ${infoData['count']}');
      }
    } catch (e) {
      print('❌ Şairler metadatası güncellenirken hata: $e');
    }
  }

  // Check if poets data update is needed (by checking version and count)
  Future<bool> isPoetsUpdateNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we have any data first
      if (!prefs.containsKey(POETS_CACHE_KEY)) {
        print('⚡ Şairler verisi bulunamadı, güncelleme gerekli');
        return true;
      }

      // Get local version info
      final localVersion = prefs.getInt(POETS_VERSION_KEY) ?? 0;
      final localCount = prefs.getInt(POETS_COUNT_KEY) ?? 0;

      // Get remote version info
      final response = await http.get(Uri.parse(poetsInfoUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> remoteInfo = json.decode(response.body);
        final remoteVersion = remoteInfo['version'] ?? 0;
        final remoteCount = remoteInfo['count'] ?? 0;

        print(
            '⚡ Şairler versiyon kontrolü - Lokal: $localVersion, Uzak: $remoteVersion');
        print(
            '⚡ Şairler sayı kontrolü - Lokal: $localCount, Uzak: $remoteCount');

        // Update metadata even if we don't update the full data
        await prefs.setString(POETS_INFO_CACHE_KEY, response.body);
        await prefs.setInt(POETS_VERSION_KEY, remoteVersion);
        await prefs.setInt(POETS_COUNT_KEY, remoteCount);

        // Update is needed if version or count has changed
        return remoteVersion > localVersion || remoteCount > localCount;
      } else {
        print('❌ Şairler info yüklenemedi: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Şairler güncelleme kontrolünde hata: $e');
      return false;
    }
  }

  // Fetch poems from API or cache
  Future<List<Poem>> fetchPoems() async {
    try {
      print('⚡ fetchPoems() çağrıldı');
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(POEMS_CACHE_KEY);

      // Data cached in SharedPreferences
      if (cachedData != null) {
        print('⚡ SharedPreferences\'ta şiir verisi bulundu');
        try {
          return _parsePoems(cachedData);
        } catch (e) {
          print('❌ Cached şiir verisi parse edilemedi: $e');
          // Parsing error, need to fetch from network
        }
      }

      // No cache or parsing error, fetch from network
      print('⚡ Şiirler ağdan yükleniyor...');

      // Increased timeout for Android
      final response = await http
          .get(Uri.parse(poemsUrl))
          .timeout(const Duration(seconds: 20), // Increased from 5 seconds
              onTimeout: () {
        print('⚠️ Şiirler yüklenirken zaman aşımı');
        throw Exception('İnternet bağlantısı yavaş, lütfen tekrar deneyin');
      });

      if (response.statusCode == 200) {
        // Save to SharedPreferences
        await prefs.setString(POEMS_CACHE_KEY, response.body);
        // Also store the current time
        await prefs.setInt(
            DATA_LAST_UPDATED_KEY, DateTime.now().millisecondsSinceEpoch);
        print('⚡ Şiirler verisi cache\'e kaydedildi');

        // Update metadata
        await updatePoemsMetadata();

        return _parsePoems(response.body);
      } else {
        print('❌ HTTP Hata: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception('Şiirler yüklenemedi: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Şiirler yüklenirken hata: $e');
      // More descriptive error message
      if (e.toString().contains('SocketException') ||
          e.toString().contains('timed out')) {
        throw Exception(
            'İnternet bağlantısı zayıf. Lütfen bağlantınızı kontrol edin ve tekrar deneyin.');
      }
      throw Exception('Şiirler yüklenirken hata: $e');
    }
  }

  // Parse poems from JSON string
  List<Poem> _parsePoems(String jsonData) {
    final dynamic parsedData = json.decode(jsonData);

    if (parsedData is List) {
      List<Poem> allPoems = [];

      for (var i = 0; i < parsedData.length; i++) {
        final poetPoemGroup = parsedData[i];

        if (poetPoemGroup is List) {
          for (var poemData in poetPoemGroup) {
            try {
              final poem = Poem.fromJson(poemData);
              allPoems.add(poem);
            } catch (e) {
              print('❌ Şiir parse edilemedi: $e');
            }
          }
        }
      }

      print('⚡ Toplam ${allPoems.length} şiir yüklendi');
      return allPoems;
    }

    return [];
  }

  // Update poems metadata without full data download
  Future<void> updatePoemsMetadata() async {
    try {
      final response = await http.get(Uri.parse(poemsInfoUrl));

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final Map<String, dynamic> infoData = json.decode(response.body);

        await prefs.setString(POEMS_INFO_CACHE_KEY, response.body);

        if (infoData.containsKey('version')) {
          await prefs.setInt(POEMS_VERSION_KEY, infoData['version']);
        }
        if (infoData.containsKey('count')) {
          await prefs.setInt(POEMS_COUNT_KEY, infoData['count']);
        }

        print(
            '⚡ Şiirler metadatası güncellendi: Versiyon ${infoData['version']}, Sayı ${infoData['count']}');
      }
    } catch (e) {
      print('❌ Şiirler metadatası güncellenirken hata: $e');
    }
  }

  // Check if poems data update is needed (by checking version and count)
  Future<bool> isPoemsUpdateNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we have any data first
      if (!prefs.containsKey(POEMS_CACHE_KEY)) {
        print('⚡ Şiirler verisi bulunamadı, güncelleme gerekli');
        return true;
      }

      // Get local version info
      final localVersion = prefs.getInt(POEMS_VERSION_KEY) ?? 0;
      final localCount = prefs.getInt(POEMS_COUNT_KEY) ?? 0;

      // Get remote version info
      final response = await http.get(Uri.parse(poemsInfoUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> remoteInfo = json.decode(response.body);
        final remoteVersion = remoteInfo['version'] ?? 0;
        final remoteCount = remoteInfo['count'] ?? 0;

        print(
            '⚡ Şiirler versiyon kontrolü - Lokal: $localVersion, Uzak: $remoteVersion');
        print(
            '⚡ Şiirler sayı kontrolü - Lokal: $localCount, Uzak: $remoteCount');

        // Update metadata even if we don't update the full data
        await prefs.setString(POEMS_INFO_CACHE_KEY, response.body);
        await prefs.setInt(POEMS_VERSION_KEY, remoteVersion);
        await prefs.setInt(POEMS_COUNT_KEY, remoteCount);

        // Update is needed if version or count has changed
        return remoteVersion > localVersion || remoteCount > localCount;
      } else {
        print('❌ Şiirler info yüklenemedi: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Şiirler güncelleme kontrolünde hata: $e');
      return false;
    }
  }

  // Method to clear cache if needed
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(POETS_CACHE_KEY);
    await prefs.remove(POEMS_CACHE_KEY);
    print('⚡ Cache temizlendi');
  }

  // Check and update data if needed - call at app startup
  Future<bool> checkAndUpdateData() async {
    print('⚡ Veri güncellemeleri kontrol ediliyor...');

    bool updatesAvailable = false;

    // Check if poets need update
    final poetsNeedUpdate = await isPoetsUpdateNeeded();
    if (poetsNeedUpdate) {
      print('⚡ Şairler verisi güncellenecek');
      try {
        await fetchPoets();
        updatesAvailable = true;
      } catch (e) {
        print('❌ Şairler güncellenirken hata: $e');
      }
    } else {
      print('⚡ Şairler verisi güncel');
    }

    // Check if poems need update
    final poemsNeedUpdate = await isPoemsUpdateNeeded();
    if (poemsNeedUpdate) {
      print('⚡ Şiirler verisi güncellenecek');
      try {
        await fetchPoems();
        updatesAvailable = true;
      } catch (e) {
        print('❌ Şiirler güncellenirken hata: $e');
      }
    } else {
      print('⚡ Şiirler verisi güncel');
    }

    return updatesAvailable;
  }

  // Get cached poet information (version and count)
  Future<Map<String, int>> getCachedPoetInfo() async {
    final prefs = await SharedPreferences.getInstance();
    var version = prefs.getInt(POETS_VERSION_KEY) ?? 0;
    var count = prefs.getInt(POETS_COUNT_KEY) ?? 0;

    // If count is 0 but we have cached data, calculate the count directly
    if (count == 0) {
      final cachedData = prefs.getString(POETS_CACHE_KEY);
      if (cachedData != null) {
        try {
          final List<dynamic> data = json.decode(cachedData);
          count = data.length;
          // Update the count in SharedPreferences for next time
          await prefs.setInt(POETS_COUNT_KEY, count);
          print('⚡ Şair sayısı SharedPreferences\'tan hesaplandı: $count');
        } catch (e) {
          print('❌ Cached şair verisi parse edilemedi: $e');
        }
      }
    }

    return {
      'version': version,
      'count': count,
    };
  }

  // Get cached poem information (version and count)
  Future<Map<String, int>> getCachedPoemInfo() async {
    final prefs = await SharedPreferences.getInstance();
    var version = prefs.getInt(POEMS_VERSION_KEY) ?? 0;
    var count = prefs.getInt(POEMS_COUNT_KEY) ?? 0;

    // If count is 0 but we have cached data, calculate the count directly
    if (count == 0) {
      final cachedData = prefs.getString(POEMS_CACHE_KEY);
      if (cachedData != null) {
        try {
          // Parse poems to get the count
          final poems = _parsePoems(cachedData);
          count = poems.length;
          // Update the count in SharedPreferences for next time
          await prefs.setInt(POEMS_COUNT_KEY, count);
          print('⚡ Şiir sayısı SharedPreferences\'tan hesaplandı: $count');
        } catch (e) {
          print('❌ Cached şiir verisi parse edilemedi: $e');
        }
      }
    }

    return {
      'version': version,
      'count': count,
    };
  }
}
