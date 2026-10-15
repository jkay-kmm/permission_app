import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usage_stats/usage_stats.dart';
import '../../model/app_usage_info.dart';
import '../../service/app_icon_service.dart';
import '../../service/daily_mood_service.dart';
import '../../service/real_app_usage_service.dart';
import '../noti/usage_tracker.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  static const _accent = Color(0xFFF27A3D);
  static const _ink = Color(0xFF2B2927);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final DailyMoodService _moodService = DailyMoodService();
  final RealAppUsageService _realUsageService = RealAppUsageService();

  Map<String, String> dailyMoods = {};
  Map<int, double> weeklyUsageHours = {};

  List<AppUsageInfo> _selectedDayApps = [];
  Duration _selectedDayTotalUsage = Duration.zero;
  bool _isLoadingDayUsage = false;

  static const List<Color> _chartColors = [
    Color(0xFFF27A3D), // Cam chủ đạo
    Color(0xFF4A90E2), // Xanh dương
    Color(0xFF8B5CC7), // Tím
    Color(0xFF2B9A73), // Xanh lá
    Color(0xFFF5A623), // Vàng hổ phách
    Color(0xFFE94E77), // Hồng
  ];

  @override
  void initState() {
    super.initState();
    _loadMonthData();
    _loadDayUsage(_selectedDay);
  }

  Future<void> _loadMonthData() async {
    try {
      final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);

      Map<String, String> monthMoods = {};
      Map<int, double> usageData = {};

      for (int day = 1; day <= lastDay.day; day++) {
        final date = DateTime(selectedDate.year, selectedDate.month, day);

        final moodImage = await _moodService.getMoodImage(date);
        if (moodImage != null) {
          monthMoods[_formatDateKey(date)] = moodImage;
        }

        final mood = await _moodService.getDailyMood(date);
        if (mood != null && mood.totalUsageMinutes != null) {
          final usageHours = mood.totalUsageMinutes! / 60.0;
          usageData[day] = usageHours;
        }
      }

      // Nếu hôm nay có dữ liệu thời gian thực mà mood chưa lưu, cập nhật từ usage_tracker
      final now = DateTime.now();
      if (selectedDate.month == now.month && selectedDate.year == now.year) {
        final todayDuration = await UsageTracker.getTodayTotalUsage();
        if (todayDuration.inMinutes > 0) {
          usageData[now.day] = todayDuration.inMinutes / 60.0;
        }
      }

      if (mounted) {
        setState(() {
          dailyMoods = monthMoods;
          weeklyUsageHours = usageData;
        });
      }
    } catch (e) {
      debugPrint('Error loading month data: $e');
    }
  }

  Future<void> _loadDayUsage(DateTime date) async {
    setState(() => _isLoadingDayUsage = true);

    try {
      final now = DateTime.now();
      final isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      List<AppUsageInfo> apps = [];

      if (isToday) {
        apps = await _realUsageService.getTodayUsage();
      } else {
        // Truy vấn dữ liệu ngày trong quá khứ qua UsageStats
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

        final List<UsageInfo> stats =
            await UsageStats.queryUsageStats(startOfDay, endOfDay);

        for (final info in stats) {
          final pkg = info.packageName ?? '';
          final ms = int.tryParse(info.totalTimeInForeground ?? '0') ?? 0;

          if (ms >= 10000 && !_isExcludedPackage(pkg)) {
            apps.add(
              AppUsageInfo(
                packageName: pkg,
                appName: _formatCleanAppName(pkg),
                usage: Duration(milliseconds: ms),
                startTime: startOfDay,
                endTime: endOfDay,
              ),
            );
          }
        }
        apps.sort((a, b) => b.usage.compareTo(a.usage));
      }

      final total = apps.fold<Duration>(
        Duration.zero,
        (sum, item) => sum + item.usage,
      );

      if (mounted) {
        setState(() {
          _selectedDay = date;
          _selectedDayApps = apps;
          _selectedDayTotalUsage = total;
          _isLoadingDayUsage = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading day usage: $e');
      if (mounted) {
        setState(() => _isLoadingDayUsage = false);
      }
    }
  }

  bool _isExcludedPackage(String pkg) {
    const knownLaunchers = {
      'com.android.launcher',
      'com.android.launcher3',
      'com.google.android.apps.nexuslauncher',
      'com.sec.android.app.launcher',
      'com.miui.home',
      'com.oppo.launcher',
      'com.huawei.android.launcher',
      'com.example.brainrot',
    };
    return knownLaunchers.contains(pkg) || pkg.isEmpty;
  }

  String _formatCleanAppName(String pkg) {
    final parts = pkg.split('.');
    if (parts.isNotEmpty) {
      final name = parts.last;
      return name[0].toUpperCase() + name.substring(1);
    }
    return pkg;
  }

  Future<void> _openNativeDigitalWellbeing() async {
    const channel = MethodChannel('com.example.brainrot/usage');
    try {
      await channel.invokeMethod('openDigitalWellbeing');
    } catch (e) {
      debugPrint('Error opening digital wellbeing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF171513) : const Color(0xFFFFF8EF);
    final cardColor = isDark ? const Color(0xFF24211E) : Colors.white;
    final primaryText = isDark ? const Color(0xFFF8F4EF) : CalendarScreen._ink;
    final secondaryText =
        isDark ? const Color(0xFFB8B0A8) : const Color(0xFF7A736D);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          'Lịch & Báo cáo',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: primaryText,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector
            _buildMonthSelector(primaryText, secondaryText),
            const SizedBox(height: 12),

            // Calendar Container Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildWeekdayHeader(secondaryText),
                  const SizedBox(height: 10),
                  _buildCalendarGrid(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Weekly Bar Chart
            _buildWeeklyUsageCard(cardColor, primaryText, secondaryText),
            const SizedBox(height: 24),

            // SƠ ĐỒ TRÒN DIGITAL WELLBEING BREAKDOWN (Cách 1)
            _buildDonutBreakdownCard(
                cardColor, primaryText, secondaryText, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(Color primaryText, Color secondaryText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              selectedDate = DateTime(
                selectedDate.year,
                selectedDate.month - 1,
              );
            });
            _loadMonthData();
          },
          icon: Icon(Icons.chevron_left_rounded, size: 28, color: primaryText),
        ),
        Text(
          _getMonthYear(selectedDate),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: primaryText,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              selectedDate = DateTime(
                selectedDate.year,
                selectedDate.month + 1,
              );
            });
            _loadMonthData();
          },
          icon: Icon(Icons.chevron_right_rounded, size: 28, color: primaryText),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(Color secondaryText) {
    const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return Row(
      children: days
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: secondaryText,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.82,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final dayNumber = index - firstWeekday + 1;

        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final cellDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          dayNumber,
        );

        final isSelected = cellDate.year == _selectedDay.year &&
            cellDate.month == _selectedDay.month &&
            cellDate.day == _selectedDay.day;

        return RepaintBoundary(
          child: _CalendarDayCell(
            dayNumber: dayNumber,
            cellDate: cellDate,
            isSelected: isSelected,
            dailyMoods: dailyMoods,
            onTap: () {
              _loadDayUsage(cellDate);
            },
          ),
        );
      },
    );
  }

  Widget _buildWeeklyUsageCard(
      Color cardColor, Color primaryText, Color secondaryText) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thời gian dùng 7 ngày qua',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: primaryText,
                ),
              ),
              Text(
                'Chạm cột để xem',
                style: TextStyle(fontSize: 12, color: secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildWeeklyChart(primaryText, secondaryText),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(Color primaryText, Color secondaryText) {
    final now = DateTime.now();
    final weekData = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = _getDayName(date.weekday);
      final hours = weeklyUsageHours[date.day] ?? 0.0;
      final isSelected = date.year == _selectedDay.year &&
          date.month == _selectedDay.month &&
          date.day == _selectedDay.day;

      weekData.add({
        'date': date,
        'day': dayName,
        'hours': hours,
        'isSelected': isSelected,
      });
    }

    final maxHours = weekData
        .map((d) => d['hours'] as double)
        .reduce((a, b) => a > b ? a : b);
    const chartHeight = 120.0;

    return SizedBox(
      height: chartHeight + 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: weekData.map((data) {
          final hours = data['hours'] as double;
          final date = data['date'] as DateTime;
          final isSelected = data['isSelected'] as bool;
          final barHeight =
              maxHours > 0 ? (hours / maxHours) * chartHeight : 0.0;

          return Expanded(
            child: InkWell(
              onTap: () {
                _loadDayUsage(date);
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (hours > 0)
                      Text(
                        '${hours.toStringAsFixed(1)}h',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? CalendarScreen._accent
                              : secondaryText,
                        ),
                      ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      height: barHeight.clamp(6.0, chartHeight),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CalendarScreen._accent
                            : CalendarScreen._accent.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                        border: isSelected
                            ? Border.all(
                                color: CalendarScreen._accent, width: 2)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['day'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color:
                            isSelected ? CalendarScreen._accent : primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// SƠ ĐỒ TRÒN PHÂN BỔ THỜI GIAN ỨNG DỤNG (Digital Wellbeing Donut Chart)
  Widget _buildDonutBreakdownCard(
      Color cardColor, Color primaryText, Color secondaryText, bool isDark) {
    final topApps = _selectedDayApps.take(5).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.donut_large_rounded,
                      color: CalendarScreen._accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phân bổ ứng dụng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: primaryText,
                        ),
                      ),
                      Text(
                        _formatDayTitle(_selectedDay),
                        style: TextStyle(fontSize: 12, color: secondaryText),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CalendarScreen._accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Digital Wellbeing',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: CalendarScreen._accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_isLoadingDayUsage)
            const SizedBox(
              height: 220,
              child: Center(
                child: CircularProgressIndicator(color: CalendarScreen._accent),
              ),
            )
          else ...[
            // Donut Chart Graphic
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(200, 200),
                      painter: _DonutChartPainter(
                        apps: topApps,
                        totalDuration: _selectedDayTotalUsage,
                        colors: _chartColors,
                        emptyColor: isDark
                            ? Colors.white.withOpacity(0.08)
                            : const Color(0xFFF0EAE4),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.touch_app_rounded,
                          size: 18,
                          color: CalendarScreen._accent,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDurationDisplay(_selectedDayTotalUsage),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: primaryText,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Tổng thời gian',
                          style: TextStyle(
                            fontSize: 11,
                            color: secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),

            // Top Apps List
            if (topApps.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Không có dữ liệu sử dụng cho ngày này.',
                    style: TextStyle(color: secondaryText, fontSize: 13),
                  ),
                ),
              )
            else ...[
              Text(
                'Ứng dụng dùng nhiều nhất',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: secondaryText,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(topApps.length, (index) {
                final app = topApps[index];
                final color = _chartColors[index % _chartColors.length];
                final percent = app.getUsagePercentage(_selectedDayTotalUsage);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _AppIconThumb(packageName: app.packageName),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              app.appName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: primaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            app.formattedUsage,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: primaryText,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${percent.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (percent / 100).clamp(0.0, 1.0),
                          minHeight: 5,
                          backgroundColor: isDark
                              ? Colors.white.withOpacity(0.06)
                              : const Color(0xFFF0EAE4),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Nút mở Native Digital Wellbeing của hệ điều hành
            Center(
              child: TextButton.icon(
                onPressed: _openNativeDigitalWellbeing,
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text(
                  'Mở Digital Wellbeing của Android',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: CalendarScreen._accent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDurationDisplay(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatDayTitle(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Hôm nay, ngày ${date.day}/${date.month}';
    }
    const days = ['CN', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
    final dayOfWeek = days[date.weekday % 7];
    return '$dayOfWeek, ngày ${date.day}/${date.month}';
  }

  String _getDayName(int weekday) {
    const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return days[weekday % 7];
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getMonthYear(DateTime date) {
    const months = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _CalendarDayCell extends StatelessWidget {
  final int dayNumber;
  final DateTime cellDate;
  final bool isSelected;
  final Map<String, String> dailyMoods;
  final VoidCallback onTap;

  const _CalendarDayCell({
    required this.dayNumber,
    required this.cellDate,
    required this.isSelected,
    required this.dailyMoods,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = dayNumber == now.day &&
        cellDate.month == now.month &&
        cellDate.year == now.year;

    final moodImage = dailyMoods[_formatDateKey(cellDate)];
    final hasActivity = moodImage != null;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? CalendarScreen._accent.withOpacity(isDark ? 0.25 : 0.15)
              : (isDark ? const Color(0xFF1E1C1A) : const Color(0xFFFAF7F2)),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: CalendarScreen._accent, width: 2)
              : (isToday
                  ? Border.all(
                      color: CalendarScreen._accent.withOpacity(0.5),
                      width: 1.5)
                  : null),
        ),
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayNumber.toString(),
              style: TextStyle(
                fontWeight:
                    isSelected || isToday ? FontWeight.bold : FontWeight.w600,
                color: isSelected || isToday
                    ? CalendarScreen._accent
                    : (isDark ? Colors.white : Colors.black),
                fontSize: 12,
              ),
            ),
            if (hasActivity) ...[
              const SizedBox(height: 2),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    moodImage,
                    fit: BoxFit.cover,
                    cacheWidth: 40,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.sentiment_satisfied_rounded,
                        color: CalendarScreen._accent,
                        size: 16,
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _AppIconThumb extends StatelessWidget {
  const _AppIconThumb({required this.packageName});

  final String packageName;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: AppIconService().getAppIcon(packageName),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.memory(
              snapshot.data!,
              width: 22,
              height: 22,
              fit: BoxFit.cover,
            ),
          );
        }
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0E5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.apps_rounded,
            size: 14,
            color: CalendarScreen._accent,
          ),
        );
      },
    );
  }
}

/// CustomPainter vẽ vòng Donut Chart với các segment ứng dụng
class _DonutChartPainter extends CustomPainter {
  final List<AppUsageInfo> apps;
  final Duration totalDuration;
  final List<Color> colors;
  final Color emptyColor;

  _DonutChartPainter({
    required this.apps,
    required this.totalDuration,
    required this.colors,
    required this.emptyColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 24.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = emptyColor;

    // Vẽ vòng tròn nền
    canvas.drawCircle(center, radius, basePaint);

    if (totalDuration.inMilliseconds == 0 || apps.isEmpty) {
      return;
    }

    double startAngle = -math.pi / 2; // Bắt đầu ở đỉnh 12h
    const gapAngle = 0.04; // Khoảng cách nhỏ giữa các cung

    for (int i = 0; i < apps.length; i++) {
      final app = apps[i];
      final ratio = app.usage.inMilliseconds / totalDuration.inMilliseconds;
      final sweepAngle = (ratio * 2 * math.pi) - gapAngle;

      if (sweepAngle > 0) {
        final arcPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = colors[i % colors.length];

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + (gapAngle / 2),
          sweepAngle,
          false,
          arcPaint,
        );
      }

      startAngle += (ratio * 2 * math.pi);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.apps != apps ||
        oldDelegate.totalDuration != totalDuration ||
        oldDelegate.emptyColor != emptyColor;
  }
}
