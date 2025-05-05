import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/services/connectivity_service.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';
import 'package:poemapp/main.dart';

class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add a delay before showing connectivity banner on startup
    final connectionStatus = ref.watch(connectionStatusProvider);

    // Add this to prevent the banner from showing immediately on startup
    final startTime = ref.watch(appStartTimeProvider);
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final timeSinceStart = currentTime - startTime;

    // Only show the banner if we're more than 5 seconds into app startup
    // This prevents the banner from briefly flashing during initial connectivity check
    if (timeSinceStart < 5000) {
      return const SizedBox.shrink();
    }

    return connectionStatus.when(
      data: (status) {
        if (status == ConnectionStatus.online) {
          return const SizedBox.shrink(); // Hide banner when online
        }

        return _buildBanner(context, status, ref);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBanner(
      BuildContext context, ConnectionStatus status, WidgetRef ref) {
    Color backgroundColor;
    IconData icon;
    String message;
    bool showRetryButton = false;

    switch (status) {
      case ConnectionStatus.offline:
        backgroundColor = Colors.red.shade700;
        icon = Icons.wifi_off_rounded;
        message = 'İnternet bağlantısı yok';
        showRetryButton = true;
        break;
      case ConnectionStatus.weak:
        backgroundColor = Colors.orange.shade700;
        icon = Icons.signal_wifi_statusbar_connected_no_internet_4_rounded;
        message = 'Zayıf internet bağlantısı';
        showRetryButton = true;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Animate(
      effects: const [
        SlideEffect(
            begin: Offset(0, -1),
            end: Offset(0, 0),
            duration: Duration(milliseconds: 400),
            curve: Curves.easeOutBack),
        FadeEffect(begin: 0, end: 1, duration: Duration(milliseconds: 400)),
      ],
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            if (showRetryButton)
              ElevatedButton(
                onPressed: () {
                  // Trigger a retry
                  ref.read(connectivityServiceProvider).checkConnectivity();

                  // If we've determined there's connectivity, refresh the data
                  // but use try-catch to handle potential state changes
                  if (status != ConnectionStatus.offline) {
                    try {
                      // Store notifier reference before the state might change
                      final refreshNotifier =
                          ref.read(refreshDataProvider.notifier);
                      refreshNotifier.state = true;
                    } catch (e) {
                      print("❌ Error refreshing data from banner: $e");
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('Tekrar Dene'),
              ),
          ],
        ),
      ),
    );
  }
}
