import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:poemapp/models/poet.dart';
import 'package:poemapp/models/poem.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String poetsUrl =
      'https://raw.githubusercontent.com/OrtakProje-1/poetry_app_datas/refs/heads/master/poets/poets.json';
  static const String poemsUrl =
      'https://raw.githubusercontent.com/OrtakProje-1/poetry_app_datas/refs/heads/master/poems/poems.json';

  static const String POETS_CACHE_KEY = 'cached_poets_data';
  static const String POEMS_CACHE_KEY = 'cached_poems_data';

  // Fetch poets from the API and cache them
  Future<List<Poet>> fetchPoets() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we have cached data
      final cachedData = prefs.getString(POETS_CACHE_KEY);
      if (cachedData != null) {
        print('⚡ Using cached poets data');
        final List<dynamic> data = json.decode(cachedData);
        return data.map((poetData) => Poet.fromJson(poetData)).toList();
      }

      // If no cached data, fetch from network
      print('⚡ No cached poets data, fetching from network');
      final response = await http.get(Uri.parse(poetsUrl));

      if (response.statusCode == 200) {
        // Save to SharedPreferences
        await prefs.setString(POETS_CACHE_KEY, response.body);
        print('⚡ Saved poets data to cache');

        final List<dynamic> data = json.decode(response.body);
        return data.map((poetData) => Poet.fromJson(poetData)).toList();
      } else {
        throw Exception('Failed to load poets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching poets: $e');
    }
  }

  // Fetch poems from the API and cache them
  Future<List<Poem>> fetchPoems() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if we have cached data
      final cachedData = prefs.getString(POEMS_CACHE_KEY);
      if (cachedData != null) {
        print('⚡ Using cached poems data');
        final dynamic parsedData = json.decode(cachedData);

        // Handle nested array structure
        if (parsedData is List) {
          List<Poem> allPoems = [];
          for (var i = 0; i < parsedData.length; i++) {
            final poetPoemGroup = parsedData[i];
            if (poetPoemGroup is List) {
              print(
                  '⚡ Processing poet group $i with ${poetPoemGroup.length} poems');
              for (var poemData in poetPoemGroup) {
                try {
                  final poem = Poem.fromJson(poemData);
                  allPoems.add(poem);
                } catch (e) {
                  print('❌ Error parsing poem: $e');
                  print('❌ Problematic poem data: $poemData');
                }
              }
            } else {
              print(
                  '⚠️ Expected list at index $i but got: ${poetPoemGroup.runtimeType}');
            }
          }
          print('⚡ Total poems loaded from cache: ${allPoems.length}');
          // Debug: Print the first few poets' IDs and how many poems each has
          final poetIds = allPoems.map((p) => p.poetId).toSet().toList();
          for (var poetId in poetIds.take(5)) {
            final count = allPoems.where((p) => p.poetId == poetId).length;
            print('⚡ Poet $poetId has $count poems');
          }
          return allPoems;
        }
        return [];
      }

      // If no cached data, fetch from network
      print('⚡ No cached poems data, fetching from network');
      final response = await http.get(Uri.parse(poemsUrl));

      if (response.statusCode == 200) {
        // Save to SharedPreferences
        await prefs.setString(POEMS_CACHE_KEY, response.body);
        print('⚡ Saved poems data to cache');

        // Handle nested array structure
        final dynamic parsedData = json.decode(response.body);
        if (parsedData is List) {
          List<Poem> allPoems = [];
          for (var i = 0; i < parsedData.length; i++) {
            final poetPoemGroup = parsedData[i];
            if (poetPoemGroup is List) {
              print(
                  '⚡ Processing poet group $i with ${poetPoemGroup.length} poems');
              for (var poemData in poetPoemGroup) {
                try {
                  final poem = Poem.fromJson(poemData);
                  allPoems.add(poem);
                } catch (e) {
                  print('❌ Error parsing poem: $e');
                  print('❌ Problematic poem data: $poemData');
                }
              }
            } else {
              print(
                  '⚠️ Expected list at index $i but got: ${poetPoemGroup.runtimeType}');
            }
          }
          print('⚡ Total poems loaded from network: ${allPoems.length}');
          // Debug: Print the first few poets' IDs and how many poems each has
          final poetIds = allPoems.map((p) => p.poetId).toSet().toList();
          for (var poetId in poetIds.take(5)) {
            final count = allPoems.where((p) => p.poetId == poetId).length;
            print('⚡ Poet $poetId has $count poems');
          }
          return allPoems;
        }
        return [];
      } else {
        throw Exception('Failed to load poems: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching poems: $e');
      throw Exception('Error fetching poems: $e');
    }
  }

  // Method to clear cache if needed
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(POETS_CACHE_KEY);
    await prefs.remove(POEMS_CACHE_KEY);
    print('⚡ Cache cleared');
  }
}
