import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme.dart';
import '../../core/widgets/state_views.dart';

/// The agent engine is milestone 5 and is not implemented yet. This screen
/// says so plainly instead of showing controls that do nothing.
class AgentView extends StatelessWidget {
  const AgentView({super.key});

  @override
  Widget build(BuildContext context) {
    const tools = [
      'tool_calculator',
      'tool_datetime',
      'tool_doc_search',
      'tool_read_file',
      'tool_write_file',
      'tool_summarize',
      'tool_history_search',
    ];
    return Scaffold(
      appBar: AppBar(title: Text('agent'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          MessageState(
            icon: Icons.construction_outlined,
            title: 'not_available_yet'.tr,
            body: 'agent_planned_body'.tr,
          ),
          SectionCard(
            title: 'planned_tools'.tr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final t in tools) Text('• ${t.tr}')],
            ),
          ),
        ],
      ),
    );
  }
}
