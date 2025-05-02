import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() async {
  final poets = generateTurkishPoets(100);
  final poems = generatePoems(poets);

  // Save poets to JSON file
  final poetsJson = json.encode(poets.map((poet) => poet.toJson()).toList());
  await File('assets/data/poets.json').writeAsString(poetsJson);

  // Save poems to JSON file
  final poemsJson = json.encode(poems.map((poem) => poem.toJson()).toList());
  await File('assets/data/poems.json').writeAsString(poemsJson);

  print('Generated ${poets.length} Turkish poets and ${poems.length} poems.');
}

List<Poet> generateTurkishPoets(int count) {
  final poets = <Poet>[];

  final turkishPoetNames = [
    'Nazım Hikmet',
    'Orhan Veli Kanık',
    'Cemal Süreya',
    'Attila İlhan',
    'Turgut Uyar',
    'Edip Cansever',
    'Cahit Sıtkı Tarancı',
    'Ahmet Haşim',
    'Yahya Kemal Beyatlı',
    'Necip Fazıl Kısakürek',
    'Tevfik Fikret',
    'Fuzuli',
    'Yunus Emre',
    'Can Yücel',
    'Ece Ayhan',
    'Ahmet Arif',
    'Özdemir Asaf',
    'Faruk Nafiz Çamlıbel',
    'Mehmet Akif Ersoy',
    'Ziya Gökalp',
    'Oktay Rifat',
    'Behçet Necatigil',
    'Sezai Karakoç',
    'Ümit Yaşar Oğuzcan',
    'Orhan Kemal',
    'Sabahattin Ali',
    'Rıfat Ilgaz',
    'Şükrü Erbaş',
    'İlhan Berk',
    'Aşık Veysel',
    'Pir Sultan Abdal',
    'Şeyh Galip',
    'Baki',
    'Nedim',
    'Nazım Hikmet Ran',
    'Aşık Mahzuni Şerif',
    'Ahmet Hamdi Tanpınar',
    'Nefi',
    'Aşık Emrah',
    'Dadaloğlu',
    'Karacaoğlan',
    'Sabit',
    'Aşık Ömer',
    'Köroğlu',
    'Erzurumlu Emrah',
    'Bayburtlu Zihni',
    'Aşık Dertli',
    'Seyrani',
    'Kul Nesimi',
    'Hayati Vasfi Taşyürek',
    'Nabi',
    'Aşık Şenlik',
    'Ahmet Yesevi',
    'Abdurrahim Karakoç',
    'Dertli Divani',
    'Gevheri',
    'Hekimoğlu İsmail',
    'İsmet Özel',
    'Aşık Daimi',
    'Hayali',
    'Cahit Külebi',
    'Nefi',
    'Salih Baba',
    'Ahmed Arif',
    'Neyzen Tevfik',
    'Metin Eloğlu',
    'Ataol Behramoğlu',
    'Gülten Akın',
    'Murathan Mungan',
    'Bedri Rahmi Eyüboğlu',
    'Sennur Sezer',
    'Sunay Akın',
    'Nigar Hanım',
    'Fazıl Hüsnü Dağlarca',
    'Didem Madak',
    'Aşık Reyhani',
    'Lale Müldür',
    'Arif Nihat Asya',
    'Ahmed Kudsi Tecer',
    'Hüseyin Rahmi Gürpınar',
    'Adnan Yücel',
    'Abdürrahim Karakoç',
    'Feyzi Halıcı',
    'Bekir Sıtkı Erdoğan',
    'Aziz Nesin',
    'Halide Edip Adıvar',
    'Ziya Osman Saba',
    'Ahmet Muhip Dıranas',
    'Bejan Matur',
    'Birhan Keskin',
    'Peyami Safa',
    'Namık Kemal',
    'Ahmet Rasim',
    'Ömer Seyfettin',
    'Halit Ziya Uşaklıgil',
    'Refik Halit Karay',
    'Yakup Kadri Karaosmanoğlu',
    'Reşat Nuri Güntekin',
    'Abdülhak Hamit Tarhan',
    'Haldun Taner',
    'Orhan Pamuk'
  ];

  // Add more names to reach 100
  for (int i = turkishPoetNames.length + 1; i <= 100; i++) {
    turkishPoetNames.add('Türk Şair $i');
  }

  final turkishCities = [
    'İstanbul',
    'Ankara',
    'İzmir',
    'Bursa',
    'Antalya',
    'Konya',
    'Adana',
    'Trabzon',
    'Erzurum',
    'Diyarbakır',
    'Edirne',
    'Sivas',
    'Kayseri',
    'Malatya',
    'Van',
    'Eskişehir',
    'Samsun',
    'Gaziantep',
    'Mardin',
    'Tokat',
    'Amasya',
    'Ordu',
    'Rize',
    'Kars',
    'Artvin'
  ];

  final literaryPeriods = [
    'Divan Edebiyatı',
    'Tanzimat Dönemi',
    'Servet-i Fünun',
    'Milli Edebiyat',
    'Fecr-i Ati',
    'Garip Akımı',
    'İkinci Yeni',
    'Toplumcu Gerçekçilik',
    'Mistik Şiir',
    'Halk Edebiyatı',
    'Modern Türk Şiiri',
    'Cumhuriyet Dönemi',
    'Çağdaş Türk Şiiri'
  ];

  final poeticStyles = [
    'Hece Vezni',
    'Aruz Vezni',
    'Serbest Nazım',
    'Koşma',
    'Gazel',
    'Kaside',
    'Mani',
    'Türkü',
    'Destan',
    'Pastoral Şiir',
    'Lirik Şiir',
    'Epik Şiir',
    'Didaktik Şiir',
    'Pastoral Şiir',
    'Satirik Şiir'
  ];

  final turkishInfluences = [
    'Yunus Emre',
    'Mevlana',
    'Fuzuli',
    'Baki',
    'Nedim',
    'Şeyh Galip',
    'Namık Kemal',
    'Tevfik Fikret',
    'Yahya Kemal',
    'Nazım Hikmet',
    'Orhan Veli',
    'Cemal Süreya',
    'Turgut Uyar',
    'Attila İlhan',
    'Necip Fazıl',
    'Ahmet Hamdi Tanpınar',
    'Mehmet Akif Ersoy',
    'Ahmet Haşim',
    'Cahit Sıtkı Tarancı'
  ];

  // Shuffle the names to randomize
  turkishPoetNames.shuffle();

  for (int i = 0; i < count; i++) {
    final random = Random();
    final birthYear = 1800 + random.nextInt(200);
    final deathYear = birthYear + 50 + random.nextInt(40);
    final birthCity = turkishCities[random.nextInt(turkishCities.length)];
    final deathCity = turkishCities[random.nextInt(turkishCities.length)];

    final numberOfPeriods = 1 + random.nextInt(2);
    final periods = <String>[];
    for (int j = 0; j < numberOfPeriods; j++) {
      final period = literaryPeriods[random.nextInt(literaryPeriods.length)];
      if (!periods.contains(period)) {
        periods.add(period);
      }
    }

    final numberOfStyles = 1 + random.nextInt(3);
    final styles = <String>[];
    for (int j = 0; j < numberOfStyles; j++) {
      final style = poeticStyles[random.nextInt(poeticStyles.length)];
      if (!styles.contains(style)) {
        styles.add(style);
      }
    }

    // Generate influences
    final numberOfInfluences = 2 + random.nextInt(3);
    final influences = <String>[];
    for (int j = 0; j < numberOfInfluences; j++) {
      final influence =
          turkishInfluences[random.nextInt(turkishInfluences.length)];
      if (!influences.contains(influence)) {
        influences.add(influence);
      }
    }

    // Generate influenced by
    final numberOfInfluencedBy = 1 + random.nextInt(2);
    final influencedBy = <String>[];
    for (int j = 0; j < numberOfInfluencedBy; j++) {
      final influence =
          turkishInfluences[random.nextInt(turkishInfluences.length)];
      if (!influencedBy.contains(influence) &&
          !influences.contains(influence)) {
        influencedBy.add(influence);
      }
    }

    final bio = 'Türk edebiyatının önde gelen isimlerinden biri olan ${turkishPoetNames[i]}, ' +
        '${periods.join(' ve ')} dönemlerinde ${styles.join(', ')} tarzında eserler vermiştir. ' +
        '$birthCity doğumlu şair, Türk şiir geleneğine önemli katkılarda bulunmuştur.';

    final poet = Poet(
      id: 'poet_${i + 1}',
      name: turkishPoetNames[i],
      birthDate: '$birthYear',
      deathDate: birthYear > 1950 ? 'Yaşıyor' : '$deathYear',
      biography: bio,
      imageUrl: 'assets/images/poets/poet_${i + 1}.jpg',
      periods: periods,
      styles: styles,
      notableWorks: [], // Will be populated after generating poems
      birthPlace: '$birthCity, Türkiye',
      deathPlace: birthYear > 1950 ? 'Yaşıyor' : '$deathCity, Türkiye',
      influences: influences,
      influencedBy: influencedBy,
    );

    poets.add(poet);
  }

  return poets;
}

