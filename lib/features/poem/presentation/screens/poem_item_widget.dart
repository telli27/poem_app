import 'package:flutter/material.dart';
import 'package:poemapp/models/poem.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';

class PoemItemWidget extends ConsumerWidget {
  final Poem poem;
  final Color textColor;
  final Color accentColor;

  const PoemItemWidget({
    Key? key,
    required this.poem,
    required this.textColor,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Şair bilgisini getir
    final poetsAsync = ref.watch(poetProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quote icon
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.format_quote,
            color: accentColor,
            size: 20,
          ),
        ),

        // Title
        Text(
          poem.name,
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 20),

        // Author and date
        Row(
          children: [
            Container(
              width: 4,
              height: 30,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ID yerine şair adını gösteriyoruz
                poetsAsync.when(
                  data: (poets) {
                    // Eğer poetId bir şair adıysa (favori sayfasından geliyorsa), direkt göster
                    if (!poem.poetId.contains('_') &&
                        !poem.poetId.startsWith('p')) {
                      return Text(
                        poem.poetId, // Bu durumda poetId aslında şairin adını içeriyor
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }

                    // Normal ID'yi şair adına çevirme
                    try {
                      final poet = poets.firstWhere(
                        (p) => p.id == poem.poetId,
                        orElse: () => throw Exception('Şair bulunamadı'),
                      );
                      return Text(
                        poet.name, // Şairin adını göster
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    } catch (e) {
                      // Şair bulunamadıysa poetId'yi göster
                      return Text(
                        poem.poetId,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }
                  },
                  loading: () => Text(
                    "Yükleniyor...",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  error: (_, __) => Text(
                    "Şair bilgisi alınamadı",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (poem.year != null)
                  Text(
                    poem.year!,
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
