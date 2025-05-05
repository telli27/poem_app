import 'package:flutter/material.dart';
import 'package:poemapp/models/poem.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';

class PoemItemWidget extends ConsumerWidget {
  final Poem poem;
  final Color textColor;
  final Color accentColor;
  final bool
      hidePoetId; // Bu parametre ile UUID'yi gizleyip sadece şair adını gösterme seçeneği

  const PoemItemWidget({
    Key? key,
    required this.poem,
    required this.textColor,
    required this.accentColor,
    this.hidePoetId = false, // Varsayılan olarak UUID'yi gösteriyoruz
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
                // Year display (moved up)
                if (poem.year != null)
                  Text(
                    poem.year!,
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                // Add a tiny space between year and poet name
                if (poem.year != null) const SizedBox(height: 2),

                // Şair adını gösteriyoruz, ID'yi değil
                poetsAsync.when(
                  data: (poets) {
                    // Şair adını bulma mantığı
                    if (_isUuid(poem.poetId)) {
                      // UUID ise, şair adını bulmayı dene
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
                        // Şair bulunamazsa, varsayılan bir ad göster
                        return Text(
                          "Şair", // Genel bir ifade
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }
                    } else {
                      // UUID değilse, doğrudan poetId'yi göster (bu durumda şair adı olmalı)
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
                    "Şair",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // UUID formatında mı kontrol eden yardımcı metod
  bool _isUuid(String text) {
    // UUID formatları genellikle şunları içerir:
    // - 32-36 karakter uzunluğunda
    // - Tire (-) karakteri içerir
    // - Alfanümerik karakterlerden oluşur
    return text.length > 20 || text.contains('-');
  }
}
