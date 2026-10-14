
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n.dart';
import '../../view_model/blocking_view_model.dart';

import '../../model/blocking_rule.dart';
import '../../service/permission_service.dart';

class BlockingScreen extends StatefulWidget {
  const BlockingScreen({super.key});

  @override
  State<BlockingScreen> createState() => _BlockingScreenState();
}

class _BlockingScreenState extends State<BlockingScreen>
    with WidgetsBindingObserver {
  final PermissionService _permissionService = PermissionService();

  bool _isLoading = true;
  PermissionStatus? _permissionStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkPermissions();
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
    final apps = await _permissionService.getLaunchableApps();
    if (!mounted) return;

    if (apps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy ứng dụng để chặn.')),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chọn ứng dụng cần chặn'),
        content: SizedBox(
          width: double.maxFinite,
          height: 420,
          child: ListView.separated(
            itemCount: apps.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final app = apps[index];
              return ListTile(
                leading: const Icon(Icons.apps),
                title: Text(app['appName']!),
                subtitle: Text(app['packageName']!),
                onTap: () async {
                  Navigator.of(dialogContext).pop();
                  await _blockApp(blockingVM, app);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  Future<void> _blockApp(
    BlockingViewModel blockingVM,
    Map<String, String> app,
  ) async {
    final packageName = app['packageName']!;
    final rule = BlockingRule(
      id: 'app_${packageName}_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Chặn ${app['appName']}',
      description: 'Chặn cả ngày',
      type: BlockingType.allDayBlock,
      targetPackages: [packageName],
      createdAt: DateTime.now(),
      status: RuleStatus.active,
    );
    await blockingVM.addRule(rule);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã chặn ${app['appName']}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);

    return Consumer<BlockingViewModel>(
      builder: (context, blockingVM, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFE4B5),
          appBar: AppBar(
            title: Text(
              "Blocking",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFFFFE4B5),
            elevation: 0,
          ),
          body: Column(
            children: [
              if (!(_permissionStatus?.hasAccessibilityPermission ?? false))
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Cần bật dịch vụ Trợ năng để phát hiện và chặn ứng dụng.',
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _enableBlocking,
                        child: const Text('Bật'),
                      ),
                    ],
                  ),
                ),
              Expanded(child: buildRulesTab(blockingVM, t)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAppPicker(blockingVM),
            icon: const Icon(Icons.add),
            label: const Text('Chặn ứng dụng'),
          ),
        );
      },
    );
  }
}

Widget buildRuleItem(BlockingRule rule, BlockingViewModel blockingVM, S t) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: rule.isActive ? Colors.green : Colors.grey,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rule.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rule.description,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              if (rule.targetPackages.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '${rule.targetPackages.length} ${"hihi"}',
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ],
          ),
        ),
        Switch(
          value: rule.isActive,
          onChanged: (value) => blockingVM.toggleRule(rule.id),
          activeColor: Colors.green,
        ),
      ],
    ),
  );
}

Widget buildRuleSection(BlockingType type, List<BlockingRule> rules, BlockingViewModel blockingVM, S t) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(
            _getRuleTypeIcon(type),
            color: _getRuleTypeColor(type),
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            type.name.replaceAll('_', ' '),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 5),
          Text(
            '(${rules.length})',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Spacer(),
          const Icon(Icons.expand_more, color: Colors.grey),
        ],
      ),
      const SizedBox(height: 15),
      ...rules.map((rule) => buildRuleItem(rule, blockingVM, t)),
    ],
  );
}
IconData _getRuleTypeIcon(BlockingType type) {
  switch (type) {
    case BlockingType.timeLimit:
      return Icons.access_time;
    case BlockingType.schedule:
      return Icons.schedule;
    case BlockingType.allDayBlock:
      return Icons.block;
    case BlockingType.focusMode:
      return Icons.center_focus_strong;
  }
}

Color _getRuleTypeColor(BlockingType type) {
  switch (type) {
    case BlockingType.timeLimit:
      return Colors.orange;
    case BlockingType.schedule:
      return Colors.blue;
    case BlockingType.allDayBlock:
      return Colors.purple;
    case BlockingType.focusMode:
      return Colors.green;
  }
}


Widget buildRulesTab(BlockingViewModel blockingVM, S t) {
  final rules = blockingVM.rules;

  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (rules.where((r) => r.isActive).isEmpty) buildWarningCard(t),

        const SizedBox(height: 20),

        ...BlockingType.values.map((type) {
          final typeRules = rules.where((r) => r!.type == type).toList();
          if (typeRules.isEmpty) return const SizedBox.shrink();

          return Column(
            children: [
              buildRuleSection(type, typeRules, blockingVM, t),
              const SizedBox(height: 20),
            ],
          );
        }),
      ],
    ),
  );
}

Widget _buildTestCard(BlockingViewModel blockingVM, S t) {
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.blue,)
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.bug_report, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Test Blocking Functionality',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Test if app blocking is working properly. Make sure you have granted all permissions first.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        // Permission status
        FutureBuilder<PermissionStatus>(
          future: _getPermissionStatus(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final status = snapshot.data!;
              return Column(
                children: [
                  _buildPermissionRow('Accessibility Service', status.hasAccessibilityPermission),
                  _buildPermissionRow('Display over other apps', status.hasOverlayPermission),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _testZaloBlock(blockingVM),
                icon: const Icon(Icons.block, size: 16),
                label: const Text('Test Zalo Block'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _testFocusMode(blockingVM),
                icon: const Icon(Icons.center_focus_strong, size: 16),
                label: const Text('Test Focus Mode'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

void _testZaloBlock(BlockingViewModel blockingVM) async {
  // Create a test rule to block Zalo
  final testRule = BlockingRule(
    id: 'test_zalo_block',
    name: 'Test Zalo Block',
    description: 'Testing Zalo blocking',
    type: BlockingType.allDayBlock,
    targetPackages: ['com.zing.zalo'],
    createdAt: DateTime.now(),
    status: RuleStatus.active,
  );

  try {
    await blockingVM.addRule(testRule);
    debugPrint('✅ Test rule added for Zalo blocking');
    
    // Show success message
    // You could add a snackbar here
  } catch (e) {
    debugPrint('❌ Error adding test rule: $e');
  }
}

void _testFocusMode(BlockingViewModel blockingVM) async {
  try {
    // Start work focus mode for 5 minutes
    await blockingVM.startFocusMode('work', duration: const Duration(minutes: 5));
    debugPrint('✅ Test focus mode started');
    
    // Show success message
    // You could add a snackbar here
  } catch (e) {
    debugPrint('❌ Error starting test focus mode: $e');
  }
}

Future<PermissionStatus> _getPermissionStatus() async {
  final permissionService = PermissionService();
  return await permissionService.checkAllPermissions();
}

Widget _buildPermissionRow(String name, bool granted) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Icon(
          granted ? Icons.check_circle : Icons.cancel,
          color: granted ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: 12,
            color: granted ? Colors.green : Colors.red,
          ),
        ),
      ],
    ),
  );
}



Widget buildWarningCard(S t) {
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.red),
    ),
    child: Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.warning, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "no rules active right now - you should set some",
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}
