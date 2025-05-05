import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/core/theme/theme_provider.dart';
import 'package:poemapp/features/favorites/presentation/pages/favorites_page.dart';
import 'package:poemapp/features/home/presentation/pages/home_page.dart';
import 'package:poemapp/widgets/startup_loading_overlay.dart';

// Provider to keep track of current tab
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTabIndex = ref.watch(selectedTabIndexProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    // Define colors
    final bgColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;
    final navBarColor = isDarkMode ? const Color(0xFF2D2D3F) : Colors.white;
    final selectedItemColor = const Color(0xFFE57373);
    final unselectedItemColor =
        isDarkMode ? Colors.white.withOpacity(0.6) : Colors.black54;

    // List of pages
    final pages = [
      const HomePage(),
      const FavoritesPage(),
    ];

    return Stack(
      children: [
        Scaffold(
          backgroundColor: bgColor,
          body: pages[selectedTabIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: navBarColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context: context,
                      icon: Icons.home_rounded,
                      label: 'Ana Sayfa',
                      index: 0,
                      selectedIndex: selectedTabIndex,
                      selectedColor: selectedItemColor,
                      unselectedColor: unselectedItemColor,
                      onTap: (index) {
                        ref.read(selectedTabIndexProvider.notifier).state =
                            index;
                      },
                    ),
                    _buildNavItem(
                      context: context,
                      icon: Icons.favorite_rounded,
                      label: 'Favoriler',
                      index: 1,
                      selectedIndex: selectedTabIndex,
                      selectedColor: selectedItemColor,
                      unselectedColor: unselectedItemColor,
                      onTap: (index) {
                        ref.read(selectedTabIndexProvider.notifier).state =
                            index;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Overlay the startup loading indicator
        const StartupLoadingOverlay(),
      ],
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required int selectedIndex,
    required Color selectedColor,
    required Color unselectedColor,
    required Function(int) onTap,
  }) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? selectedColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? selectedColor : unselectedColor,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selectedColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
