import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/poet.dart';

final poetsProvider = Provider<List<Poet>>((ref) {
  return [
    Poet(
      id: 'p1',
      name: 'Orhan Veli Kanık',
      bio:
          'Modern Türk şiirinin öncülerinden biri olan Orhan Veli Kanık, 13 Nisan 1914\'te İstanbul\'da doğdu ve 14 Kasım 1950\'de İstanbul\'da vefat etti. Garip akımının kurucularından olan şair, günlük konuşma dilini şiire taşıyarak Türk şiirinde yeni bir çığır açtı.',
      birthYear: 1914,
      deathYear: 1950,
      imageUrl: 'assets/images/poets/orhan_veli_kanik.jpg',
      poemIds: ['poem1', 'poem2'],
    ),
    Poet(
      id: 'p2',
      name: 'Arif Nihat Asya',
      bio:
          'Arif Nihat Asya, 7 Şubat 1904\'te Çatalca\'da doğdu ve 5 Ocak 1975\'te Ankara\'da vefat etti. Milli şair olarak tanınan Asya, özellikle "Bayrak" şiiriyle bilinir. Şiirlerinde milli ve manevi değerleri işleyen şair, Cumhuriyet dönemi Türk edebiyatının önemli isimlerindendir.',
      birthYear: 1904,
      deathYear: 1975,
      imageUrl: 'assets/images/poets/arif_nihat_asya.jpg',
      poemIds: ['poem3'],
    ),
    Poet(
      id: 'p3',
      name: 'Attila İlhan',
      bio:
          'Attila İlhan, 15 Haziran 1925\'te İzmir\'de doğdu ve 10 Ekim 2005\'te İstanbul\'da vefat etti. Şiir, roman, deneme, eleştiri gibi türlerde eserler veren İlhan, toplumsal gerçekçi bir çizgide ilerleyerek Türk edebiyatına önemli katkılarda bulunmuştur.',
      birthYear: 1925,
      deathYear: 2005,
      imageUrl: 'assets/images/poets/attila_ilhan.jpg',
      poemIds: ['poem4', 'poem5'],
    ),
    Poet(
      id: 'p4',
      name: 'Nazım Hikmet Ran',
      bio:
          'Nazım Hikmet, 15 Ocak 1902\'de Selanik\'te doğdu ve 3 Haziran 1963\'te Moskova\'da vefat etti. Serbest nazım tekniğini Türk şiirine kazandıran şair, toplumcu gerçekçi edebiyatın en önemli temsilcilerindendir. Şiirleri birçok dile çevrilmiş, dünya çapında tanınan bir şairdir.',
      birthYear: 1902,
      deathYear: 1963,
      imageUrl: 'assets/images/poets/nazim_hikmet.jpg',
      poemIds: ['poem6', 'poem7'],
    ),
    Poet(
      id: 'p5',
      name: 'Necip Fazıl Kısakürek',
      bio:
          'Necip Fazıl Kısakürek, 26 Mayıs 1904\'te İstanbul\'da doğdu ve 25 Mayıs 1983\'te İstanbul\'da vefat etti. "Büyük Doğu" hareketiyle anılan şair, şiir, roman, tiyatro, deneme gibi birçok türde eser vermiştir. "Çile" adlı şiir kitabı Türk edebiyatının başyapıtlarından biri olarak kabul edilir.',
      birthYear: 1904,
      deathYear: 1983,
      imageUrl: 'assets/images/poets/necip_fazil_kisakurek.jpg',
      poemIds: ['poem8', 'poem9', 'poem10'],
    ),
  ];
});

final poetByIdProvider = Provider.family<Poet?, String>((ref, poetId) {
  final poets = ref.watch(poetsProvider);
  try {
    return poets.firstWhere((poet) => poet.id == poetId);
  } catch (e) {
    return null;
  }
});

final filteredPoetsProvider = Provider<List<Poet>>((ref) {
  final poets = ref.watch(poetsProvider);
  final searchTerm = ref.watch(searchTermProvider).toLowerCase();

  if (searchTerm.isEmpty) {
    return poets;
  }

  return poets.where((poet) {
    return poet.name.toLowerCase().contains(searchTerm) ||
        (poet.bio?.toLowerCase().contains(searchTerm) ?? false);
  }).toList();
});

final searchTermProvider = StateProvider<String>((ref) => '');
