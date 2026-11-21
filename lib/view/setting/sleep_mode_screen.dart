import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../model/sleep_schedule.dart';
import '../../service/permission_service.dart';
import '../../service/sleep_mode_service.dart';

class SleepModeScreen extends StatefulWidget {
  const SleepModeScreen({super.key});

  @override
  State<SleepModeScreen> createState() => _SleepModeScreenState();
}

class _SleepModeScreenState extends State<SleepModeScreen>
    with WidgetsBindingObserver {
  final _service = SleepModeService.instance;
  final _permissions = PermissionService();
  bool _loading = true;
  bool _failed = false;
  bool _saving = false;
  bool _hasPermission = false;
  bool _enabled = false;
  int _start = 22 * 60;
  int _end = 7 * 60;
  Set<int> _days = {1, 2, 3, 4, 5, 6, 7};
  Set<String> _allowed = {};
  List<Map<String, String>> _apps = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await _permissions.hasAccessibilityPermission();
    if (mounted) setState(() => _hasPermission = granted);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      await _service.load();
      final apps = await _permissions.getLaunchableApps(throwOnError: true);
      await _checkPermission();
      if (!mounted) return;
      final value = _service.schedule;
      setState(() {
        _enabled = value.enabled;
        _start = value.startMinute;
        _end = value.endMinute;
        _days = value.days.toSet();
        _allowed = value.allowedPackages.toSet();
        _apps = apps;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickTime(bool start) async {
    final value = start ? _start : _end;
    final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: value ~/ 60, minute: value % 60));
    if (time == null || !mounted) return;
    setState(() {
      if (start) {
        _start = time.hour * 60 + time.minute;
      } else {
        _end = time.hour * 60 + time.minute;
      }
    });
  }

  Future<void> _save({bool? startNow}) async {
    final t = AppLocalizations.of(context);
    if (_start == _end || _days.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.sleepInvalidSchedule)));
      return;
    }
    setState(() => _saving = true);
    final now = DateTime.now();
    final old = _service.schedule;
    final draft = SleepSchedule(
        enabled: _enabled,
        startMinute: _start,
        endMinute: _end,
        days: _days.toList()..sort(),
        allowedPackages: _allowed.toList());
    final until = draft.nextWakeTime(now).millisecondsSinceEpoch;
    try {
      await _service.save(SleepSchedule(
        enabled: draft.enabled,
        startMinute: _start,
        endMinute: _end,
        days: draft.days,
        allowedPackages: draft.allowedPackages,
        manualUntil: startNow == true
            ? until
            : startNow == false
                ? 0
                : old.manualUntil,
        pausedUntil: startNow == false
            ? until
            : startNow == true
                ? 0
                : old.pausedUntil,
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.sleepSaved)));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.sleepSaveFailed)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _format(int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final active = _service.schedule.isActiveAt(DateTime.now());
    final dayNames = MaterialLocalizations.of(context).narrowWeekdays;
    return Scaffold(
      appBar: AppBar(title: Text(t.sleepModeTitle)),
      bottomNavigationBar: _service.supported && !_loading && !_failed
          ? SafeArea(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: FilledButton.icon(
                    onPressed: _saving ? null : () => _save(),
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check),
                    label: Text(t.sleepSave),
                  )))
          : null,
      body: !_service.supported
          ? Center(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(t.sleepAndroidOnly)))
          : _loading
              ? const Center(child: CircularProgressIndicator())
              : _failed
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(t.sleepLoadFailed),
                      TextButton(onPressed: _load, child: Text(t.retry)),
                    ]))
                  : AbsorbPointer(
                      absorbing: _saving,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                borderRadius: BorderRadius.circular(24)),
                            child: Column(children: [
                              Icon(
                                  active
                                      ? Icons.bedtime_rounded
                                      : Icons.bedtime_outlined,
                                  size: 44,
                                  color: colors.onPrimaryContainer),
                              const SizedBox(height: 12),
                              Text(active ? t.sleepActive : t.sleepInactive,
                                  style: Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                              Text(t.sleepDescription,
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              FilledButton(
                                  onPressed:
                                      _saving || (!active && !_hasPermission)
                                          ? null
                                          : () => _save(startNow: !active),
                                  child: Text(active
                                      ? t.sleepEndNow
                                      : t.sleepStartNow)),
                            ]),
                          ),
                          const SizedBox(height: 16),
                          if (!_hasPermission)
                            Card(
                                child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.permissionBannerTitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    const SizedBox(height: 8),
                                    Text(t.sleepPermissionHint),
                                    TextButton(
                                        onPressed: _permissions
                                            .requestAccessibilityPermission,
                                        child: Text(t.grantPermission)),
                                  ]),
                            )),
                          Card(
                              child: Column(children: [
                            SwitchListTile(
                                title: Text(t.sleepAutoSchedule),
                                subtitle: Text(t.sleepDaysHint),
                                value: _enabled,
                                onChanged: (value) =>
                                    setState(() => _enabled = value)),
                            ListTile(
                                leading: const Icon(Icons.bedtime_outlined),
                                title: Text(t.sleepBedtime),
                                trailing: Text(_format(_start)),
                                onTap: () => _pickTime(true)),
                            ListTile(
                                leading: const Icon(Icons.wb_sunny_outlined),
                                title: Text(t.sleepWakeTime),
                                trailing: Text(_format(_end)),
                                onTap: () => _pickTime(false)),
                            Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 0, 12, 16),
                                child:
                                    Wrap(spacing: 6, runSpacing: 4, children: [
                                  for (var day = 1; day <= 7; day++)
                                    FilterChip(
                                        label: Text(dayNames[day % 7]),
                                        tooltip: DateFormat.EEEE(
                                                Localizations.localeOf(context)
                                                    .toString())
                                            .format(DateTime(2024, 1, day)),
                                        selected: _days.contains(day),
                                        onSelected: (selected) => setState(() {
                                              if (selected) {
                                                _days.add(day);
                                              } else {
                                                _days.remove(day);
                                              }
                                            })),
                                ])),
                          ])),
                          const SizedBox(height: 16),
                          Text(t.sleepAllowedApps,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(t.sleepAllowedHint),
                          const SizedBox(height: 8),
                          if (_apps.isEmpty)
                            Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(t.noAvailableApps)),
                          Card(
                              child: Column(children: [
                            for (final app in _apps)
                              CheckboxListTile(
                                title: Text(app['appName']!),
                                subtitle: _service.essentialPackages
                                        .contains(app['packageName'])
                                    ? Text(t.sleepEssentialApp)
                                    : null,
                                value: _allowed.contains(app['packageName']) ||
                                    _service.essentialPackages
                                        .contains(app['packageName']),
                                onChanged: _service.essentialPackages
                                        .contains(app['packageName'])
                                    ? null
                                    : (selected) => setState(() {
                                          if (selected == true) {
                                            _allowed.add(app['packageName']!);
                                          } else {
                                            _allowed.remove(app['packageName']);
                                          }
                                        }),
                              ),
                          ])),
                          const SizedBox(height: 16),
                          Text(t.sleepSystemHint),
                          const SizedBox(height: 16),
                        ],
                      )),
    );
  }
}
