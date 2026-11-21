import 'dart:convert';
import 'package:brainrot/l10n/app_localizations.dart';
import 'package:brainrot/model/sleep_schedule.dart';
import 'package:brainrot/service/sleep_mode_service.dart';
import 'package:brainrot/view/setting/sleep_mode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.example.brainrot/usage');
  late Map<String, dynamic> stored;
  late bool permission;
  late bool failSave;
  late bool failApps;

  setUp(() {
    stored = const SleepSchedule().toJson();
    permission = true;
    failSave = false;
    failApps = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'getSleepMode':
          return {
            'schedule': jsonEncode(stored),
            'essentialPackages': ['phone']
          };
        case 'getLaunchableApps':
          if (failApps) throw PlatformException(code: 'APPS');
          return [
            {'packageName': 'phone', 'appName': 'Phone'},
            {'packageName': 'music', 'appName': 'Music'},
          ];
        case 'hasAccessibilityPermission':
          return permission;
        case 'requestAccessibilityPermission':
          return true;
        case 'setSleepMode':
          if (failSave) throw PlatformException(code: 'SAVE');
          stored =
              Map<String, dynamic>.from(jsonDecode(call.arguments['schedule']));
          return true;
      }
      throw MissingPluginException(call.method);
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<void> open(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('vi'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      home: SleepModeScreen(),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('saves automatic schedule and exceptions and restores them',
      (tester) async {
    await open(tester);
    final phone = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, 'Phone'));
    expect(phone.value, isTrue);
    expect(phone.onChanged, isNull);
    await tester.tap(find.byType(SwitchListTile));
    await tester.ensureVisible(find.text('Music'));
    await tester.tap(find.text('Music'));
    await tester.ensureVisible(find.text('Lưu cài đặt'));
    await tester.tap(find.text('Lưu cài đặt'));
    await tester.pumpAndSettle();
    expect(stored['enabled'], isTrue);
    expect(stored['allowedPackages'], ['music']);
    expect(
        SleepModeService.instance
            .shouldBlock('music', DateTime(2026, 11, 16, 23)),
        isFalse);
    expect(
        SleepModeService.instance
            .shouldBlock('phone', DateTime(2026, 11, 16, 23)),
        isFalse);
    expect(
        SleepModeService.instance
            .shouldBlock('new.app', DateTime(2026, 11, 16, 23)),
        isTrue);
    await tester.pumpWidget(const SizedBox());
    await open(tester);
    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue);
    expect(
        tester
            .widget<CheckboxListTile>(
                find.widgetWithText(CheckboxListTile, 'Music'))
            .value,
        isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('manual sleep starts and ends without deleting the schedule',
      (tester) async {
    await open(tester);
    await tester.tap(find.text('Lưu và ngủ ngay đến giờ thức'));
    await tester.pumpAndSettle();
    expect(stored['manualUntil'],
        greaterThan(DateTime.now().millisecondsSinceEpoch));
    expect(find.text('Đang trong giờ nghỉ'), findsOneWidget);
    await tester.tap(find.text('Kết thúc phiên ngủ hiện tại'));
    await tester.pumpAndSettle();
    expect(stored['manualUntil'], 0);
    expect(stored['pausedUntil'],
        greaterThan(DateTime.now().millisecondsSinceEpoch));
    expect(stored['days'], [1, 2, 3, 4, 5, 6, 7]);
    expect(find.text('Chưa bật chế độ ngủ'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'permission warning prevents manual activation until permission is granted',
      (tester) async {
    permission = false;
    await open(tester);
    expect(find.text('Cấp quyền'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(find.widgetWithText(
                FilledButton, 'Lưu và ngủ ngay đến giờ thức'))
            .onPressed,
        isNull);
    permission = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('Cấp quyền'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('save failure keeps the previous settings and reports the error',
      (tester) async {
    await open(tester);
    failSave = true;
    await tester.tap(find.byType(SwitchListTile));
    await tester.ensureVisible(find.text('Lưu cài đặt'));
    await tester.tap(find.text('Lưu cài đặt'));
    await tester.pumpAndSettle();
    expect(stored['enabled'], isFalse);
    expect(SleepModeService.instance.schedule.enabled, isFalse);
    expect(find.text('Không lưu được chế độ ngủ. Vui lòng thử lại.'),
        findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'app list failure offers retry instead of saving an incomplete list',
      (tester) async {
    failApps = true;
    await open(tester);
    expect(find.text('Không tải được cài đặt chế độ ngủ.'), findsOneWidget);
    failApps = false;
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Music'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
