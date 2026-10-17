import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/state_views.dart';

/// Document Q&A is milestone 6 and is not implemented yet.
class DocumentsView extends StatelessWidget {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('documents'.tr)),
      body: MessageState(
        icon: Icons.construction_outlined,
        title: 'not_available_yet'.tr,
        body: 'documents_planned_body'.tr,
      ),
    );
  }
}
