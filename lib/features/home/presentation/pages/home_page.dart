import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';
import 'package:poemapp/features/home/presentation/widgets/poet_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:poemapp/features/poet/presentation/pages/poet_detail_page.dart';
import 'dart:ui';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poets = ref.watch(poetProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Creative Header
          SliverToBoxAdapter(
            child: Animate(
              effects: const [
                FadeEffect(duration: Duration(milliseconds: 700)),
              ],
              child: Stack(
                children: [
                  // Background Art
                  Container(
                    height: 360,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2D2D3F),
                    ),
                    child: Stack(
                      children: [
                        // Design Elements
                        Positioned(
                          top: -40,
                          right: -30,
                          child: Container(
                            height: 180,
                            width: 180,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE57373).withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -60,
                          left: -40,
                          child: Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              color: const Color(0xFF64B5F6).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Content
                        Positioned.fill(
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // App Bar
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        30, 60, 30, 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "ŞiirArt",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            height: 42,
                                            width: 42,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.search,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Feature Section
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          30, 20, 30, 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Big Title
                                          const Flexible(
                                            child: Text(
                                              "Şiirin\nİzinde",
                                              style: TextStyle(
                                                fontSize: 48,
                                                height: 1.1,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                letterSpacing: -1,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          // Subtitle
                                          Text(
                                            "Kelimelerin büyülü dünyasına dalın",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Tab Selection
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        30, 20, 30, 30),
                                    height: 40,
                                    child: Row(
                                      children: [
                                        _buildTab("Keşfet", true),
                                        _buildTab("Popüler", false),
                                        _buildTab("Yeni", false),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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

          // Feature Section Title
          SliverToBoxAdapter(
            child: Animate(
              effects: const [
                FadeEffect(
                    delay: Duration(milliseconds: 400),
                    duration: Duration(milliseconds: 800)),
              ],
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Öne Çıkan Şairler",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFE57373),
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      child: const Text("Tümünü Gör"),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Featured Poets Carousel
          poets.when(
            data: (poets) => SliverToBoxAdapter(
              child: SizedBox(
                height: 320,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 30, bottom: 20),
                  itemCount: poets.length >= 5 ? 5 : poets.length,
                  itemBuilder: (context, index) {
                    return Animate(
                      effects: [
                        FadeEffect(
                          delay: Duration(milliseconds: 300 + index * 100),
                          duration: const Duration(milliseconds: 800),
                        ),
                        SlideEffect(
                          delay: Duration(milliseconds: 300 + index * 100),
                          duration: const Duration(milliseconds: 800),
                          begin: const Offset(0.3, 0),
                          end: const Offset(0, 0),
                        ),
                      ],
                      child: FeaturePoetCard(poet: poets[index], index: index),
                    );
                  },
                ),
              ),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(
                    color: Color(0xFFE57373),
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
            error: (error, stackTrace) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade300,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Bir hata oluştu',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => ref.refresh(poetProvider),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFE57373),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // All Poets Section
          SliverToBoxAdapter(
            child: Animate(
              effects: const [
                FadeEffect(
                    delay: Duration(milliseconds: 500),
                    duration: Duration(milliseconds: 800)),
              ],
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tüm Şairler",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.filter_list,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Filtrele',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
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

          // All Poets Grid
          poets.when(
            data: (poets) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Animate(
                      effects: [
                        FadeEffect(
                          delay: Duration(milliseconds: 200 + index * 50),
                          duration: const Duration(milliseconds: 500),
                        ),
                      ],
                      child: PoetGridCard(poet: poets[index], index: index),
                    );
                  },
                  childCount: poets.length,
                ),
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFE57373)),
              ),
            ),
            error: (error, stackTrace) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Bir hata oluştu',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE57373) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? null
            : Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

class FeaturePoetCard extends StatelessWidget {
  final dynamic poet;
  final int index;

  const FeaturePoetCard({Key? key, required this.poet, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Color variations for cards
    final List<Color> cardColors = [
      const Color(0xFFE57373), // Red
      const Color(0xFF64B5F6), // Blue
      const Color(0xFF81C784), // Green
      const Color(0xFFFFD54F), // Amber
      const Color(0xFFBA68C8), // Purple
    ];

    final Color cardColor = cardColors[index % cardColors.length];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PoetDetailPage(poet: poet),
          ),
        );
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 20, top: 5, bottom: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D3F),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Decoration
            Positioned(
              top: 15,
              right: 15,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          cardColor.withOpacity(0.7),
                          cardColor.withOpacity(0.4),
                        ],
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Author Image
                        ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black, Colors.transparent],
                            ).createShader(
                                Rect.fromLTRB(0, 0, rect.width, rect.height));
                          },
                          blendMode: BlendMode.dstIn,
                          child: _buildPoetImage(poet.imageUrl),
                        ),
                        // Overlay decoration
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              poet.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Info Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Metadata
                        Text(
                          '${poet.birthDate} - ${poet.deathDate}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),

                        // Stats
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: cardColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.menu_book_outlined,
                                    color: cardColor,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${poet.notableWorks.length} şiir',
                                    style: TextStyle(
                                      color: cardColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoetImage(String imageUrl) {
    // Check if using a color placeholder instead of an image URL
    if (imageUrl.startsWith('color:')) {
      return Container(
        color: const Color(0xFF2D2D3F),
        child: Center(
          child: Icon(
            Icons.format_quote,
            size: 50,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
      );
    } else {
      // Regular network image
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: const Color(0xFF2D2D3F),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white38,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: const Color(0xFF2D2D3F),
          child: Center(
            child: Icon(
              Icons.format_quote,
              size: 50,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ),
      );
    }
  }
}

class PoetGridCard extends StatelessWidget {
  final dynamic poet;
  final int index;

  const PoetGridCard({Key? key, required this.poet, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Color variations for accent elements
    final List<Color> accentColors = [
      const Color(0xFFE57373), // Red
      const Color(0xFF64B5F6), // Blue
      const Color(0xFF81C784), // Green
      const Color(0xFFFFD54F), // Amber
      const Color(0xFFBA68C8), // Purple
    ];

    final Color accentColor = accentColors[index % accentColors.length];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PoetDetailPage(poet: poet),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D3F),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container
              SizedBox(
                height: 130,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black, Colors.transparent],
                        ).createShader(
                            Rect.fromLTRB(0, 0, rect.width, rect.height));
                      },
                      blendMode: BlendMode.dstIn,
                      child: _buildGridPoetImage(poet.imageUrl, accentColor),
                    ),

                    // Bottom Gradient
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color(0xFF2D2D3F).withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Poem count badge
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.menu_book_outlined,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${poet.notableWorks.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Info section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        poet.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Years
                      Text(
                        '${poet.birthDate} - ${poet.deathDate}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      // Genre tags
                      if (poet.styles.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            poet.styles[0],
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridPoetImage(String imageUrl, Color accentColor) {
    // Check if using a color placeholder instead of an image URL
    if (imageUrl.startsWith('color:')) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withOpacity(0.5),
              accentColor.withOpacity(0.3),
            ],
          ),
        ),
        child: Center(
          child: Text(
            poet.name.substring(0, 1),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white24,
            ),
          ),
        ),
      );
    } else {
      // Regular network image
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withOpacity(0.5),
                accentColor.withOpacity(0.3),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white38,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withOpacity(0.5),
                accentColor.withOpacity(0.3),
              ],
            ),
          ),
          child: Center(
            child: Text(
              poet.name.substring(0, 1),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white24,
              ),
            ),
          ),
        ),
      );
    }
  }
}
