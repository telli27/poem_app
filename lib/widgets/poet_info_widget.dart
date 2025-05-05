import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';
import 'package:poemapp/features/home/providers/poem_provider.dart';
import 'package:poemapp/core/theme/theme_provider.dart';

class PoetInfoWidget extends ConsumerWidget {
  const PoetInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poetInfoAsync = ref.watch(poetInfoProvider);
    final poemInfoAsync = ref.watch(poemInfoProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Poet Info
        poetInfoAsync.when(
          data: (poetInfo) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${poetInfo['count']} şair',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        // Poem Info
        poemInfoAsync.when(
          data: (poemInfo) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 16,
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${poemInfo['count']} şiir',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
