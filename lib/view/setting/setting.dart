import 'package:brainrot/view_model/app_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _accent = Color(0xFFF27A3D);
  static const _ink = Color(0xFF2B2927);

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<AppViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF171513) : const Color(0xFFFFF8EF);
    final cardColor = isDark ? const Color(0xFF24211E) : Colors.white;
    final primaryText = isDark ? const Color(0xFFF8F4EF) : _ink;
    final secondaryText =
        isDark ? const Color(0xFFB8B0A8) : const Color(0xFF7A736D);
    final dividerColor =
        isDark ? Colors.white.withOpacity(.08) : const Color(0xFFF0EAE4);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
              sliver: SliverList.list(
                children: [
                  _PageHeader(
                      primaryText: primaryText, secondaryText: secondaryText),
                  const SizedBox(height: 22),
                  const _WellbeingCard(),
                  const SizedBox(height: 28),
                  _SectionLabel('TÙY CHỈNH', color: secondaryText),
                  const SizedBox(height: 10),
                  _SettingsGroup(
                    color: cardColor,
                    dividerColor: dividerColor,
                    children: [
                      _SettingsTile(
                        icon: Icons.language_rounded,
                        iconColor: const Color(0xFF5D77E5),
                        iconBackground: const Color(0xFFEFF2FF),
                        title: 'Ngôn ngữ',
                        subtitle: 'Ngôn ngữ hiển thị trong ứng dụng',
                        textColor: primaryText,
                        secondaryTextColor: secondaryText,
                        value: appSettings.locale.languageCode == 'vi'
                            ? 'Tiếng Việt'
                            : 'English',
                        onTap: () => _showLanguagePicker(context, appSettings),
                      ),
                      _SettingsTile(
                        icon: Icons.palette_outlined,
                        iconColor: const Color(0xFF8B5CC7),
                        iconBackground: const Color(0xFFF4ECFF),
                        title: 'Giao diện',
                        subtitle: 'Chọn chế độ sáng hoặc tối',
                        textColor: primaryText,
                        secondaryTextColor: secondaryText,
                        value: _themeLabel(appSettings.themeMode),
                        onTap: () => _showThemePicker(context, appSettings),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  _SectionLabel('SỨC KHỎE SỐ', color: secondaryText),
                  const SizedBox(height: 10),
                  _SettingsGroup(
                    color: cardColor,
                    dividerColor: dividerColor,
                    children: [
                      _SettingsTile(
                        icon: Icons.visibility_outlined,
                        iconColor: const Color(0xFF2B9A73),
                        iconBackground: const Color(0xFFE7F7F1),
                        title: 'Quan sát xung quanh',
                        subtitle: 'Nhắc bạn rời mắt khỏi màn hình',
                        textColor: primaryText,
                        secondaryTextColor: secondaryText,
                        badge: 'Sắp có',
                        onTap: () => _showComingSoon(
                          context,
                          title: 'Quan sát xung quanh',
                          icon: Icons.visibility_outlined,
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.bedtime_outlined,
                        iconColor: const Color(0xFF4969B2),
                        iconBackground: const Color(0xFFEAF0FF),
                        title: 'Chế độ đi ngủ',
                        subtitle: 'Tạo khoảng nghỉ trước giờ ngủ',
                        textColor: primaryText,
                        secondaryTextColor: secondaryText,
                        badge: 'Sắp có',
                        onTap: () => _showComingSoon(
                          context,
                          title: 'Chế độ đi ngủ',
                          icon: Icons.bedtime_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  _SectionLabel('HỖ TRỢ', color: secondaryText),
                  const SizedBox(height: 10),
                  _SettingsGroup(
                    color: cardColor,
                    dividerColor: dividerColor,
                    children: [
                      _SettingsTile(
                        icon: Icons.mail_outline_rounded,
                        iconColor: const Color(0xFFE07B39),
                        iconBackground: const Color(0xFFFFF0E5),
                        title: 'Liên hệ với chúng tôi',
                        subtitle: 'Góp ý hoặc báo cáo sự cố',
                        textColor: primaryText,
                        secondaryTextColor: secondaryText,
                        onTap: () => _showComingSoon(
                          context,
                          title: 'Liên hệ với chúng tôi',
                          icon: Icons.mail_outline_rounded,
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.shield_outlined,
                        iconColor: const Color(0xFF63747B),
                        iconBackground: const Color(0xFFEDF2F3),
                        title: 'Chính sách quyền riêng tư',
                        subtitle: 'Cách Brainrot bảo vệ dữ liệu của bạn',
                        textColor: primaryText,
                        secondaryTextColor: secondaryText,
                        onTap: () => _showComingSoon(
                          context,
                          title: 'Chính sách quyền riêng tư',
                          icon: Icons.shield_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Brainrot',
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Phiên bản 1.0.0',
                          style: TextStyle(color: secondaryText, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'Sáng',
        ThemeMode.dark => 'Tối',
        ThemeMode.system => 'Theo hệ thống',
      };

  Future<void> _showLanguagePicker(
    BuildContext context,
    AppViewModel appSettings,
  ) async {
    final selectedLocale = await showModalBottomSheet<Locale>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _PickerSheet<Locale>(
        title: 'Ngôn ngữ',
        subtitle: 'Chọn ngôn ngữ bạn muốn sử dụng',
        currentValue: appSettings.locale,
        options: const [
          _PickerOption(
              value: Locale('vi'), title: 'Tiếng Việt', leading: 'VI'),
          _PickerOption(value: Locale('en'), title: 'English', leading: 'EN'),
        ],
      ),
    );
    if (selectedLocale != null) await appSettings.setLocale(selectedLocale);
  }

  Future<void> _showThemePicker(
    BuildContext context,
    AppViewModel appSettings,
  ) async {
    final selectedTheme = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => _PickerSheet<ThemeMode>(
        title: 'Giao diện',
        subtitle: 'Chọn giao diện phù hợp với bạn',
        currentValue: appSettings.themeMode,
        options: const [
          _PickerOption(
            value: ThemeMode.system,
            title: 'Theo hệ thống',
            leadingIcon: Icons.brightness_auto_outlined,
          ),
          _PickerOption(
            value: ThemeMode.light,
            title: 'Sáng',
            leadingIcon: Icons.light_mode_outlined,
          ),
          _PickerOption(
            value: ThemeMode.dark,
            title: 'Tối',
            leadingIcon: Icons.dark_mode_outlined,
          ),
        ],
      ),
    );
    if (selectedTheme != null) await appSettings.setThemeMode(selectedTheme);
  }

  void _showComingSoon(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(28, 4, 28, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEEE2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _accent, size: 30),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tính năng này đang được hoàn thiện và sẽ sớm có mặt trong bản cập nhật tiếp theo.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Đã hiểu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.primaryText, required this.secondaryText});

  final Color primaryText;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cài đặt',
          style: TextStyle(
            color: primaryText,
            fontSize: 30,
            height: 1.1,
            fontWeight: FontWeight.w800,
            letterSpacing: -.7,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Cá nhân hóa trải nghiệm của bạn',
          style: TextStyle(color: secondaryText, fontSize: 15),
        ),
      ],
    );
  }
}

class _WellbeingCard extends StatelessWidget {
  const _WellbeingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF58A4E), Color(0xFFEF6941)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF27A3D).withOpacity(.24),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -16,
            top: -20,
            child: Icon(Icons.spa_rounded, size: 112, color: Color(0x24FFFFFF)),
          ),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: Colors.white.withOpacity(.22)),
                ),
                child: const Icon(
                  Icons.self_improvement_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Không gian của bạn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Ít màn hình hơn, nhiều cuộc sống hơn.',
                      style: TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, {required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({
    required this.color,
    required this.dividerColor,
    required this.children,
  });
  final Color color;
  final Color dividerColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      items.add(children[index]);
      if (index < children.length - 1) {
        items.add(Divider(height: 1, indent: 72, color: dividerColor));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: items),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.secondaryTextColor,
    required this.onTap,
    this.value,
    this.badge,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final Color textColor;
  final Color secondaryTextColor;
  final VoidCallback onTap;
  final String? value;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 14, 12, 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: secondaryTextColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEE2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: SettingsScreen._accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else if (value != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 92),
                  child: Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 5),
              Icon(
                Icons.chevron_right_rounded,
                color: secondaryTextColor.withOpacity(.65),
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerOption<T> {
  const _PickerOption({
    required this.value,
    required this.title,
    this.leading,
    this.leadingIcon,
  });
  final T value;
  final String title;
  final String? leading;
  final IconData? leadingIcon;
}

class _PickerSheet<T> extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.subtitle,
    required this.currentValue,
    required this.options,
  });
  final String title;
  final String subtitle;
  final T currentValue;
  final List<_PickerOption<T>> options;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 18),
          ...options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Material(
                color: option.value == currentValue
                    ? SettingsScreen._accent.withOpacity(.10)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(option.value),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 13),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: option.leadingIcon != null
                              ? Icon(option.leadingIcon, size: 21)
                              : Text(
                                  option.leading!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            option.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (option.value == currentValue)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: SettingsScreen._accent,
                            size: 23,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
