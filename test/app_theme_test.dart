import 'package:brainrot/theme/app_theme.dart';
import 'package:brainrot/view_model/app_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('three themes have distinct palettes and survive reload', () async {
    SharedPreferences.setMockInitialValues({});
    final seeds = AppThemeStyle.values.map((style) => style.seed).toSet();
    expect(seeds.length, 3);
    for (final style in AppThemeStyle.values) {
      final light = style.theme(Brightness.light);
      final dark = style.theme(Brightness.dark);
      expect(light.colorScheme.primary, isNot(dark.colorScheme.primary));
      expect(light.scaffoldBackgroundColor, isNot(dark.scaffoldBackgroundColor));
    }

    final settings = AppViewModel();
    await settings.setThemeStyle(AppThemeStyle.ocean);
    final reloaded = AppViewModel();
    await reloaded.loadSettings();
    expect(reloaded.themeStyle, AppThemeStyle.ocean);
  });
}
