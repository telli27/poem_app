import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poemapp/core/theme/app_theme.dart';
import 'package:poemapp/core/theme/theme_provider.dart';
import 'package:poemapp/features/main/presentation/pages/main_page.dart';
import 'package:poemapp/services/favorites_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await FavoritesService.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ThemeMode provider'ı dinle
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Türk Şiirleri',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainPage(),
    );
  }
}
