import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';
import 'dart:math' as math;

// Share card theme provider
final shareCardThemeProvider = StateProvider<int>((ref) => 0);
final shareTextSizeProvider = StateProvider<double>((ref) => 16.0);
final customFooterTextProvider = StateProvider<String>((ref) => "");

class PoemSharePage extends ConsumerStatefulWidget {
  final dynamic poem;

  const PoemSharePage({Key? key, required this.poem}) : super(key: key);

  @override
  ConsumerState<PoemSharePage> createState() => _PoemSharePageState();
}

class _PoemSharePageState extends ConsumerState<PoemSharePage> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isGeneratingImage = false;

  // Predefined themes for share cards
  final List<ShareCardTheme> themes = [
    ShareCardTheme(
      name: "Gece Mavisi",
      background: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243e)],
      ),
      textColor: Colors.white,
      accentColor: Color(0xFF64FFDA),
      emoji: "🌙",
    ),
    ShareCardTheme(
      name: "Coquette Dreams",
      background: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFC0CB), Color(0xFFFFB6C1), Color(0xFFF8F8FF)],
      ),
      textColor: Color(0xFF8B4367),
      accentColor: Color(0xFFDDA0DD),
      emoji: "🎀",
    ),
    ShareCardTheme(
      name: "That Girl Era ✨",
      background: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFFFF8E7), Color(0xFFFFE4C4), Color(0xFFFAEBD7)],
      ),
      textColor: Color(0xFF8B4513),
      accentColor: Color(0xFFD2691E),
      emoji: "✨",
    ),
    ShareCardTheme(
      name: "Pink Pilates Princess",
      background: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFC0CB), Color(0xFFFFB6C1), Color(0xFFFDF2F8)],
      ),
      textColor: Color(0xFF8B4367),
      accentColor: Color(0xFFFF69B4),
      emoji: "🩰",
    ),
    ShareCardTheme(
      name: "Old Money 💰",
      background: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2C3E50), Color(0xFF34495E), Color(0xFF1C2833)],
      ),
      textColor: Color(0xFFECF0F1),
      accentColor: Color(0xFFD4AF37),
      emoji: "🏛️",
    ),
    ShareCardTheme(
      name: "Vintage Rose",
      background: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE8D5C4), Color(0xFFD4B5A0), Color(0xFFC8A882)],
      ),
      textColor: Color(0xFF6B4423),
      accentColor: Color(0xFF8B4513),
      emoji: "🌹",
    ),
    ShareCardTheme(
      name: "Grunge Vibes 🖤",
      background: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2C2C2C), Color(0xFF1C1C1C), Color(0xFF0D0D0D)],
      ),
      textColor: Color(0xFFE0E0E0),
      accentColor: Color(0xFFFF6B6B),
      emoji: "🖤",
    ),
    ShareCardTheme(
      name: "Scandinavian Vibes",
      background: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFF5F5F5), Color(0xFFE8E8E8), Color(0xFFD3D3D3)],
      ),
      textColor: Color(0xFF2F2F2F),
      accentColor: Color(0xFF4A4A4A),
      emoji: "🌿",
    ),
    ShareCardTheme(
      name: "90s Film Photography",
      background: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFDEB887), Color(0xFFCD853F), Color(0xFFD2691E)],
      ),
      textColor: Color(0xFF8B4513),
      accentColor: Color(0xFFFFE4B5),
      emoji: "📸",
    ),
    ShareCardTheme(
      name: "Gece Yıldızları",
      background: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1A237E), Color(0xFF303F9F), Color(0xFF3F51B5)],
      ),
      textColor: Colors.white,
      accentColor: Color(0xFFE8EAF6),
      emoji: "⭐",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedTheme = ref.watch(shareCardThemeProvider);
    final textSize = ref.watch(shareTextSizeProvider);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text("Şiir Kartı Oluştur"),
        backgroundColor: const Color(0xFF2D2D3F),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: _isGeneratingImage ? null : _saveToGallery,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _isGeneratingImage ? null : _shareCard,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Card Preview - Dynamic size based on content
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: screenSize.width * 0.9,
                    ),
                    child: RepaintBoundary(
                      key: _cardKey,
                      child: _buildShareCard(selectedTheme, textSize),
                    ),
                  ),
                ),
              ),
            ),

            // Controls - Fixed height and scrollable
            Container(
              height: 320,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF2D2D3F),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Theme selection
                    const Text(
                      "🎨 Tema Seç",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 70,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: themes.length,
                        itemBuilder: (context, index) {
                          final theme = themes[index];
                          final isSelected = selectedTheme == index;
                          return GestureDetector(
                            onTap: () {
                              ref.read(shareCardThemeProvider.notifier).state =
                                  index;
                            },
                            child: Container(
                              width: 60,
                              margin: EdgeInsets.only(
                                right: index == themes.length - 1 ? 0 : 10,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                      gradient: theme.background,
                                      borderRadius: BorderRadius.circular(12),
                                      border: isSelected
                                          ? Border.all(
                                              color: Colors.white, width: 2)
                                          : Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                              width: 1),
                                    ),
                                    child: Center(
                                      child: Text(
                                        theme.emoji,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Flexible(
                                    child: Text(
                                      theme.name.split(' ').take(2).join(' '),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.6),
                                        fontSize: 9,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Text size control
                    const Text(
                      "📝 Yazı Boyutu",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.text_fields,
                            color: Colors.white.withOpacity(0.7), size: 20),
                        Expanded(
                          child: Slider(
                            value: textSize,
                            min: 12.0,
                            max: 20.0,
                            divisions: 8,
                            activeColor: const Color(0xFF7986CB),
                            inactiveColor: Colors.white.withOpacity(0.3),
                            onChanged: (value) {
                              ref.read(shareTextSizeProvider.notifier).state =
                                  value;
                            },
                          ),
                        ),
                        Text(
                          "${textSize.round()}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Custom footer text control
                    const Text(
                      "🏷️ Filigran",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          ref.read(customFooterTextProvider.notifier).state =
                              value;
                        },
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText:
                              "Özel filigran yazın (boş bırakırsanız ŞiirArt)",
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          prefixIcon: Icon(
                            Icons.copyright_rounded,
                            color: Colors.white.withOpacity(0.7),
                            size: 18,
                          ),
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
    );
  }

  Widget _buildShareCard(int themeIndex, double textSize) {
    final theme = themes[themeIndex];
    final poem = widget.poem;

    // Different design for each theme
    switch (themeIndex) {
      case 0: // Gece Mavisi - Minimalist Night Theme
        return _buildNightThemeCard(theme, textSize, poem);
      case 1: // Coquette Dreams - Coquette Dreams Theme
        return _buildCoquetteDreamsThemeCard(theme, textSize, poem);
      case 2: // That Girl Era ✨ - That Girl Era Theme
        return _buildThatGirlEraThemeCard(theme, textSize, poem);
      case 3: // Pink Pilates Princess - Pink Pilates Princess Theme
        return _buildPinkPilatesPrincessThemeCard(theme, textSize, poem);
      case 4: // Old Money 💰 - Old Money Theme
        return _buildOldMoneyThemeCard(theme, textSize, poem);
      case 5: // Vintage Rose - Vintage Rose Theme
        return _buildVintageRoseThemeCard(theme, textSize, poem);
      case 6: // Grunge Vibes 🖤 - Grunge Vibes Theme
        return _buildGrungeVibesThemeCard(theme, textSize, poem);
      case 7: // Scandinavian Vibes - Scandinavian Vibes Theme
        return _buildScandinavianVibesThemeCard(theme, textSize, poem);
      case 8: // 90s Film Photography - 90s Film Photography Theme
        return _build90sFilmPhotographyThemeCard(theme, textSize, poem);
      case 9: // Gece Yıldızları - Stars Theme
        return _buildStarsThemeCard(theme, textSize, poem);
      default:
        return _buildNightThemeCard(theme, textSize, poem);
    }
  }

  // 1. Night Theme - Stars and Moon
  Widget _buildNightThemeCard(
      ShareCardTheme theme, double textSize, dynamic poem) {
    return Container(
      decoration: BoxDecoration(
        gradient: theme.background,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Stars scattered around
          ...List.generate(
              15,
              (index) => Positioned(
                    top: 20 + (index * 23) % 150,
                    left: 30 + (index * 47) % 200,
                    child: Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )),

          // Moon in corner
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Center(
                child: Text("🌙", style: TextStyle(fontSize: 20)),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 15),
                Text(
                  poem.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: textSize,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(
                    _formatPoemContent(poem.content),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: textSize - 2,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                _buildAuthorSection(theme, textSize, poem),
                const SizedBox(height: 10),
                _buildFooter(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Coquette Dreams Theme - Coquette Dreams Theme
  Widget _buildCoquetteDreamsThemeCard(
      ShareCardTheme theme, double textSize, dynamic poem) {
    return Container(
      decoration: BoxDecoration(
        gradient: theme.background,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.accentColor.withOpacity(0.6), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Coquette decorative elements
          Positioned(
            top: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: theme.accentColor.withOpacity(0.7), width: 2),
              ),
              child: const Text("🎀", style: TextStyle(fontSize: 24)),
            ),
          ),
          Positioned(
            bottom: 25,
            left: 20,
            child: const Text("💝", style: TextStyle(fontSize: 22)),
          ),
          Positioned(
            top: 80,
            left: 25,
            child: const Text("✨", style: TextStyle(fontSize: 18)),
          ),
          Positioned(
            bottom: 60,
            right: 30,
            child: const Text("🌸", style: TextStyle(fontSize: 20)),
          ),

          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                // Coquette title with bows
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("🎀", style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        poem.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: textSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          fontFamily: 'serif',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text("🎀", style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 22),
                // Frilly content box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                        color: theme.accentColor.withOpacity(0.6), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    '"${_formatPoemContent(poem.content)}"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: textSize - 2,
                      height: 1.8,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _buildAuthorSection(theme, textSize, poem),
                const SizedBox(height: 10),
                _buildFooter(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. That Girl Era ✨ - That Girl Era Theme
  Widget _buildThatGirlEraThemeCard(
      ShareCardTheme theme, double textSize, dynamic poem) {
    return Container(
      decoration: BoxDecoration(
        gradient: theme.background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.accentColor.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Soft dreamy clouds
          Positioned(
            top: -30,
            right: -40,
            child: Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          Positioned(
            bottom: -25,
            left: -35,
            child: Container(
              width: 100,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.2),
                borderRadius: BorderRadius.circular(35),
              ),
            ),
          ),

          // Pastel elements
          Positioned(
            top: 20,
            left: 20,
            child: const Text("✨", style: TextStyle(fontSize: 28)),
          ),
          Positioned(
            top: 25,
            right: 25,
            child: const Text("🌸", style: TextStyle(fontSize: 24)),
          ),
          Positioned(
            bottom: 30,
            left: 25,
            child: const Text("✨", style: TextStyle(fontSize: 22)),
          ),
          Positioned(
            bottom: 35,
            right: 30,
            child: const Text("💕", style: TextStyle(fontSize: 20)),
          ),

          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 25),
                // Dreamy title
                Text(
                  poem.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: textSize,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                    fontFamily: 'serif',
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.8),
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Soft content box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                        color: theme.accentColor.withOpacity(0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    '"${_formatPoemContent(poem.content)}"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: textSize - 2,
                      height: 1.7,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAuthorSection(theme, textSize, poem),
                const SizedBox(height: 8),
                _buildFooter(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Pink Pilates Princess - Pink Pilates Princess Theme
  Widget _buildPinkPilatesPrincessThemeCard(
      ShareCardTheme theme, double textSize, dynamic poem) {
    return Container(
      decoration: BoxDecoration(
        gradient: theme.background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.accentColor.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Soft dreamy clouds
          Positioned(
            top: -30,
            right: -40,
            child: Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          Positioned(
            bottom: -25,
            left: -35,
            child: Container(
              width: 100,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.2),
                borderRadius: BorderRadius.circular(35),
              ),
            ),
          ),

          // Pastel elements
          Positioned(
            top: 20,
            left: 20,
            child: const Text("🩰", style: TextStyle(fontSize: 28)),
          ),
          Positioned(
            top: 25,
            right: 25,
            child: const Text("🌸", style: TextStyle(fontSize: 24)),
          ),
          Positioned(
            bottom: 30,
            left: 25,
            child: const Text("✨", style: TextStyle(fontSize: 22)),
          ),
          Positioned(
            bottom: 35,
            right: 30,
            child: const Text("💕", style: TextStyle(fontSize: 20)),
          ),

          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 25),
                // Dreamy title
                Text(
                  poem.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: textSize,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                    fontFamily: 'serif',
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.8),
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Soft content box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                        color: theme.accentColor.withOpacity(0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    '"${_formatPoemContent(poem.content)}"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: textSize - 2,
                      height: 1.7,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAuthorSection(theme, textSize, poem),
                const SizedBox(height: 8),
                _buildFooter(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. Old Money Theme - Old Money Theme
  Widget _buildOldMoneyThemeCard(
      ShareCardTheme theme, double textSize, dynamic poem) {
    return Container(
      decoration: BoxDecoration(
        gradient: theme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.accentColor.withOpacity(0.8), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Luxury patterns
          Positioned(
            top: 15,
            left: 15,
            child: CustomPaint(
              size: const Size(40, 40),
              painter: CornerDecoration(theme.accentColor.withOpacity(0.6)),
            ),
          ),
          Positioned(
            bottom: 15,
            right: 15,
            child: Transform.rotate(
              angle: 3.14159,
              child: CustomPaint(
                size: const Size(40, 40),
                painter: CornerDecoration(theme.accentColor.withOpacity(0.6)),
              ),
            ),
          ),

          // Sophisticated elements
          Positioned(
            top: 20,
            right: 20,
            child: const Text("🏛️", style: TextStyle(fontSize: 28)),
          ),
          Positioned(
            bottom: 30,
            left: 25,
            child: const Text("💼", style: TextStyle(fontSize: 22)),
          ),

          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 25),
                // Elegant title
                Text(
                  poem.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: textSize - 1,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 3,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 8),
                // Decorative line
                Container(
                  width: 80,
                  height: 1,
                  color: theme.accentColor.withOpacity(0.8),
                ),
                const SizedBox(height: 20),
                // Sophisticated content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: theme.accentColor.withOpacity(0.4), width: 1),
                  ),
                  child: Text(
                    _formatPoemContent(poem.content),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: textSize - 2,
                      height: 1.8,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _buildAuthorSection(theme, textSize, poem),
                const SizedBox(height: 10),
                _buildFooter(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 6. Vintage Rose Theme - Vintage Rose Theme
  Widget _buildVintageRoseThemeCard(
      ShareCardTheme theme, double textSize, dynamic poem) {
    return Container(
      decoration: BoxDecoration(
        gradient: theme.background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.accentColor.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Vintage texture overlay
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(0.08),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),

          // Rose elements
          Positioned(
            top: 20,
            left: 20,
            child: const Text("🌹", style: TextStyle(fontSize: 30)),
          ),
          Positioned(
            top: 25,
            right: 25,
            child: const Text("🥀", style: TextStyle(fontSize: 24)),
          ),
          Positioned(
            bottom: 30,
            left: 25,
            child: const Text("📖", style: TextStyle(fontSize: 22)),
          ),
          Positioned(
            bottom: 35,
            right: 30,
            child: const Text("🕯️", style: TextStyle(fontSize: 20)),
          ),

          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 25),
                // Vintage ornate title
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: theme.accentColor.withOpacity(0.6), width: 2),
                  ),
                  child: Text(
                    poem.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: textSize,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Aged paper content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: theme.accentColor.withOpacity(0.5), width: 2),
                  ),
                  child: Text(
                    _formatPoemContent(poem.content),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: textSize - 2,
                      height: 1.7,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAuthorSection(theme, textSize, poem),
                const SizedBox(height: 8),
                _buildFooter(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 7. Grunge Vibes Theme - Grunge Vibes Theme
  Widget _buildGrungeVibesThemeCard(
      ShareCardTheme theme, double textSize, dynamic poem) {
    return Container(
      decoration: BoxDecoration(
        gradient: theme.background,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Grunge texture overlay
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),

          // Grunge elements
          Positioned(
            top: 20,
            left: 20,
            child: const Text("🖤", style: TextStyle(fontSize: 30)),
          ),
          Positioned(
            top: 25,
            right: 25,
            child: const Text("🎸", style: TextStyle(fontSize: 24)),
          ),
          Positioned(
            bottom: 30,
            left: 25,
            child: const Text("🎵", style: TextStyle(fontSize: 22)),
          ),
          Positioned(
            bottom: 35,
            right: 30,
            child: const Text("🎧", style: TextStyle(fontSize: 20)),
          ),

          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 25),
                // Grunge title
                Text(
                  poem.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: textSize,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 20),
                // Grunge content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: Text(
                    _formatPoemContent(poem.content),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: textSize - 2,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAuthorSection(theme, textSize, poem),
                const SizedBox(height: 8),
                _buildFooter(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 8. Scandinavian Vibes - Scandinavian Vibes Theme
  Widget _buildScandinavianVibesThemeCard(
      ShareCardTheme theme, double textSize, dynamic poem) {
    return Container(
      decoration: BoxDecoration(
        gradient: theme.background,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Scandinavian texture overlay
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),

          // Scandinavian elements
          Positioned(
            top: 20,
            left: 20,
            child: const Text("🌿", style: TextStyle(fontSize: 30)),
          ),
          Positioned(
            top: 25,
            right: 25,
            child: const Text("🎵", style: TextStyle(fontSize: 24)),
          ),
          Positioned(
            bottom: 30,
            left: 25,
            child: const Text("🎶", style: TextStyle(fontSize: 22)),
          ),
          Positioned(
            bottom: 35,
            right: 30,
            child: const Text("🎶", style: TextStyle(fontSize: 20)),
          ),

          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 25),
                // Scandinavian title
                Text(
                  poem.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: textSize,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 20),
                // Scandinavian content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: theme.accentColor.withOpacity(0.5), width: 2),
                  ),
                  child: Text(
                    _formatPoemContent(poem.content),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: textSize - 2,
                      height: 1.7,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAuthorSection(theme, textSize, poem),
                const SizedBox(height: 8),
                _buildFooter(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 9. 90s Film Photography - 90s Film Photography Theme
  Widget _build90sFilmPhotographyThemeCard(
      ShareCardTheme theme, double textSize, dynamic poem) {
    return Container(
      decoration: BoxDecoration(
        gradient: theme.background,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Film photography texture overlay
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),

          // Film photography elements
          Positioned(
            top: 20,
            left: 20,
            child: const Text("📸", style: TextStyle(fontSize: 30)),
          ),
          Positioned(
            top: 25,
            right: 25,
            child: const Text("📸", style: TextStyle(fontSize: 24)),
          ),
          Positioned(
            bottom: 30,
            left: 25,
            child: const Text("📸", style: TextStyle(fontSize: 22)),
          ),
          Positioned(
            bottom: 35,
            right: 30,
            child: const Text("📸", style: TextStyle(fontSize: 20)),
          ),

          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 25),
                // Film photography title
                Text(
                  poem.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: textSize,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 20),
                // Film photography content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: theme.accentColor.withOpacity(0.5), width: 2),
                  ),
                  child: Text(
                    _formatPoemContent(poem.content),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: textSize - 2,
                      height: 1.7,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAuthorSection(theme, textSize, poem),
                const SizedBox(height: 8),
                _buildFooter(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 10. Gece Yıldızları - Stars Theme
  Widget _buildStarsThemeCard(
      ShareCardTheme theme, double textSize, dynamic poem) {
    return Container(
      decoration: BoxDecoration(
        gradient: theme.background,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Constellation of stars
          ...List.generate(
              20,
              (index) => Positioned(
                    top: 20 + (index * 17) % 160,
                    left: 25 + (index * 23) % 190,
                    child: Text(
                      index % 4 == 0
                          ? "⭐"
                          : (index % 4 == 1
                              ? "✨"
                              : (index % 4 == 2 ? "🌟" : "💫")),
                      style: TextStyle(
                        fontSize: [16, 14, 18, 12][index % 4].toDouble(),
                        color: Colors.white
                            .withOpacity([0.9, 0.7, 1.0, 0.6][index % 4]),
                      ),
                    ),
                  )),

          // Galaxy swirl
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.purple.withOpacity(0.3),
                    Colors.blue.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Stellar icon
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.purple.withOpacity(0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text("⭐", style: TextStyle(fontSize: 25)),
                  ),
                ),
                const SizedBox(height: 18),
                // Cosmic title
                Text(
                  poem.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: textSize,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2.5,
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.8),
                        offset: const Offset(0, 0),
                        blurRadius: 10,
                      ),
                      Shadow(
                        color: Colors.purple.withOpacity(0.6),
                        offset: const Offset(1, 1),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Stellar content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Text(
                    _formatPoemContent(poem.content),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: textSize - 2,
                      height: 1.7,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _buildAuthorSection(theme, textSize, poem),
                const SizedBox(height: 10),
                _buildFooter(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Common components for all themes
  Widget _buildAuthorSection(
      ShareCardTheme theme, double textSize, dynamic poem) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.accentColor.withOpacity(0.3)),
      ),
      child: FutureBuilder<String>(
        future: _getPoetName(poem.poetId),
        builder: (context, snapshot) {
          return Text(
            (snapshot.data ?? "Yükleniyor...").toUpperCase(),
            style: TextStyle(
              color: theme.textColor.withOpacity(0.9),
              fontSize: textSize - 4,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter(ShareCardTheme theme) {
    final customFooterText = ref.watch(customFooterTextProvider);
    final footerText =
        customFooterText.isNotEmpty ? customFooterText : "ŞiirArt";

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 15,
          height: 1,
          color: theme.accentColor.withOpacity(0.4),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            footerText,
            style: TextStyle(
              color: theme.textColor.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          width: 15,
          height: 1,
          color: theme.accentColor.withOpacity(0.4),
        ),
      ],
    );
  }

  String _formatPoemContent(String content) {
    // Show all selected text without truncation
    return content.trim();
  }

  Future<String> _getPoetName(String poetId) async {
    try {
      final poetsAsync = await ref.read(poetProvider.future);
      if (poetsAsync == null) return "Anonim";

      for (final poet in poetsAsync) {
        if (poet.id == poetId) {
          return poet.name;
        }
      }
      return "Anonim";
    } catch (e) {
      return "Anonim";
    }
  }

  Future<void> _saveToGallery() async {
    if (_isGeneratingImage) return;

    setState(() {
      _isGeneratingImage = true;
    });

    try {
      // Request permission
      final permission = await Permission.storage.request();
      if (!permission.isGranted) {
        _showSnackBar("Galeri izni gerekli");
        return;
      }

      // Generate image
      final imageBytes = await _generateImage();

      // Save to gallery
      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: "siir_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result['isSuccess']) {
        _showSnackBar("Kart galeriye kaydedildi! 📱");
      } else {
        _showSnackBar("Kaydetme hatası");
      }
    } catch (e) {
      _showSnackBar("Hata: $e");
    } finally {
      setState(() {
        _isGeneratingImage = false;
      });
    }
  }

  Future<void> _shareCard() async {
    if (_isGeneratingImage) return;

    setState(() {
      _isGeneratingImage = true;
    });

    try {
      final imageBytes = await _generateImage();

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/poem_card_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(imageBytes);

      // Share
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.poem.name} - ŞiirArt uygulamasından paylaşıldı',
      );
    } catch (e) {
      _showSnackBar("Paylaşım hatası: $e");
    } finally {
      setState(() {
        _isGeneratingImage = false;
      });
    }
  }

  Future<Uint8List> _generateImage() async {
    final RenderRepaintBoundary boundary =
        _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF7986CB),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class ShareCardTheme {
  final String name;
  final Gradient background;
  final Color textColor;
  final Color accentColor;
  final String emoji;

  ShareCardTheme({
    required this.name,
    required this.background,
    required this.textColor,
    required this.accentColor,
    required this.emoji,
  });
}

// Custom Painters for decorative elements
class CornerDecoration extends CustomPainter {
  final Color color;

  CornerDecoration(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Draw elegant corner decoration
    path.moveTo(0, size.height * 0.3);
    path.lineTo(0, 0);
    path.lineTo(size.width * 0.3, 0);

    path.moveTo(size.width * 0.15, size.height * 0.15);
    path.lineTo(size.width * 0.25, size.height * 0.05);
    path.moveTo(size.width * 0.05, size.height * 0.25);
    path.lineTo(size.width * 0.15, size.height * 0.15);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class WavePattern extends CustomPainter {
  final Color color;

  WavePattern(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Create wave pattern
    path.moveTo(0, size.height * 0.5);

    for (double x = 0; x <= size.width; x += 20) {
      final y = size.height * 0.5 +
          (size.height * 0.3) * math.sin((x / size.width) * 2 * math.pi);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CrystalPattern extends CustomPainter {
  final Color color;

  CrystalPattern(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Draw crystal/diamond pattern
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 3;

    // Main diamond
    path.moveTo(centerX, centerY - radius);
    path.lineTo(centerX + radius, centerY);
    path.lineTo(centerX, centerY + radius);
    path.lineTo(centerX - radius, centerY);
    path.close();

    // Inner lines
    path.moveTo(centerX, centerY - radius);
    path.lineTo(centerX, centerY + radius);
    path.moveTo(centerX - radius, centerY);
    path.lineTo(centerX + radius, centerY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
