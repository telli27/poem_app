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
import 'dart:ui';

// Seçili tab için durum yönetimi
enum TabSelection { discover, popular, newest }

final selectedTabProvider =
    StateProvider<TabSelection>((ref) => TabSelection.discover);
final searchOpenProvider = StateProvider<bool>((ref) => false);
final searchTermProvider = StateProvider<String>((ref) => '');

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poets = ref.watch(poetProvider);
    final size = MediaQuery.of(context).size;
    final selectedTab = ref.watch(selectedTabProvider);
    final isSearchOpen = ref.watch(searchOpenProvider);
    final searchTerm = ref.watch(searchTermProvider);

    return Scaffold(
      backgroundColor: ref.watch(themeModeProvider) == ThemeMode.dark
          ? const Color(0xFF1E1E2C) // Dark theme background
          : Colors.white, // Light theme background
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
                    decoration: BoxDecoration(
                      color: ref.watch(themeModeProvider) == ThemeMode.dark
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
                              color: const Color(0xFFE57373).withOpacity(0.15),
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
                              color: const Color(0xFF64B5F6).withOpacity(0.1),
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
                                        Text(
                                          "ŞiirArt",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                ref.watch(themeModeProvider) ==
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
                                                    .read(searchOpenProvider
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
                                                          .withOpacity(0.1)
                                                      : Colors.black
                                                          .withOpacity(0.05),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
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
                                                    .read(themeModeProvider
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
                                                          .withOpacity(0.1)
                                                      : Colors.black
                                                          .withOpacity(0.05),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
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
                                            color:
                                                ref.watch(themeModeProvider) ==
                                                        ThemeMode.dark
                                                    ? Colors.white
                                                    : Colors.black),
                                        onChanged: (value) {
                                          ref
                                              .read(searchTermProvider.notifier)
                                              .state = value;
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Şair veya şiir ara...',
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
                                              ? Colors.white.withOpacity(0.1)
                                              : Colors.black.withOpacity(0.05),
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
                                        padding: const EdgeInsets.fromLTRB(
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
                                                  fontWeight: FontWeight.w900,
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

                                  // Tab Selection
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        30, 20, 30, 30),
                                    height: 40,
                                    child: Row(
                                      children: [
                                        _buildTab(
                                            "Keşfet",
                                            selectedTab ==
                                                TabSelection.discover,
                                            () => ref
                                                .read(selectedTabProvider
                                                    .notifier)
                                                .state = TabSelection.discover),
                                        _buildTab(
                                            "Popüler",
                                            selectedTab == TabSelection.popular,
                                            () => ref
                                                .read(selectedTabProvider
                                                    .notifier)
                                                .state = TabSelection.popular),
                                        _buildTab(
                                            "Yeni",
                                            selectedTab == TabSelection.newest,
                                            () => ref
                                                .read(selectedTabProvider
                                                    .notifier)
                                                .state = TabSelection.newest),
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

          // Search Results (only show when search is active and has query)
          if (isSearchOpen && searchTerm.isNotEmpty)
            _buildSearchResults(ref, searchTerm),

          // Regular content (hidden during search with results)
          if (!isSearchOpen || searchTerm.isEmpty) ...[
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
                      Text(
                        selectedTab == TabSelection.discover
                            ? "Öne Çıkan Şairler"
                            : selectedTab == TabSelection.popular
                                ? "Popüler Şairler"
                                : "Yeni Eklenen Şairler",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ref.watch(themeModeProvider) == ThemeMode.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Tüm şairleri göster
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  _buildAllPoetsPage(context, ref, selectedTab),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF4A5BCC),
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

            // Featured Poets Carousel (filtered by selected tab)
            poets.when(
              data: (poets) {
                // Filtre uygula
                final filteredPoets = _filterPoetsByTab(poets, selectedTab);

                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 320,
                    child: filteredPoets.isEmpty
                        ? Center(
                            child: Text(
                              'Bu kategoride şair bulunamadı',
                              style: TextStyle(
                                  color: ref.watch(themeModeProvider) ==
                                          ThemeMode.dark
                                      ? Colors.white70
                                      : Colors.black54),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding:
                                const EdgeInsets.only(left: 30, bottom: 20),
                            itemCount: filteredPoets.length >= 5
                                ? 5
                                : filteredPoets.length,
                            itemBuilder: (context, index) {
                              return Animate(
                                effects: [
                                  FadeEffect(
                                    delay: Duration(
                                        milliseconds: 300 + index * 100),
                                    duration: const Duration(milliseconds: 800),
                                  ),
                                  SlideEffect(
                                    delay: Duration(
                                        milliseconds: 300 + index * 100),
                                    duration: const Duration(milliseconds: 800),
                                    begin: const Offset(0.3, 0),
                                    end: const Offset(0, 0),
                                  ),
                                ],
                                child: FeaturePoetCard(
                                    poet: filteredPoets[index], index: index),
                              );
                            },
                          ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(
                      color: Color(0xFF4A5BCC),
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
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => ref.refresh(poetProvider),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF4A5BCC),
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
                      Text(
                        "Tüm Şairler",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ref.watch(themeModeProvider) == ThemeMode.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showFilterDialog(context, ref),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                ref.watch(themeModeProvider) == ThemeMode.dark
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_list,
                                color: ref.watch(themeModeProvider) ==
                                        ThemeMode.dark
                                    ? Colors.white54
                                    : Colors.black54,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Filtrele',
                                style: TextStyle(
                                  color: ref.watch(themeModeProvider) ==
                                          ThemeMode.dark
                                      ? Colors.white54
                                      : Colors.black54,
                                  fontSize: 13,
                                ),
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

            // All Poets Grid (filtered by selected tab)
            poets.when(
              data: (poets) {
                // Filtre uygula
                final filteredPoets = _filterPoetsByTab(poets, selectedTab);

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                          child: PoetGridCard(
                              poet: filteredPoets[index], index: index),
                        );
                      },
                      childCount: filteredPoets.length,
                    ),
                  ),
                );
              },
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
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
                          poet.biography
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
                          poem.title
                              .toLowerCase()
                              .contains(query.toLowerCase()) ||
                          poem.content
                              .toLowerCase()
                              .contains(query.toLowerCase()) ||
                          poem.author
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
                            poem.title,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            poem.author,
                            style:
                                TextStyle(color: Colors.black.withOpacity(0.7)),
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

  // Sekme seçimlerine göre şairleri filtrele
  List<dynamic> _filterPoetsByTab(List<dynamic> poets, TabSelection tab) {
    switch (tab) {
      case TabSelection.popular:
        // Popüler olanları göster (şimdilik notableWorks sayısına göre)
        return List.from(poets)
          ..sort(
              (a, b) => b.notableWorks.length.compareTo(a.notableWorks.length));
      case TabSelection.newest:
        // Yeni eklenenler (bu örnekte doğum yılı yeni olanları gösterelim)
        return List.from(poets)
          ..sort((a, b) {
            // İlk doğum tarihlerine sayısal olarak dönüştürmeye çalış
            final aBirth = int.tryParse(a.birthDate.split(' ').last) ?? 0;
            final bBirth = int.tryParse(b.birthDate.split(' ').last) ?? 0;
            return bBirth.compareTo(aBirth); // Daha yeni doğanlar önce
          });
      case TabSelection.discover:
      default:
        // Varsayılan sıralama
        return poets;
    }
  }

  Widget _buildTab(String label, bool isSelected, VoidCallback onTap) {
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
  }

  // Tüm şairleri gösteren sayfa
  Widget _buildAllPoetsPage(
      BuildContext context, WidgetRef ref, TabSelection currentTab) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
      appBar: AppBar(
        title: Text(currentTab == TabSelection.discover
            ? "Keşfedilen Şairler"
            : currentTab == TabSelection.popular
                ? "Popüler Şairler"
                : "Yeni Eklenen Şairler"),
        backgroundColor: isDarkMode ? const Color(0xFF2D2D3F) : Colors.white,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, ref),
          ),
        ],
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
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${poet.birthDate} - ${poet.deathDate}',
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.7),
                                      fontSize: 14,
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
                                              '${poet.notableWorks.length} şiir',
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
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black54,
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
  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF2D2D3F) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Filtreleme Seçenekleri',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ref.watch(themeModeProvider) == ThemeMode.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Filter options
                  Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ref.watch(themeModeProvider) == ThemeMode.dark
                          ? Colors.white54
                          : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: TabSelection.values.map((tab) {
                      final isSelected = ref.read(selectedTabProvider) == tab;

                      return GestureDetector(
                        onTap: () {
                          ref.read(selectedTabProvider.notifier).state = tab;
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF4A5BCC)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tab == TabSelection.discover
                                ? 'Keşfet'
                                : tab == TabSelection.popular
                                    ? 'Popüler'
                                    : 'Yeni',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black.withOpacity(0.7),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF4A5BCC),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Uygula',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
          color: Colors.white,
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
                                fontSize: 15,
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
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
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
        color: Colors.white,
        child: Center(
          child: Icon(
            Icons.format_quote,
            size: 50,
            color: Colors.black.withOpacity(0.2),
          ),
        ),
      );
    } else {
      // Regular network image
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.white,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black38,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.white,
          child: Center(
            child: Icon(
              Icons.format_quote,
              size: 50,
              color: Colors.black.withOpacity(0.2),
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
          color: Colors.white,
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
                              Colors.grey.withOpacity(0.9),
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
                          color: Colors.black,
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
                          color: Colors.black.withOpacity(0.6),
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
