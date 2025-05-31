import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:convert';
import 'dart:io';

class NotificationService {
  static const String _remindersKey = 'local_reminders';

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  // Initialize the service
  static Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _isInitialized = true;

    // Uygulama açılırken mevcut hatırlatıcıları yeniden zamanla
    await _rescheduleExistingReminders();
  }

  // Mevcut hatırlatıcıları yeniden zamanla
  static Future<void> _rescheduleExistingReminders() async {
    try {
      final reminders = await _getAllReminders();
      final now = DateTime.now();
      int rescheduledCount = 0;

      print("🔄 Mevcut hatırlatıcılar kontrol ediliyor...");

      for (var reminder in reminders.values) {
        final scheduledDate = DateTime.parse(reminder['scheduledDate']);

        // Sadece gelecekteki hatırlatıcıları yeniden zamanla
        if (scheduledDate.isAfter(now)) {
          await _scheduleLocalNotification(
            int.parse(reminder['id'].substring(reminder['id'].length - 9)),
            reminder['title'],
            reminder['body'],
            scheduledDate,
          );
          rescheduledCount++;
        }
      }

      print("🔄 $rescheduledCount hatırlatıcı yeniden zamanlandı");
    } catch (e) {
      print("❌ Hatırlatıcılar yeniden zamanlanırken hata: $e");
    }
  }

  // Request permission
  static Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final iosImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    return true;
  }

  // Yeni bir hatırlatıcı ekle
  static Future<String> addReminder({
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String type,
  }) async {
    try {
      await init();

      final reminderId = DateTime.now().millisecondsSinceEpoch.toString();

      final prefs = await SharedPreferences.getInstance();
      final reminders = await _getAllReminders();

      reminders[reminderId] = {
        'id': reminderId,
        'title': title,
        'body': body,
        'scheduledDate': scheduledDate.toIso8601String(),
        'type': type,
        'isRead': false,
        'isCompleted': false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_remindersKey, json.encode(reminders));

      // Local notification zamanla
      if (scheduledDate.isAfter(DateTime.now())) {
        await _scheduleLocalNotification(
          int.parse(reminderId.substring(reminderId.length - 9)),
          title,
          body,
          scheduledDate,
        );
      }

      return reminderId;
    } catch (e) {
      throw Exception('Hatırlatıcı eklenirken hata: $e');
    }
  }

  // Hatırlatıcıyı güncelle
  static Future<void> updateReminder({
    required String reminderId,
    String? title,
    String? body,
    DateTime? scheduledDate,
    String? type,
    bool? isRead,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reminders = await _getAllReminders();

      if (!reminders.containsKey(reminderId)) {
        throw Exception('Hatırlatıcı bulunamadı');
      }

      final reminder = Map<String, dynamic>.from(reminders[reminderId]!);

      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (body != null) updateData['body'] = body;
      if (scheduledDate != null)
        updateData['scheduledDate'] = scheduledDate.toIso8601String();
      if (type != null) updateData['type'] = type;
      if (isRead != null) updateData['isRead'] = isRead;

      reminder.addAll(updateData);
      reminders[reminderId] = reminder;

      await prefs.setString(_remindersKey, json.encode(reminders));

      // Notification'ı güncelle
      await _notifications
          .cancel(int.parse(reminderId.substring(reminderId.length - 9)));

      if (scheduledDate != null && scheduledDate.isAfter(DateTime.now())) {
        await _scheduleLocalNotification(
          int.parse(reminderId.substring(reminderId.length - 9)),
          reminder['title'],
          reminder['body'],
          scheduledDate,
        );
      }
    } catch (e) {
      throw Exception('Hatırlatıcı güncellenirken hata: $e');
    }
  }

  // Hatırlatıcıyı sil
  static Future<void> deleteReminder(String reminderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reminders = await _getAllReminders();

      if (reminders.containsKey(reminderId)) {
        reminders.remove(reminderId);
        await prefs.setString(_remindersKey, json.encode(reminders));

        // Notification'ı iptal et
        await _notifications
            .cancel(int.parse(reminderId.substring(reminderId.length - 9)));
      }
    } catch (e) {
      throw Exception('Hatırlatıcı silinirken hata: $e');
    }
  }

  // Tüm hatırlatıcıları getir
  static Future<Map<String, List<Map<String, dynamic>>>> getReminders() async {
    final reminders = await _getAllReminders();
    final now = DateTime.now();

    List<Map<String, dynamic>> today = [];
    List<Map<String, dynamic>> upcoming = [];
    List<Map<String, dynamic>> expired = [];

    const int upcomingThreshold = 1200; // 20 dakika

    for (var reminder in reminders.values) {
      final scheduledDate = DateTime.parse(reminder['scheduledDate']);
      final differenceInSeconds = scheduledDate.difference(now).inSeconds;

      final isToday = scheduledDate.year == now.year &&
          scheduledDate.month == now.month &&
          scheduledDate.day == now.day;

      if (isToday) {
        today.add(reminder);
      }

      if (differenceInSeconds > 0 && differenceInSeconds <= upcomingThreshold) {
        upcoming.add(reminder);
      } else if (scheduledDate.isAfter(now) && !isToday) {
        upcoming.add(reminder);
      } else if (scheduledDate.isBefore(now)) {
        expired.add(reminder);
      }
    }

    return {
      'today': today,
      'upcoming': upcoming,
      'expired': expired,
    };
  }

  // Belirli bir tarihe göre hatırlatıcıları getir
  static Future<List<Map<String, dynamic>>> getRemindersByDate(
      DateTime date) async {
    final reminders = await _getAllReminders();
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = reminders.values.where((reminder) {
      final scheduledDate = DateTime.parse(reminder['scheduledDate']);
      return scheduledDate.isAfter(startOfDay) &&
          scheduledDate.isBefore(endOfDay);
    }).toList();

    result.sort((a, b) => DateTime.parse(a['scheduledDate'])
        .compareTo(DateTime.parse(b['scheduledDate'])));

    return result;
  }

  // Tipe göre hatırlatıcıları getir
  static Future<List<Map<String, dynamic>>> getRemindersByType(
      String type) async {
    final reminders = await _getAllReminders();

    final result =
        reminders.values.where((reminder) => reminder['type'] == type).toList();
    result.sort((a, b) => DateTime.parse(b['scheduledDate'])
        .compareTo(DateTime.parse(a['scheduledDate'])));

    return result;
  }

  // Arama yap
  static Future<List<Map<String, dynamic>>> searchReminders(
      String searchQuery) async {
    try {
      final reminders = await _getAllReminders();

      final result = reminders.values.where((reminder) {
        final title = reminder['title']?.toString().toLowerCase() ?? '';
        final body = reminder['body']?.toString().toLowerCase() ?? '';
        final type = reminder['type']?.toString().toLowerCase() ?? '';

        final query = searchQuery.toLowerCase();

        return title.contains(query) ||
            body.contains(query) ||
            type.contains(query);
      }).toList();

      result.sort((a, b) => DateTime.parse(b['scheduledDate'])
          .compareTo(DateTime.parse(a['scheduledDate'])));

      return result;
    } catch (e) {
      throw Exception('Arama yapılırken hata: $e');
    }
  }

  // Hatırlatıcıyı okundu olarak işaretle
  static Future<void> markAsRead(String reminderId) async {
    try {
      await updateReminder(
        reminderId: reminderId,
        isRead: true,
      );
    } catch (e) {
      throw Exception('Hatırlatıcı okundu işaretlenirken hata: $e');
    }
  }

  // Tamamlandı olarak işaretle
  static Future<void> markAsCompleted(String reminderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reminders = await _getAllReminders();

      if (!reminders.containsKey(reminderId)) {
        throw Exception('Hatırlatıcı bulunamadı');
      }

      final reminder = Map<String, dynamic>.from(reminders[reminderId]!);
      reminder['isCompleted'] = true;
      reminder['completedAt'] = DateTime.now().toIso8601String();
      reminder['updatedAt'] = DateTime.now().toIso8601String();

      reminders[reminderId] = reminder;
      await prefs.setString(_remindersKey, json.encode(reminders));
    } catch (e) {
      throw Exception('Hatırlatıcı tamamlandı işaretlenirken hata: $e');
    }
  }

  // Tüm bildirimleri temizle
  static Future<void> clearAllNotifications() async {
    await _notifications.cancelAll();
    print("🧹 Tüm bildirimler temizlendi");
  }

  // Manuel yeniden zamanlama (test için)
  static Future<void> manualReschedule() async {
    await clearAllNotifications();
    await _rescheduleExistingReminders();
  }

  // Aktif bildirimlerin sayısını getir (debug için)
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Test için basit bildirim
  static Future<void> sendTestNotification() async {
    try {
      await init();

      final hasPermission = await requestPermission();
      if (!hasPermission) {
        throw Exception('Bildirim izni verilmedi');
      }

      await _notifications.show(
        999,
        'Test Bildirimi',
        'Bu çalışıyorsa bildirimler tamam! ${DateTime.now().toString().substring(11, 19)}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      throw Exception('Test bildirimi hatası: $e');
    }
  }

  // Süper basit bildirim test
  static Future<void> sendSuperSimpleNotification() async {
    try {
      await init();
      final hasPermission = await requestPermission();
      if (!hasPermission) throw Exception('İzin verilmedi');

      await _notifications.show(
        12345,
        'SÜPER BASIT TEST',
        'Bu çalışmalı! ${DateTime.now().toString().substring(11, 19)}',
        const NotificationDetails(
          android: AndroidNotificationDetails('test', 'Test',
              importance: Importance.max),
          iOS: DarwinNotificationDetails(
              presentAlert: true, presentBadge: true, presentSound: true),
        ),
      );
    } catch (e) {
      throw Exception('Süper basit test hatası: $e');
    }
  }

  // Private helper methods
  static Future<Map<String, Map<String, dynamic>>> _getAllReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getString(_remindersKey);

    if (remindersJson == null) return {};

    final Map<String, dynamic> decoded = json.decode(remindersJson);
    return decoded
        .map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
  }

  static Future<void> _scheduleLocalNotification(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
  ) async {
    await init();

    final hasPermission = await requestPermission();
    if (!hasPermission) return;

    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Hatırlatıcılar',
      channelDescription: 'Zamanlanmış hatırlatıcı bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    } catch (e) {
      print("❌ Error scheduling reminder: $e");
      // Try with simpler approach
      try {
        await _notifications.zonedSchedule(
          id,
          title,
          body,
          tzDateTime,
          details,
          androidScheduleMode: AndroidScheduleMode.inexact,
        );
      } catch (e2) {
        print("❌ Fallback reminder scheduling failed: $e2");
      }
    }
  }
}
