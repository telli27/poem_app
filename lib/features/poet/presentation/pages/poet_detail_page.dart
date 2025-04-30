import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/models/poet.dart';
import 'package:poemapp/models/poem.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:poemapp/features/poem/presentation/pages/poem_detail_page.dart';
import 'package:poemapp/features/home/providers/poem_provider.dart';
import 'package:poemapp/core/theme/theme_provider.dart';
import 'dart:ui';

class PoetDetailPage extends ConsumerStatefulWidget {
  final Poet poet;

  const PoetDetailPage({
    super.key,
    required this.poet,
  });

  @override
  ConsumerState<PoetDetailPage> createState() => _PoetDetailPageState();
}

class _PoetDetailPageState extends ConsumerState<PoetDetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkTheme = themeMode == ThemeMode.dark;

    final bgColor = isDarkTheme ? const Color(0xFF1E1E2C) : Colors.white;
    final cardColor =
        isDarkTheme ? const Color(0xFF2D2D3F) : const Color(0xFFF8F9FA);
    final textColor = isDarkTheme ? Colors.white : Colors.black87;
    final accentColor = const Color(0xFFE57373);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background design elements
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              height: 220,
              width: 220,
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
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF64B5F6).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Flexible app bar with poet image and background
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                backgroundColor: bgColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background image with gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          image: widget.poet.imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(widget.poet.imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  bgColor.withOpacity(0.3),
                                  bgColor.withOpacity(0.7),
                                  bgColor,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Poet content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Poet avatar
                            Container(
                              width: 90,
                              height: 90,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: accentColor, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                                image: DecorationImage(
                                  image: NetworkImage(widget.poet.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            // Poet name and years
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Animate(
                                  effects: const [
                                    FadeEffect(
                                        duration: Duration(milliseconds: 600)),
                                    SlideEffect(
                                      begin: Offset(0, 0.2),
                                      end: Offset(0, 0),
                                    ),
                                  ],
                                  child: Text(
                                    widget.poet.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Animate(
                                  effects: const [
                                    FadeEffect(
                                      delay: Duration(milliseconds: 200),
                                      duration: Duration(milliseconds: 600),
                                    ),
                                  ],
                                  child: Text(
                                    _formatYears(widget.poet.birthDate,
                                        widget.poet.deathDate),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: accentColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.menu_book,
                                            color: accentColor,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '${widget.poet.notableWorks.length} Şiir',
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite_outline,
                        color: accentColor,
                        size: 20,
                      ),
                    ),
                  ),
                  // Tema değiştirme butonu
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(themeModeProvider.notifier).toggleThemeMode();
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                          color: accentColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Biography section
              if (widget.poet.biography != null &&
                  widget.poet.biography!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Animate(
                    effects: const [
                      FadeEffect(
                        delay: Duration(milliseconds: 200),
                        duration: Duration(milliseconds: 800),
                      ),
                    ],
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 25),
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            offset: const Offset(0, 8),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  color: accentColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text(
                                'Biyografi',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.poet.biography!,
                            style: TextStyle(
                              color: textColor.withOpacity(0.85),
                              fontSize: 15,
                              height: 1.6,
                            ),
                            maxLines: _isExpanded ? null : 6,
                            overflow:
                                _isExpanded ? null : TextOverflow.ellipsis,
                          ),
                          if (widget.poet.biography!.length > 200)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isExpanded
                                          ? 'Daha Az Göster'
                                          : 'Devamını Oku',
                                      style: TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(
                                      _isExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: accentColor,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Poems section title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Şiirleri',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Şairin tüm şiirlerini göster
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  _buildAllPoemsPage(context, widget.poet),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Tümünü Gör',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: textColor.withOpacity(0.8),
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Poems list
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                sliver: Consumer(
                  builder: (context, ref, child) {
                    final poemsAsyncValue = ref.watch(poemProvider);

                    return poemsAsyncValue.when(
                      data: (allPoems) {
                        // Filter poems for this specific poet
                        final poetPoems = allPoems
                            .where((poem) => poem.poetId == widget.poet.id)
                            .toList();

                        if (poetPoems.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  'Bu şairin şiirleri henüz eklenmemiş',
                                  style: TextStyle(
                                      color: textColor.withOpacity(0.7)),
                                ),
                              ),
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index >= poetPoems.length) return null;
                              return _buildPoemCard(poetPoems[index],
                                  accentColor, textColor, cardColor);
                            },
                            childCount: poetPoems.length,
                          ),
                        );
                      },
                      loading: () => const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                      error: (err, stack) => SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'Şiirler yüklenirken bir hata oluştu',
                              style:
                                  TextStyle(color: textColor.withOpacity(0.7)),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPoemCard(
      Poem poem, Color accentColor, Color textColor, Color cardColor) {
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 800)),
        SlideEffect(
          begin: Offset(0, 0.1),
          end: Offset(0, 0),
        ),
      ],
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // Navigate to poem detail
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PoemDetailPage(poem: poem),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          poem.title,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: textColor.withOpacity(0.4),
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    poem.content,
                    style: TextStyle(
                      color: textColor.withOpacity(0.75),
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: poem.tags.map((tag) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 12,
                            color: accentColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatYears(String birthDate, String deathDate) {
    if (birthDate.isEmpty) return '';

    if (deathDate.isEmpty) {
      return '$birthDate - Günümüz';
    }

    return '$birthDate - $deathDate';
  }

  // Şairin tüm şiirlerini gösteren sayfa
  Widget _buildAllPoemsPage(BuildContext context, Poet poet) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: Text('${poet.name} - Tüm Şiirleri'),
        backgroundColor: const Color(0xFF2D2D3F),
        elevation: 0,
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final poemsAsyncValue = ref.watch(poemProvider);

          return poemsAsyncValue.when(
            data: (allPoems) {
              // Şairin şiirlerini bul
              final poetPoems =
                  allPoems.where((poem) => poem.poetId == poet.id).toList();

              if (poetPoems.isEmpty) {
                return const Center(
                  child: Text(
                    'Bu şairin şiirleri henüz eklenmemiş',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: poetPoems.length,
                itemBuilder: (context, index) {
                  final poem = poetPoems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: const Color(0xFF2D2D3F),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PoemDetailPage(poem: poem),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE57373),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    poem.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              poem.content,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: poem.tags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE57373)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFE57373),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE57373),
              ),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Hata: $error',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        },
      ),
    );
  }
}
