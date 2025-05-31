import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:poemapp/providers/daily_poem_provider.dart';
import 'package:poemapp/core/theme/theme_provider.dart';
import 'package:poemapp/features/poem/presentation/pages/poem_detail_page.dart';
import 'package:poemapp/models/poem.dart';
import 'package:poemapp/services/daily_poem_service.dart';
import 'package:poemapp/services/notification_service.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';

class PoemCalendarPage extends ConsumerStatefulWidget {
  const PoemCalendarPage({super.key});

  @override
  ConsumerState<PoemCalendarPage> createState() => _PoemCalendarPageState();
}

class _PoemCalendarPageState extends ConsumerState<PoemCalendarPage> {
  DateTime selectedDate = DateTime.now();
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final dailyPoemsAsync = ref.watch(dailyPoemsCalendarProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    final bgColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;
    final cardColor =
        isDarkMode ? const Color(0xFF2D2D3F) : const Color(0xFFF8F9FA);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final accentColor = const Color(0xFFE57373);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Şiir Takvimi",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: dailyPoemsAsync.when(
        data: (dailyPoems) => _buildCalendarContent(
          dailyPoems,
          cardColor,
          textColor,
          accentColor,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: textColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                "Takvim yüklenirken bir hata oluştu",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(dailyPoemsCalendarProvider);
                },
                child: const Text("Tekrar Dene"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarContent(
    Map<String, Poem> dailyPoems,
    Color cardColor,
    Color textColor,
    Color accentColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section
          Animate(
            effects: const [
              FadeEffect(duration: Duration(milliseconds: 600)),
              SlideEffect(
                  begin: Offset(0, 0.3), duration: Duration(milliseconds: 600)),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "📅 Geçmiş Şiirler",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Daha önce okuduğunuz günlük şiirleri görüntüleyin",
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Calendar Header
          Animate(
            effects: const [
              FadeEffect(
                  duration: Duration(milliseconds: 600),
                  delay: Duration(milliseconds: 200)),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedDate = DateTime(
                          selectedDate.year,
                          selectedDate.month - 1,
                          selectedDate.day,
                        );
                      });
                    },
                    icon: Icon(
                      Icons.chevron_left,
                      color: textColor,
                    ),
                  ),
                  Text(
                    _getMonthYearString(selectedDate),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: selectedDate.month < DateTime.now().month ||
                            selectedDate.year < DateTime.now().year
                        ? () {
                            setState(() {
                              selectedDate = DateTime(
                                selectedDate.year,
                                selectedDate.month + 1,
                                selectedDate.day,
                              );
                            });
                          }
                        : null,
                    icon: Icon(
                      Icons.chevron_right,
                      color: selectedDate.month < DateTime.now().month ||
                              selectedDate.year < DateTime.now().year
                          ? textColor
                          : textColor.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Calendar Grid
          Animate(
            effects: const [
              FadeEffect(
                  duration: Duration(milliseconds: 600),
                  delay: Duration(milliseconds: 400)),
            ],
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Week days header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz']
                        .map((day) => Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: textColor.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),

                  // Calendar days
                  ..._buildCalendarRows(dailyPoems, textColor, accentColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Schedule Reminder Section
          Animate(
            effects: const [
              FadeEffect(
                  duration: Duration(milliseconds: 600),
                  delay: Duration(milliseconds: 600)),
              SlideEffect(
                  begin: Offset(0, 0.3),
                  duration: Duration(milliseconds: 600),
                  delay: Duration(milliseconds: 600)),
            ],
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.schedule_send,
                          color: Colors.purple,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Özel Hatırlatıcı",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Belirli bir tarihe hatırlatıcı zamanla",
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _scheduleCustomReminder,
                      icon: const Icon(Icons.add_alarm),
                      label: const Text("Hatırlatıcı Zamanla"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Recent poems list
          if (dailyPoems.isNotEmpty) ...[
            Animate(
              effects: const [
                FadeEffect(
                    duration: Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 600)),
              ],
              child: Text(
                "Son Şiirler",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ..._buildRecentPoemsList(
                dailyPoems, cardColor, textColor, accentColor),
          ] else ...[
            Animate(
              effects: const [
                FadeEffect(
                    duration: Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 600)),
              ],
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 64,
                      color: textColor.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Henüz hiç günlük şiir okumadiniz",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Günlük şiir okumaya başlayın ve takvimde görüntüleyin",
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildCalendarRows(
    Map<String, Poem> dailyPoems,
    Color textColor,
    Color accentColor,
  ) {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday - 1; // Monday = 0
    final daysInMonth = lastDayOfMonth.day;

    List<Widget> rows = [];
    List<Widget> currentRow = [];

    // Add empty cells for days before the first day of month
    for (int i = 0; i < firstWeekday; i++) {
      currentRow.add(const SizedBox(width: 40, height: 40));
    }

    // Add actual days
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(selectedDate.year, selectedDate.month, day);
      final dateKey = _getDateKey(date);
      final hasPoem = dailyPoems.containsKey(dateKey);
      final isToday = _isToday(date);
      final isFuture = date.isAfter(DateTime.now());

      currentRow.add(
        GestureDetector(
          onTap: hasPoem && !isFuture
              ? () {
                  final poem = dailyPoems[dateKey]!;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PoemDetailPage(poem: poem),
                    ),
                  );
                }
              : null,
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: hasPoem
                  ? accentColor.withOpacity(0.2)
                  : isToday
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isToday
                  ? Border.all(color: Colors.blue, width: 2)
                  : hasPoem
                      ? Border.all(color: accentColor, width: 1)
                      : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isFuture
                          ? textColor.withOpacity(0.3)
                          : hasPoem
                              ? accentColor
                              : isToday
                                  ? Colors.blue
                                  : textColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (hasPoem)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );

      if (currentRow.length == 7) {
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.from(currentRow),
            ),
          ),
        );
        currentRow.clear();
      }
    }

    // Add empty cells for remaining days
    while (currentRow.length < 7) {
      currentRow.add(const SizedBox(width: 40, height: 40));
    }

    if (currentRow.isNotEmpty) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.from(currentRow),
          ),
        ),
      );
    }

    return rows;
  }

  List<Widget> _buildRecentPoemsList(
    Map<String, Poem> dailyPoems,
    Color cardColor,
    Color textColor,
    Color accentColor,
  ) {
    final sortedEntries = dailyPoems.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key)); // Sort by date descending

    return sortedEntries.take(5).map((entry) {
      final date = DateTime.parse(entry.key.replaceAll('-', ''));
      final poem = entry.value;

      return Animate(
        effects: const [
          FadeEffect(duration: Duration(milliseconds: 400)),
          SlideEffect(
              begin: Offset(0, 0.2), duration: Duration(milliseconds: 400)),
        ],
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PoemDetailPage(poem: poem),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_stories,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poem.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Consumer(
                          builder: (context, ref, child) {
                            final poetsAsync = ref.watch(poetProvider);
                            return poetsAsync.when(
                              data: (poets) {
                                try {
                                  final poet = poets.firstWhere(
                                    (p) => p.id == poem.poetId,
                                  );
                                  return Text(
                                    poet.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: accentColor,
                                    ),
                                  );
                                } catch (e) {
                                  // Şair bulunamazsa, genel bir ifade göster
                                  return Text(
                                    "Anonim",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: accentColor,
                                    ),
                                  );
                                }
                              },
                              loading: () => Text(
                                "Yükleniyor...",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: accentColor.withOpacity(0.6),
                                ),
                              ),
                              error: (_, __) => Text(
                                "Anonim",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: accentColor,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDateForList(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: textColor.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  String _getMonthYearString(DateTime date) {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDateForList(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Bugün';
    } else if (difference == 1) {
      return 'Dün';
    } else if (difference < 7) {
      return '$difference gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _scheduleCustomReminder() async {
    // 1. Pick a date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: ref.watch(themeModeProvider) == ThemeMode.dark
                  ? const Color(0xFF2D2D3F)
                  : Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    // 2. Pick a time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: ref.watch(themeModeProvider) == ThemeMode.dark
                  ? const Color(0xFF2D2D3F)
                  : Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    // 3. Combine date and time
    final scheduledDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // 4. Check if the datetime is in the future
    if (scheduledDateTime.isBefore(DateTime.now())) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Geçmiş bir tarih seçemezsiniz!"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      // 5. Schedule the notification
      await NotificationService.addReminder(
        title: "📖 Şiir Hatırlatıcısı",
        body:
            "Zamanladığınız şiir hatırlatıcısı! Bugün güzel bir şiir okumaya ne dersiniz?",
        scheduledDate: scheduledDateTime,
        type: "poem_reminder",
      );

      if (mounted) {
        final formattedDate =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
        final formattedTime =
            "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "✅ Hatırlatıcı zamanlandı!\n📅 $formattedDate saat $formattedTime"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Hatırlatıcı zamanlanamadı: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
