import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../view_model/app_view_model.dart';
import '../../l10n/app_localizations.dart';

class ThemePickerScreen extends StatefulWidget {
  const ThemePickerScreen({super.key});

  @override
  State<ThemePickerScreen> createState() => _ThemePickerScreenState();
}

class _ThemePickerScreenState extends State<ThemePickerScreen> {
  late AppThemeStyle selected;
  int preview = 0;

  @override
  void initState() {
    super.initState();
    selected = context.read<AppViewModel>().themeStyle;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final scheme = selected.theme(dark ? Brightness.dark : Brightness.light).colorScheme;
    final names = [t.themeSunset, t.themeOcean, t.themeViolet];
    return Scaffold(
      appBar: AppBar(title: Text(t.changeTheme)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(t.themePreviewHint),
                  const SizedBox(height: 16),
                  SegmentedButton<int>(
                    segments: [
                      ButtonSegment(value: 0, label: Text(t.navHome)),
                      ButtonSegment(value: 1, label: Text(t.navCalendar)),
                    ],
                    selected: {preview},
                    onSelectionChanged: (value) => setState(() => preview = value.first),
                  ),
                  const SizedBox(height: 16),
                  _ThemePreview(style: selected, scheme: scheme, calendar: preview == 1),
                  const SizedBox(height: 20),
                  for (final style in AppThemeStyle.values)
                    Card(
                      child: RadioListTile<AppThemeStyle>(
                        title: Text(names[style.index]),
                        secondary: CircleAvatar(backgroundColor: style.seed),
                        value: style,
                        groupValue: selected,
                        onChanged: (value) => setState(() => selected = value!),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await context.read<AppViewModel>().setThemeStyle(selected);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: Text(t.applyTheme),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.style, required this.scheme, required this.calendar});

  final AppThemeStyle style;
  final ColorScheme scheme;
  final bool calendar;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: style.background(scheme.brightness),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(calendar ? t.navCalendar : t.navHome,
              style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: calendar
                  ? Column(
                      children: [
                        Text(t.calendarReportTitle, style: TextStyle(color: scheme.onSurface)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(7, (i) => CircleAvatar(
                            radius: 12,
                            backgroundColor: i == 3 ? scheme.primary : scheme.surfaceContainerHighest,
                            child: Text('${i + 1}', style: TextStyle(fontSize: 10,
                                color: i == 3 ? scheme.onPrimary : scheme.onSurface)),
                          )),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(value: .65, color: scheme.primary),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.homeScoreSubtitle, style: TextStyle(color: scheme.onSurfaceVariant)),
                        Text('82', style: TextStyle(color: scheme.primary, fontSize: 44,
                            fontWeight: FontWeight.bold)),
                        LinearProgressIndicator(value: .82, color: scheme.primary),
                        const SizedBox(height: 10),
                        Text(t.totalScreenTime, style: TextStyle(color: scheme.onSurface)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
