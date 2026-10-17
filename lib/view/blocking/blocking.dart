import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../model/blocking_rule.dart';
import '../../service/app_icon_service.dart';
import '../../service/permission_service.dart';
import '../../view_model/blocking_view_model.dart';

class BlockingScreen extends StatefulWidget {
  const BlockingScreen({super.key});

  static const _accent = Color(0xFFF27A3D);
  static const _ink = Color(0xFF2B2927);

  @override
  State<BlockingScreen> createState() => _BlockingScreenState();
}

class _BlockingScreenState extends State<BlockingScreen>
    with WidgetsBindingObserver {
  final PermissionService _permissionService = PermissionService();
  PermissionStatus? _permissionStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final status = await _permissionService.checkAllPermissions();
      if (mounted) setState(() => _permissionStatus = status);
    } catch (e) {
      debugPrint('Error checking permissions: $e');
    }
  }

  Future<void> _enableBlocking() async {
    await _permissionService.requestAccessibilityPermission();
  }

  Future<void> _showAppPicker(BlockingViewModel blockingVM) async {
    final t = AppLocalizations.of(context);
    final apps = await _permissionService.getLaunchableApps();
    if (!mounted) return;

    if (apps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.noAvailableApps),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final selectedApp = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) => _AppPickerBottomSheet(apps: apps),
    );

    if (selectedApp != null && mounted) {
      await _blockApp(blockingVM, selectedApp);
    }
  }

  Future<void> _blockApp(
    BlockingViewModel blockingVM,
    Map<String, String> app,
  ) async {
    final t = AppLocalizations.of(context);
    final packageName = app['packageName']!;
    final appName = app['appName']!;
    final rule = BlockingRule(
      id: 'app_${packageName}_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Block $appName',
      description: 'Block all day when app is opened',
      type: BlockingType.allDayBlock,
      targetPackages: [packageName],
      createdAt: DateTime.now(),
      status: RuleStatus.active,
    );
    await blockingVM.addRule(rule);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.addedBlockRule(appName)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: BlockingScreen._accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF171513) : const Color(0xFFFFF8EF);
    final cardColor = isDark ? const Color(0xFF24211E) : Colors.white;
    final primaryText = isDark ? const Color(0xFFF8F4EF) : BlockingScreen._ink;
    final secondaryText =
        isDark ? const Color(0xFFB8B0A8) : const Color(0xFF7A736D);
    final dividerColor =
        isDark ? Colors.white.withOpacity(.08) : const Color(0xFFF0EAE4);

    return Consumer<BlockingViewModel>(
      builder: (context, blockingVM, child) {
        final rules = blockingVM.rules;
        final hasAccessibility =
            _permissionStatus?.hasAccessibilityPermission ?? false;

        return Scaffold(
          backgroundColor: background,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAppPicker(blockingVM),
            elevation: 3,
            backgroundColor: BlockingScreen._accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: const Icon(Icons.add_rounded),
            label: Text(
              t.blockAppFab,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 100),
                  sliver: SliverList.list(
                    children: [
                      // Header
                      _PageHeader(
                        primaryText: primaryText,
                        secondaryText: secondaryText,
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),

                      // Permission Warning Banner if not granted
                      if (!hasAccessibility) ...[
                        _PermissionBanner(
                          onEnable: _enableBlocking,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Section Label
                      _SectionLabel(
                        t.rulesListLabel(rules.length),
                        color: secondaryText,
                      ),
                      const SizedBox(height: 10),

                      // Rules Content
                      if (rules.isEmpty)
                        _EmptyRulesCard(
                          cardColor: cardColor,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                          onAdd: () => _showAppPicker(blockingVM),
                        )
                      else ...[
                        for (final type in BlockingType.values) ...[
                          _buildTypeSection(
                            type: type,
                            rules: rules.where((r) => r.type == type).toList(),
                            blockingVM: blockingVM,
                            cardColor: cardColor,
                            dividerColor: dividerColor,
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeSection({
    required BlockingType type,
    required List<BlockingRule> rules,
    required BlockingViewModel blockingVM,
    required Color cardColor,
    required Color dividerColor,
    required Color primaryText,
    required Color secondaryText,
  }) {
    if (rules.isEmpty) return const SizedBox.shrink();

    final meta = _getRuleTypeMeta(type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Icon(meta.icon, size: 17, color: meta.iconColor),
                const SizedBox(width: 8),
                Text(
                  meta.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: meta.iconColor,
                    letterSpacing: .3,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: meta.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${rules.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: meta.iconColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _CardContainer(
            color: cardColor,
            dividerColor: dividerColor,
            children: rules.map((rule) {
              return _RuleTile(
                rule: rule,
                meta: meta,
                primaryText: primaryText,
                secondaryText: secondaryText,
                onToggle: () => blockingVM.toggleRule(rule.id),
                onDelete: () => _confirmDeleteRule(context, blockingVM, rule),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteRule(
    BuildContext context,
    BlockingViewModel blockingVM,
    BlockingRule rule,
  ) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t.confirmDeleteTitle),
        content: Text(t.confirmDeleteMessage(rule.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(t.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await blockingVM.deleteRule(rule.id);
    }
  }

  _RuleTypeMeta _getRuleTypeMeta(BlockingType type) {
    final t = AppLocalizations.of(context);
    switch (type) {
      case BlockingType.allDayBlock:
        return _RuleTypeMeta(
          title: t.blockTypeAllDay,
          icon: Icons.block_flipped,
          iconColor: const Color(0xFF8B5CC7),
          background: const Color(0xFFF4ECFF),
        );
      case BlockingType.timeLimit:
        return _RuleTypeMeta(
          title: t.blockTypeTimeLimit,
          icon: Icons.timer_outlined,
          iconColor: const Color(0xFFE07B39),
          background: const Color(0xFFFFF0E5),
        );
      case BlockingType.schedule:
        return _RuleTypeMeta(
          title: t.blockTypeSchedule,
          icon: Icons.schedule_rounded,
          iconColor: const Color(0xFF5D77E5),
          background: const Color(0xFFEFF2FF),
        );
      case BlockingType.focusMode:
        return _RuleTypeMeta(
          title: t.blockTypeFocusMode,
          icon: Icons.filter_center_focus_rounded,
          iconColor: const Color(0xFF2B9A73),
          background: const Color(0xFFE7F7F1),
        );
    }
  }
}

class _RuleTypeMeta {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color background;

  const _RuleTypeMeta({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.background,
  });
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.primaryText, required this.secondaryText});

  final Color primaryText;
  final Color secondaryText;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            t.blockingRulesTitle,
            style: TextStyle(
              color: primaryText,
              fontSize: 18,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: -.7,
            ),
          ),
        ),
      ],
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({
    required this.onEnable,
    required this.isDark,
  });

  final VoidCallback onEnable;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final bgColor = isDark ? const Color(0xFF33261A) : const Color(0xFFFFF3E0);
    const accentColor = Color(0xFFF27A3D);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.accessibility_new_rounded,
              color: accentColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.permissionBannerTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  t.permissionBannerSubtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: onEnable,
            style: FilledButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(t.permissionBannerButton,
                style: const TextStyle(fontSize: 13)),
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

class _CardContainer extends StatelessWidget {
  const _CardContainer({
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
        items.add(Divider(height: 1, indent: 70, color: dividerColor));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: items),
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  const _RuleTile({
    required this.rule,
    required this.meta,
    required this.primaryText,
    required this.secondaryText,
    required this.onToggle,
    required this.onDelete,
  });

  final BlockingRule rule;
  final _RuleTypeMeta meta;
  final Color primaryText;
  final Color secondaryText;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final firstPackage =
        rule.targetPackages.isNotEmpty ? rule.targetPackages.first : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Icon with pastel background or App Icon
          if (firstPackage != null)
            _AppIconWidget(
              packageName: firstPackage,
              fallbackIcon: meta.icon,
              fallbackBg: meta.background,
              fallbackColor: meta.iconColor,
            )
          else
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: meta.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(meta.icon, color: meta.iconColor, size: 22),
            ),
          const SizedBox(width: 14),

          // Title & Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.name,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  rule.description,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (rule.targetPackages.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: meta.background,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      t.appsApplied(rule.targetPackages.length),
                      style: TextStyle(
                        fontSize: 11,
                        color: meta.iconColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Delete icon button
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: secondaryText.withOpacity(.6),
            ),
            onPressed: onDelete,
            tooltip: t.deleteTooltip,
          ),

          // Switch
          Switch(
            value: rule.isActive,
            onChanged: (_) => onToggle(),
            activeColor: BlockingScreen._accent,
          ),
        ],
      ),
    );
  }
}

class _AppIconWidget extends StatelessWidget {
  const _AppIconWidget({
    required this.packageName,
    required this.fallbackIcon,
    required this.fallbackBg,
    required this.fallbackColor,
  });

  final String packageName;
  final IconData fallbackIcon;
  final Color fallbackBg;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: AppIconService().getAppIcon(packageName),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.memory(
              snapshot.data!,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
            ),
          );
        }
        return Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: fallbackBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(fallbackIcon, color: fallbackColor, size: 22),
        );
      },
    );
  }
}

class _EmptyRulesCard extends StatelessWidget {
  const _EmptyRulesCard({
    required this.cardColor,
    required this.primaryText,
    required this.secondaryText,
    required this.onAdd,
  });

  final Color cardColor;
  final Color primaryText;
  final Color secondaryText;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.shield_moon_outlined,
              size: 32,
              color: BlockingScreen._accent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t.emptyRulesTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: primaryText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.emptyRulesSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: secondaryText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              backgroundColor: BlockingScreen._accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(t.addFirstApp),
          ),
        ],
      ),
    );
  }
}

