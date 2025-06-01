import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/models/poem.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:poemapp/features/poem/presentation/pages/poem_detail_page.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';
import 'package:poemapp/providers/ad_service_provider.dart';

class PoemCard extends ConsumerWidget {
  final Poem poem;

  const PoemCard({
    super.key,
    required this.poem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Preload interstitial ad before navigation
          ref.read(adServiceProvider.notifier).loadInterstitialAd();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PoemDetailPage(
                poem: poem,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          poem.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          poem.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: poem.isFavorite
                              ? Theme.of(context).colorScheme.tertiary
                              : null,
                        ),
                        onPressed: () {
                          // TODO: Implement favorite functionality
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<String>(
                      future: _getPoetName(ref, poem.poetId),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? "Yükleniyor...",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        );
                      }),
                  if (poem.year != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      poem.year!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    poem.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  if (poem.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: poem.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideY(
        begin: 0.1, end: 0, duration: const Duration(milliseconds: 300));
  }

  // Helper method to get poet name from poetId
  Future<String> _getPoetName(WidgetRef ref, String poetId) async {
    final poetsAsync = await ref.watch(poetProvider.future);
    final poet = poetsAsync.firstWhere(
      (p) => p.id == poetId,
      orElse: () => throw Exception('Şair bulunamadı: $poetId'),
    );
    return poet.name;
  }
}
