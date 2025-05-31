import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';
import 'package:poemapp/features/home/providers/poem_provider.dart';
import 'package:poemapp/features/home/presentation/widgets/poet_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:poemapp/features/poet/presentation/pages/poet_detail_page.dart';
import 'package:poemapp/features/poem/presentation/pages/poem_detail_page.dart';
import 'package:poemapp/core/theme/theme_provider.dart';
import 'package:poemapp/models/poet.dart';
import 'package:poemapp/services/api_service.dart';
import 'dart:ui';
import 'package:poemapp/features/home/providers/api_service_provider.dart';
import 'package:poemapp/widgets/connectivity_banner.dart';
import 'package:poemapp/widgets/loading_state_widget.dart';
import 'package:poemapp/services/connectivity_service.dart';
import 'package:poemapp/widgets/poet_info_widget.dart';
import 'package:poemapp/widgets/error_widget.dart';
import 'package:poemapp/features/mood/presentation/pages/mood_based_poem_page.dart';

// Restore the enum but keep it commented for reference
enum TabSelection { discover, popular, newest }

final selectedTabProvider =
    StateProvider<TabSelection>((ref) => TabSelection.discover);

// Search providers
final searchOpenProvider = StateProvider<bool>((ref) => false);
final searchTermProvider = StateProvider<String>((ref) => '');
final refreshDataProvider = StateProvider<bool>((ref) => false);
final moodCardVisibleProvider = StateProvider<bool>((ref) => true);

