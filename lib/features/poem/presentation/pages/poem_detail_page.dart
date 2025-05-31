import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/models/poem.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:poemapp/core/theme/theme_provider.dart';
import 'package:poemapp/features/poem/presentation/screens/poem_item_widget.dart';
import 'package:poemapp/providers/favorites_provider.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';
import 'package:poemapp/features/share/presentation/pages/poem_share_page.dart';

// Add selection providers
final selectedTextProvider = StateProvider<String>((ref) => '');
final isSelectionModeProvider = StateProvider<bool>((ref) => false);
final floatingButtonPositionProvider = StateProvider<Offset?>((ref) => null);

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
    final isSelectionMode = ref.watch(isSelectionModeProvider);
    final selectedText = ref.watch(selectedTextProvider);

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
                              // Text Selection Button
                              GestureDetector(
                                onTap: () {
                                  ref
                                      .read(isSelectionModeProvider.notifier)
                                      .state = !isSelectionMode;
                                  if (!isSelectionMode) {
                                    ref
                                        .read(selectedTextProvider.notifier)
                                        .state = '';
                                  }
                                },
                                child: Container(
                                  height: 42,
                                  width: 42,
                                  decoration: BoxDecoration(
                                    color: isSelectionMode
                                        ? const Color(0xFF7986CB)
                                        : cardColor,
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
                                    Icons.text_fields_rounded,
                                    color: isSelectionMode
                                        ? Colors.white
                                        : textColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  // Şairin adını al ve paylaş
                                  final poetsData =
                                      ref.read(poetProvider).valueOrNull;
                                  if (poetsData != null) {
                                    String poetName = "";
                                    try {
                                      final poet = poetsData.firstWhere(
                                          (p) => p.id == widget.poem.poetId);
                                      poetName = poet.name;
                                    } catch (e) {
                                      // Şair bulunamazsa ID'yi kullan
                                      poetName = widget.poem.poetId;
                                    }

                                    Share.share(
                                      '${widget.poem.name}\n\n${widget.poem.content}\n\n- $poetName',
                                    );
                                  } else {
                                    // Şair verisi henüz yüklenmemişse sadece ID kullan
                                    Share.share(
                                      '${widget.poem.name}\n\n${widget.poem.content}\n\n- ${widget.poem.poetId}',
                                    );
                                  }
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
                            hidePoetId: true,
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
                        color: isSelectionMode
                            ? cardColor.withOpacity(0.8)
                            : cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelectionMode
                            ? Border.all(
                                color: const Color(0xFF7986CB), width: 2)
                            : null,
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
                          // Selection mode indicator
                          if (isSelectionMode)
                            Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF7986CB)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                selectedText.isEmpty
                                                    ? Icons.touch_app_rounded
                                                    : Icons
                                                        .check_circle_rounded,
                                                color: const Color(0xFF7986CB),
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      selectedText.isNotEmpty
                                                          ? "✓ Metin seçildi"
                                                          : "Kart yapmak için kelimeleri seçin",
                                                      style: TextStyle(
                                                        color: const Color(
                                                            0xFF7986CB),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    if (selectedText
                                                        .isNotEmpty) ...[
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                LinearProgressIndicator(
                                                              value: selectedText
                                                                      .length /
                                                                  400,
                                                              backgroundColor:
                                                                  const Color(
                                                                          0xFF7986CB)
                                                                      .withOpacity(
                                                                          0.2),
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                      Color>(
                                                                selectedText.length >=
                                                                        400
                                                                    ? Colors
                                                                        .orange
                                                                    : const Color(
                                                                        0xFF7986CB),
                                                              ),
                                                              minHeight: 3,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Text(
                                                            "${selectedText.length}/400",
                                                            style: TextStyle(
                                                              color: selectedText
                                                                          .length >=
                                                                      400
                                                                  ? Colors
                                                                      .orange
                                                                  : const Color(
                                                                      0xFF7986CB),
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (selectedText.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            ref
                                                .read(selectedTextProvider
                                                    .notifier)
                                                .state = '';
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.clear_rounded,
                                              color: Colors.red,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(left: 15),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: isSelectionMode
                                      ? const Color(0xFF7986CB)
                                      : accentColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: isSelectionMode
                                ? SelectableText(
                                    widget.poem.content,
                                    style: TextStyle(
                                      fontSize: _fontSize,
                                      color: textColor,
                                      height: 1.8,
                                      letterSpacing: 0.3,
                                    ),
                                    onSelectionChanged: (selection, cause) {
                                      if (selection.baseOffset !=
                                          selection.extentOffset) {
                                        final selectedPortion =
                                            widget.poem.content.substring(
                                          selection.baseOffset,
                                          selection.extentOffset,
                                        );
                                        // Limit to 400 characters
                                        if (selectedPortion.length <= 400) {
                                          ref
                                              .read(
                                                  selectedTextProvider.notifier)
                                              .state = selectedPortion;
                                        } else {
                                          // Take only first 400 characters
                                          final limitedText =
                                              selectedPortion.substring(0, 400);
                                          ref
                                              .read(
                                                  selectedTextProvider.notifier)
                                              .state = limitedText;

                                          // Show feedback
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  "Maksimum 400 karakter seçebilirsiniz"),
                                              backgroundColor: Colors.orange,
                                              duration: Duration(seconds: 2),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      } else {
                                        // Clear selection when no text is selected
                                        ref
                                            .read(selectedTextProvider.notifier)
                                            .state = '';
                                      }
                                    },
                                    selectionControls:
                                        MaterialTextSelectionControls(),
                                  )
                                : SingleChildScrollView(
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

          // Floating Card Creation Widget
          if (selectedText.isNotEmpty && isSelectionMode)
            Positioned(
              bottom: 30,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  // Create modified poem with selected text
                  final modifiedPoem = Poem(
                    id: widget.poem.id,
                    name: widget.poem.name,
                    content: selectedText,
                    poetId: widget.poem.poetId,
                    tags: widget.poem.tags,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PoemSharePage(poem: modifiedPoem),
                    ),
                  ).then((_) {
                    // Clear selection when returning
                    ref.read(selectedTextProvider.notifier).state = '';
                    ref.read(isSelectionModeProvider.notifier).state = false;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF667eea),
                            const Color(0xFF764ba2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.4),
                            offset: const Offset(0, 6),
                            blurRadius: 16,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.palette_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          // Badge with character count
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: selectedText.length >= 400
                                    ? Colors.orange
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                "${selectedText.length}",
                                style: TextStyle(
                                  color: selectedText.length >= 400
                                      ? Colors.white
                                      : const Color(0xFF667eea),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            const Color(0xFFF8F9FA),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFF667eea).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: const Color(0xFF667eea),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            selectedText.length <= 50
                                ? "Kart Oluştur"
                                : "${selectedText.length}/400",
                            style: TextStyle(
                              color: const Color(0xFF667eea),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(
                    duration: const Duration(milliseconds: 200),
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
