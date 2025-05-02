import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/models/poem.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui';
import 'package:poemapp/core/theme/theme_provider.dart';
import 'package:poemapp/features/poem/presentation/screens/poem_item_widget.dart';
import 'package:poemapp/providers/favorites_provider.dart';

class PoemDetailPage extends ConsumerStatefulWidget {
  final Poem poem;

  const PoemDetailPage({
    super.key,
    required this.poem,
  });

  @override
  ConsumerState<PoemDetailPage> createState() => _PoemDetailPageState();
}

class _PoemDetailPageState extends ConsumerState<PoemDetailPage> {
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final isFavorite = ref.watch(isPoemFavoriteProvider(widget.poem.id));

    final bgColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;
    final cardColor =
        isDarkMode ? const Color(0xFF2D2D3F) : const Color(0xFFF8F9FA);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final accentColor = const Color(0xFFE57373);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background design elements
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF64B5F6).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App Bar
                SliverToBoxAdapter(
                  child: Animate(
                    effects: const [
                      FadeEffect(duration: Duration(milliseconds: 600)),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 42,
                              width: 42,
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
                              child: Icon(
                                Icons.arrow_back,
                                color: textColor,
                                size: 20,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  ref
                                      .read(favoritePoemsProvider.notifier)
                                      .toggleFavorite(widget.poem);
                                },
                                child: Container(
                                  height: 42,
                                  width: 42,
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
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_outline,
                                    color: isFavorite ? accentColor : textColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  Share.share(
                                    '${widget.poem.name}\n\n${widget.poem.content}\n\n- ${widget.poem.poetId}',
                                  );
                                },
                                child: Container(
                                  height: 42,
                                  width: 42,
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
                                  child: Icon(
                                    Icons.share_rounded,
                                    color: textColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Poem Title & Author
                SliverToBoxAdapter(
                  child: Animate(
                    effects: const [
                      FadeEffect(
                        delay: Duration(milliseconds: 200),
                        duration: Duration(milliseconds: 800),
                      ),
                      SlideEffect(
                        delay: Duration(milliseconds: 200),
                        begin: Offset(0, 0.2),
                        end: Offset(0, 0),
                      ),
                    ],
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 10),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Önceki kod yerine yeni widget'ı kullanıyoruz
                          PoemItemWidget(
                            poem: widget.poem,
                            textColor: textColor,
                            accentColor: accentColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Tags
                if (widget.poem.tags.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Animate(
                      effects: const [
                        FadeEffect(
                          delay: Duration(milliseconds: 300),
                          duration: Duration(milliseconds: 800),
                        ),
                      ],
                      child: Container(
                        height: 38,
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.poem.tags.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    offset: const Offset(0, 3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Text(
                                '#${widget.poem.tags[index]}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: accentColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                // Font Size Controls
                SliverToBoxAdapter(
                  child: Animate(
                    effects: const [
                      FadeEffect(
                        delay: Duration(milliseconds: 400),
                        duration: Duration(milliseconds: 800),
                      ),
                    ],
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 15),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Yazı Boyutu',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          Row(
                            children: [
                              _buildSizeButton(14, 'A', textColor, accentColor),
                              const SizedBox(width: 8),
                              _buildSizeButton(16, 'A', textColor, accentColor),
                              const SizedBox(width: 8),
                              _buildSizeButton(18, 'A', textColor, accentColor),
                              const SizedBox(width: 8),
                              _buildSizeButton(20, 'A', textColor, accentColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Poem Content
                SliverToBoxAdapter(
                  child: Animate(
                    effects: const [
                      FadeEffect(
                        delay: Duration(milliseconds: 500),
                        duration: Duration(milliseconds: 800),
                      ),
                    ],
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            offset: const Offset(0, 10),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(left: 15),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: accentColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              widget.poem.content,
                              style: TextStyle(
                                fontSize: _fontSize,
                                color: textColor,
                                height: 1.8,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Theme Toggle & Bottom Info
                SliverToBoxAdapter(
                  child: Animate(
                    effects: const [
                      FadeEffect(
                        delay: Duration(milliseconds: 600),
                        duration: Duration(milliseconds: 800),
                      ),
                    ],
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                offset: const Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isDarkMode
                                          ? Icons.dark_mode
                                          : Icons.light_mode,
                                      color: accentColor,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Gece Modu',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: isDarkMode,
                                activeColor: accentColor,
                                onChanged: (value) {
                                  ref
                                      .read(themeModeProvider.notifier)
                                      .setThemeMode(value
                                          ? ThemeMode.dark
                                          : ThemeMode.light);
                                },
                              ),
                            ],
                          ),
                        ),

                        // Bottom info
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                          child: Text(
                            'Şiiri sevdiyseniz yazarın diğer eserlerine de göz atın',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: textColor.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeButton(
      double size, String text, Color textColor, Color accentColor) {
    final isSelected = _fontSize == size;

    return GestureDetector(
      onTap: () {
        setState(() {
          _fontSize = size;
        });
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: size * 0.65,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : textColor.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }
}
