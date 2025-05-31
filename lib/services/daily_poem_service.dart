import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poemapp/models/poem.dart';
import 'package:poemapp/services/api_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';
import 'dart:convert';
import 'dart:io';

class DailyPoemService {
  static const String _streakCountKey = 'reading_streak_count';
  static const String _lastReadDateKey = 'last_read_date';
  static const String _dailyPoemsKey = 'daily_poems_calendar';
  static const String _notificationEnabledKey = 'notification_enabled';
  static const String _notificationTimeKey = 'notification_time';
  static const String _lastNotificationPoemKey = 'last_notification_poem';

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  // Callback for notification taps
  static Function(String?)? onNotificationTap;

  // Initialize the service
  static Future<void> init() async {
    if (_isInitialized) return;

    print("📱 Initializing notification service...");

    // Initialize timezone
    tz.initializeTimeZones();

    // Set timezone to local
    final String timeZoneName = 'Europe/Istanbul'; // Turkey timezone
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // We'll request manually
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize with notification tap handling
    final bool? initialized = await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("📱 ==== NOTIFICATION RESPONSE RECEIVED ====");
        print("📱 Notification ID: ${response.id}");
        print("📱 Action ID: ${response.actionId}");
        print("📱 Input: ${response.input}");
        print("📱 Payload: ${response.payload}");
        print(
            "📱 Notification response type: ${response.notificationResponseType}");

        if (onNotificationTap != null && response.payload != null) {
          print("📱 Calling onNotificationTap callback...");
          onNotificationTap!(response.payload);
        } else {
          print("❌ onNotificationTap is null or payload is null");
          print("❌ onNotificationTap: $onNotificationTap");
          print("❌ payload: ${response.payload}");
        }
        print("📱 ==== NOTIFICATION RESPONSE END ====");
      },
    );

    print("📱 Notification service initialized: $initialized");
    _isInitialized = true;
  }

  // Request permission - iOS specific
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
        print("📱 iOS permission granted: $granted");
        return granted ?? false;
      }
    }
    return true; // Android doesn't need this
  }

  // Send immediate test notification
  static Future<void> sendTestNotification() async {
    print("📱 Starting test notification...");

    await init();

    print("📱 Requesting permission...");
    final hasPermission = await requestPermission();
    print("📱 Permission result: $hasPermission");

    if (!hasPermission) {
      throw Exception(
          'Bildirim izni verilmedi - iPhone ayarlarından kontrol edin');
    }

    print("📱 Sending test notification with payload...");

    // Get today's poem for payload
    final todaysPoem = await getTodaysPoemService();

    String payload = '';
    if (todaysPoem != null) {
      payload = json.encode({
        'type': 'daily_poem',
        'poem_id': todaysPoem.id,
        'poet_id': todaysPoem.poetId,
      });
      print("📱 Test notification payload: $payload");
    }

    // Very simple notification with payload
    await _notifications.show(
      0,
      'Test Bildirimi 📖',
      todaysPoem != null
          ? '${todaysPoem.title}\n\nTıklayın ve şiir detayını görün!'
          : 'Bu bir test bildirimi - şu anda saat: ${DateTime.now().hour}:${DateTime.now().minute}',
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
      payload: payload,
    );

    print("📱 Test notification sent with payload!");

    // Also try a delayed notification (1 second later)
    await Future.delayed(const Duration(seconds: 1));

    await _notifications.show(
      1,
      'Gecikmeli Test 📚',
      'Bu 1 saniye gecikmeli test bildirimi - tıklayın!',
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
      payload: payload,
    );

    print("📱 Delayed test notification sent with payload!");
  }

  // Schedule notification for specific date/time
  static Future<void> scheduleNotification(
      DateTime scheduledTime, String title, String body) async {
    await init();

    final hasPermission = await requestPermission();
    if (!hasPermission) return;

    final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test',
      importance: Importance.max,
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
        2,
        title,
        body,
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexact,
      );
      print("📱 Test notification scheduled successfully");
    } catch (e) {
      print("❌ Error scheduling test notification: $e");
    }
  }

  // Schedule daily notification with actual poem content
  static Future<void> scheduleDailyNotificationWithPoem() async {
    print("📱 Scheduling daily notification with poem content...");

    await init();

    final hasPermission = await requestPermission();
    if (!hasPermission) {
      print("📱 Permission denied - cancelling scheduling");
      return;
    }

    // Get notification time
    final timeSettings = await getNotificationTime();
    final hour = timeSettings['hour']!;
    final minute = timeSettings['minute']!;

    // Cancel existing notifications first
    await cancelAllNotifications();

    // Get today's poem
    final todaysPoem = await getTodaysPoemService();
    if (todaysPoem == null) {
      print("📱 No poem found for today - using default notification");
      await scheduleDailyNotification(hour, minute);
      return;
    }

    // Calculate next occurrence
    final now = DateTime.now();
    DateTime scheduledDate =
        DateTime(now.year, now.month, now.day, hour, minute);

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      print(
          "📱 Time has passed today, scheduling for tomorrow: $scheduledDate");
    } else {
      print("📱 Scheduling for today: $scheduledDate");
    }

    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    // Prepare poem content for notification
    String poemTitle = todaysPoem.title ?? "Günün Şiiri";
    String poemPreview = todaysPoem.content ?? "Yeni bir şiir sizi bekliyor!";

    // Truncate content if too long for notification
    if (poemPreview.length > 100) {
      poemPreview = "${poemPreview.substring(0, 97)}...";
    }

    // Create payload with poem ID for navigation
    String payload = json.encode({
      'type': 'daily_poem',
      'poem_id': todaysPoem.id,
      'poet_id': todaysPoem.poetId,
    });

    const androidDetails = AndroidNotificationDetails(
      'daily_poem_channel',
      'Günlük Şiir',
      channelDescription: 'Günlük şiir bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        '', // Empty content text since we're using expandedHtml
        htmlFormatContent: true,
        htmlFormatContentTitle: true,
        htmlFormatSummaryText: true,
      ),
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
        1,
        "📖 $poemTitle",
        poemPreview,
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );

      print("📱 Daily poem notification scheduled successfully");
      print("📱 Poem: $poemTitle");
      print("📱 Preview: $poemPreview");

      // Save the poem info for reference
      await _saveLastNotificationPoem(todaysPoem);
    } catch (e) {
      print("❌ Error scheduling poem notification: $e");
      // Fallback to simple notification
      await scheduleDailyNotification(hour, minute);
    }
  }

  // Save last notification poem info
  static Future<void> _saveLastNotificationPoem(Poem poem) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastNotificationPoemKey, json.encode(poem.toJson()));
  }

  // Get last notification poem
  static Future<Poem?> getLastNotificationPoem() async {
    final prefs = await SharedPreferences.getInstance();
    final poemData = prefs.getString(_lastNotificationPoemKey);
    if (poemData != null) {
      try {
        final poemJson = json.decode(poemData) as Map<String, dynamic>;
        return Poem.fromJson(poemJson);
      } catch (e) {
        print("❌ Error parsing last notification poem: $e");
      }
    }
    return null;
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print("📱 All notifications cancelled");
  }

  // Enable/disable daily notifications
  static Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);

    if (enabled) {
      // Use the new poem-based notification
      await scheduleDailyNotificationWithPoem();
    } else {
      await cancelAllNotifications();
    }
  }

  // Check if notifications are enabled
  static Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ?? true;
  }

  // Set notification time
  static Future<void> setNotificationTime(int hour, int minute) async {
    print("📱 Setting notification time: $hour:$minute");

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationTimeKey, '$hour:$minute');

    print("📱 Saved to preferences: $hour:$minute");

    if (await isNotificationEnabled()) {
      // Use the new poem-based notification
      await scheduleDailyNotificationWithPoem();
    }
  }

  // Get notification time
  static Future<Map<String, int>> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_notificationTimeKey) ?? '9:0';

    print("📱 Retrieved time string: $timeString");

    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    print("📱 Parsed time: $hour:$minute");

    return {
      'hour': hour,
      'minute': minute,
    };
  }

  // Get today's poem
  static Future<Poem?> getTodaysPoemService() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayKey();

      // Check if we already have today's poem
      final dailyPoems = prefs.getString(_dailyPoemsKey);
      if (dailyPoems != null) {
        final poemsMap = json.decode(dailyPoems) as Map<String, dynamic>;
        if (poemsMap.containsKey(today)) {
          final poemData = poemsMap[today] as Map<String, dynamic>;
          return Poem.fromJson(poemData);
        }
      }

      // Get a random poem for today
      final apiService = ApiService();
      final allPoems = await apiService.fetchPoems();

      if (allPoems.isNotEmpty) {
        // Use date as seed for consistent daily poem
        final seed = DateTime.now().day +
            DateTime.now().month * 31 +
            DateTime.now().year * 365;
        final random = Random(seed);
        final todaysPoem = allPoems[random.nextInt(allPoems.length)];

        // Save today's poem
        await _saveDailyPoem(today, todaysPoem);
        return todaysPoem;
      }
    } catch (e) {
      print("❌ Error getting today's poem: $e");
    }
    return null;
  }

  // Save daily poem
  static Future<void> _saveDailyPoem(String dateKey, Poem poem) async {
    final prefs = await SharedPreferences.getInstance();
    final dailyPoems = prefs.getString(_dailyPoemsKey);

    Map<String, dynamic> poemsMap = {};
    if (dailyPoems != null) {
      poemsMap = json.decode(dailyPoems) as Map<String, dynamic>;
    }

    poemsMap[dateKey] = poem.toJson();
    await prefs.setString(_dailyPoemsKey, json.encode(poemsMap));
  }

  // Get poem for specific date
  static Future<Poem?> getPoemForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _getDateKey(date);

    final dailyPoems = prefs.getString(_dailyPoemsKey);
    if (dailyPoems != null) {
      final poemsMap = json.decode(dailyPoems) as Map<String, dynamic>;
      if (poemsMap.containsKey(dateKey)) {
        final poemData = poemsMap[dateKey] as Map<String, dynamic>;
        return Poem.fromJson(poemData);
      }
    }
    return null;
  }

  // Get all daily poems
  static Future<Map<String, Poem>> getAllDailyPoems() async {
    final prefs = await SharedPreferences.getInstance();
    final dailyPoems = prefs.getString(_dailyPoemsKey);

    if (dailyPoems != null) {
      final poemsMap = json.decode(dailyPoems) as Map<String, dynamic>;
      final result = <String, Poem>{};

      for (final entry in poemsMap.entries) {
        result[entry.key] = Poem.fromJson(entry.value as Map<String, dynamic>);
      }
      return result;
    }
    return {};
  }

  // Record poem read and update streak
  static Future<void> recordPoemRead() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayKey();
    final lastReadDate = prefs.getString(_lastReadDateKey);

    if (lastReadDate == today) return;

    await prefs.setString(_lastReadDateKey, today);

    if (lastReadDate != null) {
      final lastDate = DateTime.parse(lastReadDate.replaceAll('-', ''));
      final todayDate = DateTime.now();
      final difference = todayDate.difference(lastDate).inDays;

      if (difference == 1) {
        final currentStreak = await getReadingStreak();
        await prefs.setInt(_streakCountKey, currentStreak + 1);
      } else if (difference > 1) {
        await prefs.setInt(_streakCountKey, 1);
      }
    } else {
      await prefs.setInt(_streakCountKey, 1);
    }
  }

  // Get reading streak
  static Future<int> getReadingStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakCountKey) ?? 0;
  }

  // Check if poem was read today
  static Future<bool> isPoemReadToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayKey();
    final lastReadDate = prefs.getString(_lastReadDateKey);
    return lastReadDate == today;
  }

  // Helper methods
  static String _getTodayKey() {
    final now = DateTime.now();
    return _getDateKey(now);
  }

  static String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // En basit garantili çalışan bildirim testi
  static Future<void> sendUltraSimpleNotification() async {
    print("🚨 === ULTRA SIMPLE NOTIFICATION TEST ===");

    try {
      // Tamamen yeni plugin instance
      final testNotifications = FlutterLocalNotificationsPlugin();

      // Android ve iOS için minimal settings
      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      );

      // Initialize
      bool? initialized = await testNotifications.initialize(initSettings);
      print("🚨 Plugin initialized: $initialized");

      // iOS permission
      if (Platform.isIOS) {
        final iosPlugin =
            testNotifications.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        if (iosPlugin != null) {
          bool? granted = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          print("🚨 iOS Permission granted: $granted");

          if (granted != true) {
            print("🚨 iOS Permission denied - stopping test");
            return;
          }
        }
      }

      // Android için permission kontrol
      if (Platform.isAndroid) {
        print("🚨 Android platform detected - no special permission needed");
      }

      // En basit bildirim - hem Android hem iOS için
      await testNotifications.show(
        999999,
        'ULTRA SIMPLE TEST',
        'Android Test! Eğer bu görünüyorsa bildirimler çalışıyor! ${DateTime.now().toString().substring(11, 19)}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'ultra_test_channel',
            'Ultra Test',
            channelDescription: 'Ultra simple test notifications',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );

      print("🚨 First ultra simple notification sent!");

      // 3 saniye sonra bir tane daha
      await Future.delayed(const Duration(seconds: 3));

      await testNotifications.show(
        999998,
        'ULTRA SIMPLE TEST 2',
        'Android Test 2! 3 saniye sonra gelen test! ${DateTime.now().toString().substring(11, 19)}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'ultra_test_channel',
            'Ultra Test',
            channelDescription: 'Ultra simple test notifications',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            ticker: 'Ultra Test Ticker',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );

      print("🚨 Second ultra simple notification sent!");
    } catch (e) {
      print("🚨 ULTRA SIMPLE TEST FAILED: $e");
      print("🚨 Stack: ${StackTrace.current}");
    }

    print("🚨 === ULTRA SIMPLE TEST COMPLETE ===");
  }

  // Check actual notification permission status
  static Future<bool> checkNotificationPermission() async {
    try {
      await init();

      if (Platform.isAndroid) {
        // Android'de plugin'den permission durumunu kontrol et
        final androidImplementation =
            _notifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          final bool? granted =
              await androidImplementation.areNotificationsEnabled();
          print("📱 Android notification permission: $granted");
          return granted ?? false;
        }
        return true; // Fallback for older Android versions
      } else if (Platform.isIOS) {
        final iosImplementation =
            _notifications.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        if (iosImplementation != null) {
          final bool? granted = await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          print("📱 iOS notification permission: $granted");
          return granted ?? false;
        }
      }

      return false;
    } catch (e) {
      print("❌ Error checking notification permission: $e");
      return false;
    }
  }

  // Request permission and return result
  static Future<bool> requestNotificationPermission() async {
    try {
      await init();

      if (Platform.isAndroid) {
        // Android'de izin iste
        final androidImplementation =
            _notifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          final bool? granted =
              await androidImplementation.requestNotificationsPermission();
          print("📱 Android permission request result: $granted");
          return granted ?? false;
        }
        return true;
      } else if (Platform.isIOS) {
        return await requestPermission(); // Mevcut iOS fonksiyonunu kullan
      }

      return false;
    } catch (e) {
      print("❌ Error requesting notification permission: $e");
      return false;
    }
  }

  // Schedule daily notification (simple version without poem content)
  static Future<void> scheduleDailyNotification(int hour, int minute) async {
    print("📱 Scheduling simple daily notification for $hour:$minute");

    await init();

    final hasPermission = await requestPermission();
    if (!hasPermission) {
      print("📱 Permission denied - cancelling scheduling");
      return;
    }

    // Cancel existing notifications first
    await cancelAllNotifications();

    // Calculate next occurrence
    final now = DateTime.now();
    DateTime scheduledDate =
        DateTime(now.year, now.month, now.day, hour, minute);

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      print(
          "📱 Time has passed today, scheduling for tomorrow: $scheduledDate");
    } else {
      print("📱 Scheduling for today: $scheduledDate");
    }

    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'daily_poem_channel',
      'Günlük Şiir',
      channelDescription: 'Günlük şiir bildirimleri',
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
        1,
        'Günün Şiiri 📖',
        'Yeni bir şiir sizi bekliyor! Okumaya hazır mısınız?',
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print("📱 Simple daily notification scheduled successfully");
    } catch (e) {
      print("❌ Error scheduling simple notification: $e");
    }
  }
}
