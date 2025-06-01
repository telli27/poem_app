import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:poemapp/providers/daily_poem_provider.dart';
import 'package:poemapp/providers/favorites_provider.dart';
import 'package:poemapp/core/theme/theme_provider.dart';
import 'package:poemapp/features/poem/presentation/pages/poem_detail_page.dart';
import 'package:poemapp/features/daily_poem/presentation/pages/poem_calendar_page.dart';
import 'package:poemapp/features/daily_poem/presentation/pages/notification_settings_page.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';
import 'dart:ui';
import 'package:poemapp/providers/ad_service_provider.dart';

class DailyPoemPage extends ConsumerStatefulWidget {
  const DailyPoemPage({super.key});

  @override
  ConsumerState<DailyPoemPage> createState() => _DailyPoemPageState();
}

class _DailyPoemPageState extends ConsumerState<DailyPoemPage> {
  bool _hasRecordedRead = false;

  @override
  Widget build(BuildContext context) {
    final todaysPoemAsync = ref.watch(dailyPoemNotifierProvider);
    final streakAsync = ref.watch(readingStreakProvider);
    final poemReadToday = ref.watch(poemReadTodayProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    final bgColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;
    final cardColor =
        isDarkMode ? const Color(0xFF2D2D3F) : const Color(0xFFF8F9FA);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final accentColor = const Color(0xFFE57373);
    final goldColor = const Color(0xFFFFD700);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background design elements
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: goldColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Animate(
                  effects: const [
                    FadeEffect(duration: Duration(milliseconds: 600)),
                  ],
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(30, 60, 30, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "📖 Günün Şiiri",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getFormattedDate(),
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Notification settings button
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: const Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: textColor,
                                  size: 22,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationSettingsPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Calendar button
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: const Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.calendar_month_outlined,
                                  color: textColor,
                                  size: 22,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PoemCalendarPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Streak Widget
              SliverToBoxAdapter(
                child: Animate(
                  effects: const [
                    FadeEffect(
                        duration: Duration(milliseconds: 600),
                        delay: Duration(milliseconds: 200)),
                    SlideEffect(
                        begin: Offset(0, 0.3),
                        duration: Duration(milliseconds: 600),
                        delay: Duration(milliseconds: 200)),
                  ],
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          goldColor.withOpacity(0.2),
                          accentColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: goldColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: goldColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.local_fire_department,
                            color: goldColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              streakAsync.when(
                                data: (streak) => Text(
                                  "$streak günlük seri",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                loading: () => Text(
                                  "Yükleniyor...",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                error: (_, __) => Text(
                                  "0 günlük seri",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              poemReadToday.when(
                                data: (isRead) => Text(
                                  isRead
                                      ? "Bugün tamamlandı! 🎉"
                                      : "Bugünkü şiiri oku",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textColor.withOpacity(0.7),
                                  ),
                                ),
                                loading: () => Text(
                                  "Kontrol ediliyor...",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textColor.withOpacity(0.7),
                                  ),
                                ),
                                error: (_, __) => Text(
                                  "Bugünkü şiiri oku",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textColor.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Today's Poem
              SliverToBoxAdapter(
                child: Animate(
                  effects: const [
                    FadeEffect(
                        duration: Duration(milliseconds: 600),
                        delay: Duration(milliseconds: 400)),
                    SlideEffect(
                        begin: Offset(0, 0.3),
                        duration: Duration(milliseconds: 600),
                        delay: Duration(milliseconds: 400)),
                  ],
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                    child: todaysPoemAsync.when(
                      data: (poem) {
                        if (poem == null) {
                          return _buildEmptyState(cardColor, textColor);
                        }
                        return _buildPoemCard(
                            poem, cardColor, textColor, accentColor);
                      },
                      loading: () => _buildLoadingState(cardColor, textColor),
                      error: (error, _) => _buildErrorState(
                          cardColor, textColor, error.toString()),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPoemCard(
      dynamic poem, Color cardColor, Color textColor, Color accentColor) {
    final isFavorite = ref.watch(isPoemFavoriteProvider(poem.id));
    final poetsAsync = ref.watch(poetProvider);

    return GestureDetector(
      onTap: () {
        _recordPoemRead();
        // Preload interstitial ad before navigation
        ref.read(adServiceProvider.notifier).loadInterstitialAd();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PoemDetailPage(poem: poem),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    poem.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    // Favorite button
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(favoritePoemsProvider.notifier)
                            .toggleFavorite(poem);
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: isFavorite
                              ? accentColor.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? accentColor
                              : textColor.withOpacity(0.6),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Share button
                    GestureDetector(
                      onTap: () {
                        poetsAsync.whenData((poets) {
                          String poetName = _getPoetName(poets, poem.poetId);
                          Share.share(
                            '${poem.name}\n\n${poem.content}\n\n- $poetName\n\nTürk Şiirleri uygulamasından paylaşıldı.',
                          );
                        });
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.share_outlined,
                          color: textColor.withOpacity(0.6),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Author
            poetsAsync.when(
              data: (poets) {
                final poetName = _getPoetName(poets, poem.poetId);
                return Text(
                  poetName,
                  style: TextStyle(
                    fontSize: 16,
                    color: accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
              loading: () => Text(
                "Yükleniyor...",
                style: TextStyle(
                  fontSize: 16,
                  color: accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              error: (_, __) => Text(
                poem.poetId,
                style: TextStyle(
                  fontSize: 16,
                  color: accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Poem content
            Text(
              poem.content,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: textColor,
              ),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),

            // Read more button
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  "Şiiri Oku",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            "Bugünün şiiri yükleniyor...",
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Color cardColor, Color textColor, String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: textColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "Şiir yüklenirken bir hata oluştu",
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ref.read(dailyPoemNotifierProvider.notifier).refreshTodaysPoem();
            },
            child: const Text("Tekrar Dene"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 48,
            color: textColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "Henüz bugünün şiiri hazırlanmadı",
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ref.read(dailyPoemNotifierProvider.notifier).refreshTodaysPoem();
            },
            child: const Text("Yenile"),
          ),
        ],
      ),
    );
  }

  void _recordPoemRead() {
    if (!_hasRecordedRead) {
      ref.read(dailyPoemNotifierProvider.notifier).recordPoemRead();
      _hasRecordedRead = true;

      // Refresh streak and read status
      ref.invalidate(readingStreakProvider);
      ref.invalidate(poemReadTodayProvider);
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];

    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  // Helper method to get poet name from poet ID
  String _getPoetName(List poets, String poetId) {
    // Check if poetId is a UUID (contains hyphens and is 36 characters long)
    if (_isUuid(poetId)) {
      try {
        final poet = poets.firstWhere(
          (p) => p.id == poetId,
          orElse: () => throw Exception('Şair bulunamadı'),
        );
        return poet.name;
      } catch (e) {
        return "Şair";
      }
    } else {
      // If it's not UUID, it's likely already the poet name
      return poetId;
    }
  }

  // Helper method to check if a string is UUID format
  bool _isUuid(String text) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(text);
  }
}