List<Poem> generatePoems(List<Poet> poets) {
  final poems = <Poem>[];

  // First, add some famous poems with their real content
  poems.addAll(generateFamousTurkishPoems(poets));

  // Then generate random poems
  poems.addAll(generateRandomPoems(poets));

  return poems;
}

List<Poem> generateFamousTurkishPoems(List<Poet> poets) {
  final famousPoems = <Poem>[];
  final poetMap = {for (var poet in poets) poet.name: poet};

  // Nazım Hikmet - Salkım Söğüt
  if (poetMap.containsKey('Nazım Hikmet')) {
    final poet = poetMap['Nazım Hikmet']!;
    poet.notableWorks.add('Salkım Söğüt');

    famousPoems.add(Poem(
      id: '${poet.id}_poem_famous_1',
      poetId: poet.id,
      title: 'Salkım Söğüt',
      content:
          'Akıyordu su\nGösterip aynasında söğüt ağaçlarını\nSalkım söğütler yıkıyordu suda saçlarını\nYazın sıcak günleriydi\nYalınayak bir çocuk\nElinde bir dal söğüt\nUzaklara gidiyordu...',
      author: poet.name,
      year: '1928',
      tags: ['serbest', 'modern', 'politik'],
      isFavorite: true,
      themes: ['Doğa', 'Yaşam', 'Umut'],
      readingTime: 2,
    ));
  }

  // Orhan Veli Kanık - İstanbul'u Dinliyorum
  if (poetMap.containsKey('Orhan Veli Kanık')) {
    final poet = poetMap['Orhan Veli Kanık']!;
    poet.notableWorks.add('İstanbul\'u Dinliyorum');

    famousPoems.add(Poem(
      id: '${poet.id}_poem_famous_1',
      poetId: poet.id,
      title: 'İstanbul\'u Dinliyorum',
      content:
          'İstanbul\'u dinliyorum, gözlerim kapalı\nÖnce hafiften bir rüzgar esiyor\nYavaş yavaş sallanıyor\nYapraklar, ağaçlarda;\nUzaklarda, çok uzaklarda,\nSucuların hiç durmayan çıngırakları\nİstanbul\'u dinliyorum, gözlerim kapalı.',
      author: poet.name,
      year: '1945',
      tags: ['serbest', 'modern', 'lirik'],
      isFavorite: true,
      themes: ['İstanbul', 'Sevgi', 'Şehir'],
      readingTime: 2,
    ));
  }

  // Ahmet Haşim - Merdiven
  if (poetMap.containsKey('Ahmet Haşim')) {
    final poet = poetMap['Ahmet Haşim']!;
    poet.notableWorks.add('Merdiven');

    famousPoems.add(Poem(
      id: '${poet.id}_poem_famous_1',
      poetId: poet.id,
      title: 'Merdiven',
      content:
          'Ağır, ağır çıkacaksın bu merdivenlerden,\nEteklerinde güneş rengi bir yığın yaprak,\nVe bir zaman bakacaksın semaya ağlayarak...\nSular sarardı... Yüzün perde perde solmakta,\nKızıl havâları seyret ki akşam olmakta...',
      author: poet.name,
      year: '1921',
      tags: ['aruz', 'geleneksel', 'lirik'],
      isFavorite: true,
      themes: ['Zaman', 'Melankoli', 'Akşam'],
      readingTime: 2,
    ));
  }

  // Cahit Sıtkı Tarancı - Otuz Beş Yaş
  if (poetMap.containsKey('Cahit Sıtkı Tarancı')) {
    final poet = poetMap['Cahit Sıtkı Tarancı']!;
    poet.notableWorks.add('Otuz Beş Yaş');

    famousPoems.add(Poem(
      id: '${poet.id}_poem_famous_1',
      poetId: poet.id,
      title: 'Otuz Beş Yaş',
      content:
          'Yaş otuz beş! Yolun yarısı eder.\nDante gibi ortasındayız ömrün.\nDelikanlı çağımızdaki cevher,\nYalvarmak, yakarmak nafile bugün,\nGört beni, kim bilir, belki son defa.',
      author: poet.name,
      year: '1946',
      tags: ['lirik', 'hece', 'modern'],
      isFavorite: true,
      themes: ['Yaşam', 'Zaman', 'Ölüm'],
      readingTime: 3,
    ));
  }

  // Yunus Emre - Gel Gör Beni Aşk Neyledi
  if (poetMap.containsKey('Yunus Emre')) {
    final poet = poetMap['Yunus Emre']!;
    poet.notableWorks.add('Gel Gör Beni Aşk Neyledi');

    famousPoems.add(Poem(
      id: '${poet.id}_poem_famous_1',
      poetId: poet.id,
      title: 'Gel Gör Beni Aşk Neyledi',
      content:
          'Gel gör beni aşk neyledi,\nDerde giriftar eyledi.\nBen ağlarım yane yane,\nAşk boyadı beni kane.\nNe âkilem ne divane,\nGel gör beni aşk neyledi.',
      author: poet.name,
      year: '1300',
      tags: ['tasavvuf', 'hece', 'geleneksel'],
      isFavorite: true,
      themes: ['Aşk', 'İnanç', 'Tasavvuf'],
      readingTime: 2,
    ));
  }

  // Fuzuli - Leyla ile Mecnun'dan
  if (poetMap.containsKey('Fuzuli')) {
    final poet = poetMap['Fuzuli']!;
    poet.notableWorks.add('Leyla ile Mecnun');

    famousPoems.add(Poem(
      id: '${poet.id}_poem_famous_1',
      poetId: poet.id,
      title: 'Leyla ile Mecnun\'dan',
      content:
          'Canım bu tenden alursa felek,\nCismün kuludur, canın melek.\nCanım tenümden cüda kılsa çarh,\nToprağıma Leylî kıla tarh.',
      author: poet.name,
      year: '1535',
      tags: ['divan', 'aruz', 'geleneksel'],
      isFavorite: true,
      themes: ['Aşk', 'Hasret', 'Ölüm'],
      readingTime: 3,
    ));
  }

  // Necip Fazıl Kısakürek - Çile
  if (poetMap.containsKey('Necip Fazıl Kısakürek')) {
    final poet = poetMap['Necip Fazıl Kısakürek']!;
    poet.notableWorks.add('Çile');

    famousPoems.add(Poem(
      id: '${poet.id}_poem_famous_1',
      poetId: poet.id,
      title: 'Çile',
      content:
          'Gâiblerden bir ses geldi: Bu adam,\nDaima bir şeyler soracaktır.\nHaykırmak, gövdede bir yaredir\nPerdeler, tutulmuş bir uğultu...\nBir fikir ki, sıcak yarada kezzap,\nBir iman ki, kanatlarında ölüm...',
      author: poet.name,
      year: '1939',
      tags: ['hece', 'modern', 'mistik'],
      isFavorite: true,
      themes: ['İnanç', 'Varoluş', 'Hayat'],
      readingTime: 4,
    ));
  }

  // Attila İlhan - Ben Sana Mecburum
  if (poetMap.containsKey('Attila İlhan')) {
    final poet = poetMap['Attila İlhan']!;
    poet.notableWorks.add('Ben Sana Mecburum');

    famousPoems.add(Poem(
      id: '${poet.id}_poem_famous_1',
      poetId: poet.id,
      title: 'Ben Sana Mecburum',
      content:
          'Ben sana mecburum bilemezsin\nAdını mıh gibi aklımda tutuyorum\nBüyüdükçe büyüyor gözlerin\nBen sana mecburum bilemezsin\nİçimi seninle ısıtıyorum.',
      author: poet.name,
      year: '1960',
      tags: ['serbest', 'modern', 'lirik'],
      isFavorite: true,
      themes: ['Aşk', 'Tutku', 'Hasret'],
      readingTime: 3,
    ));
  }

  // Cemal Süreya - Üvercinka
  if (poetMap.containsKey('Cemal Süreya')) {
    final poet = poetMap['Cemal Süreya']!;
    poet.notableWorks.add('Üvercinka');

    famousPoems.add(Poem(
      id: '${poet.id}_poem_famous_1',
      poetId: poet.id,
      title: 'Üvercinka',
      content:
          'Ölü mü denir şimdi ona eskiten bir yazı\nAdam mısralarını örer tırnaklar kadar soylu\nHangi şarkıyı söylese birden biterdi\nKimbilir kimdi belki de bir tornavida',
      author: poet.name,
      year: '1958',
      tags: ['ikinci yeni', 'modern', 'serbest'],
      isFavorite: true,
      themes: ['Aşk', 'Erotizm', 'Hayat'],
      readingTime: 3,
    ));
  }

  // Yahya Kemal Beyatlı - Sessiz Gemi
  if (poetMap.containsKey('Yahya Kemal Beyatlı')) {
    final poet = poetMap['Yahya Kemal Beyatlı']!;
    poet.notableWorks.add('Sessiz Gemi');

    famousPoems.add(Poem(
      id: '${poet.id}_poem_famous_1',
      poetId: poet.id,
      title: 'Sessiz Gemi',
      content:
          'Artık demir almak günü gelmişse zamandan,\nMeçhule giden bir gemi kalkar bu limandan.\nHiç yolcusu yokmuş gibi sessizce alır yol;\nSallanmaz o kalkışta ne mendil ne de bir kol.',
      author: poet.name,
      year: '1925',
      tags: ['aruz', 'geleneksel', 'lirik'],
      isFavorite: true,
      themes: ['Ölüm', 'Yolculuk', 'Kader'],
      readingTime: 2,
    ));
  }

  return famousPoems;
}

