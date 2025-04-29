import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/poem.dart';

final poemsProvider = Provider<List<Poem>>((ref) {
  return [
    Poem(
      id: '1',
      title: 'İstanbul\'u Dinliyorum',
      content: '''İstanbul'u dinliyorum, gözlerim kapalı
Önce hafiften bir rüzgar esiyor
Yavaş yavaş sallanıyor
Yapraklar ağaçlarda;
Uzaklarda, çok uzaklarda
Sucuların hiç durmayan çıngırakları
İstanbul'u dinliyorum, gözlerim kapalı.''',
      poetId: '1',
      poetName: 'Orhan Veli Kanık',
      year: 1941,
      likes: 245,
      tags: ['İstanbul', 'Şehir', 'Yaşam'],
    ),
    Poem(
      id: '2',
      title: 'Lavinia',
      content: '''Bir delinin hatıra defterinden:
Lavinia, karanlıkta en güzel kadındır.
Ben ona pembe duvarlı bir taraçada
Güneşin battığı saatlerde rastladım.
Zümrüt renkli gözlerinde
Bir daüssıla hasreti vardı.
Mütemadiyen ağlamak
Ve öpmek ihtiyacı duyuyordu.
Ben onu çok sevdim.
O, beni sevmek istedi,
Sevebildiği kadar.
Bugün ayrıldık,
Hiç görüşmeyeceğiz artık.
Belki de hatırlamayacağız,
Tanışıp ayrıldığımızı.
Fakat yalnız yıldızlar bilecekler
Aramızda geçenleri.''',
      poetId: '1',
      poetName: 'Orhan Veli Kanık',
      year: 1937,
      likes: 189,
      tags: ['Aşk', 'Ayrılık', 'Hüzün'],
    ),
    Poem(
      id: '3',
      title: 'Beyaz Gemi',
      content: '''Bir beyaz gemi geçecek
Bir sabah vakti camların önünden.
İçinde hiç tanımadığın insanlar,
İçinde tanımadığın memleketlerin şarkıları.
Bir beyaz gemi dalgalara kendini bırakacak
Ve bu küçük şehir uzaklaşacak gitgide;
Küçük evleri, caddeleri ve köprüleriyle,
Köprüleri, artık hatırlanmayacak kadar küçük köprüleriyle...''',
      poetId: '1',
      poetName: 'Orhan Veli Kanık',
      year: 1947,
      likes: 203,
      tags: ['Deniz', 'Yolculuk', 'Özlem'],
    ),
    Poem(
      id: '4',
      title: 'Bayrak',
      content: '''Ey mavi göklerin beyaz ve kızıl süsü,
Kız kardeşimin gelinliği, şehidimin son örtüsü,
Işık ışık, dalga dalga bayrağım!
Senin destanını okudum, senin destanını yazacağım.

Sana benim gözümle bakmayanın
Mezarını kazacağım.
Seni selâmlamadan uçan kuşun
Yuvasını bozacağım.''',
      poetId: '2',
      poetName: 'Arif Nihat Asya',
      year: 1946,
      likes: 321,
      tags: ['Vatan', 'Bayrak', 'Milli'],
    ),
    Poem(
      id: '5',
      title: 'Ben Sana Mecburum',
      content: '''Ben sana mecburum bilemezsin
Adını mıh gibi aklımda tutuyorum
Büyüdükçe büyüyor gözlerin
Ben sana mecburum bilemezsin
İçimi seninle ısıtıyorum.''',
      poetId: '3',
      poetName: 'Attila İlhan',
      year: 1960,
      likes: 376,
      tags: ['Aşk', 'Tutku', 'Bağlılık'],
    ),
    Poem(
      id: '6',
      title: 'Üç Şey',
      content: '''Bir yalnızlık, bir sigara, bir de çay
İlk ikisini sev,
Üçüncüsüne alış.''',
      poetId: '4',
      poetName: 'Cemal Süreya',
      year: 1954,
      likes: 265,
      tags: ['Yalnızlık', 'Yaşam', 'Minimal'],
    ),
    Poem(
      id: '7',
      title: 'Sessiz Gemi',
      content: '''Artık demir almak günü gelmişse zamandan,
Meçhule giden bir gemi kalkar bu limandan.
Hiç yolcusu yokmuş gibi sessizce alır yol;
Sallanmaz o kalkışta ne mendil ne de bir kol.

Rıhtımda kalanlar bu seyahatten elemli,
Günlerce siyah ufka bakar gözleri nemli.
Biçare gönüller! Ne giden son gemidir bu!
Hicranlı hayatın ne de son matemidir bu!''',
      poetId: '5',
      poetName: 'Yahya Kemal Beyatlı',
      year: 1925,
      likes: 298,
      tags: ['Ölüm', 'Yolculuk', 'Veda'],
    ),
    Poem(
      id: '8',
      title: 'Ne İçindeyim Zamanın',
      content: '''Ne içindeyim zamanın,
Ne de büsbütün dışında;
Yekpare, geniş bir anın
Parçalanmaz akışında.''',
      poetId: '6',
      poetName: 'Ahmet Hamdi Tanpınar',
      year: 1946,
      likes: 247,
      tags: ['Zaman', 'Varoluş', 'Felsefi'],
    ),
    Poem(
      id: '9',
      title: 'Sevdadır',
      content: '''Başak olsun buğday olsun yeter ki
Senin emeğinle dolsun avcun
Koysan tuz gibi eriyip gitse içimde
Yaşamak ne güzel ne güzel
Uzun uzun türkü söyler gibi ne güzel.

Dudaklarında bal olsun incir olsun yeter ki
Biraz içimden biraz sevdadan biraz da
Öpsem yarım kalmasın hayat
Ölmek ne güzel ne güzel
Sonuna kadar yaşamışsan eğer.''',
      poetId: '7',
      poetName: 'Özdemir Asaf',
      year: 1965,
      likes: 276,
      tags: ['Aşk', 'Yaşam', 'Ölüm'],
    ),
    Poem(
      id: '10',
      title: 'Bir Çocuk Bahçesinde',
      content: '''Zeytin ağacı
Ilık bir günde
Söyledi bana
Derinden.
Zeytin ağacını 
Dinle dedi
Bir çocuk.
Nazım Hikmet
Sofya'da zindanda
Söyledi bunu da
Derinden.''',
      poetId: '8',
      poetName: 'Nazım Hikmet',
      year: 1957,
      likes: 314,
      tags: ['Doğa', 'Özgürlük', 'Politik'],
    ),
  ];
});

final searchTermProvider = StateProvider<String>((ref) => '');

final filteredPoemsProvider = Provider<List<Poem>>((ref) {
  final poems = ref.watch(poemsProvider);
  final searchTerm = ref.watch(searchTermProvider).toLowerCase();

  if (searchTerm.isEmpty) {
    return poems;
  }

  return poems.where((poem) {
    return poem.title.toLowerCase().contains(searchTerm) ||
        poem.content.toLowerCase().contains(searchTerm) ||
        (poem.poetName != null &&
            poem.poetName!.toLowerCase().contains(searchTerm)) ||
        (poem.tags != null &&
            poem.tags!.any((tag) => tag.toLowerCase().contains(searchTerm)));
  }).toList();
});
