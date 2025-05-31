import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/models/poem.dart';
import 'package:poemapp/services/daily_poem_service.dart';

// Provider for today's poem
final todaysPoemProvider = FutureProvider<Poem?>((ref) async {
  return await DailyPoemService.getTodaysPoemService();
});

// Provider for reading streak
final readingStreakProvider = FutureProvider<int>((ref) async {
  return await DailyPoemService.getReadingStreak();
});

// Provider for notification settings
final notificationEnabledProvider = FutureProvider<bool>((ref) async {
  return await DailyPoemService.isNotificationEnabled();
});

final notificationTimeProvider = FutureProvider<Map<String, int>>((ref) async {
  return await DailyPoemService.getNotificationTime();
});

// Provider to check if poem was read today
final poemReadTodayProvider = FutureProvider<bool>((ref) async {
  return await DailyPoemService.isPoemReadToday();
});

// Provider for daily poems calendar
final dailyPoemsCalendarProvider =
    FutureProvider<Map<String, Poem>>((ref) async {
  return await DailyPoemService.getAllDailyPoems();
});

// State provider for tracking when notification settings change
final notificationSettingsChangedProvider = StateProvider<bool>((ref) => false);

// Provider for poem of specific date
final poemForDateProvider =
    Provider.family<FutureProvider<Poem?>, DateTime>((ref, date) {
  return FutureProvider<Poem?>((ref) async {
    return await DailyPoemService.getPoemForDate(date);
  });
});

// Notifier for managing daily poem state changes
class DailyPoemNotifier extends StateNotifier<AsyncValue<Poem?>> {
  DailyPoemNotifier() : super(const AsyncValue.loading()) {
    _loadTodaysPoem();
  }

  Future<void> _loadTodaysPoem() async {
    try {
      final poem = await DailyPoemService.getTodaysPoemService();
      state = AsyncValue.data(poem);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> recordPoemRead() async {
    try {
      await DailyPoemService.recordPoemRead();
    } catch (e) {
      print("❌ Error recording poem read: $e");
    }
  }

  Future<void> refreshTodaysPoem() async {
    state = const AsyncValue.loading();
    await _loadTodaysPoem();
  }
}

final dailyPoemNotifierProvider =
    StateNotifierProvider<DailyPoemNotifier, AsyncValue<Poem?>>((ref) {
  return DailyPoemNotifier();
});

// Notification settings notifier
class NotificationSettingsNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  NotificationSettingsNotifier() : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      print("🔧 Loading notification settings...");

      final enabled = await DailyPoemService.isNotificationEnabled();
      print("🔧 Notification enabled: $enabled");

      final time = await DailyPoemService.getNotificationTime();
      print("🔧 Notification time: $time");

      state = AsyncValue.data({
        'enabled': enabled,
        'time': time,
      });

      print("🔧 Settings loaded successfully");
    } catch (e, stack) {
      print("❌ Error loading notification settings: $e");
      print("❌ Stack trace: $stack");

      // Use default settings instead of error state
      state = AsyncValue.data({
        'enabled': false,
        'time': {'hour': 9, 'minute': 0},
      });
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    try {
      if (enabled) {
        final hasPermission = await DailyPoemService.requestPermission();
        if (!hasPermission) {
          throw Exception('Bildirim izni verilmedi');
        }
      }

      await DailyPoemService.setNotificationEnabled(enabled);
      await _loadSettings();
    } catch (e, stack) {
      print("❌ Error toggling notifications: $e");
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateNotificationTime(int hour, int minute) async {
    try {
      await DailyPoemService.setNotificationTime(hour, minute);
      await _loadSettings();
    } catch (e, stack) {
      print("❌ Error updating notification time: $e");
      state = AsyncValue.error(e, stack);
    }
  }
}

final notificationSettingsNotifierProvider = StateNotifierProvider<
    NotificationSettingsNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return NotificationSettingsNotifier();
});
