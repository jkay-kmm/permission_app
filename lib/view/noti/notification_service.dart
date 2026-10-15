import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'usage_tracker.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String channelId = 'daily_usage_channel';
  static const String channelName = 'Nhắc nhở sử dụng hằng ngày';
  static const String channelDescription =
      'Thông báo tổng thời gian sử dụng điện thoại lúc 21:00';
  static const int notificationId = 2100;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Khởi tạo local notification và timezone
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Cấu hình múi giờ (mặc định Asia/Ho_Chi_Minh)
    tz.initializeTimeZones();
    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    }

    // 2. Khởi tạo cài đặt cho Android
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Nhấn vào thông báo sẽ mở ứng dụng
      },
    );

    // 3. Tạo Notification Channel với Importance High
    final androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _isInitialized = true;
  }

  /// Xin quyền POST_NOTIFICATIONS (Android 13+ / API 33+)
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        final result = await Permission.notification.request();
        return result.isGranted;
      }
      return status.isGranted;
    }
    return false;
  }

  /// Hiển thị thông báo sử dụng ngay lập tức
  Future<void> showUsageNotification(Duration usage) async {
    await initialize();

    final formattedText = UsageTracker.formatUsage(usage);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        'Hôm nay bạn đã sử dụng điện thoại $formattedText.\nHãy thư giãn và nghỉ ngơi nhé!',
        contentTitle: '📊 Thống kê sử dụng hôm nay',
        summaryText: 'Digital Wellbeing',
      ),
    );

    final details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      notificationId,
      '📊 Thống kê sử dụng hôm nay',
      'Hôm nay bạn đã sử dụng điện thoại $formattedText',
      details,
    );
  }
}
