import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../app/app_config.dart';
import '../../app/theme.dart';
import '../../core/widgets/state_views.dart';
import '../../data/local/database.dart';
import '../../data/repositories/conversation_repository.dart';

/// Reports are stored only on this device. The user can copy one to send it
/// to the developer themselves; nothing is uploaded automatically.
class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Get.find<ConversationRepository>();
    final fmt = DateFormat.yMMMd().add_Hm();
    return Scaffold(
      appBar: AppBar(title: Text('my_reports'.tr)),
      body: FutureBuilder<List<ContentReport>>(
        future: repo.reports(),
        builder: (context, snap) {
          final items = snap.data ?? const [];
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (items.isEmpty) {
            return MessageState(
              icon: Icons.flag_outlined,
              title: 'no_reports'.tr,
              body: 'reports_explainer'.trParams({
                'email': AppConfig.privacyContact,
              }),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(
                'reports_explainer'.trParams({
                  'email': AppConfig.privacyContact,
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final r in items)
                Card(
                  child: ListTile(
                    title: Text(r.reason.tr),
                    subtitle: Text(
                      '${fmt.format(r.createdAt)}\n${r.excerpt}',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      tooltip: 'copy'.tr,
                      icon: const Icon(Icons.copy),
                      onPressed: () => Clipboard.setData(
                        ClipboardData(
                          text:
                              'Report: ${r.reason}\nModel: ${r.modelId ?? '-'}\n'
                              'Date: ${r.createdAt.toIso8601String()}\n\n${r.excerpt}',
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
