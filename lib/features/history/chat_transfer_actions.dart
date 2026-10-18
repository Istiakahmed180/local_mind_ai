import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../services/chat_transfer.dart';

String _stamp() => DateFormat('yyyyMMdd-HHmm').format(DateTime.now());

String _safeName(String title) {
  final s = title.replaceAll(RegExp(r'[^\w\- ]+', unicode: true), '').trim();
  final short = s.length > 40 ? s.substring(0, 40) : s;
  return short.isEmpty ? 'chat' : short.replaceAll(' ', '_');
}

/// Exports all chats, or one chat when [conversationId] is given, as JSON
/// (re-importable) or Markdown (readable only).
Future<void> exportChats(
  BuildContext context, {
  String? conversationId,
  bool markdown = false,
}) async {
  final service = Get.find<ChatTransferService>();
  final chats = await service.load(conversationId: conversationId);
  if (chats.isEmpty) {
    Get.snackbar('chat_export'.tr, 'chat_export_nothing'.tr);
    return;
  }
  if (!context.mounted) return;
  final messages = chats.fold<int>(0, (s, c) => s + c.messages.length);
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('chat_export'.tr),
      content: Text(
        'chat_export_confirm'.trParams({
          'chats': '${chats.length}',
          'messages': '$messages',
        }),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('cancel'.tr),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('chat_export_save'.tr),
        ),
      ],
    ),
  );
  if (ok != true) return;

  final String body;
  final String fileName;
  if (markdown) {
    body = chats.map(chatToMarkdown).join('\n---\n\n');
    fileName = '${_safeName(chats.first.conversation.title)}.md';
  } else {
    body = encodeChats(chats);
    fileName = conversationId == null
        ? 'localmind-chats-${_stamp()}.json'
        : 'localmind-chat-${_safeName(chats.first.conversation.title)}.json';
  }
  final uri = await FilePicker.saveFile(
    fileName: fileName,
    bytes: Uint8List.fromList(utf8.encode(body)),
    mimeType: markdown ? 'text/markdown' : 'application/json',
  );
  if (uri != null) {
    Get.snackbar('chat_export'.tr, 'chat_export_done'.tr);
  }
}

/// Picks a JSON export, shows what it contains, and imports after confirming.
Future<void> importChats(BuildContext context) async {
  final picked = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: const ['json'],
  );
  final path = picked?.path;
  if (path == null) return;
  try {
    final file = File(path);
    if (await file.length() > maxImportBytes) {
      throw const ChatImportException('chat_import_too_large');
    }
    final String text;
    try {
      text = await file.readAsString();
    } on FileSystemException {
      throw const ChatImportException('chat_import_not_json');
    }
    final parsed = parseChatExport(text);
    if (parsed.conversations.isEmpty) {
      throw const ChatImportException('chat_import_empty');
    }
    if (!context.mounted) return;
    final messages = parsed.conversations.fold<int>(
      0,
      (s, c) => s + c.messages.length,
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('chat_import'.tr),
        content: Text(
          'chat_import_confirm'.trParams({
            'chats': '${parsed.conversations.length}',
            'messages': '$messages',
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('chat_import'.tr),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final r = await Get.find<ChatTransferService>().import(parsed);
    Get.snackbar(
      'chat_import'.tr,
      'chat_import_done'.trParams({
        'imported': '${r.imported}',
        'duplicates': '${r.duplicates}',
        'skipped': '${r.skippedInvalid}',
      }),
      duration: const Duration(seconds: 5),
    );
  } on ChatImportException catch (e) {
    Get.snackbar('chat_import'.tr, e.reason.tr);
  } finally {
    await FilePicker.clearTemporaryFiles();
  }
}
