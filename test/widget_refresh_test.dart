import 'package:brainrot/view_model/home_view_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const usageChannel = MethodChannel('com.example.brainrot/usage');
  const widgetChannel = MethodChannel('home_widget');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final savedData = <String, dynamic>{};
  var updates = 0;
  var minutes = 0;
  var hasPermission = true;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    savedData.clear();
    updates = 0;
    minutes = 0;
    hasPermission = true;
    messenger.setMockMethodCallHandler(usageChannel, (call) async {
      switch (call.method) {
        case 'hasUsagePermission':
          return hasPermission;
        case 'getUsageStats':
          return [
            {
              'packageName': 'test.app',
              'appName': 'Test app',
              'usageTimeMillis': Duration(minutes: minutes).inMilliseconds,
            }
          ];
        case 'getMultipleAppIcons':
          return <String, dynamic>{};
        default:
          throw StateError('Unexpected usage call: ${call.method}');
      }
    });
    messenger.setMockMethodCallHandler(widgetChannel, (call) async {
      final args = Map<String, dynamic>.from(call.arguments as Map);
      if (call.method == 'saveWidgetData') {
        savedData[args['id'] as String] = args['data'];
      } else if (call.method == 'updateWidget') {
        updates++;
      } else {
        throw StateError('Unexpected widget call: ${call.method}');
      }
      return true;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(usageChannel, null);
    messenger.setMockMethodCallHandler(widgetChannel, null);
  });

  test('silent refresh publishes each mood transition and the new day', () async {
    final model = HomeViewModel();
    addTearDown(model.dispose);
    for (final entry in {
      150: 'vui',
      151: 'suynghi',
      210: 'suynghi',
      211: 'cangthang',
      300: 'cangthang',
      301: 'buonngu',
      0: 'vui',
    }.entries) {
      minutes = entry.key;
      final previousUpdates = updates;
      await model.silentRefresh();
      expect(model.errorMessage, isNull);
      expect(updates, previousUpdates + 1);
      expect(savedData['widget_mood_image'], entry.value);
      expect(savedData['widget_score'], model.currentScore.toInt());
    }
  });

  test('silent refresh publishes even when the score has not changed', () async {
    final model = HomeViewModel();
    addTearDown(model.dispose);
    await model.silentRefresh();
    await model.silentRefresh();
    expect(updates, 2);
  });

  test('denied usage access preserves the last widget mood', () async {
    final model = HomeViewModel();
    addTearDown(model.dispose);
    hasPermission = false;
    await model.silentRefresh();
    expect(updates, 0);
    expect(savedData, isEmpty);
  });
}
