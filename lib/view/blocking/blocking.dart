
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

class _BlockingScreenState extends State<BlockingScreen> {
  final PermissionService _permissionService = PermissionService();

  bool _isLoading = true;
  PermissionStatus? _permissionStatus;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _isLoading = false);
    });
  }

  Future<void> _checkPermissions() async {
    try {
      final status = await _permissionService.checkAllPermissions();
      setState(() => _permissionStatus = status);
    } catch (e) {
      debugPrint('Error checking permissions: $e');
    }
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
          body: buildRulesTab(blockingVM, t),
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
        // Test blocking functionality card
        _buildTestCard(blockingVM, t),
        
        const SizedBox(height: 20),
        
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
