import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme.dart';
import '../../core/widgets/state_views.dart';
import '../../services/agent/agent_tool.dart';

/// Asks the user before a tool that touches files runs. Dismissing the
/// dialog counts as "Deny".
Future<bool> showApprovalDialog(AgentTool tool, ToolCall call) async {
  final allowed = await Get.dialog<bool>(
    _ApprovalDialog(tool: tool, call: call),
    barrierDismissible: false,
  );
  return allowed ?? false;
}

class _ApprovalDialog extends StatelessWidget {
  const _ApprovalDialog({required this.tool, required this.call});

  final AgentTool tool;
  final ToolCall call;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final explain = switch (tool.name) {
      'read_file' => 'agent_approve_read_body'.tr,
      'write_file' => 'agent_approve_write_body'.trParams({
        'name': '${call.args['filename']}',
      }),
      _ => 'agent_approve_generic_body'.tr,
    };
    final content = call.args['content'];
    return AlertDialog(
      icon: IconBadge(
        Icons.lock_outline_rounded,
        size: 48,
        iconSize: 24,
        background: AppColors.of(context).warningContainer,
        color: AppColors.of(context).warning,
      ),
      title: Text('agent_approve_title'.trParams({'tool': tool.labelKey.tr})),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(explain),
            if (content is String) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'agent_content_preview'.tr,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 200),
                padding: const EdgeInsets.all(AppSpacing.ms),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: SingleChildScrollView(child: Text(content)),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back<bool>(result: false),
          child: Text('agent_deny'.tr),
        ),
        FilledButton(
          onPressed: () => Get.back<bool>(result: true),
          child: Text('agent_allow'.tr),
        ),
      ],
    );
  }
}
