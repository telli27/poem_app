import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:poemapp/core/theme/theme_provider.dart';
import 'package:poemapp/features/home/providers/poem_provider.dart';
import 'package:poemapp/features/poem/presentation/pages/poem_detail_page.dart';

// Mood providers
final selectedMoodProvider = StateProvider<String?>((ref) => null);
final moodPoemsProvider = StateProvider<List<dynamic>>((ref) => []);
final isFilteringProvider = StateProvider<bool>((ref) => false);
final displayCountProvider = StateProvider<int>((ref) => 8);

class MoodBasedPoemPage extends ConsumerWidget {
  const MoodBasedPoemPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final selectedMood = ref.watch(selectedMoodProvider);
    final isFiltering = ref.watch(isFilteringProvider);

    final bgColor =
        isDarkMode ? const Color(0xFF1E1E2C) : const Color(0xFFF8F9FA);
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Ruh Halime Göre Şiir",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (selectedMood != null)
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: textColor, size: 20),
              onPressed: () {
                ref.read(selectedMoodProvider.notifier).state = null;
                ref.read(moodPoemsProvider.notifier).state = [];
                ref.read(isFilteringProvider.notifier).state = false;
                ref.read(displayCountProvider.notifier).state = 8;
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact Header
            Animate(
              effects: const [
                FadeEffect(duration: Duration(milliseconds: 600)),
              ],
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF2D2D3F).withOpacity(0.5)
                      : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF7986CB).withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7986CB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.psychology_rounded,
                        color: const Color(0xFF7986CB),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bugün Nasıl Hissediyorsun?",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          Text(
                            "Ruh halini seç, şiirleri keşfet",
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Compact Mood Grid
            Animate(
              effects: const [
                FadeEffect(
                    delay: Duration(milliseconds: 100),
                    duration: Duration(milliseconds: 400)),
              ],
              child: _buildCompactMoodGrid(ref, isDarkMode, textColor),
            ),

            // Loading indicator
            if (isFiltering) ...[
              const SizedBox(height: 20),
              _buildCompactLoading(isDarkMode, textColor),
            ],

            // Selected mood results
            if (selectedMood != null && !isFiltering) ...[
              const SizedBox(height: 20),
              Animate(
                effects: const [
                  FadeEffect(
                      delay: Duration(milliseconds: 200),
                      duration: Duration(milliseconds: 400)),
                ],
                child:
                    _buildMoodResults(ref, selectedMood, isDarkMode, textColor),
              ),
            ],

            // Default explanation when no mood is selected
            if (selectedMood == null && !isFiltering) ...[
              const SizedBox(height: 20),
              Animate(
                effects: const [
                  FadeEffect(
                      delay: Duration(milliseconds: 150),
                      duration: Duration(milliseconds: 400)),
                  SlideEffect(
                      begin: Offset(0, 0.1),
                      delay: Duration(milliseconds: 150),
                      duration: Duration(milliseconds: 400)),
                ],
                child: _buildExplanationCard(isDarkMode, textColor),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactLoading(bool isDarkMode, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D3F) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7986CB)),
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Şiirler aranıyor...",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMoodGrid(
      WidgetRef ref, bool isDarkMode, Color textColor) {
    final selectedMood = ref.watch(selectedMoodProvider);
    final isFiltering = ref.watch(isFilteringProvider);

    final moods = [
      {
        'name': 'Romantik',
        'emoji': '💕',
        'color': const Color(0xFFE91E63),
        'keywords': ['aşk', 'sevda', 'sevgili', 'gönül', 'kalp', 'yar'],
      },
      {
        'name': 'Hüzünlü',
        'emoji': '😢',
        'color': const Color(0xFF2196F3),
        'keywords': ['hüzün', 'ağlamak', 'acı', 'keder', 'yaş', 'gözyaşı'],
      },
      {
        'name': 'Mutlu',
        'emoji': '😊',
        'color': const Color(0xFFFFC107),
        'keywords': ['mutluluk', 'sevinç', 'neşe', 'gülmek', 'şarkı', 'dans'],
      },
      {
        'name': 'Nostaljik',
        'emoji': '🌅',
        'color': const Color(0xFFFF9800),
        'keywords': ['anı', 'geçmiş', 'çocukluk', 'hatıra', 'özlem', 'anne'],
      },
      {
        'name': 'Umutlu',
        'emoji': '🌟',
        'color': const Color(0xFF4CAF50),
        'keywords': ['umut', 'sabah', 'güneş', 'gelecek', 'hayal', 'ışık'],
      },
      {
        'name': 'Yalnız',
        'emoji': '🌙',
        'color': const Color(0xFF9C27B0),
        'keywords': [
          'yalnızlık',
          'sessizlik',
          'gece',
          'tek',
          'boşluk',
          'kimsesiz'
        ],
      },
      {
        'name': 'Öfkeli',
        'emoji': '🔥',
        'color': const Color(0xFFF44336),
        'keywords': ['öfke', 'kızgın', 'sinir', 'ateş', 'isyan', 'haksızlık'],
      },
      {
        'name': 'Heyecanlı',
        'emoji': '⚡',
        'color': const Color(0xFF673AB7),
        'keywords': [
          'heyecan',
          'coşku',
          'enerji',
          'dinamik',
          'yaşam',
          'tutkulu'
        ],
      },
      {
        'name': 'Huzurlu',
        'emoji': '🕊️',
        'color': const Color(0xFF607D8B),
        'keywords': [
          'huzur',
          'sakinlik',
          'dinginlik',
          'barış',
          'sessiz',
          'meditasyon'
        ],
      },
      {
        'name': 'Doğa',
        'emoji': '🌿',
        'color': const Color(0xFF009688),
        'keywords': ['dağ', 'deniz', 'ağaç', 'çiçek', 'rüzgar', 'orman'],
      },
      {
        'name': 'Felsefi',
        'emoji': '🤔',
        'color': const Color(0xFF795548),
        'keywords': [
          'düşünce',
          'felsefe',
          'bilgelik',
          'hakikat',
          'yaşam',
          'anlam'
        ],
      },
      {
        'name': 'Mevsimsel',
        'emoji': '🍂',
        'color': const Color(0xFFFF5722),
        'keywords': ['sonbahar', 'kış', 'bahar', 'yaz', 'kar', 'yaprak'],
      },
      {
        'name': 'Vatansever',
        'emoji': '🇹🇷',
        'color': const Color(0xFFE53935),
        'keywords': ['vatan', 'millet', 'bayrak', 'toprak', 'yurt', 'asker'],
      },
      {
        'name': 'Arkadaşlık',
        'emoji': '🤝',
        'color': const Color(0xFF00BCD4),
        'keywords': [
          'arkadaş',
          'dostluk',
          'birlik',
          'beraber',
          'kardeş',
          'sevgi'
        ],
      },
      {
        'name': 'Kararlı',
        'emoji': '💪',
        'color': const Color(0xFF8BC34A),
        'keywords': [
          'kararlılık',
          'güç',
          'irade',
          'mücadele',
          'başarı',
          'hedef'
        ],
      },
      {
        'name': 'Şaşkın',
        'emoji': '😲',
        'color': const Color(0xFFFFEB3B),
        'keywords': [
          'şaşkınlık',
          'hayret',
          'merak',
          'soru',
          'anlayamama',
          'düşünce'
        ],
      },
      {
        'name': 'Manevi',
        'emoji': '🙏',
        'color': const Color(0xFF3F51B5),
        'keywords': ['dua', 'inanç', 'ruh', 'kutsal', 'ilahi', 'manevi'],
      },
      {
        'name': 'Özgür',
        'emoji': '🦅',
        'color': const Color(0xFF1976D2),
        'keywords': [
          'özgürlük',
          'uçmak',
          'serbest',
          'bağımsız',
          'rüzgar',
          'gökyüzü'
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            "Ruh Halini Seç",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.8),
            ),
          ),
        ),

        // Horizontal Scrollable Chips
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final mood = moods[index];
              final isSelected = selectedMood == mood['name'];
              final moodColor = mood['color'] as Color;

              return Animate(
                effects: [
                  FadeEffect(
                    delay: Duration(milliseconds: 20 * index),
                    duration: const Duration(milliseconds: 250),
                  ),
                ],
                child: Container(
                  margin: EdgeInsets.only(
                    right: index == moods.length - 1 ? 0 : 12,
                  ),
                  child: GestureDetector(
                    onTap: isFiltering
                        ? null
                        : () async {
                            ref.read(selectedMoodProvider.notifier).state =
                                mood['name'] as String;
                            ref.read(isFilteringProvider.notifier).state = true;
                            ref.read(displayCountProvider.notifier).state = 8;

                            await Future.delayed(
                                const Duration(milliseconds: 100));
                            await _filterPoemsByMoodAsync(
                                ref, mood['keywords'] as List<String>);
                            ref.read(isFilteringProvider.notifier).state =
                                false;
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 50,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? moodColor.withOpacity(0.15)
                            : isDarkMode
                                ? const Color(0xFF2D2D3F)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected
                              ? moodColor
                              : isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.1),
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? moodColor.withOpacity(0.3)
                                : Colors.black
                                    .withOpacity(isDarkMode ? 0.2 : 0.05),
                            blurRadius: isSelected ? 8 : 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Emoji
                              Text(
                                mood['emoji'] as String,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 8),

                              // Name
                              Text(
                                mood['name'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? moodColor : textColor,
                                ),
                              ),
                            ],
                          ),

                          // Loading overlay
                          if (isFiltering && isSelected)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMoodResults(
      WidgetRef ref, String selectedMood, bool isDarkMode, Color textColor) {
    final moodPoems = ref.watch(moodPoemsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Compact Results header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2D2D3F) : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_stories_rounded,
                color: const Color(0xFF7986CB),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "$selectedMood Şiirler",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const Spacer(),
              Text(
                "${moodPoems.length} şiir",
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Results content
        if (moodPoems.isEmpty)
          _buildEmptyResults(isDarkMode, textColor)
        else
          _buildPoemsList(moodPoems, isDarkMode, textColor),
      ],
    );
  }

  Widget _buildEmptyResults(bool isDarkMode, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D3F) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 32,
            color: textColor.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            "Bu ruh haline uygun şiir bulunamadı",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            "Başka bir ruh hali deneyin",
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPoemsList(
      List<dynamic> poems, bool isDarkMode, Color textColor) {
    return Consumer(
      builder: (context, ref, child) {
        final displayCount = ref.watch(displayCountProvider);
        final displayPoems = poems.take(displayCount).toList();

        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayPoems.length,
              itemBuilder: (context, index) {
                final poem = displayPoems[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PoemDetailPage(poem: poem),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode ? const Color(0xFF2D2D3F) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7986CB).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.auto_stories,
                              size: 14,
                              color: const Color(0xFF7986CB),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  poem.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  poem.content,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: textColor.withOpacity(0.6),
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: textColor.withOpacity(0.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Show more button - better positioning
            if (poems.length > displayCount) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: textColor.withOpacity(0.1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Increase display count by 10
                        final currentCount = ref.read(displayCountProvider);
                        ref.read(displayCountProvider.notifier).state =
                            currentCount + 10;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7986CB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.expand_more, size: 16),
                      label: Text(
                        "Daha fazla (${poems.length - displayCount} şiir)",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: textColor.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _filterPoemsByMoodAsync(
      WidgetRef ref, List<String> keywords) async {
    final poems = ref.read(poemProvider);

    await poems.when(
      data: (poemList) async {
        final filteredPoems = await Future.microtask(() {
          return poemList.where((poem) {
            final content = poem.content.toLowerCase();
            final title = poem.name.toLowerCase();

            return keywords.any((keyword) =>
                content.contains(keyword.toLowerCase()) ||
                title.contains(keyword.toLowerCase()));
          }).toList();
        });

        ref.read(moodPoemsProvider.notifier).state = filteredPoems;
      },
      loading: () async {
        ref.read(moodPoemsProvider.notifier).state = [];
      },
      error: (error, stack) async {
        ref.read(moodPoemsProvider.notifier).state = [];
      },
    );
  }

  Widget _buildExplanationCard(bool isDarkMode, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D3F) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF7986CB).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              color: const Color(0xFF7986CB),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            "Şiir Keşfetmeye Hazır mısın?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            "Yukarıdan bir ruh hali seç ve sana özel şiirleri keşfet. Her ruh hali farklı duygular içeren benzersiz şiirler getirecek.",
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Features
          Row(
            children: [
              Expanded(
                child: _buildFeatureItem(
                    "💕", "Duygusal", "Kalbine dokunan", isDarkMode, textColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureItem(
                    "🎯", "Kişisel", "Sana özel seçim", isDarkMode, textColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureItem(
                    "✨", "Kaliteli", "Seçkin şiirler", isDarkMode, textColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String title, String subtitle,
      bool isDarkMode, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E2C) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: textColor.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
