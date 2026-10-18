import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../app/app_config.dart';
import '../../app/theme.dart';
import '../../core/widgets/state_views.dart';
import '../../data/local/database.dart';
import '../../data/repositories/conversation_repository.dart';
import '../../services/report_mailer.dart';

/// Reports are stored on this device. Sending one opens the user's email app
/// with a draft they review and send themselves; nothing is uploaded silently.
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
          final explainer = 'reports_explainer'.trParams({
            'email': AppConfig.privacyContact,
          });
          if (items.isEmpty) {
            return MessageState(
              icon: Icons.flag_outlined,
              title: 'no_reports'.tr,
              body: explainer,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(explainer),
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
                      tooltip: 'report_send'.tr,
                      icon: const Icon(Icons.outgoing_mail),
                      onPressed: () => showReportSendDialog(context, r),
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

/// Shows the exact email text, then opens the email app if the user agrees.
Future<void> showReportSendDialog(BuildContext context, ContentReport r) async {
  final body = formatReportEmail(r);
  final choice = await showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('report_send'.tr),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'report_send_preview'.trParams({
                'email': AppConfig.privacyContact,
              }),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: SelectableText(
                body,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'copy'),
          child: Text('copy'.tr),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, 'email'),
          child: Text('report_open_email'.tr),
        ),
      ],
    ),
  );
  if (choice == 'copy') {
    await Clipboard.setData(ClipboardData(text: body));
  } else if (choice == 'email') {
    final opened = await ReportMailer().compose(r);
    if (!opened) {
      await Clipboard.setData(ClipboardData(text: body));
      Get.snackbar(
        'report_send'.tr,
        'report_no_email_app'.trParams({'email': AppConfig.privacyContact}),
      );
    }
  }
}
