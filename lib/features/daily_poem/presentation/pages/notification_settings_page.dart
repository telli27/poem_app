import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:poemapp/providers/daily_poem_provider.dart';
import 'package:poemapp/core/theme/theme_provider.dart';
import 'package:poemapp/services/daily_poem_service.dart';
import 'package:poemapp/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  TimeOfDay? selectedTime;
  bool? systemPermissionGranted;
  bool isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkSystemPermission();
  }

  Future<void> _checkSystemPermission() async {
    setState(() {
      isCheckingPermission = true;
    });

    try {
      final hasPermission =
          await DailyPoemService.checkNotificationPermission();
      setState(() {
        systemPermissionGranted = hasPermission;
        isCheckingPermission = false;
      });
      print("📱 System permission check result: $hasPermission");
    } catch (e) {
      print("❌ Permission check error: $e");
      setState(() {
        systemPermissionGranted = false;
        isCheckingPermission = false;
      });
    }
  }

  Future<void> _requestSystemPermission() async {
    try {
      final granted = await DailyPoemService.requestNotificationPermission();
      setState(() {
        systemPermissionGranted = granted;
      });

      if (granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Bildirim izni verildi!"),
            backgroundColor: Colors.green,
          ),
        );
        // Auto-enable notifications when permission is granted
        ref
            .read(notificationSettingsNotifierProvider.notifier)
            .toggleNotifications(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "❌ Bildirim izni reddedildi. Lütfen ayarlardan manuel olarak açın."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print("❌ Permission request error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ İzin isteği hatası: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openAppSettings() async {
    try {
      // permission_handler kullanarak uygulama ayarlarını aç
      await openAppSettings();

      // Ayarlardan dönüşte izin durumunu kontrol et
      Future.delayed(const Duration(seconds: 2), () {
        _checkSystemPermission();
      });
    } catch (e) {
      print("❌ App settings error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Lütfen telefon ayarlarından bildirim izinlerini kontrol edin"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(notificationSettingsNotifierProvider);
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
          "Bildirim Ayarları",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: _checkSystemPermission,
          ),
        ],
      ),
      body: isCheckingPermission
          ? const Center(child: CircularProgressIndicator())
          : settingsAsync.when(
              data: (settings) => _buildSettingsContent(
                settings,
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
                      "Ayarlar yüklenirken bir hata oluştu",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(notificationSettingsNotifierProvider);
                      },
                      child: const Text("Tekrar Dene"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSettingsContent(
    Map<String, dynamic> settings,
    Color cardColor,
    Color textColor,
    Color accentColor,
  ) {
    final isEnabled = settings['enabled'] as bool;
    final timeMap = settings['time'] as Map<String, int>;
    final hour = timeMap['hour']!;
    final minute = timeMap['minute']!;

    // Sistem izni yoksa uygulama ayarı da kapalı olmalı
    final canToggle = systemPermissionGranted == true;
    final showPermissionWarning = systemPermissionGranted == false;

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
                  "📱 Günlük Bildirimler",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Her gün aynı saatte yeni bir şiir bildirimi alın",
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Permission Warning Card
          if (showPermissionWarning) ...[
            Animate(
              effects: const [
                FadeEffect(
                    duration: Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 100)),
                SlideEffect(
                    begin: Offset(0, 0.3),
                    duration: Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 100)),
              ],
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.2),
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
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.warning,
                            color: Colors.orange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "⚠️ Bildirim İzni Gerekli",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Bildirim almak için sistem iznine ihtiyaç var",
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _requestSystemPermission,
                            icon: const Icon(Icons.notifications),
                            label: const Text("İzin Ver"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openAppSettings,
                            icon: const Icon(Icons.settings),
                            label: const Text("Ayarlar"),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.orange),
                              foregroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Enable/Disable Toggle
          Animate(
            effects: const [
              FadeEffect(
                  duration: Duration(milliseconds: 600),
                  delay: Duration(milliseconds: 200)),
              SlideEffect(
                  begin: Offset(0, 0.3),
                  duration: Duration(milliseconds: 600),
                  delay: Duration(milliseconds: 200)),
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
                  Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: (canToggle ? accentColor : Colors.grey)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          canToggle
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                          color: canToggle ? accentColor : Colors.grey,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bildirimleri Etkinleştir",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: canToggle
                                    ? textColor
                                    : textColor.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              canToggle
                                  ? (isEnabled
                                      ? "Bildirimler açık"
                                      : "Bildirimler kapalı")
                                  : "Sistem izni gerekli",
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: canToggle && isEnabled,
                        onChanged: canToggle
                            ? (value) {
                                ref
                                    .read(notificationSettingsNotifierProvider
                                        .notifier)
                                    .toggleNotifications(value);
                              }
                            : null,
                        activeColor: accentColor,
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey.withOpacity(0.3),
                      ),
                    ],
                  ),
                  if (!canToggle) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.grey, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Önce sistem bildirim iznini etkinleştirin",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Time Settings
          if (canToggle && isEnabled) ...[
            Animate(
              effects: const [
                FadeEffect(
                    duration: Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 400)),
                SlideEffect(
                    begin: Offset(0, 0.3),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.schedule,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Bildirim Zamanı",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Her gün ${_formatTime(hour, minute)} zamanında",
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
                        onPressed: () => _selectTime(context, hour, minute),
                        icon: const Icon(Icons.edit_calendar),
                        label: Text(
                            "Zamanı Değiştir (${_formatTime(hour, minute)})"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
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
            const SizedBox(height: 20),

          /*
            // Test Buttons Section
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
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
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
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.science,
                            color: Colors.green,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "🧪 Bildirim Testleri",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Bildirim sistemini test edin",
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

                    // Ultra Simple Test Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _sendTestNotification,
                        icon: const Icon(Icons.flash_on),
                        label: const Text("⚡ Anında Test"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
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
                    const SizedBox(height: 12),

                    // 2 Minutes Later Test Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _test2MinuteLater,
                        icon: const Icon(Icons.timer),
                        label: const Text("⏰ 2 Dakika Sonra Test"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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

                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "💡 Nasıl Test Edilir:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "• ⚡ Anında Test: Hemen bildirim gelir\n• ⏰ 2 Dakika Sonra: Uygulamayı arkaplana atın ve bekleyin\n• Bildirim gelmezse sistem ayarlarını kontrol edin",
                            style: TextStyle(
                              fontSize: 11,
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            */
          ]
        ],
      ),
    );
  }

  Future<void> _selectTime(
      BuildContext context, int currentHour, int currentMinute) async {
    print("🕐 DEBUG: Current time from settings: $currentHour:$currentMinute");

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
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

    if (picked != null) {
      print("🕐 DEBUG: User picked time: ${picked.hour}:${picked.minute}");
      print(
          "🕐 DEBUG: Calling updateNotificationTime with: ${picked.hour}, ${picked.minute}");

      ref
          .read(notificationSettingsNotifierProvider.notifier)
          .updateNotificationTime(picked.hour, picked.minute);
    }
  }

  void _sendTestNotification() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🚨 ULTRA SIMPLE TEST başlatılıyor..."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );

      // Send ultra simple notification
      await DailyPoemService.sendUltraSimpleNotification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "🚨 ULTRA SIMPLE TEST tamamlandı! Eğer bildirim gelmediyse iOS ayarlarını kontrol edin."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print("🚨 Ultra simple test hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🚨 Ultra simple test hatası: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _testReminderService() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🔔 Hatırlatıcı servisi test ediliyor..."),
          backgroundColor: Colors.indigo,
          duration: Duration(seconds: 2),
        ),
      );

      // 30 saniye sonrası için hatırlatıcı ekle
      final reminderId = await NotificationService.addReminder(
        title: "🧪 Hatırlatıcı Test",
        body:
            "Bu yeni hatırlatıcı servisi testi! Çalışıyorsa, sistem hazır demektir.",
        scheduledDate: DateTime.now().add(const Duration(seconds: 30)),
        type: "test",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "✅ Hatırlatıcı eklendi! 30 saniye sonra gelecek.\nID: ${reminderId.substring(reminderId.length - 6)}"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      print("🔔 Hatırlatıcı servisi test edildi. ID: $reminderId");
    } catch (e) {
      print("❌ Hatırlatıcı servisi test hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Hatırlatıcı test hatası: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Yeni test fonksiyonu - 1 dakika sonra bildirim
  void _testQuickNotification() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⏰ 1 dakika sonra bildirim test ediliyor..."),
          backgroundColor: Colors.purple,
          duration: Duration(seconds: 3),
        ),
      );

      // 1 dakika sonra bildirim zamanla
      final scheduledTime = DateTime.now().add(const Duration(minutes: 1));

      await DailyPoemService.scheduleNotification(
        scheduledTime,
        "⏰ 1 Dakika Test",
        "Bu 1 dakika sonra gelen test bildirimi! Saat: ${scheduledTime.hour}:${scheduledTime.minute}",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "✅ 1 dakika sonra bildirim zamanlandı!\nSaat: ${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      print("⏰ 1 dakika sonra bildirim zamanlandı: $scheduledTime");
    } catch (e) {
      print("❌ 1 dakika test hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ 1 dakika test hatası: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  String _formatTime(int hour, int minute) {
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }

  void _checkPendingNotifications() async {
    try {
      final pendingNotifications =
          await NotificationService.getPendingNotifications();
      final reminders = await NotificationService.getReminders();

      print("📋 Aktif bildirimler: ${pendingNotifications.length}");
      print("📋 Kayıtlı hatırlatıcılar: ${reminders['upcoming']?.length ?? 0}");

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("📋 Bildirim Durumu"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Aktif bildirimler: ${pendingNotifications.length}"),
                Text(
                    "Bugünkü hatırlatıcılar: ${reminders['today']?.length ?? 0}"),
                Text(
                    "Yaklaşan hatırlatıcılar: ${reminders['upcoming']?.length ?? 0}"),
                Text(
                    "Geçmiş hatırlatıcılar: ${reminders['expired']?.length ?? 0}"),
                const SizedBox(height: 16),
                if (pendingNotifications.isNotEmpty) ...[
                  const Text("Aktif bildirimler:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...pendingNotifications.take(3).map((notif) => Text(
                      "• ${notif.title} (ID: ${notif.id})",
                      style: const TextStyle(fontSize: 12))),
                ]
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Tamam"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("❌ Bildirim kontrolü hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Hata: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _manualReschedule() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🔄 Hatırlatıcılar yeniden zamanlanıyor..."),
          backgroundColor: Colors.brown,
          duration: Duration(seconds: 2),
        ),
      );

      await NotificationService.manualReschedule();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Hatırlatıcılar yeniden zamanlandı!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print("❌ Yeniden zamanlama hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Hata: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _debugTimeSettings() async {
    try {
      final timeMap = await DailyPoemService.getNotificationTime();
      final currentTime = DateTime.now();

      print("🕐 === TIME SETTINGS DEBUG ===");
      print(
          "🕐 Current device time: ${currentTime.hour}:${currentTime.minute}");
      print(
          "🕐 Saved notification time: ${timeMap['hour']}:${timeMap['minute']}");

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("🕐 Saat Ayarları Debug"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "Şuanki cihaz saati: ${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}"),
                const SizedBox(height: 8),
                Text(
                    "Kayıtlı bildirim saati: ${timeMap['hour'].toString().padLeft(2, '0')}:${timeMap['minute'].toString().padLeft(2, '0')}"),
                const SizedBox(height: 16),
                const Text("Eğer bu saat yanlışsa:"),
                const Text("1. Saati tekrar ayarlayın"),
                const Text("2. Yeniden Zamanla butonuna basın"),
                const SizedBox(height: 16),
                Text("Timezone: Europe/Istanbul",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Tamam"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Automatically fix by resetting to current hour
                  ref
                      .read(notificationSettingsNotifierProvider.notifier)
                      .updateNotificationTime(
                          currentTime.hour, currentTime.minute);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "🕐 Saat şuanki zamana ayarlandı: ${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text("Şuanki Saate Ayarla"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("❌ Debug time settings error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Hata: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _superSimpleTest() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🚨 ULTRA SIMPLE TEST başlatılıyor..."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );

      // Send ultra simple notification
      await DailyPoemService.sendUltraSimpleNotification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "🚨 ULTRA SIMPLE TEST tamamlandı! Eğer bildirim gelmediyse iOS ayarlarını kontrol edin."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print("🚨 Ultra simple test hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🚨 Ultra simple test hatası: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _test2MinuteLater() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("2 Dakika Sonra Test başlatılıyor..."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // 2 dakika sonra bildirim zamanla
      final scheduledTime = DateTime.now().add(const Duration(minutes: 2));

      await DailyPoemService.scheduleNotification(
        scheduledTime,
        "2 Dakika Sonra Test",
        "Bu 2 dakika sonra gelen test bildirimi! Saat: ${scheduledTime.hour}:${scheduledTime.minute}",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "✅ 2 dakika sonra bildirim zamanlandı!\nSaat: ${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      print("⏰ 2 dakika sonra bildirim zamanlandı: $scheduledTime");
    } catch (e) {
      print("❌ 2 dakika test hatası: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ 2 dakika test hatası: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
