class SleepSchedule {
  const SleepSchedule({
    this.enabled = false,
    this.startMinute = 22 * 60,
    this.endMinute = 7 * 60,
    this.days = const [1, 2, 3, 4, 5, 6, 7],
    this.allowedPackages = const [],
    this.manualUntil = 0,
    this.pausedUntil = 0,
  });

  final bool enabled;
  final int startMinute;
  final int endMinute;
  // Days refer to the evening the sleep period starts.
  final List<int> days;
  final List<String> allowedPackages;
  final int manualUntil;
  final int pausedUntil;

  bool isActiveAt(DateTime now) {
    if (now.millisecondsSinceEpoch < pausedUntil) return false;
    if (now.millisecondsSinceEpoch < manualUntil) return true;
    if (!enabled || days.isEmpty || startMinute == endMinute) return false;
    final minute = now.hour * 60 + now.minute;
    if (startMinute < endMinute) {
      return days.contains(now.weekday) &&
          minute >= startMinute &&
          minute < endMinute;
    }
    final previousDay = now.weekday == 1 ? 7 : now.weekday - 1;
    return (minute >= startMinute && days.contains(now.weekday)) ||
        (minute < endMinute && days.contains(previousDay));
  }

  DateTime nextWakeTime(DateTime now) {
    final today =
        DateTime(now.year, now.month, now.day, endMinute ~/ 60, endMinute % 60);
    return today.isAfter(now)
        ? today
        : DateTime(
            now.year, now.month, now.day + 1, endMinute ~/ 60, endMinute % 60);
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'startMinute': startMinute,
        'endMinute': endMinute,
        'days': days,
        'allowedPackages': allowedPackages,
        'manualUntil': manualUntil,
        'pausedUntil': pausedUntil,
      };

  factory SleepSchedule.fromJson(Map<String, dynamic> json) {
    final start = json['startMinute'] as int? ?? 22 * 60;
    final end = json['endMinute'] as int? ?? 7 * 60;
    final days = List<int>.from(json['days'] ?? [1, 2, 3, 4, 5, 6, 7]);
    if (start < 0 ||
        start >= 1440 ||
        end < 0 ||
        end >= 1440 ||
        start == end ||
        days.isEmpty ||
        days.any((day) => day < 1 || day > 7)) {
      throw const FormatException('Invalid sleep schedule');
    }
    return SleepSchedule(
      enabled: json['enabled'] as bool? ?? false,
      startMinute: start,
      endMinute: end,
      days: days,
      allowedPackages: List<String>.from(json['allowedPackages'] ?? []),
      manualUntil: json['manualUntil'] as int? ?? 0,
      pausedUntil: json['pausedUntil'] as int? ?? 0,
    );
  }
}