class _AppPickerBottomSheet extends StatefulWidget {
  const _AppPickerBottomSheet({required this.apps});

  final List<Map<String, String>> apps;

  @override
  State<_AppPickerBottomSheet> createState() => _AppPickerBottomSheetState();
}

class _AppPickerBottomSheetState extends State<_AppPickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredApps = [];

  @override
  void initState() {
    super.initState();
    _filteredApps = widget.apps;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredApps = widget.apps;
      } else {
        _filteredApps = widget.apps.where((app) {
          final name = (app['appName'] ?? '').toLowerCase();
          final pkg = (app['packageName'] ?? '').toLowerCase();
          return name.contains(query) || pkg.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF24211E) : Colors.white;
    final primaryText = isDark ? const Color(0xFFF8F4EF) : BlockingScreen._ink;
    final secondaryText =
        isDark ? const Color(0xFFB8B0A8) : const Color(0xFF7A736D);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.appPickerTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.appPickerSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryText,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Search bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: t.searchAppsHint,
                        hintStyle:
                            TextStyle(color: secondaryText, fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: secondaryText, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(.06)
                            : const Color(0xFFF5F0EB),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _filteredApps.isEmpty
                    ? Center(
                        child: Text(
                          t.noAppsFound,
                          style: TextStyle(color: secondaryText),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filteredApps.length,
                        itemBuilder: (context, index) {
                          final app = _filteredApps[index];
                          final pkg = app['packageName'] ?? '';
                          final name = app['appName'] ?? '';

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            leading: _AppIconWidget(
                              packageName: pkg,
                              fallbackIcon: Icons.apps_rounded,
                              fallbackBg: const Color(0xFFFFF0E5),
                              fallbackColor: BlockingScreen._accent,
                            ),
                            title: Text(
                              name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: primaryText,
                              ),
                            ),
                            subtitle: Text(
                              pkg,
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Colors.grey,
                            ),
                            onTap: () => Navigator.of(context).pop(app),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