// Add mood providers
final selectedMoodProvider = StateProvider<String?>((ref) => null);
final moodPoemsProvider = StateProvider<List<dynamic>>((ref) => []);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poets = ref.watch(poetProvider);
    final size = MediaQuery.of(context).size;
    final selectedTab = ref.watch(selectedTabProvider);
    final isSearchOpen = ref.watch(searchOpenProvider);
    final searchTerm = ref.watch(searchTermProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    // Reset mood card visibility when returning to home page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(moodCardVisibleProvider.notifier).state = true;
    });

    // Check if data is still loading or has error
    final bool isLoading = poets is AsyncLoading;
    final bool hasError = poets is AsyncError;

    return Scaffold(
      backgroundColor: ref.watch(themeModeProvider) == ThemeMode.dark
          ? const Color(0xFF1E1E2C) // Dark theme background
          : Colors.white, // Light theme background
      body: Stack(
        children: [
          // Ana sayfa yükleme hatası varsa, büyük error widget göster
          if (hasError || (poets.value != null && poets.value!.isEmpty))
            ErrorDisplayWidget(
              errorMessage: hasError
                  ? poets.error.toString()
                  : 'Şair verisi yüklenemedi.',
              onRetry: () {
                // Check connectivity
                ref.read(connectivityServiceProvider).checkConnectivity();
                // Trigger data reload
                ref.refresh(poetProvider);
                ref.refresh(poemProvider);
              },
            ),

          // Normal içerik - hatası yoksa göster
          if (!hasError && (poets.value == null || poets.value!.isNotEmpty))
            CustomScrollView(
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
                          height: 270,
                          decoration: BoxDecoration(
                            color: ref.watch(themeModeProvider) ==
                                    ThemeMode.dark
                                ? const Color(0xFF2D2D3F) // Dark theme surface
                                : Colors.white, // Light theme surface
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
                                    color: const Color(0xFFE57373)
                                        .withOpacity(0.15),
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
                                    color: const Color(0xFF64B5F6)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              // Content
                              Positioned.fill(
                                child: ClipRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 20, sigmaY: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // App Bar
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              30, 60, 30, 0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "ŞiirArt",
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: ref.watch(
                                                              themeModeProvider) ==
                                                          ThemeMode.dark
                                                      ? Colors.white
                                                      : Colors.black,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      ref
                                                          .read(
                                                              searchOpenProvider
                                                                  .notifier)
                                                          .state = !isSearchOpen;
                                                    },
                                                    child: Container(
                                                      height: 42,
                                                      width: 42,
                                                      decoration: BoxDecoration(
                                                        color: ref.watch(
                                                                    themeModeProvider) ==
                                                                ThemeMode.dark
                                                            ? Colors.white
                                                                .withOpacity(
                                                                    0.1)
                                                            : Colors.black
                                                                .withOpacity(
                                                                    0.05),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Icon(
                                                        isSearchOpen
                                                            ? Icons.close
                                                            : Icons.search,
                                                        color: ref.watch(
                                                                    themeModeProvider) ==
                                                                ThemeMode.dark
                                                            ? Colors.white
                                                            : Colors.black,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  // Tema değiştirme butonu
                                                  GestureDetector(
                                                    onTap: () {
                                                      ref
                                                          .read(
                                                              themeModeProvider
                                                                  .notifier)
                                                          .toggleThemeMode();
                                                    },
                                                    child: Container(
                                                      height: 42,
                                                      width: 42,
                                                      decoration: BoxDecoration(
                                                        color: ref.watch(
                                                                    themeModeProvider) ==
                                                                ThemeMode.dark
                                                            ? Colors.white
                                                                .withOpacity(
                                                                    0.1)
                                                            : Colors.black
                                                                .withOpacity(
                                                                    0.05),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Icon(
                                                        ref.watch(themeModeProvider) ==
                                                                ThemeMode.dark
                                                            ? Icons.dark_mode
                                                            : Icons.light_mode,
                                                        color: ref.watch(
                                                                    themeModeProvider) ==
                                                                ThemeMode.dark
                                                            ? Colors.white
                                                            : Colors.black,
                                                        size: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Search Bar (conditional)
                                        if (isSearchOpen)
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                30, 15, 30, 0),
                                            child: TextField(
                                              style: TextStyle(
                                                  color: ref.watch(
                                                              themeModeProvider) ==
                                                          ThemeMode.dark
                                                      ? Colors.white
                                                      : Colors.black),
                                              onChanged: (value) {
                                                ref
                                                    .read(searchTermProvider
                                                        .notifier)
                                                    .state = value;
                                              },
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Şair veya şiir ara...',
                                                hintStyle: TextStyle(
                                                    color: ref.watch(
                                                                themeModeProvider) ==
                                                            ThemeMode.dark
                                                        ? Colors.white
                                                            .withOpacity(0.5)
                                                        : Colors.black
                                                            .withOpacity(0.5)),
                                                fillColor: ref.watch(
                                                            themeModeProvider) ==
                                                        ThemeMode.dark
                                                    ? Colors.white
                                                        .withOpacity(0.1)
                                                    : Colors.black
                                                        .withOpacity(0.05),
                                                filled: true,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                                prefixIcon: Icon(Icons.search,
                                                    color: ref.watch(
                                                                themeModeProvider) ==
                                                            ThemeMode.dark
                                                        ? Colors.white
                                                        : Colors.black54),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 12,
                                                  horizontal: 16,
                                                ),
                                              ),
                                            ),
                                          ),

                                        // Feature Section (hidden during search)
                                        if (!isSearchOpen)
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      30, 10, 30, 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Big Title
                                                  Flexible(
                                                    child: Text(
                                                      "Şiirin\nİzinde",
                                                      style: TextStyle(
                                                        fontSize: 48,
                                                        height: 1.1,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: ref.watch(
                                                                    themeModeProvider) ==
                                                                ThemeMode.dark
                                                            ? Colors.white
                                                            : Colors.black,
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
                                                      color: ref.watch(
                                                                  themeModeProvider) ==
                                                              ThemeMode.dark
                                                          ? Colors.white
                                                              .withOpacity(0.7)
                                                          : Colors.black
                                                              .withOpacity(0.7),
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                        const SizedBox(height: 0),
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

                // Search Results (only show when search is active and has query)
                if (isSearchOpen && searchTerm.isNotEmpty)
                  _buildSearchResults(ref, searchTerm),

                // Regular content (hidden during search with results)
                if (!isSearchOpen || searchTerm.isEmpty) ...[
                  // Mood-based Poem Recommendation Feature
                  Consumer(
                    builder: (context, ref, child) {
                      final isMoodCardVisible =
                          ref.watch(moodCardVisibleProvider);

                      if (!isMoodCardVisible) {
                        return const SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        );
                      }

                      return SliverToBoxAdapter(
                        child: Animate(
                          effects: const [
                            FadeEffect(
                                delay: Duration(milliseconds: 300),
                                duration: Duration(milliseconds: 800)),
                            SlideEffect(
                                begin: Offset(0, 0.3),
                                delay: Duration(milliseconds: 300),
                                duration: Duration(milliseconds: 800)),
                          ],
                          child:
                              _buildMoodRecommendationSection(ref, isDarkMode),
                        ),
                      );
                    },
                  ),

                  // Feature Section Title

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
                            Text(
                              "Tüm Şairler",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: ref.watch(themeModeProvider) ==
                                        ThemeMode.dark
                                    ? Colors.white
                                    : Colors.black,
                                letterSpacing: 0.3,
                              ),
                            ),
                            // Add poet info widget
                            const PoetInfoWidget(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // All Poets Grid (filtered by selected tab)
                  poets.when(
                    data: (poets) {
                      // Filtre uygula
                      final filteredPoets =
                          _filterPoetsByTab(poets, selectedTab);

                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 20,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return Animate(
                                effects: [
                                  FadeEffect(
                                    delay: Duration(
                                        milliseconds: 50 + (index % 8) * 30),
                                    duration: const Duration(milliseconds: 300),
                                  ),
                                ],
                                child: PoetGridCard(
                                    poet: filteredPoets[index], index: index),
                              );
                            },
                            childCount: filteredPoets.length,
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: true,
                          ),
                        ),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(
                      child: SizedBox
                          .shrink(), // We'll show our custom loading state
                    ),
                    error: (error, stackTrace) => const SliverToBoxAdapter(
                      child: SizedBox
                          .shrink(), // We'll show our custom error state
                    ),
                  ),
                ],

                // Show loading state widget if data is loading or has error
                if (isLoading || hasError)
                  SliverFillRemaining(
                    child: LoadingStateWidget(
                      state: poets,
                      onRetry: () {
                        // Check connectivity first
                        ref
                            .read(connectivityServiceProvider)
                            .checkConnectivity();
                        // Refresh data
                        ref.read(refreshDataProvider.notifier).state = true;
                      },
                    ),
                  ),
              ],
            ),

          // Connectivity banner at the top
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ConnectivityBanner(),
          ),
        ],
      ),
    );
  }

  // Arama sonuçları widgeti
  Widget _buildSearchResults(WidgetRef ref, String query) {
    if (query.isEmpty)
      return const SliverToBoxAdapter(child: SizedBox.shrink());

    return Consumer(
      builder: (context, ref, child) {
        final poetsAsync = ref.watch(poetProvider);
        final poemsAsync = ref.watch(poemProvider);

        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Arama başlığı
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
                child: Text(
                  "Arama Sonuçları",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: ref.watch(themeModeProvider) == ThemeMode.dark
                        ? Colors.white
                        : Colors.black,
                    letterSpacing: 0.3,
                  ),
                ),
              ),

              // Birleştirilmiş sonuçlar
              _buildCombinedResults(
                  context, ref, query, poetsAsync, poemsAsync),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCombinedResults(
      BuildContext context,
      WidgetRef ref,
      String query,
      AsyncValue<List<dynamic>> poetsAsync,
      AsyncValue<List<dynamic>> poemsAsync) {
    if (poetsAsync.isLoading || poemsAsync.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: Color(0xFFE57373)),
        ),
      );
    }

    if (poetsAsync.hasError || poemsAsync.hasError) {
      return Center(
        child: Text(
          'Bir hata oluştu',
          style: TextStyle(
            color: ref.watch(themeModeProvider) == ThemeMode.dark
                ? Colors.white.withOpacity(0.6)
                : Colors.black.withOpacity(0.6),
          ),
        ),
      );
    }

    final poets = poetsAsync.value ?? [];
    final poems = poemsAsync.value ?? [];

    // Şair sonuçlarını filtrele
    final poetResults = poets
        .where((poet) =>
            poet.name.toLowerCase().contains(query.toLowerCase()) ||
            poet.about.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Şiir sonuçlarını filtrele (maksimum 3 tane)
    final poemResults = poems
        .where((poem) =>
            poem.name.toLowerCase().contains(query.toLowerCase()) ||
            poem.content.toLowerCase().contains(query.toLowerCase()))
        .take(3)
        .toList();

    if (poetResults.isEmpty && poemResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: ref.watch(themeModeProvider) == ThemeMode.dark
                    ? Colors.white.withOpacity(0.3)
                    : Colors.black.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Aradığınız içerik bulunamadı',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: ref.watch(themeModeProvider) == ThemeMode.dark
                      ? Colors.white.withOpacity(0.6)
                      : Colors.black.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Farklı anahtar kelimeler deneyin',
                style: TextStyle(
                  fontSize: 14,
                  color: ref.watch(themeModeProvider) == ThemeMode.dark
                      ? Colors.white.withOpacity(0.4)
                      : Colors.black.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Şair sonuçları
          if (poetResults.isNotEmpty) ...[
            if (poetResults.length == 1)
              _buildPoetSearchCard(context, ref, poetResults.first)
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: poetResults.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 160,
                      margin: EdgeInsets.only(
                        right: index == poetResults.length - 1 ? 0 : 16,
                      ),
                      child: _buildCompactPoetCard(
                          context, ref, poetResults[index], index),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
          ],

          // Şiir sonuçları
          if (poemResults.isNotEmpty) ...[
            Text(
              "İlgili Şiirler",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ref.watch(themeModeProvider) == ThemeMode.dark
                    ? Colors.white.withOpacity(0.8)
                    : Colors.black.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            ...poemResults
                .map((poem) => _buildPoemSearchCard(context, ref, poem)),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPoetSearchCard(
      BuildContext context, WidgetRef ref, dynamic poet) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D3F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PoetDetailPage(poet: poet),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE57373).withOpacity(0.2),
                      const Color(0xFFE57373).withOpacity(0.1),
                    ],
                  ),
                ),
                child: poet.image != null && poet.image.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: poet.image,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: Text(
                              poet.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFFE57373),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Text(
                              poet.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFFE57373),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          poet.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFE57373),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poet.name,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${poet.poemCount} şiir",
                      style: TextStyle(
                        color: const Color(0xFFE57373),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      poet.about.length > 80
                          ? "${poet.about.substring(0, 80)}..."
                          : poet.about,
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.7),
                        fontSize: 13,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDarkMode
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.5),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactPoetCard(
      BuildContext context, WidgetRef ref, dynamic poet, int index) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final List<List<Color>> gradientColors = [
      [const Color(0xFF667EEA), const Color(0xFF764BA2)], // Purple-Blue
      [const Color(0xFF9CECFB), const Color(0xFF0052D4)], // Light Blue-Blue
      [const Color(0xFFFBDA61), const Color(0xFFFF5ACD)], // Yellow-Pink
      [const Color(0xFFFF9A8B), const Color(0xFFA8E6CF)], // Coral-Mint
      [const Color(0xFFA8EDEA), const Color(0xFFFED6E3)], // Mint-Pink
      [const Color(0xFFD299C2), const Color(0xFFFEF9D7)], // Pink-Yellow
      [const Color(0xFF89F7FE), const Color(0xFF66A6FF)], // Cyan-Blue
      [const Color(0xFFFFE259), const Color(0xFFFFA751)], // Yellow-Orange
    ];
    final gradientPair = gradientColors[index % gradientColors.length];

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
          color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isDarkMode
              ? Border.all(color: Colors.white.withOpacity(0.1), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Top gradient line
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientPair,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),

            // Avatar section
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: gradientPair,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gradientPair[0].withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: poet.image != null && poet.image.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: poet.image,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: Text(
                                  poet.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Center(
                                child: Text(
                                  poet.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                poet.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),

            // Info section
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name
                    Flexible(
                      child: Text(
                        poet.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF2D3748),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Şiir sayısı - kompakt badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667EEA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF667EEA).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.library_books,
                            size: 12,
                            color: const Color(0xFF667EEA),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "${poet.poemCount} Şiir",
                            style: TextStyle(
                              color: const Color(0xFF667EEA),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Keşfet butonu - kompakt ve güvenli
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PoetDetailPage(poet: poet),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          elevation: 1,
                          shadowColor: const Color(0xFF667EEA).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Keşfet',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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

  Widget _buildPoemSearchCard(
      BuildContext context, WidgetRef ref, dynamic poem) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D3F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PoemDetailPage(poem: poem),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          poem.name,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: FutureBuilder<String>(
          future: _getPoetName(ref, poem.poetId),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? "Yükleniyor...",
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black.withOpacity(0.7),
              ),
            );
          },
        ),
        trailing: Icon(
          Icons.auto_stories_rounded,
          color: const Color(0xFF64B5F6),
          size: 20,
        ),
      ),
    );
  }

  // Update the _filterPoetsByTab method to just return all poets without filtering
  List<dynamic> _filterPoetsByTab(List<dynamic> poets, TabSelection tab) {
    // No filtering - just return all poets
    return poets;
  }

  // Method to build tab selection button - keep for now but commented out
  /*Widget _buildTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Consumer(builder: (context, ref, _) {
        final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
        return Container(
          margin: const EdgeInsets.only(right: 15),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4A5BCC) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? null
                : Border.all(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.3)
                        : Colors.black.withOpacity(0.3),
                    width: 1),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : isDarkMode
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.7),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        );
      }),
    );
  }*/

  // Tüm şairleri gösteren sayfa
  Widget _buildAllPoetsPage(
      BuildContext context, WidgetRef ref, TabSelection currentTab) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
      appBar: AppBar(
        title: Text("Tüm Şairler"),
        backgroundColor: isDarkMode ? const Color(0xFF2D2D3F) : Colors.white,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.filter_list),
        //     onPressed: () => _showFilterDialog(context, ref),
        //   ),
        // ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final poetsAsync = ref.watch(poetProvider);

          return poetsAsync.when(
            data: (poets) {
              final filteredPoets = _filterPoetsByTab(poets, currentTab);

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredPoets.length,
                itemBuilder: (context, index) {
                  final poet = filteredPoets[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: isDarkMode ? const Color(0xFF2D2D3F) : Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PoetDetailPage(poet: poet),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: poet.imageUrl.startsWith('color:')
                                    ? null
                                    : DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            poet.imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                color: poet.imageUrl.startsWith('color:')
                                    ? const Color(0xFFE57373).withOpacity(0.3)
                                    : null,
                              ),
                              child: poet.imageUrl.startsWith('color:')
                                  ? Center(
                                      child: Text(
                                        poet.name.substring(0, 1),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    poet.name,
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    poet.poemCount > 0
                                        ? "${poet.poemCount} şiir"
                                        : "Şiiri yok",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkMode
                                          ? Colors.white.withOpacity(0.6)
                                          : Colors.black.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE57373)
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.menu_book_outlined,
                                              color: Color(0xFFE57373),
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${poet.poemCount} şiir',
                                              style: const TextStyle(
                                                color: Color(0xFFE57373),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (poet.styles.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF64B5F6)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            poet.styles[0],
                                            style: const TextStyle(
                                              color: Color(0xFF64B5F6),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color:
                                  isDarkMode ? Colors.white54 : Colors.black54,
                              size: 16,
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
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          );
        },
      ),
    );
  }

  // Filtreleme diyaloğu
  // void _showFilterDialog(BuildContext context, WidgetRef ref) {
  //   // ... code removed ...
  // }

  Future<String> _getPoetName(WidgetRef ref, String poetId) async {
    final poetsAsync = await ref.watch(poetProvider.future);
    final poet = poetsAsync.firstWhere(
      (p) => p.id == poetId,
      orElse: () => Poet(
        id: '',
        name: 'Bilinmeyen Şair',
        about: '',
        image: '',
        poemCount: 0,
      ),
    );
    return poet.name;
  }

  // Add mood recommendation section method
  Widget _buildMoodRecommendationSection(WidgetRef ref, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Builder(
        builder: (context) => GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MoodBasedPoemPage(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF7986CB).withOpacity(0.1),
                  const Color(0xFF5C6BC0).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF7986CB).withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  children: [
                    // Icon section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7986CB).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.psychology_rounded,
                            color: const Color(0xFF7986CB),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "💕😢🌟🌿",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Content section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ruh Halime Göre Şiir Bul",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Bugün nasıl hissediyorsun? Sana özel şiirler keşfet",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.black.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow icon (keep for navigation hint)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: const Color(0xFF7986CB),
                      size: 18,
                    ),
                  ],
                ),

                // Close button in top right corner
                Positioned(
                  top: -6,
                  right: -6,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(moodCardVisibleProvider.notifier).state = false;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.black.withOpacity(0.4)
                            : Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.2)
                              : Colors.black.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black.withOpacity(0.8),
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
  }
}

class PoetGridCard extends ConsumerWidget {
  final dynamic poet;
  final int index;

  const PoetGridCard({Key? key, required this.poet, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D2D3F) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PoetDetailPage(poet: poet),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar - kompakt boyut
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF667EEA),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: poet.image != null && poet.image.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: poet.image,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: Text(
                                _getInitial(poet.name),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Text(
                                _getInitial(poet.name),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            _getInitial(poet.name),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 8),

                // Şair adı - kompakt ve güvenli
                Flexible(
                  child: Text(
                    poet.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 6),

                // Şiir sayısı - kompakt badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.library_books,
                        size: 12,
                        color: const Color(0xFF667EEA),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        "${poet.poemCount} Şiir",
                        style: TextStyle(
                          color: const Color(0xFF667EEA),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Keşfet butonu - kompakt ve güvenli
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PoetDetailPage(poet: poet),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shadowColor: const Color(0xFF667EEA).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      'Keşfet',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
  }

  String _getInitial(String name) {
    if (name.isEmpty) return "?";
    return name.substring(0, 1).toUpperCase();
  }
}
