import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app/app_config.dart';
import '../data/local/database.dart';

/// File format for exported chats. Plain, unencrypted JSON.
const chatExportFormat = 'localmind-chats';
const chatExportVersion = 1;

/// Limits for imported files, so a damaged or hostile file cannot exhaust
/// memory or storage.
const maxImportBytes = 50 * 1024 * 1024;
const maxImportConversations = 5000;
const maxImportMessagesPerConversation = 20000;
const maxImportMessageChars = 200000;
const maxImportTitleChars = 200;

const _roles = {'user', 'assistant'};
const _statuses = {'complete', 'cancelled', 'error'};

class ExportedChat {
  const ExportedChat(this.conversation, this.messages);

  final Conversation conversation;
  final List<Message> messages;
}

/// Encodes chats as JSON. Message timing stats are kept; nothing else from
/// the app (models, documents, memory, settings) is included.
String encodeChats(List<ExportedChat> chats, {DateTime? now}) =>
    const JsonEncoder.withIndent('  ').convert({
      'format': chatExportFormat,
      'version': chatExportVersion,
      'app': AppConfig.appName,
      'appVersion': AppConfig.version,
      'exportedAt': (now ?? DateTime.now()).toUtc().toIso8601String(),
      'conversations': [
        for (final c in chats)
          {
            'id': c.conversation.id,
            'title': c.conversation.title,
            'modelId': c.conversation.modelId,
            'createdAt': c.conversation.createdAt.toUtc().toIso8601String(),
            'updatedAt': c.conversation.updatedAt.toUtc().toIso8601String(),
            'messages': [
              for (final m in c.messages)
                {
                  'role': m.role,
                  'content': m.content,
                  'status': m.status,
                  'modelId': m.modelId,
                  'createdAt': m.createdAt.toUtc().toIso8601String(),
                  if (m.completionTokens != null)
                    'completionTokens': m.completionTokens,
                  if (m.timeToFirstTokenMs != null)
                    'timeToFirstTokenMs': m.timeToFirstTokenMs,
                  if (m.tokensPerSecond != null)
                    'tokensPerSecond': m.tokensPerSecond,
                },
            ],
          },
      ],
    });

/// A readable Markdown copy of one chat. Not importable.
String chatToMarkdown(ExportedChat c, {String userLabel = 'You'}) {
  final b = StringBuffer('# ${c.conversation.title}\n\n');
  b.writeln(
    '_${AppConfig.appName} · ${c.conversation.createdAt.toUtc().toIso8601String()}'
    '${c.conversation.modelId == null ? '' : ' · ${c.conversation.modelId}'}_\n',
  );
  for (final m in c.messages) {
    final who = m.role == 'user' ? userLabel : (m.modelId ?? 'AI');
    b.writeln('**$who:**\n');
    b.writeln(m.content.trim());
    if (m.status != 'complete') b.writeln('\n_(${m.status})_');
    b.writeln();
  }
  return b.toString();
}

class ChatImportException implements Exception {
  const ChatImportException(this.reason);

  /// Translation key.
  final String reason;
}

class ParsedMessage {
  const ParsedMessage({
    required this.role,
    required this.content,
    required this.status,
    required this.modelId,
    required this.createdAt,
    this.completionTokens,
    this.timeToFirstTokenMs,
    this.tokensPerSecond,
  });

  final String role;
  final String content;
  final String status;
  final String? modelId;
  final DateTime createdAt;
  final int? completionTokens;
  final int? timeToFirstTokenMs;
  final double? tokensPerSecond;
}

