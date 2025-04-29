import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/models/poet.dart';

final poetProvider = FutureProvider<List<Poet>>((ref) async {
  // Simulate network delay for testing purposes
  await Future.delayed(const Duration(milliseconds: 800));

  // Return local dummy data
  return [
    Poet(
      id: '1',
      name: 'Nâzım Hikmet',
      birthDate: '15 Ocak 1902',
      deathDate: '3 Haziran 1963',
      biography:
          'Nâzım Hikmet Ran, Türk şair, oyun yazarı, romancı ve anı yazarı. "Romantik komünist" ve "romantik devrimci" olarak tanımlanır. Şiirleri elliden fazla dile çevrilmiş ve eserleri birçok ödül almıştır. Toplumcu gerçekçi şiirin Türkiye\'deki en önemli temsilcilerinden biri olarak kabul edilir. "Mavi Gözlü Dev" lakabıyla da anılır. Yaşamının büyük bir bölümünü sürgünde ve hapishanelerde geçirmiştir. Eserleri uzun yıllar Türkiye\'de yasaklanmıştır.',
      imageUrl: 'color:blue', // Using color instead of network URL
      periods: ['Cumhuriyet Dönemi'],
      styles: ['Modern', 'Toplumcu Gerçekçi'],
      notableWorks: [
        'Memleketimden İnsan Manzaraları',
        'Kuvâyi Milliye',
        'Şeyh Bedrettin Destanı'
      ],
      birthPlace: 'Selanik',
      deathPlace: 'Moskova',
      influences: ['Vladimir Mayakovski', 'Fütürizm'],
      influencedBy: ['Fütürizm', 'Sosyalist Gerçekçilik'],
    ),
    Poet(
      id: '2',
      name: 'Orhan Veli Kanık',
      birthDate: '13 Nisan 1914',
      deathDate: '14 Kasım 1950',
      biography:
          'Orhan Veli Kanık, Türk şair. Cumhuriyet dönemi Türk şiirinin en önemli şairlerinden biridir. Garip akımının kurucularındandır. Şiirde biçim ve öz olarak yaptığı büyük değişikliklerle, kendisinden sonraki şairleri büyük ölçüde etkilemiştir. Şiiri günlük konuşma diline yaklaştırmış, şiirde ahenk için kullanılan vezin ve kafiyeyi atmış, şiirde söz sanatlarına yer vermemiştir.',
      imageUrl: 'color:red', // Using color instead of network URL
      periods: ['Cumhuriyet Dönemi'],
      styles: ['Garip Akımı'],
      notableWorks: ['Garip', 'Vazgeçemediğim', 'Destan Gibi'],
      birthPlace: 'İstanbul',
      deathPlace: 'İstanbul',
      influences: ['Fransız Şiiri'],
      influencedBy: ['Sürrealizm'],
    ),
    Poet(
      id: '3',
      name: 'Yunus Emre',
      birthDate: '1240 (yaklaşık)',
      deathDate: '1321 (yaklaşık)',
      biography:
          'Yunus Emre, Türk mutasavvıf, şair ve düşünür. Yunus Emre, Anadolu\'da Türkçe şiirin öncüsü olarak görülür. Tasavvuf düşüncesini halkın anlayabileceği sade bir dille ifade etmiştir. İnsanlık sevgisi, hoşgörü ve barış kavramlarını işlemiş, insanın insan olarak değerini vurgulamıştır.',
      imageUrl: 'color:green', // Using color instead of network URL
      periods: ['Eski Anadolu Türkçesi Dönemi'],
      styles: ['Tasavvufi Halk Şiiri'],
      notableWorks: ['Risaletü\'n Nushiyye', 'Yunus Emre Divanı'],
      birthPlace: 'Eskişehir (?)Sakarya (?)',
      deathPlace: 'Eskişehir Mihalıççık (?)',
      influences: ['Ahmed Yesevi', 'Mevlana'],
      influencedBy: ['Tasavvuf Felsefesi', 'İslam'],
    ),
    Poet(
      id: '4',
      name: 'Fuzûlî',
      birthDate: '1483 (yaklaşık)',
      deathDate: '1556',
      biography:
          'Fuzûlî, Türk divan edebiyatının en büyük şairlerinden. Asıl adı Mehmed\'dir. Fuzuli mahlasını kullanmıştır. Türkçe, Arapça ve Farsça şiirler yazmış, üç dilde de divanlar oluşturmuştur. En önemli eserlerinden biri Leyla ile Mecnun mesnevisidir.',
      imageUrl: 'color:purple', // Using color instead of network URL
      periods: ['Klasik Divan Edebiyatı'],
      styles: ['Divan Şiiri'],
      notableWorks: ['Leyla ve Mecnun', 'Beng ü Bade', 'Hadîkatü\'s-Süedâ'],
      birthPlace: 'Kerbela (?)Bağdat (?)',
      deathPlace: 'Kerbela',
      influences: ['Klasik Osmanlı Şiiri'],
      influencedBy: ['Tasavvuf', 'İslam Felsefesi'],
    ),
    Poet(
      id: '5',
      name: 'Cemal Süreya',
      birthDate: '1931',
      deathDate: '9 Ocak 1990',
      biography:
          'Cemal Süreya (doğum adıyla Cemalettin Seber), Türk şair, yazar, eleştirmen ve çevirmen. İkinci Yeni akımının en önemli temsilcilerinden biridir. Şiirleri, nesnel gerçekleri kendine özgü bir bakışla işleyen, imgelerle yüklü eserlerdir. Eserlerinde lirizm, ironi ve erotizm gibi temalar öne çıkar.',
      imageUrl: 'color:orange', // Using color instead of network URL
      periods: ['Cumhuriyet Dönemi'],
      styles: ['İkinci Yeni'],
      notableWorks: ['Üvercinka', 'Göçebe', 'Sevda Sözleri'],
      birthPlace: 'Erzincan',
      deathPlace: 'İstanbul',
      influences: ['İkinci Yeni Şairleri'],
      influencedBy: ['Modern Türk Şiiri', 'Batı Şiiri'],
    ),
  ];
});
