import 'package:brainrot/model/sleep_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mondayNight = SleepSchedule(enabled: true, days: [1]);

  test('overnight schedule belongs to the day bedtime starts, end is exclusive',
      () {
    expect(mondayNight.isActiveAt(DateTime(2026, 11, 16, 21, 59)), isFalse);
    expect(mondayNight.isActiveAt(DateTime(2026, 11, 16, 22)), isTrue);
    expect(mondayNight.isActiveAt(DateTime(2026, 11, 17, 0)), isTrue);
    expect(mondayNight.isActiveAt(DateTime(2026, 11, 17, 6, 59)), isTrue);
    expect(mondayNight.isActiveAt(DateTime(2026, 11, 17, 7)), isFalse);
    expect(mondayNight.isActiveAt(DateTime(2026, 11, 16, 6)), isFalse);
    expect(mondayNight.isActiveAt(DateTime(2026, 11, 17, 22)), isFalse);
  });

  test('Sunday bedtime continues into Monday morning', () {
    const sunday = SleepSchedule(enabled: true, days: [7]);
    expect(sunday.isActiveAt(DateTime(2026, 11, 16, 6)), isTrue);
    expect(sunday.isActiveAt(DateTime(2026, 11, 17, 6)), isFalse);
  });

  test('same-day sleep respects selected days and exact boundaries', () {
    const nap = SleepSchedule(
        enabled: true, startMinute: 13 * 60, endMinute: 14 * 60, days: [1]);
    expect(nap.isActiveAt(DateTime(2026, 11, 16, 13)), isTrue);
    expect(nap.isActiveAt(DateTime(2026, 11, 16, 14)), isFalse);
    expect(nap.isActiveAt(DateTime(2026, 11, 17, 13, 30)), isFalse);
    expect(
        const SleepSchedule().isActiveAt(DateTime(2026, 11, 16, 23)), isFalse);
  });

  test('manual sleep expires at the next wake time even without a schedule',
      () {
    final now = DateTime(2026, 11, 16, 21);
    final wake = mondayNight.nextWakeTime(now);
    expect(wake, DateTime(2026, 11, 17, 7));
    final manual = SleepSchedule(manualUntil: wake.millisecondsSinceEpoch);
    expect(manual.isActiveAt(now), isTrue);
    expect(manual.isActiveAt(wake), isFalse);
    expect(mondayNight.nextWakeTime(DateTime(2026, 11, 17, 6)), wake);
    expect(mondayNight.nextWakeTime(wake), DateTime(2026, 11, 18, 7));
  });

  test(
      'ending a session skips this night and preserves the next scheduled night',
      () {
    final until = DateTime(2026, 11, 17, 7).millisecondsSinceEpoch;
    final paused = SleepSchedule(enabled: true, pausedUntil: until);
    expect(paused.isActiveAt(DateTime(2026, 11, 16, 23)), isFalse);
    expect(paused.isActiveAt(DateTime(2026, 11, 17, 6)), isFalse);
    expect(paused.isActiveAt(DateTime(2026, 11, 17, 22)), isTrue);
  });

  test('settings round trip keeps schedule, exceptions and session override',
      () {
    const original = SleepSchedule(
        enabled: true,
        days: [1, 5],
        allowedPackages: ['com.example.music'],
        manualUntil: 123456789);
    expect(
        SleepSchedule.fromJson(original.toJson()).toJson(), original.toJson());
    expect(SleepSchedule.fromJson({}).enabled, isFalse);
  });

  test('invalid schedules are rejected before saving', () {
    for (final json in [
      {'startMinute': -1},
      {'endMinute': 1440},
      {'days': <int>[]},
      {
        'days': [0]
      },
      {
        'days': [8]
      },
      {'startMinute': 420, 'endMinute': 420},
    ]) {
      expect(() => SleepSchedule.fromJson(json), throwsFormatException);
    }
  });
}
