import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/features/poem/presentation/pages/poem_detail_page.dart';
import 'package:poemapp/models/poem.dart';
import 'package:poemapp/models/poet.dart';
import 'package:poemapp/core/theme/theme_provider.dart';
import 'dart:ui';
import 'package:poemapp/features/home/providers/poet_provider.dart';
import 'package:poemapp/features/home/providers/poem_provider.dart';
import 'package:poemapp/services/api_service.dart';
import 'package:poemapp/features/home/providers/api_service_provider.dart';

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
  void initState() {
    super.initState();
    _isExpanded = false;
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkTheme = themeMode == ThemeMode.dark;

    final bgColor = isDarkTheme ? const Color(0xFF1E1E2C) : Colors.white;
    final cardColor =
        isDarkTheme ? const Color(0xFF2D2D3F) : const Color(0xFFF8F9FA);
    final textColor = isDarkTheme ? Colors.white : Colors.black87;
    final accentColor = const Color(0xFFE57373);
    final appBarIconColor = isDarkTheme ? Colors.white : Colors.black87;

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
                leading: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
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
                      child: Icon(
                        Icons.arrow_back,
                        color: appBarIconColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.zero,
                  expandedTitleScale: 1.0,
                  collapseMode: CollapseMode.pin,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background image with gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          image: widget.poet.image.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(widget.poet.image),
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
                        padding: const EdgeInsets.fromLTRB(20, 100, 0, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Poet avatar with more top padding to move it down
                            Padding(
                              padding: const EdgeInsets.only(top: 0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 90,
                                    height: 90,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: widget.poet.image.isEmpty
                                          ? accentColor.withOpacity(0.2)
                                          : null,
                                      border: Border.all(
                                          color: accentColor, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 10,
                                        ),
                                      ],
                                      image: widget.poet.image.isNotEmpty
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                  widget.poet.image),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: widget.poet.image.isEmpty
                                        ? Center(
                                            child: Text(
                                              _getInitial(widget.poet.name),
                                              style: TextStyle(
                                                color: accentColor,
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                ],
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
                                    style: TextStyle(
                                      color: isDarkTheme
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 0),
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
                                      color: isDarkTheme
                                          ? Colors.white.withOpacity(0.8)
                                          : Colors.black87.withOpacity(0.8),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 0),
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
                                            '${widget.poet.poemCount} Şiir',
                                            style: TextStyle(
                                              color: isDarkTheme
                                                  ? Colors.white
                                                      .withOpacity(0.9)
                                                  : Colors.black87
                                                      .withOpacity(0.9),
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
                actions: [
                  // Tema değiştirme butonu
                  Padding(
                    padding: const EdgeInsets.only(right: 16, top: 10),
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

              // Biography section - Minimalist Design
              if (widget.poet.about.isNotEmpty)
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
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 6),
                            blurRadius: 10,
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
                                  color: accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  color: accentColor,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Biyografi',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            widget.poet.about,
                            style: TextStyle(
                              color: textColor.withOpacity(0.8),
                              fontSize: 14,
                              height: 1.6,
                            ),
                            maxLines: _isExpanded ? null : 6,
                            overflow:
                                _isExpanded ? null : TextOverflow.ellipsis,
                          ),
                          if (widget.poet.about.length > 200)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _isExpanded
                                          ? 'Daha Az Göster'
                                          : 'Devamını Oku',
                                      style: TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Icon(
                                      _isExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: accentColor,
                                      size: 18,
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
                        'Şiirler',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Şair ID'sini seçili şair provider'ına aktar
                          ref.read(selectedPoetIdProvider.notifier).state =
                              widget.poet.id;
                          // Tüm şiirler sayfasına geçiş yap
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
                    // Debug poet ID
                    print(
                        "🔍 Looking for poems for poet with ID: ${widget.poet.id}");

                    // Şaire ait şiirleri getir - Şairin ID'sini doğrudan kullan
                    final poemsAsync =
                        ref.watch(poemsByPoetProvider(widget.poet.id));

                    // Check if poems are empty
                    if (poemsAsync.isEmpty) {
                      // Try to reload the data if we haven't tried yet
                      if (!ref.read(refreshDataProvider)) {
                        // Set the refresh flag to true to trigger a reload
                        print(
                            "🔄 Triggering data refresh for poet ${widget.poet.id}");
                        Future.microtask(() {
                          ref.read(refreshDataProvider.notifier).state = true;
                        });

                        return SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Şiirler yükleniyor...',
                                    style: TextStyle(
                                        color: textColor.withOpacity(0.7)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.sentiment_dissatisfied,
                                  size: 40,
                                  color: textColor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Bu şairin şiirleri henüz eklenmemiş',
                                  style: TextStyle(
                                      color: textColor.withOpacity(0.7)),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Clear cache and trigger reload
                                    ref
                                        .read(apiServiceProvider)
                                        .clearCache()
                                        .then((_) {
                                      ref
                                          .read(refreshDataProvider.notifier)
                                          .state = true;
                                    });
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Yeniden Dene'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        accentColor.withOpacity(0.2),
                                    foregroundColor: accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= poemsAsync.length) return null;
                          return _buildPoemCard(poemsAsync[index], accentColor,
                              textColor, cardColor);
                        },
                        childCount: poemsAsync.length,
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
                          poem.name,
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
                    poem.content.trim().isEmpty
                        ? "Şiirin içeriğini görmek için tıkla..."
                        : poem.content,
                    style: TextStyle(
                      color: textColor.withOpacity(0.75),
                      fontSize: 14,
                      height: 1.5,
                      fontStyle: poem.content.trim().isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: (poem.tags.isEmpty)
                        ? [
                            Container(
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
                                '#şiir',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ]
                        : poem.tags.map((tag) {
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

  // Şair şiirlerinin tamamını gösteren sayfa
  Widget _buildAllPoemsPage(BuildContext context, Poet poet) {
    return Consumer(
      builder: (context, ref, child) {
        final themeMode = ref.watch(themeModeProvider);
        final isDarkTheme = themeMode == ThemeMode.dark;

        final bgColor = isDarkTheme ? const Color(0xFF1E1E2C) : Colors.white;
        final cardColor =
            isDarkTheme ? const Color(0xFF2D2D3F) : const Color(0xFFF8F9FA);
        final textColor = isDarkTheme ? Colors.white : Colors.black87;
        final accentColor = const Color(0xFFE57373);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(
              poet.name,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            backgroundColor: cardColor,
            elevation: 0,
            foregroundColor: textColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Consumer(
            builder: (context, ref, child) {
              final poetPoemsAsync = ref.watch(poetPoemsProvider);

              return poetPoemsAsync.when(
                data: (poetPoems) {
                  if (poetPoems.isEmpty) {
                    return Center(
                      child: Text(
                        'Bu şairin şiirleri henüz eklenmemiş',
                        style: TextStyle(color: textColor.withOpacity(0.7)),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: poetPoems.length,
                    itemBuilder: (context, index) {
                      return _buildPoemCard(
                          poetPoems[index], accentColor, textColor, cardColor);
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => Center(
                  child: Text(
                    'Şiirler yüklenirken bir hata oluştu',
                    style: TextStyle(color: textColor.withOpacity(0.7)),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _getInitial(String name) {
    if (name.isEmpty) return '';
    return name.substring(0, 1).toUpperCase();
  }
}
