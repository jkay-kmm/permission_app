import 'package:flutter/material.dart';

enum AppThemeStyle { sunset, ocean, violet }

extension AppThemeStyleColors on AppThemeStyle {
  Color get seed => switch (this) {
        AppThemeStyle.sunset => const Color(0xFFF27A3D),
        AppThemeStyle.ocean => const Color(0xFF176BA0),
        AppThemeStyle.violet => const Color(0xFF7554B8),
      };

  Color background(Brightness brightness) => switch ((this, brightness)) {
        (AppThemeStyle.sunset, Brightness.light) => const Color(0xFFFFF8EF),
        (AppThemeStyle.ocean, Brightness.light) => const Color(0xFFF0F7FC),
        (AppThemeStyle.violet, Brightness.light) => const Color(0xFFF7F2FC),
        (AppThemeStyle.sunset, Brightness.dark) => const Color(0xFF171513),
        (AppThemeStyle.ocean, Brightness.dark) => const Color(0xFF101C26),
        (AppThemeStyle.violet, Brightness.dark) => const Color(0xFF1C1727),
      };

  ThemeData theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    final backgroundColor = background(brightness);
    final surface = brightness == Brightness.light
        ? Colors.white
        : Color.alphaBlend(seed.withOpacity(.12), backgroundColor);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(surface: surface),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(backgroundColor: backgroundColor),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
