import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/core/theme/theme_provider.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';
import 'package:poemapp/services/connectivity_service.dart';

class LoadingStateWidget extends ConsumerWidget {
  final AsyncValue state;
  final VoidCallback onRetry;
  final String loadingMessage;
  final String errorMessage;

  const LoadingStateWidget({
    required this.state,
    required this.onRetry,
    this.loadingMessage = 'Veriler yükleniyor...',
    this.errorMessage = 'Veriler yüklenemedi',
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final connectionStatus = ref.watch(connectionStatusProvider);

    return Center(
      child: state.when(
        data: (_) => const SizedBox
            .shrink(), // Should not be visible when data is loaded
        loading: () => _buildLoadingState(isDarkMode),
        error: (error, _) => connectionStatus.when(
          data: (status) =>
              _buildErrorState(context, isDarkMode, status, error.toString()),
          loading: () => _buildErrorState(
              context, isDarkMode, ConnectionStatus.offline, error.toString()),
          error: (_, __) => _buildErrorState(
              context, isDarkMode, ConnectionStatus.offline, error.toString()),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 400)),
      ],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: const Color(0xFFE57373),
            backgroundColor: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
          const SizedBox(height: 24),
          Text(
            loadingMessage,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    bool isDarkMode,
    ConnectionStatus connectionStatus,
    String errorDetails,
  ) {
    String message = errorMessage;
    IconData iconData = Icons.error_outline_rounded;
    Color iconColor = Colors.red.shade700;
    bool showAutoReloadMessage = false;

    // Customize message based on connection status
    if (connectionStatus == ConnectionStatus.offline) {
      message =
          'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin ve tekrar deneyin.';
      iconData = Icons.wifi_off_rounded;
      showAutoReloadMessage = true;
    } else if (connectionStatus == ConnectionStatus.weak) {
      message = 'Zayıf internet bağlantısı. Verileri yükleyemedik.';
      iconData = Icons.signal_wifi_statusbar_connected_no_internet_4_rounded;
      iconColor = Colors.orange.shade700;
    }

    // If error details contains specific message about auto-reload
    if (errorDetails.contains('Bağlantı kurulduğunda') ||
        errorDetails.contains('otomatik olarak yüklenecek')) {
      showAutoReloadMessage = true;
    }

    // Check for specific Android network errors
    if (errorDetails.contains('SocketException') ||
        errorDetails.contains('HandshakeException')) {
      message =
          'Ağ bağlantısı hatası. Mobil veri veya Wi-Fi bağlantınızı kontrol edin.';
      iconData = Icons.signal_wifi_connected_no_internet_4_rounded;
    } else if (errorDetails.contains('timed out')) {
      message =
          'Bağlantı zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin.';
      iconData = Icons.timer_off_rounded;
    }

    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 400)),
      ],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: iconColor,
            size: 64,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (showAutoReloadMessage)
            Padding(
              padding: const EdgeInsets.only(
                  top: 16.0, left: 32.0, right: 32.0, bottom: 8.0),
              child: Text(
                'Bağlantı kurulduğunda veriler otomatik olarak yüklenecek.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tekrar Dene'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: iconColor,
                width: 1.5,
              ),
              foregroundColor: iconColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          if (errorDetails.isNotEmpty &&
              !errorDetails.contains('İnternet bağlantısı yok') &&
              !errorDetails.contains('Bağlantı kurulduğunda') &&
              !errorDetails.contains('SocketException') &&
              !errorDetails.contains('timed out') &&
              !errorDetails.contains('HandshakeException') &&
              errorDetails != 'Exception: Failed to load poets')
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'Hata Detayı: $errorDetails',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
