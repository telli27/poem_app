import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/core/theme/theme_provider.dart';
import 'package:poemapp/features/favorites/presentation/pages/favorites_page.dart';
import 'package:poemapp/features/home/presentation/pages/home_page.dart';
import 'package:poemapp/features/daily_poem/presentation/pages/daily_poem_page.dart';
import 'package:poemapp/widgets/startup_loading_overlay.dart';

// Provider to keep track of current tab
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTabIndex = ref.watch(selectedTabIndexProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    // Define colors with improved gradient schemes
    final bgColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;

    // List of pages
    final pages = [
      const HomePage(),
      const DailyPoemPage(),
      const FavoritesPage(),
    ];

    return Stack(
      children: [
        Scaffold(
          backgroundColor: bgColor,
          body: pages[selectedTabIndex],
          bottomNavigationBar: _buildModernBottomNavBar(
            context,
            ref,
            selectedTabIndex,
            isDarkMode,
          ),
        ),

        // Overlay the startup loading indicator
        const StartupLoadingOverlay(),
      ],
    );
  }

  Widget _buildModernBottomNavBar(
    BuildContext context,
    WidgetRef ref,
    int selectedTabIndex,
    bool isDarkMode,
  ) {
    return SafeArea(
      minimum: EdgeInsets.zero,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF2D2D3F).withOpacity(0.95),
                    const Color(0xFF1E1E2C).withOpacity(0.95),
                  ]
                : [
                    Colors.white.withOpacity(0.95),
                    const Color(0xFFFAFAFA).withOpacity(0.95),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.4)
                  : Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: isDarkMode
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.08),
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAnimatedNavItem(
                  context: context,
                  ref: ref,
                  icon: Icons.home_rounded,
                  label: 'Ana Sayfa',
                  index: 0,
                  selectedIndex: selectedTabIndex,
                  isDarkMode: isDarkMode,
                ),
                _buildAnimatedNavItem(
                  context: context,
                  ref: ref,
                  icon: Icons.auto_stories_rounded,
                  label: 'Günün Şiiri',
                  index: 1,
                  selectedIndex: selectedTabIndex,
                  isDarkMode: isDarkMode,
                ),
                _buildAnimatedNavItem(
                  context: context,
                  ref: ref,
                  icon: Icons.favorite_rounded,
                  label: 'Favoriler',
                  index: 2,
                  selectedIndex: selectedTabIndex,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedNavItem({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required int index,
    required int selectedIndex,
    required bool isDarkMode,
  }) {
    final isSelected = selectedIndex == index;

    // Define gradient colors for selected state - calming purple-blue tones
    final gradientColors = [
      const Color(0xFF7986CB), // Soft blue-purple
      const Color(0xFF5C6BC0), // Medium blue-purple
      const Color(0xFF3F51B5), // Deep blue-purple
    ];

    final unselectedColor = isDarkMode
        ? Colors.white.withOpacity(0.65)
        : Colors.black.withOpacity(0.65);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: gradientColors[0].withOpacity(0.2),
          highlightColor: gradientColors[0].withOpacity(0.1),
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(selectedTabIndexProvider.notifier).state = index;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.all(isSelected ? 7 : 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              gradientColors[0].withOpacity(0.2),
                              gradientColors[1].withOpacity(0.15),
                              gradientColors[2].withOpacity(0.1),
                            ],
                          )
                        : null,
                    border: isSelected
                        ? Border.all(
                            color: gradientColors[0].withOpacity(0.3),
                            width: 0.5,
                          )
                        : null,
                  ),
                  child: isSelected
                      ? ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: gradientColors,
                          ).createShader(bounds),
                          child: Icon(
                            icon,
                            size: 20,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          icon,
                          size: 18,
                          color: unselectedColor,
                        ),
                ),

                // Label
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    fontSize: isSelected ? 9.5 : 8.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                  child: isSelected
                      ? ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: gradientColors,
                          ).createShader(bounds),
                          child: Text(
                            label,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : Text(
                          label,
                          style: TextStyle(color: unselectedColor),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
