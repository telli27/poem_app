import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/poet.dart';

final poetsProvider = FutureProvider<List<Poet>>((ref) async {
  // Simulate a delay for loading
  await Future.delayed(const Duration(milliseconds: 800));

  // Örnek şair verileri
  return [
    Poet(
      id: '1',
      name: 'Nazım Hikmet',
      birthYear: 1902,
      deathYear: 1963,
      poemCount: 42,
      biography: 'Türk şair, yazar, oyun yazarı ve memoar yazarı.',
      imageUrl: 'https://example.com/nazim.jpg',
    ),
    Poet(
      id: '2',
      name: 'Orhan Veli Kanık',
      birthYear: 1914,
      deathYear: 1950,
      poemCount: 36,
      biography: 'Garip akımının kurucularından Türk şair.',
      imageUrl: 'https://example.com/orhan.jpg',
    ),
    Poet(
      id: '3',
      name: 'Cahit Sıtkı Tarancı',
      birthYear: 1910,
      deathYear: 1956,
      poemCount: 28,
      biography: 'Cumhuriyet dönemi Türk şairi.',
      imageUrl: 'https://example.com/cahit.jpg',
    ),
    Poet(
      id: '4',
      name: 'Necip Fazıl Kısakürek',
      birthYear: 1904,
      deathYear: 1983,
      poemCount: 50,
      biography: 'Türk şair, yazar ve düşünür.',
      imageUrl: 'https://example.com/necip.jpg',
    ),
    Poet(
      id: '5',
      name: 'Cemal Süreya',
      birthYear: 1931,
      deathYear: 1990,
      poemCount: 33,
      biography: 'İkinci Yeni şiir akımının önde gelen isimlerinden.',
      imageUrl: 'https://example.com/cemal.jpg',
    ),
    Poet(
      id: '6',
      name: 'Turgut Uyar',
      birthYear: 1927,
      deathYear: 1985,
      poemCount: 29,
      biography: 'İkinci Yeni şiir akımının önemli şairlerinden.',
      imageUrl: 'https://example.com/turgut.jpg',
    ),
    Poet(
      id: '7',
      name: 'Can Yücel',
      birthYear: 1926,
      deathYear: 1999,
      poemCount: 40,
      biography: 'Şair ve çevirmen.',
      imageUrl: 'https://example.com/can.jpg',
    ),
    Poet(
      id: '8',
      name: 'Attila İlhan',
      birthYear: 1925,
      deathYear: 2005,
      poemCount: 45,
      biography: 'Türk şair, yazar, senarist.',
      imageUrl: 'https://example.com/attila.jpg',
    ),
  ];
});

final searchTermProvider = StateProvider<String>((ref) => '');

final filteredPoetsProvider = Provider<AsyncValue<List<Poet>>>((ref) {
  final poetsAsyncValue = ref.watch(poetsProvider);
  final searchTerm = ref.watch(searchTermProvider);

  return poetsAsyncValue.whenData((poets) {
    if (searchTerm.isEmpty) {
      return poets;
    }

    return poets
        .where((poet) =>
            poet.name.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
  });
});
