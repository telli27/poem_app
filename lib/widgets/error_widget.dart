import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';

class ErrorDisplayWidget extends ConsumerWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const ErrorDisplayWidget({
    super.key,
    this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.red.shade400,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Veriler yüklenemedi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Refresh flag'ini ayarla
                try {
                  ref.read(refreshDataProvider.notifier).state = true;
                } catch (e) {
                  print("❌ Error updating refresh flag: $e");
                }

                // Callback'i çağır
                onRetry();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
