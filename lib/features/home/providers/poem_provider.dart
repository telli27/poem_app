import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/models/poem.dart';

final poemsByPoetProvider = Provider.family<List<Poem>, String>((ref, poetId) {
  final allPoems = ref.watch(poemProvider);
  return allPoems.when(
    data: (poems) => poems.where((poem) => poem.poetId == poetId).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final poemProvider = FutureProvider<List<Poem>>((ref) async {
  // Simulate network delay for testing purposes
  await Future.delayed(const Duration(milliseconds: 800));

  // Return dummy poems
  return [
    // Nazım Hikmet Şiirleri (poetId: '1')
    Poem(
      id: '1',
      poetId: '1',
      title: 'Yaşamaya Dair',
      content: 'Yaşamak şakaya gelmez,\n'
          'büyük bir ciddiyetle yaşayacaksın\n'
          'bir sincap gibi mesela,\n'
          'yani, yaşamanın dışında ve ötesinde hiçbir şey beklemeden,\n'
          'yani bütün işin gücün yaşamak olacak.\n'
          'Yaşamayı ciddiye alacaksın,\n'
          'yani o derecede, öylesine ki,\n'
          'mesela, kolların bağlı arkadan, sırtın duvarda,\n'
          'yahut kocaman gözlüklerin,\n'
          'beyaz gömleğinle bir laboratuarda\n'
          'insanlar için ölebileceksin,\n'
          'hem de yüzünü bile görmediğin insanlar için,\n'
          'hem de hiç kimse seni buna zorlamamışken,\n'
          'hem de en güzel en gerçek şeyin\n'
          'yaşamak olduğunu bildiğin halde.',
      author: 'Nazım Hikmet',
      year: '1947',
      tags: ['Hayat', 'İnsan', 'Yaşam', 'Sevgi'],
    ),
    Poem(
      id: '2',
      poetId: '1',
      title: 'Saman Sarısı',
      content: 'Saman sarısı bir yıldız kayıyor\n'
          'durup seyretmedeyim...\n'
          'Fecirde, büyük, mavi bir kuş gibi\n'
          'bu şehr-i İstanbul\n'
          'uçup gidecek gibi görünüyor...\n'
          'Geçti sürünerek gecenin son dizisi\n'
          'ağır ağır, kırık dökük bir yük arabası\n'
          've arkasından bir köpek koştu havlayarak.',
      author: 'Nazım Hikmet',
      year: '1929',
      tags: ['İstanbul', 'Gece', 'Şehir'],
    ),
    Poem(
      id: '3',
      poetId: '1',
      title: 'Masalların Masalı',
      content: 'Su başında durmuşuz,\n'
          'çınarla ben.\n'
          'Suda suretimiz çıkıyor,\n'
          'çınarla benim.\n'
          'Suyun şavkı vuruyor bize,\n'
          'çınarla bana.\n'
          'Su başında durmuşuz,\n'
          'çınarla ben, bir de kedi.\n'
          'Suda suretimiz çıkıyor,\n'
          'çınarla benim, bir de kedinin.\n'
          'Suyun şavkı vuruyor bize,\n'
          'çınarla bana, bir de kediye.\n'
          'Su başında durmuşuz,\n'
          'çınar, ben, kedi, bir de güneş.\n'
          'Suda suretimiz çıkıyor,\n'
          'çınarın, benim, kedinin, bir de güneşin.\n'
          'Suyun şavkı vuruyor bize,\n'
          'çınara, bana, kediye, bir de güneşe.\n'
          'Su başında durmuşuz,\n'
          'çınar, ben, kedi, güneş, bir de ömrümüz.\n'
          'Suda suretimiz çıkıyor,\n'
          'çınarın, benim, kedinin, güneşin, bir de ömrümüzün.\n'
          'Suyun şavkı vuruyor bize,\n'
          'çınara, bana, kediye, güneşe, bir de ömrümüze.\n'
          'Su başında durmuşuz.\n'
          'Önce kedi gidecek,\n'
          'kaybolacak suda sureti.\n'
          'Sonra ben gideceğim,\n'
          'kaybolacak suda suretim.\n'
          'Sonra çınar gidecek,\n'
          'kaybolacak suda sureti.\n'
          'Sonra su gidecek\n'
          'güneş kalacak;\n'
          'sonra o da gidecek...',
      author: 'Nazım Hikmet',
      year: '1946',
      tags: ['Yaşam', 'Doğa', 'Ölüm'],
    ),

    // Orhan Veli Şiirleri (poetId: '2')
    Poem(
      id: '4',
      poetId: '2',
      title: 'İstanbul\'u Dinliyorum',
      content: 'İstanbul\'u dinliyorum, gözlerim kapalı\n'
          'Önce hafiften bir rüzgar esiyor;\n'
          'Yavaş yavaş sallanıyor\n'
          'Yapraklar ağaçlarda;\n'
          'Uzaklarda, çok uzaklarda,\n'
          'Sucuların hiç durmayan çıngırakları\n'
          'İstanbul\'u dinliyorum, gözlerim kapalı.\n\n'
          'İstanbul\'u dinliyorum, gözlerim kapalı;\n'
          'Kuşlar geçiyor, derken;\n'
          'Yükseklerden, sürü sürü, çığlık çığlık.\n'
          'Ağlar çekiliyor dalyanlarda;\n'
          'Bir kadının suya değiyor ayakları;\n'
          'İstanbul\'u dinliyorum, gözlerim kapalı.\n\n'
          'İstanbul\'u dinliyorum, gözlerim kapalı;\n'
          'Serin serin Kapalıçarşı\n'
          'Cıvıl cıvıl Mahmutpaşa\n'
          'Güvercin dolu avlular\n'
          'Çekiç sesleri uzaklardan\n'
          'Güzelim bahar rüzgarında ter kokuları;\n'
          'İstanbul\'u dinliyorum, gözlerim kapalı.',
      author: 'Orhan Veli Kanık',
      year: '1947',
      tags: ['İstanbul', 'Şehir', 'Doğa'],
    ),
    Poem(
      id: '5',
      poetId: '2',
      title: 'Anlatamıyorum',
      content: 'Ağlasam sesimi duyar mısınız,\n'
          'Mısralarımda;\n'
          'Dokunabilir misiniz,\n'
          'Gözyaşlarıma, ellerinizle?\n\n'
          'Bilmezdim şarkıların bu kadar güzel,\n'
          'Kelimelerinse kifayetsiz olduğunu\n'
          'Bu derde düşmeden önce.\n\n'
          'Bir yer var, biliyorum;\n'
          'Her şeyi söylemek mümkün;\n'
          'Epeyce yaklaşmışım, duyuyorum;\n'
          'Anlatamıyorum.',
      author: 'Orhan Veli Kanık',
      year: '1941',
      tags: ['Duygu', 'İfade', 'Aşk'],
    ),

    // Yunus Emre Şiirleri (poetId: '3')
    Poem(
      id: '6',
      poetId: '3',
      title: 'Gel Gör Beni Aşk Neyledi',
      content: 'Gel gör beni aşk neyledi\n'
          'Derde giriftar eyledi\n'
          'Ben ağlarım ele gülmez\n'
          'Halım diger-gûn eyledi\n\n'
          'Benzim sarı gözlerim yaş\n'
          'Bağrım pâre ciğerim taş\n'
          'Halden bilmez bir dertli baş\n'
          'Bu aşk beni zebun eyledi\n\n'
          'Aşk dediğin bir çürük ip\n'
          'Halim kime ederim kılıp\n'
          'Meyil ettim dilber alıp\n'
          'Beni mecnun eyledi\n\n'
          'Ben Yunus-u biçareyim\n'
          'Baştan ayağa yareyim\n'
          'Dost elinden avareyim\n'
          'Başım terkân eyledi',
      author: 'Yunus Emre',
      year: null,
      tags: ['Aşk', 'Tasavvuf', 'Dert'],
    ),
    Poem(
      id: '7',
      poetId: '3',
      title: 'Bana Seni Gerek Seni',
      content: 'Aşkın aldı benden beni\n'
          'Bana seni gerek seni\n'
          'Ben yanarım dünü günü\n'
          'Bana seni gerek seni\n\n'
          'Ne varlığa sevinirim\n'
          'Ne yokluğa yerinirim\n'
          'Aşkın ile avunurum\n'
          'Bana seni gerek seni\n\n'
          'Cennet cennet dedikleri\n'
          'Birkaç köşkle birkaç huri\n'
          'İsteyene ver onları\n'
          'Bana seni gerek seni',
      author: 'Yunus Emre',
      year: null,
      tags: ['Tasavvuf', 'Allah Aşkı', 'Manevi'],
    ),

    // Fuzuli Şiirleri (poetId: '4')
    Poem(
      id: '8',
      poetId: '4',
      title: 'Su Kasidesi',
      content: 'Saçma ey göz eşkden gönlümdeki odlare su\n'
          'Kim bu denlü dutuşan odlare kılmaz çare su\n\n'
          'Abgûndur günbed-i devvâr rengi bilmezem\n'
          'Ya muhît olmuş gözümden günbed-i devvâre su\n\n'
          'Zevk-i tiğinden aceb yoh olsa gönlüm çâk çâk\n'
          'Kim mürûr ilen bırağur rahnei dîvâre su\n\n'
          'Vehm ilen söyler dil-i mecrûh peykânın sözün\n'
          'İhtiyât ilen içer her kimde olsa yâre su',
      author: 'Fuzûlî',
      year: null,
      tags: ['Kaside', 'Divan', 'Su', 'Hz. Muhammed'],
    ),

    // Cemal Süreya Şiirleri (poetId: '5')
    Poem(
      id: '9',
      poetId: '5',
      title: 'Üvercinka',
      content: 'Böylece bir kere daha boynuna sarılırım hayatın\n'
          'Istıraplarımız ve itirazlarımız\n'
          'Can çekişen bir kuş mudur avuçlarınızda\n'
          'Gökyüzüne bir küpegibi asılmış sesimiz\n'
          'Şüphesiz kalacak yüzümüz ve sesimiz yaralı\n'
          'Vakitlerimiz ve sözlerimiz yaralı\n'
          'Ama boynuna sarılırım hayatın bir kere daha.\n\n'
          'Bir sevinçle minelenir yontulmuş yakut taşlarımız\n'
          'En zavallı günümüzde bile, en korkak günümüzde\n'
          'Yüreklerimizde bir çocuk telaşı,\n'
          'Serçe telaşı gibi bir şey,\n'
          'Hayırların, duraklamaların büyük telaşı.\n'
          'Uzanıp kısalır, kısalıp uzarız\n'
          'Uzanıp kısalarak yaşarız\n'
          'Ama boynuna sarılırım hayatın bir kere daha.',
      author: 'Cemal Süreya',
      year: '1954',
      tags: ['Hayat', 'Aşk', 'İkinci Yeni'],
    ),
    Poem(
      id: '10',
      poetId: '5',
      title: 'Aşk',
      content: 'Şimdi sen kalkıp gidiyorsun. Git.\n'
          'Gözlerin durur mu onları da götür.\n'
          'Oysa ben senin gözlerinsiz edemem bilirsin\n'
          'Kurşunkalem gözlerinsiz\n'
          'Kağıtlar gözlerinsiz edemem\n'
          'Denize gözlerinsiz gidemem bilirsin\n\n'
          'Senin gözlerin olmadı mı\n'
          'Benim gözlerim de görmez ki\n'
          'Senin gözlerinsiz dostum\n'
          'Dostlarımı göremem bilirsin\n\n'
          'Üç gün gözlerinsiz kaldım dün gece\n'
          'Üç gece gözlerinsiz kaldım dün gündüz\n'
          'Uykular uyandırmadı azarlandım\n'
          'Tatlı sert tatlı sert azarlandım\n'
          'Yokluğun bir ateşten kordon gibi\n'
          'Dolandı boynuma boynumda kaldı\n\n'
          'Şimdi sen kalkıp gidiyorsun. Git.\n'
          'Gözlerin durur mu onları da götür.\n'
          'Oysa ben sensiz edemem bilirsin\n\n'
          'Edemem de edemem, bilirsin.',
      author: 'Cemal Süreya',
      year: '1954',
      tags: ['Aşk', 'Ayrılık', 'İkinci Yeni'],
    ),
  ];
});
