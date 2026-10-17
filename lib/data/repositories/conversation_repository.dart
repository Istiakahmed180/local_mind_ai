import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

class ConversationRepository {
  ConversationRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  Stream<List<Conversation>> watchAll({String query = ''}) {
    final q = _db.select(_db.conversations)
      ..orderBy([(c) => OrderingTerm.desc(c.updatedAt)]);
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      final pattern = '%${_escapeLike(trimmed)}%';
      q.where(
        (c) =>
            c.title.like(pattern, escapeChar: r'\') |
            existsQuery(
              _db.select(_db.messages)..where(
                (m) =>
                    m.conversationId.equalsExp(c.id) &
                    m.content.like(pattern, escapeChar: r'\'),
              ),
            ),
      );
    }
    return q.watch();
  }

  Future<Conversation?> byId(String id) => (_db.select(
    _db.conversations,
  )..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<Conversation> create({required String title, String? modelId}) async {
    final now = DateTime.now();
    final row = ConversationsCompanion.insert(
      id: _uuid.v4(),
      title: title,
      modelId: Value(modelId),
      createdAt: now,
      updatedAt: now,
    );
    return _db.into(_db.conversations).insertReturning(row);
  }

  Future<void> rename(String id, String title) =>
      (_db.update(_db.conversations)..where((c) => c.id.equals(id))).write(
        ConversationsCompanion(title: Value(title)),
      );

  Future<void> setModel(String id, String? modelId) =>
      (_db.update(_db.conversations)..where((c) => c.id.equals(id))).write(
        ConversationsCompanion(modelId: Value(modelId)),
      );

  Future<void> delete(String id) =>
      (_db.delete(_db.conversations)..where((c) => c.id.equals(id))).go();

  Stream<List<Message>> watchMessages(String conversationId) =>
      (_db.select(_db.messages)
            ..where((m) => m.conversationId.equals(conversationId))
            ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
          .watch();

  Future<List<Message>> messages(String conversationId) =>
      (_db.select(_db.messages)
            ..where((m) => m.conversationId.equals(conversationId))
            ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
          .get();

  Future<Message> addMessage({
    required String conversationId,
    required String role,
    required String content,
    String status = 'complete',
    String? modelId,
    int? completionTokens,
    int? timeToFirstTokenMs,
    double? tokensPerSecond,
  }) async {
    final now = DateTime.now();
    final row = await _db
        .into(_db.messages)
        .insertReturning(
          MessagesCompanion.insert(
            id: _uuid.v4(),
            conversationId: conversationId,
            role: role,
            content: content,
            status: Value(status),
            modelId: Value(modelId),
            completionTokens: Value(completionTokens),
            timeToFirstTokenMs: Value(timeToFirstTokenMs),
            tokensPerSecond: Value(tokensPerSecond),
            createdAt: now,
          ),
        );
    await (_db.update(_db.conversations)
          ..where((c) => c.id.equals(conversationId)))
        .write(ConversationsCompanion(updatedAt: Value(now)));
    return row;
  }

  Future<void> deleteMessage(String id) =>
      (_db.delete(_db.messages)..where((m) => m.id.equals(id))).go();

  Future<void> report({
    required String messageId,
    required String? modelId,
    required String reason,
    required String excerpt,
  }) => _db
      .into(_db.contentReports)
      .insert(
        ContentReportsCompanion.insert(
          id: _uuid.v4(),
          messageId: messageId,
          modelId: Value(modelId),
          reason: reason,
          excerpt: excerpt.length > 2000 ? excerpt.substring(0, 2000) : excerpt,
          createdAt: DateTime.now(),
        ),
      );

  Future<List<ContentReport>> reports() => (_db.select(
    _db.contentReports,
  )..orderBy([(r) => OrderingTerm.desc(r.createdAt)])).get();

  static String _escapeLike(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
}
