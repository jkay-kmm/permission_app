import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:usage_stats/usage_stats.dart';

class UsageTracker {
  // Danh sách các package launcher / home screen phổ biến cần loại trừ
  static const Set<String> _knownLaunchers = {
    'com.android.launcher',
    'com.android.launcher3',
    'com.google.android.apps.nexuslauncher',
    'com.sec.android.app.launcher', // Samsung OneUI
    'com.miui.home',               // Xiaomi MIUI/HyperOS
    'com.oppo.launcher',           // Oppo ColorOS
    'com.huawei.android.launcher',  // Huawei EMUI
    'com.teslacoilsw.launcher',    // Nova Launcher
    'com.microsoft.launcher',      // Microsoft Launcher
  };

  /// Kiểm tra đã có quyền PACKAGE_USAGE_STATS chưa
  static Future<bool> checkPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      final granted = await UsageStats.checkUsagePermission();
      return granted ?? false;
    } catch (e) {
      debugPrint('Error checking usage permission: $e');
      return false;
    }
  }

  /// Mở màn hình Cài đặt hệ thống để người dùng cấp quyền
  static Future<void> requestPermission() async {
    if (Platform.isAndroid) {
      try {
        await UsageStats.grantUsagePermission();
      } catch (e) {
        debugPrint('Error requesting usage permission: $e');
      }
    }
  }

  /// Hiển thị Dialog giải thích lý do cần quyền trước khi mở Cài đặt
  static Future<bool> showPermissionExplanationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.query_stats_rounded, color: Color(0xFFF27A3D)),
            SizedBox(width: 10),
            Text('Quyền sử dụng máy'),
          ],
        ),
        content: const Text(
          'Ứng dụng cần quyền "Truy cập dữ liệu sử dụng" để tính tổng thời gian '
          'bạn dùng điện thoại trong ngày và gửi thông báo nhắc nhở lúc 21:00.\n\n'
          'Vui lòng tìm ứng dụng trong danh sách và bật quyền này.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Để sau'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF27A3D),
            ),
            child: const Text('Mở Cài đặt'),
          ),
        ],
      ),
    );

    if (result == true) {
      await requestPermission();
      return true;
    }
    return false;
  }

  /// Tính tổng thời gian sử dụng điện thoại từ 00:00 hôm nay đến thời điểm hiện tại
  static Future<Duration> getTodayTotalUsage() async {
    if (!Platform.isAndroid) return Duration.zero;

    final hasPermission = await checkPermission();
    if (!hasPermission) return Duration.zero;

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    // Lấy package name của chính app hiện tại để loại bỏ
    String currentAppPackage = '';
    try {
      final info = await PackageInfo.fromPlatform();
      currentAppPackage = info.packageName;
    } catch (_) {}

    try {
      final List<UsageInfo> usageStats = await UsageStats.queryUsageStats(
        startOfToday,
        now,
      );

      int totalMilliseconds = 0;

      for (final info in usageStats) {
        final pkg = info.packageName ?? '';

        // Bỏ qua Launcher và chính ứng dụng này
        if (_knownLaunchers.contains(pkg) || pkg == currentAppPackage || pkg.isEmpty) {
          continue;
        }

        final fgTimeMs = int.tryParse(info.totalTimeInForeground ?? '0') ?? 0;
        if (fgTimeMs > 0) {
          totalMilliseconds += fgTimeMs;
        }
      }

      return Duration(milliseconds: totalMilliseconds);
    } catch (e) {
      debugPrint('Error querying usage stats: $e');
      return Duration.zero;
    }
  }

  /// Format Duration thành chuỗi "X giờ Y phút"
  static String formatUsage(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours giờ $minutes phút';
    } else if (hours > 0) {
      return '$hours giờ';
    } else {
      return '$minutes phút';
    }
  }
}