List<Poem> generateRandomPoems(List<Poet> poets) {
  final poems = <Poem>[];
  final random = Random();

  final turkishPoemTitles = [
    'Yalnızlık',
    'Hasret',
    'Vatan',
    'Aşk',
    'Özlem',
    'Gurbet',
    'Umut',
    'İstanbul',
    'Anadolu',
    'Yaşam',
    'Zaman',
    'Yolculuk',
    'Hüzün',
    'Sevda',
    'Gece',
    'Yıldızlar',
    'Deniz',
    'Güneş',
    'Yağmur',
    'Rüzgar',
    'Dağlar',
    'Irmak',
    'Bahar',
    'Sonbahar',
    'Kış',
    'Yaz',
    'Toprak',
    'Gökyüzü',
    'Ölüm',
    'Yaşam',
    'Anılar',
    'Çocukluk',
    'Gençlik',
    'İhtiyarlık',
    'Dostluk',
    'Kardeşlik',
    'İnsan',
    'Hayat',
    'Özgürlük',
    'Seni Düşünmek',
    'Sessiz Gemi',
    'Kar Musikileri',
    'Mavi Liman',
    'Garip',
    'Ağıt',
    'Mesnevi',
    'İstiklal Marşı',
    'Kaldırımlar',
    'Akşam',
    'Sabah',
    'Dağlarca',
    'Saatleri Ayarlama Enstitüsü',
    'Kuvâyi Milliye',
    'Anayurt Oteli',
    'Sisler Bulvarı',
    'Memleketimden İnsan Manzaraları',
    'Hoşçakal',
    'Sen',
    'Üvercinka',
    'Sana Gitmeyi Düşünüyorum',
    'Piraye İçin Yazılmış Saat 21-22 Şiirleri',
    'Rubâiyât',
    'Kaside',
    'Gazel',
    'Meyhane',
    'Her Şey Yerli Yerinde',
    'Yalan',
    'Bu Ülke',
    'Hicaz Şarkısı',
    'Mor Külhani',
    'Sonra İşte Yaşlandığını Hissediyorsun',
    'Kapalı Çarşı',
    'Otuz Beş Yaş',
    'Kör Ayna, Kayıp Şark',
    'Çakmak Çakmaya Geldim',
    'Bin Hüzünlü Haz',
    'Haziranda Ölmek Zor',
    'Kan Kalesi',
    'Gül Şiirleri',
    'Mona Rosa',
    'Çile',
    'Rubâiler',
    'Şahdamar',
    'Sevgilerde',
    'Bakışsız Bir Kedi Kara',
    'Yerçekimli Karanfil',
    'Aylak Adam',
    'Sürgün Ülkeden Başkentler Başkentine',
    'Yaşamak Bir Ağaç Gibi',
    'Salkım Salkım Tan Yelleri',
    'Bu Memleket Bizim'
  ];

  final themes = [
    'Aşk',
    'Doğa',
    'Ölüm',
    'Yaşam',
    'Savaş',
    'Barış',
    'Özgürlük',
    'İnanç',
    'Zaman',
    'Anı',
    'Kimlik',
    'Umutsuzluk',
    'Umut',
    'Güzellik',
    'Vatan',
    'Hasret',
    'Özlem',
    'Gurbet',
    'Yalnızlık',
    'Toplumsal Mücadele'
  ];

  final tags = [
    'lirik',
    'epik',
    'pastoral',
    'didaktik',
    'satirik',
    'serbest',
    'hece',
    'aruz',
    'modern',
    'geleneksel',
    'tasavvuf',
    'halk',
    'divan',
    'politik',
    'sosyal',
    'milli',
    'aşk',
    'doğa',
    'ölüm',
    'yaşam'
  ];

  for (final poet in poets) {
    // Generate between 5 and 20 poems for each poet
    final poemCount = 5 + random.nextInt(16);
    final poetWorks = <String>[];

    for (int i = 1; i <= poemCount; i++) {
      final poemId = '${poet.id}_poem_$i';

      // Generate Turkish poem title
      final titleIndex = random.nextInt(turkishPoemTitles.length);
      String title = turkishPoemTitles[titleIndex];

      // Add some variation to titles to avoid duplicates
      if (random.nextBool()) {
        title += ' ${random.nextInt(3) + 1}';
      }

      poetWorks.add(title);

      // Generate sample Turkish poem content
      final numberOfLines = 5 + random.nextInt(10);
      final contentLines = <String>[];

      // Daha gerçekçi şiir içerikleri
      final poemLineTemplates = [
        "Gözlerimde tüten bir sızı gibi,",
        "Akşam çökerken sessizce,",
        "Rüzgârlar fısıldarken ağaçlara,",
        "Denizin mavisi, göğün mavisi,",
        "Yağmurlar yağıyor şehrin üstüne,",
        "Uzak diyarlardan gelen anılar,",
        "Zaman bir nehir gibi akıp gidiyor,",
        "İçimdeki yangın hiç sönmüyor,",
        "Kuşlar göçüyor güz vakti,",
        "Memleket hasreti yüreğimde,",
        "Bir dağ başında bıraktım sevdamı,",
        "Aşk bir gülüştür inceden,",
        "Dağların ardında kalan köyüm,",
        "Yıldızlar bana senin gözlerini anlatır,",
        "Hüzün çökünce kalbe akşamüstü,",
        "Şafak sökerken dağların ardından,",
        "Gece karanlığında yanan bir ışık,",
        "Gönlüm hep sende kaldı,",
        "Yaşam bir nefes kadar kısa,",
        "Özgürlük rüzgârı esince,",
        "Sen bir ceylan olsan ben bir avcı,",
        "Ölüm bize ne uzak bize ne yakın,",
        "Masmavi bir gökyüzünün altında,",
        "Yaprağa suyun gittiği yoldan gittim,",
        "Hayat kısa, kuşlar uçuyor,",
        "Her şey her şey ne güzel ne güzel,",
        "Hiçbir şey eskisi gibi değil artık,",
        "Bir çocuğun gözlerinde dünya yeniden kurulur,",
        "Sana benim gözümle bakma,",
        "Şakaklarıma kar mı yağdı ne var?",
        "Seni sevdim seveli hayalin karşımda,",
        "Hoş geldin safa geldin ey gönül sultanımız,",
        "Bir yer var biliyorum her şeyi söylemek mümkün,",
        "Seni anlatabilmek seni,",
        "Sus artık içimdeki çocuk,",
        "Dağ dağa kavuşmaz insan insana kavuşur,",
        "Ne doğan güne hükmüm geçer ne halden anlayan bulunur,",
        "Yürekleri dağlayan bir ateş gibiydi yokluğun,",
        "Geceler ülkesinde yolculuk ediyoruz,",
        "Yoksuluz gecelerimiz çok kısa günlerimiz uzun,",
        "Ben gülü sevdiğimi gülün dikeni bilir,",
        "Çektiklerimizi bir biz biliriz bir de gök kubbe,",
        "İnsan olan vatanını satar mı?",
        "Kalbim yine üzgün seni anıyor,",
        "Hangi rüzgâr attı seni bahçeme?",
        "Gün olur alır başımı giderim,",
        "Gözlerin gözlerime değince felaketim olurdu ağlardım,",
        "Her yeni gün bir mucize gibi başlar,",
        "Bir gün bir tepede koyun koyuna,",
        "Dünya bir penceredir her gelen bakar gider,",
        "Ben seni unutmak için sevmedim,",
        "İnsan yaşadığı yere benzer,",
        "Herkes gibi bir hikâyen olmalı senin de,",
        "Sevdiğini söylemeyen dilden özür dilerim,",
        "Bir bakışın yetecek güzel gözlü sevgili,",
        "Sular gibi çağlarım seslenir hep derinden,",
        "Gözlerine bakınca anlıyorum ki hayat güzel,",
        "Beni sevdin diye pişman değilim,",
        "İnan ki çok özledim sesini duymayı,",
        "Hiçbir şey anlatmıyor artık eski dizeler"
      ];

      for (int j = 0; j < numberOfLines; j++) {
        // Şiirlere biraz çeşitlilik katmak için
        final lineTemplate =
            poemLineTemplates[random.nextInt(poemLineTemplates.length)];
        final randomWord =
            turkishPoemTitles[random.nextInt(turkishPoemTitles.length)]
                .toLowerCase();

        // Bazen şablonu kullan, bazen de başlıkla birleştir
        if (random.nextBool()) {
          contentLines.add(lineTemplate);
        } else {
          contentLines.add('$randomWord ${lineTemplate.toLowerCase()}');
        }
      }

      final content = contentLines.join('\n');

      // Generate tags
      final numberOfTags = 1 + random.nextInt(4);
      final poemTags = <String>[];

      for (int j = 0; j < numberOfTags; j++) {
        final tag = tags[random.nextInt(tags.length)];
        if (!poemTags.contains(tag)) {
          poemTags.add(tag);
        }
      }

      // Generate themes
      final numberOfThemes = 1 + random.nextInt(3);
      final poemThemes = <String>[];

      for (int j = 0; j < numberOfThemes; j++) {
        final theme = themes[random.nextInt(themes.length)];
        if (!poemThemes.contains(theme)) {
          poemThemes.add(theme);
        }
      }

      final poem = Poem(
        id: poemId,
        poetId: poet.id,
        title: title,
        content: content,
        author: poet.name,
        year: '${int.parse(poet.birthDate) + 20 + random.nextInt(40)}',
        tags: poemTags,
        isFavorite: random.nextBool(),
        imageUrl: random.nextBool() ? 'assets/images/poems/$poemId.jpg' : null,
        themes: poemThemes,
        readingTime: 1 + random.nextInt(10),
      );

      poems.add(poem);
    }

    // Update poet's notableWorks
    poet.notableWorks.addAll(poetWorks);
  }

  return poems;
}

