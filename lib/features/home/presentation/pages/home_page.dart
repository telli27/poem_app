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

// Restore the enum but keep it commented for reference
enum TabSelection { discover, popular, newest }

final selectedTabProvider =
    StateProvider<TabSelection>((ref) => TabSelection.discover);

// Search providers
final searchOpenProvider = StateProvider<bool>((ref) => false);
final searchTermProvider = StateProvider<String>((ref) => '');
final refreshDataProvider = StateProvider<bool>((ref) => false);

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
                          height: 360,
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
                                                      30, 20, 30, 10),
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

                                        const SizedBox(height: 30),
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ref.watch(themeModeProvider) ==
                                        ThemeMode.dark
                                    ? Colors.white
                                    : Colors.black,
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
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 30),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return Animate(
                                effects: [
                                  FadeEffect(
                                    delay: Duration(
                                        milliseconds: 200 + index * 50),
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                ],
                                child: PoetGridCard(
                                    poet: filteredPoets[index], index: index),
                              );
                            },
                            childCount: filteredPoets.length,
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

    // Şairleri ara
    return Consumer(
      builder: (context, ref, child) {
        final poetsAsync = ref.watch(poetProvider);
        final poemsAsync = ref.watch(poemProvider);

        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Şair sonuçları
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: Text(
                  "Şairler",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              poetsAsync.when(
                data: (poets) {
                  final results = poets
                      .where((poet) =>
                          poet.name
                              .toLowerCase()
                              .contains(query.toLowerCase()) ||
                          poet.about
                              .toLowerCase()
                              .contains(query.toLowerCase()))
                      .toList();

                  if (results.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 30, bottom: 20),
                      child: Text(
                        'Hiçbir şair bulunamadı',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(left: 30, bottom: 20),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        return FeaturePoetCard(
                          poet: results[index],
                          index: index,
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFFE57373)),
                  ),
                ),
                error: (_, __) => const Center(
                  child: Text('Bir hata oluştu',
                      style: TextStyle(color: Colors.black54)),
                ),
              ),

              // Şiir sonuçları
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
                child: Text(
                  "Şiirler",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              poemsAsync.when(
                data: (poems) {
                  final results = poems
                      .where((poem) =>
                          poem.name
                              .toLowerCase()
                              .contains(query.toLowerCase()) ||
                          poem.content
                              .toLowerCase()
                              .contains(query.toLowerCase()))
                      .toList();

                  if (results.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 30, bottom: 30),
                      child: Text(
                        'Hiçbir şiir bulunamadı',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.only(left: 30, right: 30, bottom: 30),
                    itemCount: results.length > 5 ? 5 : results.length,
                    itemBuilder: (context, index) {
                      final poem = results[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          onTap: () {
                            // Şiir detayına git
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PoemDetailPage(poem: poem),
                              ),
                            );
                          },
                          title: Text(
                            poem.name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: FutureBuilder<String>(
                            future: _getPoetName(ref, poem.poetId),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? "Yükleniyor...",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ref.watch(themeModeProvider) ==
                                          ThemeMode.dark
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.black.withOpacity(0.7),
                                ),
                              );
                            },
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black54,
                            size: 16,
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFFE57373)),
                  ),
                ),
                error: (_, __) => const Center(
                  child: Text('Bir hata oluştu',
                      style: TextStyle(color: Colors.black54)),
                ),
              ),
            ],
          ),
        );
      },
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
}

class FeaturePoetCard extends ConsumerWidget {
  final dynamic poet;
  final int index;

  const FeaturePoetCard({Key? key, required this.poet, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    // Color variations for cards
    final List<Color> cardColors = [
      const Color(0xFFE57373), // Red
      const Color(0xFF64B5F6), // Blue
      const Color(0xFF81C784), // Green
      const Color(0xFFFFD54F), // Amber
      const Color(0xFFBA68C8), // Purple
    ];

    final Color accentColor = cardColors[index % cardColors.length];
    final backgroundColor = isDarkMode ? const Color(0xFF2D2D3F) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      child: GestureDetector(
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
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar section with reduced height
              SizedBox(
                height: 120,
                child: Container(
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        image: poet.image != null && poet.image.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(poet.image),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: poet.image == null || poet.image.isEmpty
                          ? Center(
                              child: Text(
                                _getInitial(poet.name),
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              // Compact info section
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Name
                    Text(
                      poet.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Poem count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${poet.poemCount} şiir",
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Button
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PoetDetailPage(poet: poet),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Şiirleri Gör',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

class PoetGridCard extends ConsumerWidget {
  final dynamic poet;
  final int index;

  const PoetGridCard({Key? key, required this.poet, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    // Color variations for accent elements
    final List<Color> accentColors = [
      const Color(0xFFE57373), // Red
      const Color(0xFF64B5F6), // Blue
      const Color(0xFF81C784), // Green
      const Color(0xFFFFD54F), // Amber
      const Color(0xFFBA68C8), // Purple
    ];

    final Color accentColor = accentColors[index % accentColors.length];
    final bgColor = isDarkMode ? const Color(0xFF2D2D3F) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

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
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar section with fixed height
            SizedBox(
              height: 110,
              child: Container(
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bgColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      image: poet.image != null && poet.image.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(poet.image),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: poet.image == null || poet.image.isEmpty
                        ? Center(
                            child: Text(
                              _getInitial(poet.name),
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // Compact info section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Name
                  Text(
                    poet.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Poem count badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${poet.poemCount} şiir",
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Button
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PoetDetailPage(poet: poet),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Şiirleri Gör',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_forward,
                          size: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitial(String name) {
    if (name.isEmpty) return "?";
    return name.substring(0, 1).toUpperCase();
  }
}
