import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/core/theme/theme_provider.dart';
import 'package:poemapp/features/poem/presentation/pages/poem_detail_page.dart';
import 'package:poemapp/models/poem.dart';
import 'package:poemapp/providers/favorites_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:poemapp/providers/ad_service_provider.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritePoems = ref.watch(favoritePoemsProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    final bgColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;
    final cardColor =
        isDarkMode ? const Color(0xFF2D2D3F) : const Color(0xFFF8F9FA);
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
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
                child: Text(
                  "Favorilerim",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),

          // Favorites List
          favoritePoems.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 70,
                          color: textColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Henüz favori şiiriniz yok",
                          style: TextStyle(
                            fontSize: 18,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Şiirleri favorilere eklemek için\nşiir detayında yer alan kalp simgesine tıklayın",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final poem = favoritePoems[index];
                      return Animate(
                        effects: [
                          FadeEffect(
                            delay: Duration(milliseconds: 50 * index),
                            duration: const Duration(milliseconds: 300),
                          ),
                        ],
                        child: _buildPoemCard(
                            context, poem, cardColor, textColor, ref),
                      );
                    },
                    childCount: favoritePoems.length,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildPoemCard(
    BuildContext context,
    Poem poem,
    Color cardColor,
    Color textColor,
    WidgetRef ref,
  ) {
    return GestureDetector(
      onTap: () {
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
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    poem.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite, color: Color(0xFFE57373)),
                  onPressed: () {
                    ref
                        .read(favoritePoemsProvider.notifier)
                        .toggleFavorite(poem);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              poem.poetId,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              poem.content.length > 100
                  ? '${poem.content.substring(0, 100)}...'
                  : poem.content,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.9),
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