// Poet model for data generation
class Poet {
  final String id;
  final String name;
  final String birthDate;
  final String deathDate;
  final String biography;
  final String imageUrl;
  final List<String> periods;
  final List<String> styles;
  final List<String> notableWorks;
  final String birthPlace;
  final String deathPlace;
  final List<String> influences;
  final List<String> influencedBy;

  Poet({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.deathDate,
    required this.biography,
    required this.imageUrl,
    required this.periods,
    required this.styles,
    required this.notableWorks,
    required this.birthPlace,
    required this.deathPlace,
    required this.influences,
    required this.influencedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate,
      'deathDate': deathDate,
      'biography': biography,
      'imageUrl': imageUrl,
      'periods': periods,
      'styles': styles,
      'notableWorks': notableWorks,
      'birthPlace': birthPlace,
      'deathPlace': deathPlace,
      'influences': influences,
      'influencedBy': influencedBy,
    };
  }
}

// Poem model for data generation
class Poem {
  final String id;
  final String poetId;
  final String title;
  final String content;
  final String author;
  final String? year;
  final List<String> tags;
  final bool isFavorite;
  final String? imageUrl;
  final List<String>? themes;
  final int? readingTime;

  Poem({
    required this.id,
    required this.poetId,
    required this.title,
    required this.content,
    required this.author,
    this.year,
    required this.tags,
    this.isFavorite = false,
    this.imageUrl,
    this.themes,
    this.readingTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poetId': poetId,
      'title': title,
      'content': content,
      'author': author,
      'year': year,
      'tags': tags,
      'isFavorite': isFavorite,
      'imageUrl': imageUrl,
      'themes': themes,
      'readingTime': readingTime,
    };
  }
}
