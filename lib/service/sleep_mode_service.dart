import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../model/sleep_schedule.dart';

class SleepModeService {
  SleepModeService._();
  static final instance = SleepModeService._();
  static const _channel = MethodChannel('com.example.brainrot/usage');

  SleepSchedule _schedule = const SleepSchedule();
  SleepSchedule get schedule => _schedule;
  Set<String> essentialPackages = {};
  bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> load() async {
    if (!supported) return;
    final data =
        await _channel.invokeMapMethod<String, dynamic>('getSleepMode');
    if (data == null) throw StateError('Could not load sleep mode');
    final schedule =
        SleepSchedule.fromJson(jsonDecode(data['schedule'] as String));
    essentialPackages = Set<String>.from(data['essentialPackages'] as List);
    _schedule = schedule;
  }

  Future<void> save(SleepSchedule value) async {
    if (!supported) throw UnsupportedError('Sleep mode requires Android');
    // Validate before crossing the platform boundary.
    SleepSchedule.fromJson(value.toJson());
    final saved = await _channel.invokeMethod<bool>('setSleepMode', {
      'schedule': jsonEncode(value.toJson()),
    });
    if (saved != true) throw StateError('Could not save sleep mode');
    _schedule = value;
  }

  bool shouldBlock(String packageName, DateTime now) =>
      schedule.isActiveAt(now) &&
      !essentialPackages.contains(packageName) &&
      !schedule.allowedPackages.contains(packageName);
}