class ParsedConversation {
  const ParsedConversation({
    required this.sourceId,
    required this.title,
    required this.modelId,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  final String sourceId;
  final String title;
  final String? modelId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ParsedMessage> messages;
}

class ParsedImport {
  const ParsedImport(this.conversations, this.skippedInvalid);

  final List<ParsedConversation> conversations;

  /// Conversations or messages dropped because they were malformed.
  final int skippedInvalid;
}

/// Parses and validates an export file. Throws [ChatImportException] when the
/// file as a whole is unusable; drops individual malformed entries.
ParsedImport parseChatExport(String text) {
  if (text.length > maxImportBytes) {
    throw const ChatImportException('chat_import_too_large');
  }
  final Object? root;
  try {
    root = jsonDecode(text);
  } on FormatException {
    throw const ChatImportException('chat_import_not_json');
  }
  if (root is! Map || root['format'] != chatExportFormat) {
    throw const ChatImportException('chat_import_wrong_format');
  }
  final version = root['version'];
  if (version is! int || version > chatExportVersion || version < 1) {
    throw const ChatImportException('chat_import_newer_version');
  }
  final list = root['conversations'];
  if (list is! List) {
    throw const ChatImportException('chat_import_wrong_format');
  }
  if (list.length > maxImportConversations) {
    throw const ChatImportException('chat_import_too_large');
  }

  var skipped = 0;
  final out = <ParsedConversation>[];
  for (final raw in list) {
    final c = _parseConversation(raw);
    if (c == null) {
      skipped++;
      continue;
    }
    skipped += c.$2;
    out.add(c.$1);
  }
  return ParsedImport(out, skipped);
}

(ParsedConversation, int)? _parseConversation(Object? raw) {
  if (raw is! Map) return null;
  final id = raw['id'];
  final title = raw['title'];
  final created = _date(raw['createdAt']);
  final msgs = raw['messages'];
  if (id is! String || id.isEmpty || id.length > 100) return null;
  if (title is! String || created == null || msgs is! List) return null;
  if (msgs.length > maxImportMessagesPerConversation) return null;
  var skipped = 0;
  final messages = <ParsedMessage>[];
  for (final m in msgs) {
    final pm = _parseMessage(m);
    if (pm == null) {
      skipped++;
    } else {
      messages.add(pm);
    }
  }
  final cleanTitle = title.trim().isEmpty
      ? 'Imported chat'
      : title.trim().substring(
          0,
          title.trim().length.clamp(0, maxImportTitleChars),
        );
  return (
    ParsedConversation(
      sourceId: id,
      title: cleanTitle,
      modelId: _optString(raw['modelId']),
      createdAt: created,
      updatedAt: _date(raw['updatedAt']) ?? created,
      messages: messages,
    ),
    skipped,
  );
}

ParsedMessage? _parseMessage(Object? raw) {
  if (raw is! Map) return null;
  final role = raw['role'];
  final content = raw['content'];
  final created = _date(raw['createdAt']);
  if (role is! String || !_roles.contains(role)) return null;
  if (content is! String || content.length > maxImportMessageChars) {
    return null;
  }
  if (created == null) return null;
  final status = raw['status'];
  return ParsedMessage(
    role: role,
    content: content,
    status: status is String && _statuses.contains(status)
        ? status
        : 'complete',
    modelId: _optString(raw['modelId']),
    createdAt: created,
    completionTokens: _optInt(raw['completionTokens']),
    timeToFirstTokenMs: _optInt(raw['timeToFirstTokenMs']),
    tokensPerSecond: _optDouble(raw['tokensPerSecond']),
  );
}

DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;

String? _optString(Object? v) =>
    v is String && v.isNotEmpty && v.length <= 200 ? v : null;

int? _optInt(Object? v) => v is int && v >= 0 ? v : null;

double? _optDouble(Object? v) =>
    v is num && v.isFinite && v >= 0 ? v.toDouble() : null;

class ImportResult {
  const ImportResult({
    required this.imported,
    required this.duplicates,
    required this.skippedInvalid,
  });

  final int imported;
  final int duplicates;
  final int skippedInvalid;
}

/// Reads chats for export and writes imported chats in one transaction.
class ChatTransferService {
  ChatTransferService(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  Future<List<ExportedChat>> load({String? conversationId}) async {
    final q = _db.select(_db.conversations)
      ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]);
    if (conversationId != null) q.where((c) => c.id.equals(conversationId));
    final convs = await q.get();
    return [
      for (final c in convs)
        ExportedChat(
          c,
          await (_db.select(_db.messages)
                ..where((m) => m.conversationId.equals(c.id))
                ..orderBy([
                  (m) => OrderingTerm.asc(m.createdAt),
                  // Timestamps have one-second precision; insertion order breaks ties.
                  (m) => OrderingTerm.asc(const CustomExpression<int>('rowid')),
                ]))
              .get(),
        ),
    ];
  }

  /// Imports [parsed]. A conversation whose id already exists is treated as
  /// already imported and skipped, so importing the same file twice is safe.
  Future<ImportResult> import(ParsedImport parsed) => _db.transaction(() async {
    var imported = 0;
    var duplicates = 0;
    for (final c in parsed.conversations) {
      final exists = await (_db.select(
        _db.conversations,
      )..where((x) => x.id.equals(c.sourceId))).getSingleOrNull();
      if (exists != null) {
        duplicates++;
        continue;
      }
      await _db
          .into(_db.conversations)
          .insert(
            ConversationsCompanion.insert(
              id: c.sourceId,
              title: c.title,
              modelId: Value(c.modelId),
              createdAt: c.createdAt,
              updatedAt: c.updatedAt,
            ),
          );
      for (final m in c.messages) {
        await _db
            .into(_db.messages)
            .insert(
              MessagesCompanion.insert(
                id: _uuid.v4(),
                conversationId: c.sourceId,
                role: m.role,
                content: m.content,
                status: Value(m.status),
                modelId: Value(m.modelId),
                completionTokens: Value(m.completionTokens),
                timeToFirstTokenMs: Value(m.timeToFirstTokenMs),
                tokensPerSecond: Value(m.tokensPerSecond),
                createdAt: m.createdAt,
              ),
            );
      }
      imported++;
    }
    return ImportResult(
      imported: imported,
      duplicates: duplicates,
      skippedInvalid: parsed.skippedInvalid,
    );
  });
}
