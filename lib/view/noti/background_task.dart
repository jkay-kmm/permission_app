import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'notification_service.dart';
import 'usage_tracker.dart';

const String dailyUsageTaskKey = 'com.example.brainrot.daily_usage_check';
const String prefLastNotifiedDateKey = 'last_notified_date';
const String prefIsScheduledKey = 'is_daily_reminder_enabled';

/// Callback chạy ngầm trong Isolate riêng biệt của Android WorkManager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // 1. Phải đảm bảo Flutter engine binding được khởi tạo trong isolate nền
    WidgetsFlutterBinding.ensureInitialized();

    if (taskName == dailyUsageTaskKey) {
      final now = DateTime.now();

      // Khung giờ kiểm tra: từ 21:00 đến 21:20
      final isTargetTimeFrame = now.hour == 21 && now.minute <= 20;

      if (isTargetTimeFrame) {
        final prefs = await SharedPreferences.getInstance();
        final todayKey =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final lastSentDate = prefs.getString(prefLastNotifiedDateKey);

        // Nếu hôm nay chưa gửi thông báo thì mới gửi
        if (lastSentDate != todayKey) {
          final totalUsage = await UsageTracker.getTodayTotalUsage();
          await NotificationService().showUsageNotification(totalUsage);

          // Đánh dấu đã gửi thành công cho ngày hôm nay
          await prefs.setString(prefLastNotifiedDateKey, todayKey);
        }
      }
    }

    return Future.value(true);
  });
}

class BackgroundTaskManager {
  /// Khởi tạo WorkManager
  static Future<void> initialize() async {
    if (!Platform.isAndroid) return;
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );
    } catch (e) {
      debugPrint('Error initializing Workmanager: $e');
    }
  }

  /// Đăng ký tác vụ định kỳ mỗi 15 phút (giới hạn tối thiểu của Android WorkManager)
  static Future<void> scheduleDailyCheck() async {
    if (!Platform.isAndroid) return;

    try {
      await Workmanager().registerPeriodicTask(
        dailyUsageTaskKey,
        dailyUsageTaskKey,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
        ),
        existingWorkPolicy: ExistingWorkPolicy.update,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefIsScheduledKey, true);
    } catch (e) {
      debugPrint('Error scheduling daily check: $e');
    }
  }

  /// Hủy tác vụ định kỳ
  static Future<void> cancelDailyCheck() async {
    if (!Platform.isAndroid) return;

    try {
      await Workmanager().cancelByUniqueName(dailyUsageTaskKey);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefIsScheduledKey, false);
    } catch (e) {
      debugPrint('Error canceling daily check: $e');
    }
  }

  /// Kiểm tra trạng thái đang bật hay tắt
  static Future<bool> isScheduled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefIsScheduledKey) ?? false;
  }
}
