import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../noti/background_task.dart';
import '../noti/notification_service.dart';
import '../noti/usage_tracker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DailyReminderScreen extends StatefulWidget {
  const DailyReminderScreen({super.key});

  static const _accent = Color(0xFFF27A3D);
  static const _ink = Color(0xFF2B2927);

  @override
  State<DailyReminderScreen> createState() => _DailyReminderScreenState();
}

class _DailyReminderScreenState extends State<DailyReminderScreen>
    with WidgetsBindingObserver {
  Duration _todayUsage = Duration.zero;
  bool _hasUsagePermission = false;
  bool _isReminderEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    final hasPerm = await UsageTracker.checkPermission();
    final isScheduled = await BackgroundTaskManager.isScheduled();

    Duration usage = Duration.zero;
    if (hasPerm) {
      usage = await UsageTracker.getTodayTotalUsage();
    }

    if (mounted) {
      setState(() {
        _hasUsagePermission = hasPerm;
        _isReminderEnabled = isScheduled;
        _todayUsage = usage;
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePermissionRequest() async {
    await UsageTracker.showPermissionExplanationDialog(context);
    await _refreshData();
  }

  Future<void> _toggleReminder(bool value) async {
    if (value) {
      // 1. Kiểm tra quyền thông báo Android 13+
      final granted =
          await NotificationService().requestNotificationPermission();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Vui lòng cấp quyền thông báo để kích hoạt tính năng'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // 2. Kiểm tra quyền usage stats
      if (!_hasUsagePermission) {
        final opened =
            await UsageTracker.showPermissionExplanationDialog(context);
        if (!opened) return;
      }

      // 3. Khuyên tắt Battery Optimization
      await _requestIgnoreBatteryOptimization();

      // 4. Lên lịch định kỳ
      await BackgroundTaskManager.scheduleDailyCheck();
    } else {
      await BackgroundTaskManager.cancelDailyCheck();
    }

    setState(() => _isReminderEnabled = value);
  }

  Future<void> _requestIgnoreBatteryOptimization() async {
    if (Platform.isAndroid) {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (!status.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }
  }

  Future<void> _testNotificationNow() async {
    final granted = await NotificationService().requestNotificationPermission();
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa có quyền hiển thị thông báo!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final usage = await UsageTracker.getTodayTotalUsage();
    await NotificationService().showUsageNotification(usage);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi thông báo thử nghiệm thành công!'),
          backgroundColor: DailyReminderScreen._accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF171513) : const Color(0xFFFFF8EF);
    final cardColor = isDark ? const Color(0xFF24211E) : Colors.white;
    final primaryText =
        isDark ? const Color(0xFFF8F4EF) : DailyReminderScreen._ink;
    final secondaryText =
        isDark ? const Color(0xFFB8B0A8) : const Color(0xFF7A736D);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          'Nhắc nhở lúc 21:00',
          style: TextStyle(
            color: primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryText),
      ),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.hexagonDots(
                  color: DailyReminderScreen._accent, size: 50))
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Card: Thống kê thời gian hôm nay
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF58A4E), Color(0xFFEF6941)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color:
                                DailyReminderScreen._accent.withOpacity(0.24),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.access_time_filled_rounded,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Thời gian dùng điện thoại hôm nay',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _hasUsagePermission
                                ? UsageTracker.formatUsage(_todayUsage)
                                : 'Chưa cấp quyền',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Cảnh báo nếu chưa cấp quyền PACKAGE_USAGE_STATS
                    if (!_hasUsagePermission) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF33261A)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: DailyReminderScreen._accent.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: DailyReminderScreen._accent,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Cần quyền truy cập sử dụng để app tự động đo thời gian.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: primaryText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: _handlePermissionRequest,
                              style: FilledButton.styleFrom(
                                backgroundColor: DailyReminderScreen._accent,
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Cấp quyền'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Card Bật/Tắt tính năng nhắc nhở 21:00
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: SwitchListTile(
                        value: _isReminderEnabled,
                        onChanged: _toggleReminder,
                        activeColor: DailyReminderScreen._accent,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Nhắc nhở lúc 21:00 mỗi ngày',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: primaryText,
                          ),
                        ),
                        subtitle: Text(
                          'Tự động gửi thông báo tổng thời gian sử dụng điện thoại mỗi tối',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nút Test gửi thử thông báo ngay
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _testNotificationNow,
                        style: FilledButton.styleFrom(
                          backgroundColor: DailyReminderScreen._accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(
                          Icons.notifications_active_rounded,
                          size: 20,
                        ),
                        label: const Text(
                          'Gửi thông báo thử ngay',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Card hướng dẫn tối ưu pin
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.battery_charging_full_rounded,
                                color: Color(0xFF2B9A73),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Mẹo chạy ngầm ổn định',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: primaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Để tác vụ nền luôn kích hoạt đúng giờ lúc 21:00 trên các dòng máy Xiaomi, Samsung, Oppo: vui lòng tắt tính năng "Tối ưu hóa pin" cho ứng dụng Brainrot.',
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryText,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: _requestIgnoreBatteryOptimization,
                            child: const Text(
                              'Cài đặt không tối ưu pin →',
                              style: TextStyle(
                                color: DailyReminderScreen._accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
