// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryThroughMessageIdMeta =
      const VerificationMeta('summaryThroughMessageId');
  @override
  late final GeneratedColumn<String> summaryThroughMessageId =
      GeneratedColumn<String>(
        'summary_through_message_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    modelId,
    createdAt,
    updatedAt,
    summary,
    summaryThroughMessageId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conversation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('summary_through_message_id')) {
      context.handle(
        _summaryThroughMessageIdMeta,
        summaryThroughMessageId.isAcceptableOrUnknown(
          data['summary_through_message_id']!,
          _summaryThroughMessageIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      summaryThroughMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_through_message_id'],
      ),
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final String id;
  final String title;
  final String? modelId;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// AI-written summary of the oldest messages, used once the chat no longer
  /// fits the context window.
  final String? summary;

  /// Last message the summary covers. If that message is deleted the summary
  /// is discarded.
  final String? summaryThroughMessageId;
  const Conversation({
    required this.id,
    required this.title,
    this.modelId,
    required this.createdAt,
    required this.updatedAt,
    this.summary,
    this.summaryThroughMessageId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || modelId != null) {
      map['model_id'] = Variable<String>(modelId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || summaryThroughMessageId != null) {
      map['summary_through_message_id'] = Variable<String>(
        summaryThroughMessageId,
      );
    }
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      title: Value(title),
      modelId: modelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      summaryThroughMessageId: summaryThroughMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(summaryThroughMessageId),
    );
  }

  factory Conversation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      modelId: serializer.fromJson<String?>(json['modelId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      summary: serializer.fromJson<String?>(json['summary']),
      summaryThroughMessageId: serializer.fromJson<String?>(
        json['summaryThroughMessageId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'modelId': serializer.toJson<String?>(modelId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'summary': serializer.toJson<String?>(summary),
      'summaryThroughMessageId': serializer.toJson<String?>(
        summaryThroughMessageId,
      ),
    };
  }

  Conversation copyWith({
    String? id,
    String? title,
    Value<String?> modelId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> summary = const Value.absent(),
    Value<String?> summaryThroughMessageId = const Value.absent(),
  }) => Conversation(
    id: id ?? this.id,
    title: title ?? this.title,
    modelId: modelId.present ? modelId.value : this.modelId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    summary: summary.present ? summary.value : this.summary,
    summaryThroughMessageId: summaryThroughMessageId.present
        ? summaryThroughMessageId.value
        : this.summaryThroughMessageId,
  );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      summary: data.summary.present ? data.summary.value : this.summary,
      summaryThroughMessageId: data.summaryThroughMessageId.present
          ? data.summaryThroughMessageId.value
          : this.summaryThroughMessageId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('modelId: $modelId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('summary: $summary, ')
          ..write('summaryThroughMessageId: $summaryThroughMessageId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    modelId,
    createdAt,
    updatedAt,
    summary,
    summaryThroughMessageId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == this.id &&
          other.title == this.title &&
          other.modelId == this.modelId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.summary == this.summary &&
          other.summaryThroughMessageId == this.summaryThroughMessageId);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> modelId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> summary;
  final Value<String?> summaryThroughMessageId;
  final Value<int> rowid;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.modelId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.summary = const Value.absent(),
    this.summaryThroughMessageId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsCompanion.insert({
    required String id,
    required String title,
    this.modelId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.summary = const Value.absent(),
    this.summaryThroughMessageId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Conversation> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? modelId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? summary,
    Expression<String>? summaryThroughMessageId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (modelId != null) 'model_id': modelId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (summary != null) 'summary': summary,
      if (summaryThroughMessageId != null)
        'summary_through_message_id': summaryThroughMessageId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? modelId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? summary,
    Value<String?>? summaryThroughMessageId,
    Value<int>? rowid,
  }) {
    return ConversationsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      modelId: modelId ?? this.modelId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      summary: summary ?? this.summary,
      summaryThroughMessageId:
          summaryThroughMessageId ?? this.summaryThroughMessageId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (summaryThroughMessageId.present) {
      map['summary_through_message_id'] = Variable<String>(
        summaryThroughMessageId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('modelId: $modelId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('summary: $summary, ')
          ..write('summaryThroughMessageId: $summaryThroughMessageId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES conversations (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('complete'),
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completionTokensMeta = const VerificationMeta(
    'completionTokens',
  );
  @override
  late final GeneratedColumn<int> completionTokens = GeneratedColumn<int>(
    'completion_tokens',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeToFirstTokenMsMeta =
      const VerificationMeta('timeToFirstTokenMs');
  @override
  late final GeneratedColumn<int> timeToFirstTokenMs = GeneratedColumn<int>(
    'time_to_first_token_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokensPerSecondMeta = const VerificationMeta(
    'tokensPerSecond',
  );
  @override
  late final GeneratedColumn<double> tokensPerSecond = GeneratedColumn<double>(
    'tokens_per_second',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    role,
    content,
    status,
    modelId,
    completionTokens,
    timeToFirstTokenMs,
    tokensPerSecond,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    }
    if (data.containsKey('completion_tokens')) {
      context.handle(
        _completionTokensMeta,
        completionTokens.isAcceptableOrUnknown(
          data['completion_tokens']!,
          _completionTokensMeta,
        ),
      );
    }
    if (data.containsKey('time_to_first_token_ms')) {
      context.handle(
        _timeToFirstTokenMsMeta,
        timeToFirstTokenMs.isAcceptableOrUnknown(
          data['time_to_first_token_ms']!,
          _timeToFirstTokenMsMeta,
        ),
      );
    }
    if (data.containsKey('tokens_per_second')) {
      context.handle(
        _tokensPerSecondMeta,
        tokensPerSecond.isAcceptableOrUnknown(
          data['tokens_per_second']!,
          _tokensPerSecondMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      ),
      completionTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completion_tokens'],
      ),
      timeToFirstTokenMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_to_first_token_ms'],
      ),
      tokensPerSecond: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tokens_per_second'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String conversationId;
  final String role;
  final String content;
  final String status;
  final String? modelId;
  final int? completionTokens;
  final int? timeToFirstTokenMs;
  final double? tokensPerSecond;
  final DateTime createdAt;
  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.status,
    this.modelId,
    this.completionTokens,
    this.timeToFirstTokenMs,
    this.tokensPerSecond,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || modelId != null) {
      map['model_id'] = Variable<String>(modelId);
    }
    if (!nullToAbsent || completionTokens != null) {
      map['completion_tokens'] = Variable<int>(completionTokens);
    }
    if (!nullToAbsent || timeToFirstTokenMs != null) {
      map['time_to_first_token_ms'] = Variable<int>(timeToFirstTokenMs);
    }
    if (!nullToAbsent || tokensPerSecond != null) {
      map['tokens_per_second'] = Variable<double>(tokensPerSecond);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      status: Value(status),
      modelId: modelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelId),
      completionTokens: completionTokens == null && nullToAbsent
          ? const Value.absent()
          : Value(completionTokens),
      timeToFirstTokenMs: timeToFirstTokenMs == null && nullToAbsent
          ? const Value.absent()
          : Value(timeToFirstTokenMs),
      tokensPerSecond: tokensPerSecond == null && nullToAbsent
          ? const Value.absent()
          : Value(tokensPerSecond),
      createdAt: Value(createdAt),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      status: serializer.fromJson<String>(json['status']),
      modelId: serializer.fromJson<String?>(json['modelId']),
      completionTokens: serializer.fromJson<int?>(json['completionTokens']),
      timeToFirstTokenMs: serializer.fromJson<int?>(json['timeToFirstTokenMs']),
      tokensPerSecond: serializer.fromJson<double?>(json['tokensPerSecond']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'status': serializer.toJson<String>(status),
      'modelId': serializer.toJson<String?>(modelId),
      'completionTokens': serializer.toJson<int?>(completionTokens),
      'timeToFirstTokenMs': serializer.toJson<int?>(timeToFirstTokenMs),
      'tokensPerSecond': serializer.toJson<double?>(tokensPerSecond),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? role,
    String? content,
    String? status,
    Value<String?> modelId = const Value.absent(),
    Value<int?> completionTokens = const Value.absent(),
    Value<int?> timeToFirstTokenMs = const Value.absent(),
    Value<double?> tokensPerSecond = const Value.absent(),
    DateTime? createdAt,
  }) => Message(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    role: role ?? this.role,
    content: content ?? this.content,
    status: status ?? this.status,
    modelId: modelId.present ? modelId.value : this.modelId,
    completionTokens: completionTokens.present
        ? completionTokens.value
        : this.completionTokens,
    timeToFirstTokenMs: timeToFirstTokenMs.present
        ? timeToFirstTokenMs.value
        : this.timeToFirstTokenMs,
    tokensPerSecond: tokensPerSecond.present
        ? tokensPerSecond.value
        : this.tokensPerSecond,
    createdAt: createdAt ?? this.createdAt,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      status: data.status.present ? data.status.value : this.status,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      completionTokens: data.completionTokens.present
          ? data.completionTokens.value
          : this.completionTokens,
      timeToFirstTokenMs: data.timeToFirstTokenMs.present
          ? data.timeToFirstTokenMs.value
          : this.timeToFirstTokenMs,
      tokensPerSecond: data.tokensPerSecond.present
          ? data.tokensPerSecond.value
          : this.tokensPerSecond,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('status: $status, ')
          ..write('modelId: $modelId, ')
          ..write('completionTokens: $completionTokens, ')
          ..write('timeToFirstTokenMs: $timeToFirstTokenMs, ')
          ..write('tokensPerSecond: $tokensPerSecond, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    role,
    content,
    status,
    modelId,
    completionTokens,
    timeToFirstTokenMs,
    tokensPerSecond,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.status == this.status &&
          other.modelId == this.modelId &&
          other.completionTokens == this.completionTokens &&
          other.timeToFirstTokenMs == this.timeToFirstTokenMs &&
          other.tokensPerSecond == this.tokensPerSecond &&
          other.createdAt == this.createdAt);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> role;
  final Value<String> content;
  final Value<String> status;
  final Value<String?> modelId;
  final Value<int?> completionTokens;
  final Value<int?> timeToFirstTokenMs;
  final Value<double?> tokensPerSecond;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.status = const Value.absent(),
    this.modelId = const Value.absent(),
    this.completionTokens = const Value.absent(),
    this.timeToFirstTokenMs = const Value.absent(),
    this.tokensPerSecond = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String conversationId,
    required String role,
    required String content,
    this.status = const Value.absent(),
    this.modelId = const Value.absent(),
    this.completionTokens = const Value.absent(),
    this.timeToFirstTokenMs = const Value.absent(),
    this.tokensPerSecond = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       conversationId = Value(conversationId),
       role = Value(role),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? status,
    Expression<String>? modelId,
    Expression<int>? completionTokens,
    Expression<int>? timeToFirstTokenMs,
    Expression<double>? tokensPerSecond,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (status != null) 'status': status,
      if (modelId != null) 'model_id': modelId,
      if (completionTokens != null) 'completion_tokens': completionTokens,
      if (timeToFirstTokenMs != null)
        'time_to_first_token_ms': timeToFirstTokenMs,
      if (tokensPerSecond != null) 'tokens_per_second': tokensPerSecond,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? conversationId,
    Value<String>? role,
    Value<String>? content,
    Value<String>? status,
    Value<String?>? modelId,
    Value<int?>? completionTokens,
    Value<int?>? timeToFirstTokenMs,
    Value<double?>? tokensPerSecond,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      status: status ?? this.status,
      modelId: modelId ?? this.modelId,
      completionTokens: completionTokens ?? this.completionTokens,
      timeToFirstTokenMs: timeToFirstTokenMs ?? this.timeToFirstTokenMs,
      tokensPerSecond: tokensPerSecond ?? this.tokensPerSecond,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (completionTokens.present) {
      map['completion_tokens'] = Variable<int>(completionTokens.value);
    }
    if (timeToFirstTokenMs.present) {
      map['time_to_first_token_ms'] = Variable<int>(timeToFirstTokenMs.value);
    }
    if (tokensPerSecond.present) {
      map['tokens_per_second'] = Variable<double>(tokensPerSecond.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('status: $status, ')
          ..write('modelId: $modelId, ')
          ..write('completionTokens: $completionTokens, ')
          ..write('timeToFirstTokenMs: $timeToFirstTokenMs, ')
          ..write('tokensPerSecond: $tokensPerSecond, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstalledModelsTable extends InstalledModels
    with TableInfo<$InstalledModelsTable, InstalledModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstalledModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verifiedMeta = const VerificationMeta(
    'verified',
  );
  @override
  late final GeneratedColumn<bool> verified = GeneratedColumn<bool>(
    'verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("verified" IN (0, 1))',
    ),
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastLoadMsMeta = const VerificationMeta(
    'lastLoadMs',
  );
  @override
  late final GeneratedColumn<int> lastLoadMs = GeneratedColumn<int>(
    'last_load_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastTtftMsMeta = const VerificationMeta(
    'lastTtftMs',
  );
  @override
  late final GeneratedColumn<int> lastTtftMs = GeneratedColumn<int>(
    'last_ttft_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastTokensPerSecondMeta =
      const VerificationMeta('lastTokensPerSecond');
  @override
  late final GeneratedColumn<double> lastTokensPerSecond =
      GeneratedColumn<double>(
        'last_tokens_per_second',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    source,
    filePath,
    sizeBytes,
    sha256,
    verified,
    installedAt,
    lastUsedAt,
    lastLoadMs,
    lastTtftMs,
    lastTokensPerSecond,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installed_models';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstalledModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    }
    if (data.containsKey('verified')) {
      context.handle(
        _verifiedMeta,
        verified.isAcceptableOrUnknown(data['verified']!, _verifiedMeta),
      );
    } else if (isInserting) {
      context.missing(_verifiedMeta);
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installedAtMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_load_ms')) {
      context.handle(
        _lastLoadMsMeta,
        lastLoadMs.isAcceptableOrUnknown(
          data['last_load_ms']!,
          _lastLoadMsMeta,
        ),
      );
    }
    if (data.containsKey('last_ttft_ms')) {
      context.handle(
        _lastTtftMsMeta,
        lastTtftMs.isAcceptableOrUnknown(
          data['last_ttft_ms']!,
          _lastTtftMsMeta,
        ),
      );
    }
    if (data.containsKey('last_tokens_per_second')) {
      context.handle(
        _lastTokensPerSecondMeta,
        lastTokensPerSecond.isAcceptableOrUnknown(
          data['last_tokens_per_second']!,
          _lastTokensPerSecondMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InstalledModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstalledModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      ),
      verified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}verified'],
      )!,
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      ),
      lastLoadMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_load_ms'],
      ),
      lastTtftMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_ttft_ms'],
      ),
      lastTokensPerSecond: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_tokens_per_second'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $InstalledModelsTable createAlias(String alias) {
    return $InstalledModelsTable(attachedDatabase, alias);
  }
}

class InstalledModel extends DataClass implements Insertable<InstalledModel> {
  final String id;
  final String displayName;
  final String source;
  final String filePath;
  final int sizeBytes;
  final String? sha256;
  final bool verified;
  final DateTime installedAt;
  final DateTime? lastUsedAt;
  final int? lastLoadMs;
  final int? lastTtftMs;
  final double? lastTokensPerSecond;
  final String? lastError;
  const InstalledModel({
    required this.id,
    required this.displayName,
    required this.source,
    required this.filePath,
    required this.sizeBytes,
    this.sha256,
    required this.verified,
    required this.installedAt,
    this.lastUsedAt,
    this.lastLoadMs,
    this.lastTtftMs,
    this.lastTokensPerSecond,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['source'] = Variable<String>(source);
    map['file_path'] = Variable<String>(filePath);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || sha256 != null) {
      map['sha256'] = Variable<String>(sha256);
    }
    map['verified'] = Variable<bool>(verified);
    map['installed_at'] = Variable<DateTime>(installedAt);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    if (!nullToAbsent || lastLoadMs != null) {
      map['last_load_ms'] = Variable<int>(lastLoadMs);
    }
    if (!nullToAbsent || lastTtftMs != null) {
      map['last_ttft_ms'] = Variable<int>(lastTtftMs);
    }
    if (!nullToAbsent || lastTokensPerSecond != null) {
      map['last_tokens_per_second'] = Variable<double>(lastTokensPerSecond);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  InstalledModelsCompanion toCompanion(bool nullToAbsent) {
    return InstalledModelsCompanion(
      id: Value(id),
      displayName: Value(displayName),
      source: Value(source),
      filePath: Value(filePath),
      sizeBytes: Value(sizeBytes),
      sha256: sha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(sha256),
      verified: Value(verified),
      installedAt: Value(installedAt),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
      lastLoadMs: lastLoadMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoadMs),
      lastTtftMs: lastTtftMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTtftMs),
      lastTokensPerSecond: lastTokensPerSecond == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTokensPerSecond),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory InstalledModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstalledModel(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      source: serializer.fromJson<String>(json['source']),
      filePath: serializer.fromJson<String>(json['filePath']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      sha256: serializer.fromJson<String?>(json['sha256']),
      verified: serializer.fromJson<bool>(json['verified']),
      installedAt: serializer.fromJson<DateTime>(json['installedAt']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
      lastLoadMs: serializer.fromJson<int?>(json['lastLoadMs']),
      lastTtftMs: serializer.fromJson<int?>(json['lastTtftMs']),
      lastTokensPerSecond: serializer.fromJson<double?>(
        json['lastTokensPerSecond'],
      ),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'source': serializer.toJson<String>(source),
      'filePath': serializer.toJson<String>(filePath),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'sha256': serializer.toJson<String?>(sha256),
      'verified': serializer.toJson<bool>(verified),
      'installedAt': serializer.toJson<DateTime>(installedAt),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
      'lastLoadMs': serializer.toJson<int?>(lastLoadMs),
      'lastTtftMs': serializer.toJson<int?>(lastTtftMs),
      'lastTokensPerSecond': serializer.toJson<double?>(lastTokensPerSecond),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  InstalledModel copyWith({
    String? id,
    String? displayName,
    String? source,
    String? filePath,
    int? sizeBytes,
    Value<String?> sha256 = const Value.absent(),
    bool? verified,
    DateTime? installedAt,
    Value<DateTime?> lastUsedAt = const Value.absent(),
    Value<int?> lastLoadMs = const Value.absent(),
    Value<int?> lastTtftMs = const Value.absent(),
    Value<double?> lastTokensPerSecond = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => InstalledModel(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    source: source ?? this.source,
    filePath: filePath ?? this.filePath,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    sha256: sha256.present ? sha256.value : this.sha256,
    verified: verified ?? this.verified,
    installedAt: installedAt ?? this.installedAt,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
    lastLoadMs: lastLoadMs.present ? lastLoadMs.value : this.lastLoadMs,
    lastTtftMs: lastTtftMs.present ? lastTtftMs.value : this.lastTtftMs,
    lastTokensPerSecond: lastTokensPerSecond.present
        ? lastTokensPerSecond.value
        : this.lastTokensPerSecond,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  InstalledModel copyWithCompanion(InstalledModelsCompanion data) {
    return InstalledModel(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      source: data.source.present ? data.source.value : this.source,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      verified: data.verified.present ? data.verified.value : this.verified,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
      lastLoadMs: data.lastLoadMs.present
          ? data.lastLoadMs.value
          : this.lastLoadMs,
      lastTtftMs: data.lastTtftMs.present
          ? data.lastTtftMs.value
          : this.lastTtftMs,
      lastTokensPerSecond: data.lastTokensPerSecond.present
          ? data.lastTokensPerSecond.value
          : this.lastTokensPerSecond,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstalledModel(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('source: $source, ')
          ..write('filePath: $filePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('verified: $verified, ')
          ..write('installedAt: $installedAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('lastLoadMs: $lastLoadMs, ')
          ..write('lastTtftMs: $lastTtftMs, ')
          ..write('lastTokensPerSecond: $lastTokensPerSecond, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    source,
    filePath,
    sizeBytes,
    sha256,
    verified,
    installedAt,
    lastUsedAt,
    lastLoadMs,
    lastTtftMs,
    lastTokensPerSecond,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstalledModel &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.source == this.source &&
          other.filePath == this.filePath &&
          other.sizeBytes == this.sizeBytes &&
          other.sha256 == this.sha256 &&
          other.verified == this.verified &&
          other.installedAt == this.installedAt &&
          other.lastUsedAt == this.lastUsedAt &&
          other.lastLoadMs == this.lastLoadMs &&
          other.lastTtftMs == this.lastTtftMs &&
          other.lastTokensPerSecond == this.lastTokensPerSecond &&
          other.lastError == this.lastError);
}

class InstalledModelsCompanion extends UpdateCompanion<InstalledModel> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String> source;
  final Value<String> filePath;
  final Value<int> sizeBytes;
  final Value<String?> sha256;
  final Value<bool> verified;
  final Value<DateTime> installedAt;
  final Value<DateTime?> lastUsedAt;
  final Value<int?> lastLoadMs;
  final Value<int?> lastTtftMs;
  final Value<double?> lastTokensPerSecond;
  final Value<String?> lastError;
  final Value<int> rowid;
  const InstalledModelsCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.source = const Value.absent(),
    this.filePath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.verified = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.lastLoadMs = const Value.absent(),
    this.lastTtftMs = const Value.absent(),
    this.lastTokensPerSecond = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstalledModelsCompanion.insert({
    required String id,
    required String displayName,
    required String source,
    required String filePath,
    required int sizeBytes,
    this.sha256 = const Value.absent(),
    required bool verified,
    required DateTime installedAt,
    this.lastUsedAt = const Value.absent(),
    this.lastLoadMs = const Value.absent(),
    this.lastTtftMs = const Value.absent(),
    this.lastTokensPerSecond = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       source = Value(source),
       filePath = Value(filePath),
       sizeBytes = Value(sizeBytes),
       verified = Value(verified),
       installedAt = Value(installedAt);
  static Insertable<InstalledModel> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? source,
    Expression<String>? filePath,
    Expression<int>? sizeBytes,
    Expression<String>? sha256,
    Expression<bool>? verified,
    Expression<DateTime>? installedAt,
    Expression<DateTime>? lastUsedAt,
    Expression<int>? lastLoadMs,
    Expression<int>? lastTtftMs,
    Expression<double>? lastTokensPerSecond,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (source != null) 'source': source,
      if (filePath != null) 'file_path': filePath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (sha256 != null) 'sha256': sha256,
      if (verified != null) 'verified': verified,
      if (installedAt != null) 'installed_at': installedAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (lastLoadMs != null) 'last_load_ms': lastLoadMs,
      if (lastTtftMs != null) 'last_ttft_ms': lastTtftMs,
      if (lastTokensPerSecond != null)
        'last_tokens_per_second': lastTokensPerSecond,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstalledModelsCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String>? source,
    Value<String>? filePath,
    Value<int>? sizeBytes,
    Value<String?>? sha256,
    Value<bool>? verified,
    Value<DateTime>? installedAt,
    Value<DateTime?>? lastUsedAt,
    Value<int?>? lastLoadMs,
    Value<int?>? lastTtftMs,
    Value<double?>? lastTokensPerSecond,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return InstalledModelsCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      source: source ?? this.source,
      filePath: filePath ?? this.filePath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sha256: sha256 ?? this.sha256,
      verified: verified ?? this.verified,
      installedAt: installedAt ?? this.installedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      lastLoadMs: lastLoadMs ?? this.lastLoadMs,
      lastTtftMs: lastTtftMs ?? this.lastTtftMs,
      lastTokensPerSecond: lastTokensPerSecond ?? this.lastTokensPerSecond,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (verified.present) {
      map['verified'] = Variable<bool>(verified.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (lastLoadMs.present) {
      map['last_load_ms'] = Variable<int>(lastLoadMs.value);
    }
    if (lastTtftMs.present) {
      map['last_ttft_ms'] = Variable<int>(lastTtftMs.value);
    }
    if (lastTokensPerSecond.present) {
      map['last_tokens_per_second'] = Variable<double>(
        lastTokensPerSecond.value,
      );
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstalledModelsCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('source: $source, ')
          ..write('filePath: $filePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha256: $sha256, ')
          ..write('verified: $verified, ')
          ..write('installedAt: $installedAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('lastLoadMs: $lastLoadMs, ')
          ..write('lastTtftMs: $lastTtftMs, ')
          ..write('lastTokensPerSecond: $lastTokensPerSecond, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContentReportsTable extends ContentReports
    with TableInfo<$ContentReportsTable, ContentReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _excerptMeta = const VerificationMeta(
    'excerpt',
  );
  @override
  late final GeneratedColumn<String> excerpt = GeneratedColumn<String>(
    'excerpt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageId,
    modelId,
    reason,
    excerpt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentReport> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('excerpt')) {
      context.handle(
        _excerptMeta,
        excerpt.isAcceptableOrUnknown(data['excerpt']!, _excerptMeta),
      );
    } else if (isInserting) {
      context.missing(_excerptMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContentReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentReport(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      excerpt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}excerpt'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ContentReportsTable createAlias(String alias) {
    return $ContentReportsTable(attachedDatabase, alias);
  }
}

class ContentReport extends DataClass implements Insertable<ContentReport> {
  final String id;
  final String messageId;
  final String? modelId;
  final String reason;
  final String excerpt;
  final DateTime createdAt;
  const ContentReport({
    required this.id,
    required this.messageId,
    this.modelId,
    required this.reason,
    required this.excerpt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['message_id'] = Variable<String>(messageId);
    if (!nullToAbsent || modelId != null) {
      map['model_id'] = Variable<String>(modelId);
    }
    map['reason'] = Variable<String>(reason);
    map['excerpt'] = Variable<String>(excerpt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ContentReportsCompanion toCompanion(bool nullToAbsent) {
    return ContentReportsCompanion(
      id: Value(id),
      messageId: Value(messageId),
      modelId: modelId == null && nullToAbsent
          ? const Value.absent()
          : Value(modelId),
      reason: Value(reason),
      excerpt: Value(excerpt),
      createdAt: Value(createdAt),
    );
  }

  factory ContentReport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentReport(
      id: serializer.fromJson<String>(json['id']),
      messageId: serializer.fromJson<String>(json['messageId']),
      modelId: serializer.fromJson<String?>(json['modelId']),
      reason: serializer.fromJson<String>(json['reason']),
      excerpt: serializer.fromJson<String>(json['excerpt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'messageId': serializer.toJson<String>(messageId),
      'modelId': serializer.toJson<String?>(modelId),
      'reason': serializer.toJson<String>(reason),
      'excerpt': serializer.toJson<String>(excerpt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ContentReport copyWith({
    String? id,
    String? messageId,
    Value<String?> modelId = const Value.absent(),
    String? reason,
    String? excerpt,
    DateTime? createdAt,
  }) => ContentReport(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    modelId: modelId.present ? modelId.value : this.modelId,
    reason: reason ?? this.reason,
    excerpt: excerpt ?? this.excerpt,
    createdAt: createdAt ?? this.createdAt,
  );
  ContentReport copyWithCompanion(ContentReportsCompanion data) {
    return ContentReport(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      reason: data.reason.present ? data.reason.value : this.reason,
      excerpt: data.excerpt.present ? data.excerpt.value : this.excerpt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentReport(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('modelId: $modelId, ')
          ..write('reason: $reason, ')
          ..write('excerpt: $excerpt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, messageId, modelId, reason, excerpt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentReport &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.modelId == this.modelId &&
          other.reason == this.reason &&
          other.excerpt == this.excerpt &&
          other.createdAt == this.createdAt);
}

class ContentReportsCompanion extends UpdateCompanion<ContentReport> {
  final Value<String> id;
  final Value<String> messageId;
  final Value<String?> modelId;
  final Value<String> reason;
  final Value<String> excerpt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ContentReportsCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.reason = const Value.absent(),
    this.excerpt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentReportsCompanion.insert({
    required String id,
    required String messageId,
    this.modelId = const Value.absent(),
    required String reason,
    required String excerpt,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       messageId = Value(messageId),
       reason = Value(reason),
       excerpt = Value(excerpt),
       createdAt = Value(createdAt);
  static Insertable<ContentReport> custom({
    Expression<String>? id,
    Expression<String>? messageId,
    Expression<String>? modelId,
    Expression<String>? reason,
    Expression<String>? excerpt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (modelId != null) 'model_id': modelId,
      if (reason != null) 'reason': reason,
      if (excerpt != null) 'excerpt': excerpt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentReportsCompanion copyWith({
    Value<String>? id,
    Value<String>? messageId,
    Value<String?>? modelId,
    Value<String>? reason,
    Value<String>? excerpt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ContentReportsCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      modelId: modelId ?? this.modelId,
      reason: reason ?? this.reason,
      excerpt: excerpt ?? this.excerpt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (excerpt.present) {
      map['excerpt'] = Variable<String>(excerpt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentReportsCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('modelId: $modelId, ')
          ..write('reason: $reason, ')
          ..write('excerpt: $excerpt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentsTable extends Documents
    with TableInfo<$DocumentsTable, Document> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chunkCountMeta = const VerificationMeta(
    'chunkCount',
  );
  @override
  late final GeneratedColumn<int> chunkCount = GeneratedColumn<int>(
    'chunk_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _charCountMeta = const VerificationMeta(
    'charCount',
  );
  @override
  late final GeneratedColumn<int> charCount = GeneratedColumn<int>(
    'char_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _indexedAtMeta = const VerificationMeta(
    'indexedAt',
  );
  @override
  late final GeneratedColumn<DateTime> indexedAt = GeneratedColumn<DateTime>(
    'indexed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrPagesMeta = const VerificationMeta(
    'ocrPages',
  );
  @override
  late final GeneratedColumn<int> ocrPages = GeneratedColumn<int>(
    'ocr_pages',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    filePath,
    sizeBytes,
    pageCount,
    chunkCount,
    charCount,
    status,
    error,
    importedAt,
    indexedAt,
    ocrPages,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<Document> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('chunk_count')) {
      context.handle(
        _chunkCountMeta,
        chunkCount.isAcceptableOrUnknown(data['chunk_count']!, _chunkCountMeta),
      );
    }
    if (data.containsKey('char_count')) {
      context.handle(
        _charCountMeta,
        charCount.isAcceptableOrUnknown(data['char_count']!, _charCountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('indexed_at')) {
      context.handle(
        _indexedAtMeta,
        indexedAt.isAcceptableOrUnknown(data['indexed_at']!, _indexedAtMeta),
      );
    }
    if (data.containsKey('ocr_pages')) {
      context.handle(
        _ocrPagesMeta,
        ocrPages.isAcceptableOrUnknown(data['ocr_pages']!, _ocrPagesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Document map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Document(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      chunkCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_count'],
      )!,
      charCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}char_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      indexedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}indexed_at'],
      ),
      ocrPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ocr_pages'],
      ),
    );
  }

  @override
  $DocumentsTable createAlias(String alias) {
    return $DocumentsTable(attachedDatabase, alias);
  }
}

class Document extends DataClass implements Insertable<Document> {
  final String id;
  final String name;
  final String kind;
  final String filePath;
  final int sizeBytes;
  final int? pageCount;
  final int chunkCount;
  final int charCount;
  final String status;
  final String? error;
  final DateTime importedAt;
  final DateTime? indexedAt;

  /// Pages whose text came from OCR; their text may contain errors.
  final int? ocrPages;
  const Document({
    required this.id,
    required this.name,
    required this.kind,
    required this.filePath,
    required this.sizeBytes,
    this.pageCount,
    required this.chunkCount,
    required this.charCount,
    required this.status,
    this.error,
    required this.importedAt,
    this.indexedAt,
    this.ocrPages,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['file_path'] = Variable<String>(filePath);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    map['chunk_count'] = Variable<int>(chunkCount);
    map['char_count'] = Variable<int>(charCount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['imported_at'] = Variable<DateTime>(importedAt);
    if (!nullToAbsent || indexedAt != null) {
      map['indexed_at'] = Variable<DateTime>(indexedAt);
    }
    if (!nullToAbsent || ocrPages != null) {
      map['ocr_pages'] = Variable<int>(ocrPages);
    }
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      filePath: Value(filePath),
      sizeBytes: Value(sizeBytes),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      chunkCount: Value(chunkCount),
      charCount: Value(charCount),
      status: Value(status),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      importedAt: Value(importedAt),
      indexedAt: indexedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(indexedAt),
      ocrPages: ocrPages == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrPages),
    );
  }

  factory Document.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Document(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      filePath: serializer.fromJson<String>(json['filePath']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      chunkCount: serializer.fromJson<int>(json['chunkCount']),
      charCount: serializer.fromJson<int>(json['charCount']),
      status: serializer.fromJson<String>(json['status']),
      error: serializer.fromJson<String?>(json['error']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      indexedAt: serializer.fromJson<DateTime?>(json['indexedAt']),
      ocrPages: serializer.fromJson<int?>(json['ocrPages']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'filePath': serializer.toJson<String>(filePath),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'pageCount': serializer.toJson<int?>(pageCount),
      'chunkCount': serializer.toJson<int>(chunkCount),
      'charCount': serializer.toJson<int>(charCount),
      'status': serializer.toJson<String>(status),
      'error': serializer.toJson<String?>(error),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'indexedAt': serializer.toJson<DateTime?>(indexedAt),
      'ocrPages': serializer.toJson<int?>(ocrPages),
    };
  }

  Document copyWith({
    String? id,
    String? name,
    String? kind,
    String? filePath,
    int? sizeBytes,
    Value<int?> pageCount = const Value.absent(),
    int? chunkCount,
    int? charCount,
    String? status,
    Value<String?> error = const Value.absent(),
    DateTime? importedAt,
    Value<DateTime?> indexedAt = const Value.absent(),
    Value<int?> ocrPages = const Value.absent(),
  }) => Document(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    filePath: filePath ?? this.filePath,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    chunkCount: chunkCount ?? this.chunkCount,
    charCount: charCount ?? this.charCount,
    status: status ?? this.status,
    error: error.present ? error.value : this.error,
    importedAt: importedAt ?? this.importedAt,
    indexedAt: indexedAt.present ? indexedAt.value : this.indexedAt,
    ocrPages: ocrPages.present ? ocrPages.value : this.ocrPages,
  );
  Document copyWithCompanion(DocumentsCompanion data) {
    return Document(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      chunkCount: data.chunkCount.present
          ? data.chunkCount.value
          : this.chunkCount,
      charCount: data.charCount.present ? data.charCount.value : this.charCount,
      status: data.status.present ? data.status.value : this.status,
      error: data.error.present ? data.error.value : this.error,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      indexedAt: data.indexedAt.present ? data.indexedAt.value : this.indexedAt,
      ocrPages: data.ocrPages.present ? data.ocrPages.value : this.ocrPages,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Document(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('filePath: $filePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('pageCount: $pageCount, ')
          ..write('chunkCount: $chunkCount, ')
          ..write('charCount: $charCount, ')
          ..write('status: $status, ')
          ..write('error: $error, ')
          ..write('importedAt: $importedAt, ')
          ..write('indexedAt: $indexedAt, ')
          ..write('ocrPages: $ocrPages')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    filePath,
    sizeBytes,
    pageCount,
    chunkCount,
    charCount,
    status,
    error,
    importedAt,
    indexedAt,
    ocrPages,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Document &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.filePath == this.filePath &&
          other.sizeBytes == this.sizeBytes &&
          other.pageCount == this.pageCount &&
          other.chunkCount == this.chunkCount &&
          other.charCount == this.charCount &&
          other.status == this.status &&
          other.error == this.error &&
          other.importedAt == this.importedAt &&
          other.indexedAt == this.indexedAt &&
          other.ocrPages == this.ocrPages);
}

class DocumentsCompanion extends UpdateCompanion<Document> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> filePath;
  final Value<int> sizeBytes;
  final Value<int?> pageCount;
  final Value<int> chunkCount;
  final Value<int> charCount;
  final Value<String> status;
  final Value<String?> error;
  final Value<DateTime> importedAt;
  final Value<DateTime?> indexedAt;
  final Value<int?> ocrPages;
  final Value<int> rowid;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.filePath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.chunkCount = const Value.absent(),
    this.charCount = const Value.absent(),
    this.status = const Value.absent(),
    this.error = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.indexedAt = const Value.absent(),
    this.ocrPages = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsCompanion.insert({
    required String id,
    required String name,
    required String kind,
    required String filePath,
    required int sizeBytes,
    this.pageCount = const Value.absent(),
    this.chunkCount = const Value.absent(),
    this.charCount = const Value.absent(),
    required String status,
    this.error = const Value.absent(),
    required DateTime importedAt,
    this.indexedAt = const Value.absent(),
    this.ocrPages = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind),
       filePath = Value(filePath),
       sizeBytes = Value(sizeBytes),
       status = Value(status),
       importedAt = Value(importedAt);
  static Insertable<Document> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? filePath,
    Expression<int>? sizeBytes,
    Expression<int>? pageCount,
    Expression<int>? chunkCount,
    Expression<int>? charCount,
    Expression<String>? status,
    Expression<String>? error,
    Expression<DateTime>? importedAt,
    Expression<DateTime>? indexedAt,
    Expression<int>? ocrPages,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (filePath != null) 'file_path': filePath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (pageCount != null) 'page_count': pageCount,
      if (chunkCount != null) 'chunk_count': chunkCount,
      if (charCount != null) 'char_count': charCount,
      if (status != null) 'status': status,
      if (error != null) 'error': error,
      if (importedAt != null) 'imported_at': importedAt,
      if (indexedAt != null) 'indexed_at': indexedAt,
      if (ocrPages != null) 'ocr_pages': ocrPages,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? filePath,
    Value<int>? sizeBytes,
    Value<int?>? pageCount,
    Value<int>? chunkCount,
    Value<int>? charCount,
    Value<String>? status,
    Value<String?>? error,
    Value<DateTime>? importedAt,
    Value<DateTime?>? indexedAt,
    Value<int?>? ocrPages,
    Value<int>? rowid,
  }) {
    return DocumentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      filePath: filePath ?? this.filePath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      pageCount: pageCount ?? this.pageCount,
      chunkCount: chunkCount ?? this.chunkCount,
      charCount: charCount ?? this.charCount,
      status: status ?? this.status,
      error: error ?? this.error,
      importedAt: importedAt ?? this.importedAt,
      indexedAt: indexedAt ?? this.indexedAt,
      ocrPages: ocrPages ?? this.ocrPages,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (chunkCount.present) {
      map['chunk_count'] = Variable<int>(chunkCount.value);
    }
    if (charCount.present) {
      map['char_count'] = Variable<int>(charCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (indexedAt.present) {
      map['indexed_at'] = Variable<DateTime>(indexedAt.value);
    }
    if (ocrPages.present) {
      map['ocr_pages'] = Variable<int>(ocrPages.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('filePath: $filePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('pageCount: $pageCount, ')
          ..write('chunkCount: $chunkCount, ')
          ..write('charCount: $charCount, ')
          ..write('status: $status, ')
          ..write('error: $error, ')
          ..write('importedAt: $importedAt, ')
          ..write('indexedAt: $indexedAt, ')
          ..write('ocrPages: $ocrPages, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentChunksTable extends DocumentChunks
    with TableInfo<$DocumentChunksTable, DocumentChunk> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentChunksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES documents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lineStartMeta = const VerificationMeta(
    'lineStart',
  );
  @override
  late final GeneratedColumn<int> lineStart = GeneratedColumn<int>(
    'line_start',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lineEndMeta = const VerificationMeta(
    'lineEnd',
  );
  @override
  late final GeneratedColumn<int> lineEnd = GeneratedColumn<int>(
    'line_end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    ordinal,
    page,
    lineStart,
    lineEnd,
    body,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_chunks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentChunk> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    } else if (isInserting) {
      context.missing(_ordinalMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    }
    if (data.containsKey('line_start')) {
      context.handle(
        _lineStartMeta,
        lineStart.isAcceptableOrUnknown(data['line_start']!, _lineStartMeta),
      );
    }
    if (data.containsKey('line_end')) {
      context.handle(
        _lineEndMeta,
        lineEnd.isAcceptableOrUnknown(data['line_end']!, _lineEndMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentChunk map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentChunk(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      ),
      lineStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_start'],
      ),
      lineEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_end'],
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
    );
  }

  @override
  $DocumentChunksTable createAlias(String alias) {
    return $DocumentChunksTable(attachedDatabase, alias);
  }
}

class DocumentChunk extends DataClass implements Insertable<DocumentChunk> {
  final int id;
  final String documentId;
  final int ordinal;
  final int? page;
  final int? lineStart;
  final int? lineEnd;
  final String body;
  const DocumentChunk({
    required this.id,
    required this.documentId,
    required this.ordinal,
    this.page,
    this.lineStart,
    this.lineEnd,
    required this.body,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['document_id'] = Variable<String>(documentId);
    map['ordinal'] = Variable<int>(ordinal);
    if (!nullToAbsent || page != null) {
      map['page'] = Variable<int>(page);
    }
    if (!nullToAbsent || lineStart != null) {
      map['line_start'] = Variable<int>(lineStart);
    }
    if (!nullToAbsent || lineEnd != null) {
      map['line_end'] = Variable<int>(lineEnd);
    }
    map['body'] = Variable<String>(body);
    return map;
  }

  DocumentChunksCompanion toCompanion(bool nullToAbsent) {
    return DocumentChunksCompanion(
      id: Value(id),
      documentId: Value(documentId),
      ordinal: Value(ordinal),
      page: page == null && nullToAbsent ? const Value.absent() : Value(page),
      lineStart: lineStart == null && nullToAbsent
          ? const Value.absent()
          : Value(lineStart),
      lineEnd: lineEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(lineEnd),
      body: Value(body),
    );
  }

  factory DocumentChunk.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentChunk(
      id: serializer.fromJson<int>(json['id']),
      documentId: serializer.fromJson<String>(json['documentId']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
      page: serializer.fromJson<int?>(json['page']),
      lineStart: serializer.fromJson<int?>(json['lineStart']),
      lineEnd: serializer.fromJson<int?>(json['lineEnd']),
      body: serializer.fromJson<String>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'documentId': serializer.toJson<String>(documentId),
      'ordinal': serializer.toJson<int>(ordinal),
      'page': serializer.toJson<int?>(page),
      'lineStart': serializer.toJson<int?>(lineStart),
      'lineEnd': serializer.toJson<int?>(lineEnd),
      'body': serializer.toJson<String>(body),
    };
  }

  DocumentChunk copyWith({
    int? id,
    String? documentId,
    int? ordinal,
    Value<int?> page = const Value.absent(),
    Value<int?> lineStart = const Value.absent(),
    Value<int?> lineEnd = const Value.absent(),
    String? body,
  }) => DocumentChunk(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    ordinal: ordinal ?? this.ordinal,
    page: page.present ? page.value : this.page,
    lineStart: lineStart.present ? lineStart.value : this.lineStart,
    lineEnd: lineEnd.present ? lineEnd.value : this.lineEnd,
    body: body ?? this.body,
  );
  DocumentChunk copyWithCompanion(DocumentChunksCompanion data) {
    return DocumentChunk(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      page: data.page.present ? data.page.value : this.page,
      lineStart: data.lineStart.present ? data.lineStart.value : this.lineStart,
      lineEnd: data.lineEnd.present ? data.lineEnd.value : this.lineEnd,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentChunk(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('ordinal: $ordinal, ')
          ..write('page: $page, ')
          ..write('lineStart: $lineStart, ')
          ..write('lineEnd: $lineEnd, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, documentId, ordinal, page, lineStart, lineEnd, body);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentChunk &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.ordinal == this.ordinal &&
          other.page == this.page &&
          other.lineStart == this.lineStart &&
          other.lineEnd == this.lineEnd &&
          other.body == this.body);
}

class DocumentChunksCompanion extends UpdateCompanion<DocumentChunk> {
  final Value<int> id;
  final Value<String> documentId;
  final Value<int> ordinal;
  final Value<int?> page;
  final Value<int?> lineStart;
  final Value<int?> lineEnd;
  final Value<String> body;
  const DocumentChunksCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.page = const Value.absent(),
    this.lineStart = const Value.absent(),
    this.lineEnd = const Value.absent(),
    this.body = const Value.absent(),
  });
  DocumentChunksCompanion.insert({
    this.id = const Value.absent(),
    required String documentId,
    required int ordinal,
    this.page = const Value.absent(),
    this.lineStart = const Value.absent(),
    this.lineEnd = const Value.absent(),
    required String body,
  }) : documentId = Value(documentId),
       ordinal = Value(ordinal),
       body = Value(body);
  static Insertable<DocumentChunk> custom({
    Expression<int>? id,
    Expression<String>? documentId,
    Expression<int>? ordinal,
    Expression<int>? page,
    Expression<int>? lineStart,
    Expression<int>? lineEnd,
    Expression<String>? body,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (ordinal != null) 'ordinal': ordinal,
      if (page != null) 'page': page,
      if (lineStart != null) 'line_start': lineStart,
      if (lineEnd != null) 'line_end': lineEnd,
      if (body != null) 'body': body,
    });
  }

  DocumentChunksCompanion copyWith({
    Value<int>? id,
    Value<String>? documentId,
    Value<int>? ordinal,
    Value<int?>? page,
    Value<int?>? lineStart,
    Value<int?>? lineEnd,
    Value<String>? body,
  }) {
    return DocumentChunksCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      ordinal: ordinal ?? this.ordinal,
      page: page ?? this.page,
      lineStart: lineStart ?? this.lineStart,
      lineEnd: lineEnd ?? this.lineEnd,
      body: body ?? this.body,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (lineStart.present) {
      map['line_start'] = Variable<int>(lineStart.value);
    }
    if (lineEnd.present) {
      map['line_end'] = Variable<int>(lineEnd.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentChunksCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('ordinal: $ordinal, ')
          ..write('page: $page, ')
          ..write('lineStart: $lineStart, ')
          ..write('lineEnd: $lineEnd, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }
}

class $MemoryEntriesTable extends MemoryEntries
    with TableInfo<$MemoryEntriesTable, MemoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    content,
    enabled,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MemoryEntriesTable createAlias(String alias) {
    return $MemoryEntriesTable(attachedDatabase, alias);
  }
}

class MemoryEntry extends DataClass implements Insertable<MemoryEntry> {
  final String id;
  final String content;
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MemoryEntry({
    required this.id,
    required this.content,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content'] = Variable<String>(content);
    map['enabled'] = Variable<bool>(enabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MemoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return MemoryEntriesCompanion(
      id: Value(id),
      content: Value(content),
      enabled: Value(enabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MemoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryEntry(
      id: serializer.fromJson<String>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'content': serializer.toJson<String>(content),
      'enabled': serializer.toJson<bool>(enabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MemoryEntry copyWith({
    String? id,
    String? content,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MemoryEntry(
    id: id ?? this.id,
    content: content ?? this.content,
    enabled: enabled ?? this.enabled,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MemoryEntry copyWithCompanion(MemoryEntriesCompanion data) {
    return MemoryEntry(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryEntry(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, content, enabled, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryEntry &&
          other.id == this.id &&
          other.content == this.content &&
          other.enabled == this.enabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MemoryEntriesCompanion extends UpdateCompanion<MemoryEntry> {
  final Value<String> id;
  final Value<String> content;
  final Value<bool> enabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MemoryEntriesCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryEntriesCompanion.insert({
    required String id,
    required String content,
    this.enabled = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       content = Value(content),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MemoryEntry> custom({
    Expression<String>? id,
    Expression<String>? content,
    Expression<bool>? enabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (enabled != null) 'enabled': enabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? content,
    Value<bool>? enabled,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MemoryEntriesCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChunkEmbeddingsTable extends ChunkEmbeddings
    with TableInfo<$ChunkEmbeddingsTable, ChunkEmbedding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChunkEmbeddingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chunkIdMeta = const VerificationMeta(
    'chunkId',
  );
  @override
  late final GeneratedColumn<int> chunkId = GeneratedColumn<int>(
    'chunk_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES document_chunks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vectorMeta = const VerificationMeta('vector');
  @override
  late final GeneratedColumn<Uint8List> vector = GeneratedColumn<Uint8List>(
    'vector',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [chunkId, modelId, vector];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chunk_embeddings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChunkEmbedding> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chunk_id')) {
      context.handle(
        _chunkIdMeta,
        chunkId.isAcceptableOrUnknown(data['chunk_id']!, _chunkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chunkIdMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('vector')) {
      context.handle(
        _vectorMeta,
        vector.isAcceptableOrUnknown(data['vector']!, _vectorMeta),
      );
    } else if (isInserting) {
      context.missing(_vectorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chunkId, modelId};
  @override
  ChunkEmbedding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChunkEmbedding(
      chunkId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      vector: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}vector'],
      )!,
    );
  }

  @override
  $ChunkEmbeddingsTable createAlias(String alias) {
    return $ChunkEmbeddingsTable(attachedDatabase, alias);
  }
}

class ChunkEmbedding extends DataClass implements Insertable<ChunkEmbedding> {
  final int chunkId;
  final String modelId;
  final Uint8List vector;
  const ChunkEmbedding({
    required this.chunkId,
    required this.modelId,
    required this.vector,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chunk_id'] = Variable<int>(chunkId);
    map['model_id'] = Variable<String>(modelId);
    map['vector'] = Variable<Uint8List>(vector);
    return map;
  }

  ChunkEmbeddingsCompanion toCompanion(bool nullToAbsent) {
    return ChunkEmbeddingsCompanion(
      chunkId: Value(chunkId),
      modelId: Value(modelId),
      vector: Value(vector),
    );
  }

  factory ChunkEmbedding.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChunkEmbedding(
      chunkId: serializer.fromJson<int>(json['chunkId']),
      modelId: serializer.fromJson<String>(json['modelId']),
      vector: serializer.fromJson<Uint8List>(json['vector']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chunkId': serializer.toJson<int>(chunkId),
      'modelId': serializer.toJson<String>(modelId),
      'vector': serializer.toJson<Uint8List>(vector),
    };
  }

  ChunkEmbedding copyWith({int? chunkId, String? modelId, Uint8List? vector}) =>
      ChunkEmbedding(
        chunkId: chunkId ?? this.chunkId,
        modelId: modelId ?? this.modelId,
        vector: vector ?? this.vector,
      );
  ChunkEmbedding copyWithCompanion(ChunkEmbeddingsCompanion data) {
    return ChunkEmbedding(
      chunkId: data.chunkId.present ? data.chunkId.value : this.chunkId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      vector: data.vector.present ? data.vector.value : this.vector,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChunkEmbedding(')
          ..write('chunkId: $chunkId, ')
          ..write('modelId: $modelId, ')
          ..write('vector: $vector')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(chunkId, modelId, $driftBlobEquality.hash(vector));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChunkEmbedding &&
          other.chunkId == this.chunkId &&
          other.modelId == this.modelId &&
          $driftBlobEquality.equals(other.vector, this.vector));
}

class ChunkEmbeddingsCompanion extends UpdateCompanion<ChunkEmbedding> {
  final Value<int> chunkId;
  final Value<String> modelId;
  final Value<Uint8List> vector;
  final Value<int> rowid;
  const ChunkEmbeddingsCompanion({
    this.chunkId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.vector = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChunkEmbeddingsCompanion.insert({
    required int chunkId,
    required String modelId,
    required Uint8List vector,
    this.rowid = const Value.absent(),
  }) : chunkId = Value(chunkId),
       modelId = Value(modelId),
       vector = Value(vector);
  static Insertable<ChunkEmbedding> custom({
    Expression<int>? chunkId,
    Expression<String>? modelId,
    Expression<Uint8List>? vector,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chunkId != null) 'chunk_id': chunkId,
      if (modelId != null) 'model_id': modelId,
      if (vector != null) 'vector': vector,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChunkEmbeddingsCompanion copyWith({
    Value<int>? chunkId,
    Value<String>? modelId,
    Value<Uint8List>? vector,
    Value<int>? rowid,
  }) {
    return ChunkEmbeddingsCompanion(
      chunkId: chunkId ?? this.chunkId,
      modelId: modelId ?? this.modelId,
      vector: vector ?? this.vector,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chunkId.present) {
      map['chunk_id'] = Variable<int>(chunkId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (vector.present) {
      map['vector'] = Variable<Uint8List>(vector.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChunkEmbeddingsCompanion(')
          ..write('chunkId: $chunkId, ')
          ..write('modelId: $modelId, ')
          ..write('vector: $vector, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BenchmarkResultsTable extends BenchmarkResults
    with TableInfo<$BenchmarkResultsTable, BenchmarkRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BenchmarkResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextSizeMeta = const VerificationMeta(
    'contextSize',
  );
  @override
  late final GeneratedColumn<int> contextSize = GeneratedColumn<int>(
    'context_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _runsMeta = const VerificationMeta('runs');
  @override
  late final GeneratedColumn<int> runs = GeneratedColumn<int>(
    'runs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loadMsMeta = const VerificationMeta('loadMs');
  @override
  late final GeneratedColumn<int> loadMs = GeneratedColumn<int>(
    'load_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeToFirstTokenMsMeta =
      const VerificationMeta('timeToFirstTokenMs');
  @override
  late final GeneratedColumn<int> timeToFirstTokenMs = GeneratedColumn<int>(
    'time_to_first_token_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promptTokensMeta = const VerificationMeta(
    'promptTokens',
  );
  @override
  late final GeneratedColumn<int> promptTokens = GeneratedColumn<int>(
    'prompt_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completionTokensMeta = const VerificationMeta(
    'completionTokens',
  );
  @override
  late final GeneratedColumn<int> completionTokens = GeneratedColumn<int>(
    'completion_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptTokensPerSecondMeta =
      const VerificationMeta('promptTokensPerSecond');
  @override
  late final GeneratedColumn<double> promptTokensPerSecond =
      GeneratedColumn<double>(
        'prompt_tokens_per_second',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _generationTokensPerSecondMeta =
      const VerificationMeta('generationTokensPerSecond');
  @override
  late final GeneratedColumn<double> generationTokensPerSecond =
      GeneratedColumn<double>(
        'generation_tokens_per_second',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _generationMinMeta = const VerificationMeta(
    'generationMin',
  );
  @override
  late final GeneratedColumn<double> generationMin = GeneratedColumn<double>(
    'generation_min',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _generationMaxMeta = const VerificationMeta(
    'generationMax',
  );
  @override
  late final GeneratedColumn<double> generationMax = GeneratedColumn<double>(
    'generation_max',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rssAfterLoadBytesMeta = const VerificationMeta(
    'rssAfterLoadBytes',
  );
  @override
  late final GeneratedColumn<int> rssAfterLoadBytes = GeneratedColumn<int>(
    'rss_after_load_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rssPeakBytesMeta = const VerificationMeta(
    'rssPeakBytes',
  );
  @override
  late final GeneratedColumn<int> rssPeakBytes = GeneratedColumn<int>(
    'rss_peak_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceMeta = const VerificationMeta('device');
  @override
  late final GeneratedColumn<String> device = GeneratedColumn<String>(
    'device',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    modelId,
    modelName,
    createdAt,
    contextSize,
    runs,
    loadMs,
    timeToFirstTokenMs,
    promptTokens,
    completionTokens,
    promptTokensPerSecond,
    generationTokensPerSecond,
    generationMin,
    generationMax,
    rssAfterLoadBytes,
    rssPeakBytes,
    device,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'benchmark_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<BenchmarkRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('context_size')) {
      context.handle(
        _contextSizeMeta,
        contextSize.isAcceptableOrUnknown(
          data['context_size']!,
          _contextSizeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contextSizeMeta);
    }
    if (data.containsKey('runs')) {
      context.handle(
        _runsMeta,
        runs.isAcceptableOrUnknown(data['runs']!, _runsMeta),
      );
    } else if (isInserting) {
      context.missing(_runsMeta);
    }
    if (data.containsKey('load_ms')) {
      context.handle(
        _loadMsMeta,
        loadMs.isAcceptableOrUnknown(data['load_ms']!, _loadMsMeta),
      );
    } else if (isInserting) {
      context.missing(_loadMsMeta);
    }
    if (data.containsKey('time_to_first_token_ms')) {
      context.handle(
        _timeToFirstTokenMsMeta,
        timeToFirstTokenMs.isAcceptableOrUnknown(
          data['time_to_first_token_ms']!,
          _timeToFirstTokenMsMeta,
        ),
      );
    }
    if (data.containsKey('prompt_tokens')) {
      context.handle(
        _promptTokensMeta,
        promptTokens.isAcceptableOrUnknown(
          data['prompt_tokens']!,
          _promptTokensMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_promptTokensMeta);
    }
    if (data.containsKey('completion_tokens')) {
      context.handle(
        _completionTokensMeta,
        completionTokens.isAcceptableOrUnknown(
          data['completion_tokens']!,
          _completionTokensMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completionTokensMeta);
    }
    if (data.containsKey('prompt_tokens_per_second')) {
      context.handle(
        _promptTokensPerSecondMeta,
        promptTokensPerSecond.isAcceptableOrUnknown(
          data['prompt_tokens_per_second']!,
          _promptTokensPerSecondMeta,
        ),
      );
    }
    if (data.containsKey('generation_tokens_per_second')) {
      context.handle(
        _generationTokensPerSecondMeta,
        generationTokensPerSecond.isAcceptableOrUnknown(
          data['generation_tokens_per_second']!,
          _generationTokensPerSecondMeta,
        ),
      );
    }
    if (data.containsKey('generation_min')) {
      context.handle(
        _generationMinMeta,
        generationMin.isAcceptableOrUnknown(
          data['generation_min']!,
          _generationMinMeta,
        ),
      );
    }
    if (data.containsKey('generation_max')) {
      context.handle(
        _generationMaxMeta,
        generationMax.isAcceptableOrUnknown(
          data['generation_max']!,
          _generationMaxMeta,
        ),
      );
    }
    if (data.containsKey('rss_after_load_bytes')) {
      context.handle(
        _rssAfterLoadBytesMeta,
        rssAfterLoadBytes.isAcceptableOrUnknown(
          data['rss_after_load_bytes']!,
          _rssAfterLoadBytesMeta,
        ),
      );
    }
    if (data.containsKey('rss_peak_bytes')) {
      context.handle(
        _rssPeakBytesMeta,
        rssPeakBytes.isAcceptableOrUnknown(
          data['rss_peak_bytes']!,
          _rssPeakBytesMeta,
        ),
      );
    }
    if (data.containsKey('device')) {
      context.handle(
        _deviceMeta,
        device.isAcceptableOrUnknown(data['device']!, _deviceMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BenchmarkRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BenchmarkRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      contextSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}context_size'],
      )!,
      runs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}runs'],
      )!,
      loadMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}load_ms'],
      )!,
      timeToFirstTokenMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_to_first_token_ms'],
      ),
      promptTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prompt_tokens'],
      )!,
      completionTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completion_tokens'],
      )!,
      promptTokensPerSecond: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prompt_tokens_per_second'],
      ),
      generationTokensPerSecond: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}generation_tokens_per_second'],
      ),
      generationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}generation_min'],
      ),
      generationMax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}generation_max'],
      ),
      rssAfterLoadBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rss_after_load_bytes'],
      ),
      rssPeakBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rss_peak_bytes'],
      ),
      device: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device'],
      )!,
    );
  }

  @override
  $BenchmarkResultsTable createAlias(String alias) {
    return $BenchmarkResultsTable(attachedDatabase, alias);
  }
}

class BenchmarkRecord extends DataClass implements Insertable<BenchmarkRecord> {
  final String id;
  final String modelId;
  final String modelName;
  final DateTime createdAt;
  final int contextSize;
  final int runs;
  final int loadMs;
  final int? timeToFirstTokenMs;
  final int promptTokens;
  final int completionTokens;
  final double? promptTokensPerSecond;
  final double? generationTokensPerSecond;
  final double? generationMin;
  final double? generationMax;
  final int? rssAfterLoadBytes;
  final int? rssPeakBytes;

  /// e.g. "Google Pixel 7 · Android 14 · 8 cores · 8.0 GB".
  final String device;
  const BenchmarkRecord({
    required this.id,
    required this.modelId,
    required this.modelName,
    required this.createdAt,
    required this.contextSize,
    required this.runs,
    required this.loadMs,
    this.timeToFirstTokenMs,
    required this.promptTokens,
    required this.completionTokens,
    this.promptTokensPerSecond,
    this.generationTokensPerSecond,
    this.generationMin,
    this.generationMax,
    this.rssAfterLoadBytes,
    this.rssPeakBytes,
    required this.device,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['model_id'] = Variable<String>(modelId);
    map['model_name'] = Variable<String>(modelName);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['context_size'] = Variable<int>(contextSize);
    map['runs'] = Variable<int>(runs);
    map['load_ms'] = Variable<int>(loadMs);
    if (!nullToAbsent || timeToFirstTokenMs != null) {
      map['time_to_first_token_ms'] = Variable<int>(timeToFirstTokenMs);
    }
    map['prompt_tokens'] = Variable<int>(promptTokens);
    map['completion_tokens'] = Variable<int>(completionTokens);
    if (!nullToAbsent || promptTokensPerSecond != null) {
      map['prompt_tokens_per_second'] = Variable<double>(promptTokensPerSecond);
    }
    if (!nullToAbsent || generationTokensPerSecond != null) {
      map['generation_tokens_per_second'] = Variable<double>(
        generationTokensPerSecond,
      );
    }
    if (!nullToAbsent || generationMin != null) {
      map['generation_min'] = Variable<double>(generationMin);
    }
    if (!nullToAbsent || generationMax != null) {
      map['generation_max'] = Variable<double>(generationMax);
    }
    if (!nullToAbsent || rssAfterLoadBytes != null) {
      map['rss_after_load_bytes'] = Variable<int>(rssAfterLoadBytes);
    }
    if (!nullToAbsent || rssPeakBytes != null) {
      map['rss_peak_bytes'] = Variable<int>(rssPeakBytes);
    }
    map['device'] = Variable<String>(device);
    return map;
  }

  BenchmarkResultsCompanion toCompanion(bool nullToAbsent) {
    return BenchmarkResultsCompanion(
      id: Value(id),
      modelId: Value(modelId),
      modelName: Value(modelName),
      createdAt: Value(createdAt),
      contextSize: Value(contextSize),
      runs: Value(runs),
      loadMs: Value(loadMs),
      timeToFirstTokenMs: timeToFirstTokenMs == null && nullToAbsent
          ? const Value.absent()
          : Value(timeToFirstTokenMs),
      promptTokens: Value(promptTokens),
      completionTokens: Value(completionTokens),
      promptTokensPerSecond: promptTokensPerSecond == null && nullToAbsent
          ? const Value.absent()
          : Value(promptTokensPerSecond),
      generationTokensPerSecond:
          generationTokensPerSecond == null && nullToAbsent
          ? const Value.absent()
          : Value(generationTokensPerSecond),
      generationMin: generationMin == null && nullToAbsent
          ? const Value.absent()
          : Value(generationMin),
      generationMax: generationMax == null && nullToAbsent
          ? const Value.absent()
          : Value(generationMax),
      rssAfterLoadBytes: rssAfterLoadBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(rssAfterLoadBytes),
      rssPeakBytes: rssPeakBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(rssPeakBytes),
      device: Value(device),
    );
  }

  factory BenchmarkRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BenchmarkRecord(
      id: serializer.fromJson<String>(json['id']),
      modelId: serializer.fromJson<String>(json['modelId']),
      modelName: serializer.fromJson<String>(json['modelName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      contextSize: serializer.fromJson<int>(json['contextSize']),
      runs: serializer.fromJson<int>(json['runs']),
      loadMs: serializer.fromJson<int>(json['loadMs']),
      timeToFirstTokenMs: serializer.fromJson<int?>(json['timeToFirstTokenMs']),
      promptTokens: serializer.fromJson<int>(json['promptTokens']),
      completionTokens: serializer.fromJson<int>(json['completionTokens']),
      promptTokensPerSecond: serializer.fromJson<double?>(
        json['promptTokensPerSecond'],
      ),
      generationTokensPerSecond: serializer.fromJson<double?>(
        json['generationTokensPerSecond'],
      ),
      generationMin: serializer.fromJson<double?>(json['generationMin']),
      generationMax: serializer.fromJson<double?>(json['generationMax']),
      rssAfterLoadBytes: serializer.fromJson<int?>(json['rssAfterLoadBytes']),
      rssPeakBytes: serializer.fromJson<int?>(json['rssPeakBytes']),
      device: serializer.fromJson<String>(json['device']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'modelId': serializer.toJson<String>(modelId),
      'modelName': serializer.toJson<String>(modelName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'contextSize': serializer.toJson<int>(contextSize),
      'runs': serializer.toJson<int>(runs),
      'loadMs': serializer.toJson<int>(loadMs),
      'timeToFirstTokenMs': serializer.toJson<int?>(timeToFirstTokenMs),
      'promptTokens': serializer.toJson<int>(promptTokens),
      'completionTokens': serializer.toJson<int>(completionTokens),
      'promptTokensPerSecond': serializer.toJson<double?>(
        promptTokensPerSecond,
      ),
      'generationTokensPerSecond': serializer.toJson<double?>(
        generationTokensPerSecond,
      ),
      'generationMin': serializer.toJson<double?>(generationMin),
      'generationMax': serializer.toJson<double?>(generationMax),
      'rssAfterLoadBytes': serializer.toJson<int?>(rssAfterLoadBytes),
      'rssPeakBytes': serializer.toJson<int?>(rssPeakBytes),
      'device': serializer.toJson<String>(device),
    };
  }

  BenchmarkRecord copyWith({
    String? id,
    String? modelId,
    String? modelName,
    DateTime? createdAt,
    int? contextSize,
    int? runs,
    int? loadMs,
    Value<int?> timeToFirstTokenMs = const Value.absent(),
    int? promptTokens,
    int? completionTokens,
    Value<double?> promptTokensPerSecond = const Value.absent(),
    Value<double?> generationTokensPerSecond = const Value.absent(),
    Value<double?> generationMin = const Value.absent(),
    Value<double?> generationMax = const Value.absent(),
    Value<int?> rssAfterLoadBytes = const Value.absent(),
    Value<int?> rssPeakBytes = const Value.absent(),
    String? device,
  }) => BenchmarkRecord(
    id: id ?? this.id,
    modelId: modelId ?? this.modelId,
    modelName: modelName ?? this.modelName,
    createdAt: createdAt ?? this.createdAt,
    contextSize: contextSize ?? this.contextSize,
    runs: runs ?? this.runs,
    loadMs: loadMs ?? this.loadMs,
    timeToFirstTokenMs: timeToFirstTokenMs.present
        ? timeToFirstTokenMs.value
        : this.timeToFirstTokenMs,
    promptTokens: promptTokens ?? this.promptTokens,
    completionTokens: completionTokens ?? this.completionTokens,
    promptTokensPerSecond: promptTokensPerSecond.present
        ? promptTokensPerSecond.value
        : this.promptTokensPerSecond,
    generationTokensPerSecond: generationTokensPerSecond.present
        ? generationTokensPerSecond.value
        : this.generationTokensPerSecond,
    generationMin: generationMin.present
        ? generationMin.value
        : this.generationMin,
    generationMax: generationMax.present
        ? generationMax.value
        : this.generationMax,
    rssAfterLoadBytes: rssAfterLoadBytes.present
        ? rssAfterLoadBytes.value
        : this.rssAfterLoadBytes,
    rssPeakBytes: rssPeakBytes.present ? rssPeakBytes.value : this.rssPeakBytes,
    device: device ?? this.device,
  );
  BenchmarkRecord copyWithCompanion(BenchmarkResultsCompanion data) {
    return BenchmarkRecord(
      id: data.id.present ? data.id.value : this.id,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      contextSize: data.contextSize.present
          ? data.contextSize.value
          : this.contextSize,
      runs: data.runs.present ? data.runs.value : this.runs,
      loadMs: data.loadMs.present ? data.loadMs.value : this.loadMs,
      timeToFirstTokenMs: data.timeToFirstTokenMs.present
          ? data.timeToFirstTokenMs.value
          : this.timeToFirstTokenMs,
      promptTokens: data.promptTokens.present
          ? data.promptTokens.value
          : this.promptTokens,
      completionTokens: data.completionTokens.present
          ? data.completionTokens.value
          : this.completionTokens,
      promptTokensPerSecond: data.promptTokensPerSecond.present
          ? data.promptTokensPerSecond.value
          : this.promptTokensPerSecond,
      generationTokensPerSecond: data.generationTokensPerSecond.present
          ? data.generationTokensPerSecond.value
          : this.generationTokensPerSecond,
      generationMin: data.generationMin.present
          ? data.generationMin.value
          : this.generationMin,
      generationMax: data.generationMax.present
          ? data.generationMax.value
          : this.generationMax,
      rssAfterLoadBytes: data.rssAfterLoadBytes.present
          ? data.rssAfterLoadBytes.value
          : this.rssAfterLoadBytes,
      rssPeakBytes: data.rssPeakBytes.present
          ? data.rssPeakBytes.value
          : this.rssPeakBytes,
      device: data.device.present ? data.device.value : this.device,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BenchmarkRecord(')
          ..write('id: $id, ')
          ..write('modelId: $modelId, ')
          ..write('modelName: $modelName, ')
          ..write('createdAt: $createdAt, ')
          ..write('contextSize: $contextSize, ')
          ..write('runs: $runs, ')
          ..write('loadMs: $loadMs, ')
          ..write('timeToFirstTokenMs: $timeToFirstTokenMs, ')
          ..write('promptTokens: $promptTokens, ')
          ..write('completionTokens: $completionTokens, ')
          ..write('promptTokensPerSecond: $promptTokensPerSecond, ')
          ..write('generationTokensPerSecond: $generationTokensPerSecond, ')
          ..write('generationMin: $generationMin, ')
          ..write('generationMax: $generationMax, ')
          ..write('rssAfterLoadBytes: $rssAfterLoadBytes, ')
          ..write('rssPeakBytes: $rssPeakBytes, ')
          ..write('device: $device')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    modelId,
    modelName,
    createdAt,
    contextSize,
    runs,
    loadMs,
    timeToFirstTokenMs,
    promptTokens,
    completionTokens,
    promptTokensPerSecond,
    generationTokensPerSecond,
    generationMin,
    generationMax,
    rssAfterLoadBytes,
    rssPeakBytes,
    device,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BenchmarkRecord &&
          other.id == this.id &&
          other.modelId == this.modelId &&
          other.modelName == this.modelName &&
          other.createdAt == this.createdAt &&
          other.contextSize == this.contextSize &&
          other.runs == this.runs &&
          other.loadMs == this.loadMs &&
          other.timeToFirstTokenMs == this.timeToFirstTokenMs &&
          other.promptTokens == this.promptTokens &&
          other.completionTokens == this.completionTokens &&
          other.promptTokensPerSecond == this.promptTokensPerSecond &&
          other.generationTokensPerSecond == this.generationTokensPerSecond &&
          other.generationMin == this.generationMin &&
          other.generationMax == this.generationMax &&
          other.rssAfterLoadBytes == this.rssAfterLoadBytes &&
          other.rssPeakBytes == this.rssPeakBytes &&
          other.device == this.device);
}

class BenchmarkResultsCompanion extends UpdateCompanion<BenchmarkRecord> {
  final Value<String> id;
  final Value<String> modelId;
  final Value<String> modelName;
  final Value<DateTime> createdAt;
  final Value<int> contextSize;
  final Value<int> runs;
  final Value<int> loadMs;
  final Value<int?> timeToFirstTokenMs;
  final Value<int> promptTokens;
  final Value<int> completionTokens;
  final Value<double?> promptTokensPerSecond;
  final Value<double?> generationTokensPerSecond;
  final Value<double?> generationMin;
  final Value<double?> generationMax;
  final Value<int?> rssAfterLoadBytes;
  final Value<int?> rssPeakBytes;
  final Value<String> device;
  final Value<int> rowid;
  const BenchmarkResultsCompanion({
    this.id = const Value.absent(),
    this.modelId = const Value.absent(),
    this.modelName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.contextSize = const Value.absent(),
    this.runs = const Value.absent(),
    this.loadMs = const Value.absent(),
    this.timeToFirstTokenMs = const Value.absent(),
    this.promptTokens = const Value.absent(),
    this.completionTokens = const Value.absent(),
    this.promptTokensPerSecond = const Value.absent(),
    this.generationTokensPerSecond = const Value.absent(),
    this.generationMin = const Value.absent(),
    this.generationMax = const Value.absent(),
    this.rssAfterLoadBytes = const Value.absent(),
    this.rssPeakBytes = const Value.absent(),
    this.device = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BenchmarkResultsCompanion.insert({
    required String id,
    required String modelId,
    required String modelName,
    required DateTime createdAt,
    required int contextSize,
    required int runs,
    required int loadMs,
    this.timeToFirstTokenMs = const Value.absent(),
    required int promptTokens,
    required int completionTokens,
    this.promptTokensPerSecond = const Value.absent(),
    this.generationTokensPerSecond = const Value.absent(),
    this.generationMin = const Value.absent(),
    this.generationMax = const Value.absent(),
    this.rssAfterLoadBytes = const Value.absent(),
    this.rssPeakBytes = const Value.absent(),
    required String device,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       modelId = Value(modelId),
       modelName = Value(modelName),
       createdAt = Value(createdAt),
       contextSize = Value(contextSize),
       runs = Value(runs),
       loadMs = Value(loadMs),
       promptTokens = Value(promptTokens),
       completionTokens = Value(completionTokens),
       device = Value(device);
  static Insertable<BenchmarkRecord> custom({
    Expression<String>? id,
    Expression<String>? modelId,
    Expression<String>? modelName,
    Expression<DateTime>? createdAt,
    Expression<int>? contextSize,
    Expression<int>? runs,
    Expression<int>? loadMs,
    Expression<int>? timeToFirstTokenMs,
    Expression<int>? promptTokens,
    Expression<int>? completionTokens,
    Expression<double>? promptTokensPerSecond,
    Expression<double>? generationTokensPerSecond,
    Expression<double>? generationMin,
    Expression<double>? generationMax,
    Expression<int>? rssAfterLoadBytes,
    Expression<int>? rssPeakBytes,
    Expression<String>? device,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modelId != null) 'model_id': modelId,
      if (modelName != null) 'model_name': modelName,
      if (createdAt != null) 'created_at': createdAt,
      if (contextSize != null) 'context_size': contextSize,
      if (runs != null) 'runs': runs,
      if (loadMs != null) 'load_ms': loadMs,
      if (timeToFirstTokenMs != null)
        'time_to_first_token_ms': timeToFirstTokenMs,
      if (promptTokens != null) 'prompt_tokens': promptTokens,
      if (completionTokens != null) 'completion_tokens': completionTokens,
      if (promptTokensPerSecond != null)
        'prompt_tokens_per_second': promptTokensPerSecond,
      if (generationTokensPerSecond != null)
        'generation_tokens_per_second': generationTokensPerSecond,
      if (generationMin != null) 'generation_min': generationMin,
      if (generationMax != null) 'generation_max': generationMax,
      if (rssAfterLoadBytes != null) 'rss_after_load_bytes': rssAfterLoadBytes,
      if (rssPeakBytes != null) 'rss_peak_bytes': rssPeakBytes,
      if (device != null) 'device': device,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BenchmarkResultsCompanion copyWith({
    Value<String>? id,
    Value<String>? modelId,
    Value<String>? modelName,
    Value<DateTime>? createdAt,
    Value<int>? contextSize,
    Value<int>? runs,
    Value<int>? loadMs,
    Value<int?>? timeToFirstTokenMs,
    Value<int>? promptTokens,
    Value<int>? completionTokens,
    Value<double?>? promptTokensPerSecond,
    Value<double?>? generationTokensPerSecond,
    Value<double?>? generationMin,
    Value<double?>? generationMax,
    Value<int?>? rssAfterLoadBytes,
    Value<int?>? rssPeakBytes,
    Value<String>? device,
    Value<int>? rowid,
  }) {
    return BenchmarkResultsCompanion(
      id: id ?? this.id,
      modelId: modelId ?? this.modelId,
      modelName: modelName ?? this.modelName,
      createdAt: createdAt ?? this.createdAt,
      contextSize: contextSize ?? this.contextSize,
      runs: runs ?? this.runs,
      loadMs: loadMs ?? this.loadMs,
      timeToFirstTokenMs: timeToFirstTokenMs ?? this.timeToFirstTokenMs,
      promptTokens: promptTokens ?? this.promptTokens,
      completionTokens: completionTokens ?? this.completionTokens,
      promptTokensPerSecond:
          promptTokensPerSecond ?? this.promptTokensPerSecond,
      generationTokensPerSecond:
          generationTokensPerSecond ?? this.generationTokensPerSecond,
      generationMin: generationMin ?? this.generationMin,
      generationMax: generationMax ?? this.generationMax,
      rssAfterLoadBytes: rssAfterLoadBytes ?? this.rssAfterLoadBytes,
      rssPeakBytes: rssPeakBytes ?? this.rssPeakBytes,
      device: device ?? this.device,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (contextSize.present) {
      map['context_size'] = Variable<int>(contextSize.value);
    }
    if (runs.present) {
      map['runs'] = Variable<int>(runs.value);
    }
    if (loadMs.present) {
      map['load_ms'] = Variable<int>(loadMs.value);
    }
    if (timeToFirstTokenMs.present) {
      map['time_to_first_token_ms'] = Variable<int>(timeToFirstTokenMs.value);
    }
    if (promptTokens.present) {
      map['prompt_tokens'] = Variable<int>(promptTokens.value);
    }
    if (completionTokens.present) {
      map['completion_tokens'] = Variable<int>(completionTokens.value);
    }
    if (promptTokensPerSecond.present) {
      map['prompt_tokens_per_second'] = Variable<double>(
        promptTokensPerSecond.value,
      );
    }
    if (generationTokensPerSecond.present) {
      map['generation_tokens_per_second'] = Variable<double>(
        generationTokensPerSecond.value,
      );
    }
    if (generationMin.present) {
      map['generation_min'] = Variable<double>(generationMin.value);
    }
    if (generationMax.present) {
      map['generation_max'] = Variable<double>(generationMax.value);
    }
    if (rssAfterLoadBytes.present) {
      map['rss_after_load_bytes'] = Variable<int>(rssAfterLoadBytes.value);
    }
    if (rssPeakBytes.present) {
      map['rss_peak_bytes'] = Variable<int>(rssPeakBytes.value);
    }
    if (device.present) {
      map['device'] = Variable<String>(device.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BenchmarkResultsCompanion(')
          ..write('id: $id, ')
          ..write('modelId: $modelId, ')
          ..write('modelName: $modelName, ')
          ..write('createdAt: $createdAt, ')
          ..write('contextSize: $contextSize, ')
          ..write('runs: $runs, ')
          ..write('loadMs: $loadMs, ')
          ..write('timeToFirstTokenMs: $timeToFirstTokenMs, ')
          ..write('promptTokens: $promptTokens, ')
          ..write('completionTokens: $completionTokens, ')
          ..write('promptTokensPerSecond: $promptTokensPerSecond, ')
          ..write('generationTokensPerSecond: $generationTokensPerSecond, ')
          ..write('generationMin: $generationMin, ')
          ..write('generationMax: $generationMax, ')
          ..write('rssAfterLoadBytes: $rssAfterLoadBytes, ')
          ..write('rssPeakBytes: $rssPeakBytes, ')
          ..write('device: $device, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $InstalledModelsTable installedModels = $InstalledModelsTable(
    this,
  );
  late final $ContentReportsTable contentReports = $ContentReportsTable(this);
  late final $DocumentsTable documents = $DocumentsTable(this);
  late final $DocumentChunksTable documentChunks = $DocumentChunksTable(this);
  late final $MemoryEntriesTable memoryEntries = $MemoryEntriesTable(this);
  late final $ChunkEmbeddingsTable chunkEmbeddings = $ChunkEmbeddingsTable(
    this,
  );
  late final $BenchmarkResultsTable benchmarkResults = $BenchmarkResultsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    conversations,
    messages,
    installedModels,
    contentReports,
    documents,
    documentChunks,
    memoryEntries,
    chunkEmbeddings,
    benchmarkResults,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'conversations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('messages', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'documents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('document_chunks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'document_chunks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chunk_embeddings', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ConversationsTableCreateCompanionBuilder =
    ConversationsCompanion Function({
      required String id,
      required String title,
      Value<String?> modelId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> summary,
      Value<String?> summaryThroughMessageId,
      Value<int> rowid,
    });
typedef $$ConversationsTableUpdateCompanionBuilder =
    ConversationsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> modelId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> summary,
      Value<String?> summaryThroughMessageId,
      Value<int> rowid,
    });

final class $$ConversationsTableReferences
    extends BaseReferences<_$AppDatabase, $ConversationsTable, Conversation> {
  $$ConversationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MessagesTable, List<Message>> _messagesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.messages,
    aliasName: 'conversations__id__messages__conversation_id',
  );

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.conversationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryThroughMessageId => $composableBuilder(
    column: $table.summaryThroughMessageId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> messagesRefs(
    Expression<bool> Function($$MessagesTableFilterComposer f) f,
  ) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryThroughMessageId => $composableBuilder(
    column: $table.summaryThroughMessageId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get summaryThroughMessageId => $composableBuilder(
    column: $table.summaryThroughMessageId,
    builder: (column) => column,
  );

  Expression<T> messagesRefs<T extends Object>(
    Expression<T> Function($$MessagesTableAnnotationComposer a) f,
  ) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationsTable,
          Conversation,
          $$ConversationsTableFilterComposer,
          $$ConversationsTableOrderingComposer,
          $$ConversationsTableAnnotationComposer,
          $$ConversationsTableCreateCompanionBuilder,
          $$ConversationsTableUpdateCompanionBuilder,
          (Conversation, $$ConversationsTableReferences),
          Conversation,
          PrefetchHooks Function({bool messagesRefs})
        > {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> modelId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> summaryThroughMessageId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion(
                id: id,
                title: title,
                modelId: modelId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                summary: summary,
                summaryThroughMessageId: summaryThroughMessageId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> modelId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> summary = const Value.absent(),
                Value<String?> summaryThroughMessageId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion.insert(
                id: id,
                title: title,
                modelId: modelId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                summary: summary,
                summaryThroughMessageId: summaryThroughMessageId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConversationsTable, Conversation>(table),
                  $$ConversationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (messagesRefs) db.messages],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (messagesRefs)
                    await $_getPrefetchedData<
                      Conversation,
                      $ConversationsTable,
                      Message
                    >(
                      currentTable: table,
                      referencedTable: $$ConversationsTableReferences
                          ._messagesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ConversationsTableReferences(
                            db,
                            table,
                            p0,
                          ).messagesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.conversationId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationsTable,
      Conversation,
      $$ConversationsTableFilterComposer,
      $$ConversationsTableOrderingComposer,
      $$ConversationsTableAnnotationComposer,
      $$ConversationsTableCreateCompanionBuilder,
      $$ConversationsTableUpdateCompanionBuilder,
      (Conversation, $$ConversationsTableReferences),
      Conversation,
      PrefetchHooks Function({bool messagesRefs})
    >;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  required String id,
  required String conversationId,
  required String role,
  required String content,
  Value<String> status,
  Value<String?> modelId,
  Value<int?> completionTokens,
  Value<int?> timeToFirstTokenMs,
  Value<double?> tokensPerSecond,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> id,
  Value<String> conversationId,
  Value<String> role,
  Value<String> content,
  Value<String> status,
  Value<String?> modelId,
  Value<int?> completionTokens,
  Value<int?> timeToFirstTokenMs,
  Value<double?> tokensPerSecond,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$MessagesTableReferences
    extends BaseReferences<_$AppDatabase, $MessagesTable, Message> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConversationsTable _conversationIdTable(_$AppDatabase db) => db
      .conversations
      .createAlias('messages__conversation_id__conversations__id');

  $$ConversationsTableProcessedTableManager get conversationId {
    final $_column = $_itemColumn<String>('conversation_id')!;

    final manager = $$ConversationsTableTableManager(
      $_db,
      $_db.conversations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completionTokens => $composableBuilder(
    column: $table.completionTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeToFirstTokenMs => $composableBuilder(
    column: $table.timeToFirstTokenMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tokensPerSecond => $composableBuilder(
    column: $table.tokensPerSecond,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableFilterComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completionTokens => $composableBuilder(
    column: $table.completionTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeToFirstTokenMs => $composableBuilder(
    column: $table.timeToFirstTokenMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tokensPerSecond => $composableBuilder(
    column: $table.tokensPerSecond,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableOrderingComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<int> get completionTokens => $composableBuilder(
    column: $table.completionTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeToFirstTokenMs => $composableBuilder(
    column: $table.timeToFirstTokenMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tokensPerSecond => $composableBuilder(
    column: $table.tokensPerSecond,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ConversationsTableAnnotationComposer get conversationId {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableAnnotationComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, $$MessagesTableReferences),
          Message,
          PrefetchHooks Function({bool conversationId})
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> modelId = const Value.absent(),
                Value<int?> completionTokens = const Value.absent(),
                Value<int?> timeToFirstTokenMs = const Value.absent(),
                Value<double?> tokensPerSecond = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                status: status,
                modelId: modelId,
                completionTokens: completionTokens,
                timeToFirstTokenMs: timeToFirstTokenMs,
                tokensPerSecond: tokensPerSecond,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String conversationId,
                required String role,
                required String content,
                Value<String> status = const Value.absent(),
                Value<String?> modelId = const Value.absent(),
                Value<int?> completionTokens = const Value.absent(),
                Value<int?> timeToFirstTokenMs = const Value.absent(),
                Value<double?> tokensPerSecond = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                status: status,
                modelId: modelId,
                completionTokens: completionTokens,
                timeToFirstTokenMs: timeToFirstTokenMs,
                tokensPerSecond: tokensPerSecond,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MessagesTable, Message>(table),
                  $$MessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({conversationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (conversationId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.conversationId,
                        referencedTable: $$MessagesTableReferences
                            ._conversationIdTable(db),
                        referencedColumn: $$MessagesTableReferences
                            ._conversationIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, $$MessagesTableReferences),
      Message,
      PrefetchHooks Function({bool conversationId})
    >;
typedef $$InstalledModelsTableCreateCompanionBuilder =
    InstalledModelsCompanion Function({
      required String id,
      required String displayName,
      required String source,
      required String filePath,
      required int sizeBytes,
      Value<String?> sha256,
      required bool verified,
      required DateTime installedAt,
      Value<DateTime?> lastUsedAt,
      Value<int?> lastLoadMs,
      Value<int?> lastTtftMs,
      Value<double?> lastTokensPerSecond,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$InstalledModelsTableUpdateCompanionBuilder =
    InstalledModelsCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<String> source,
      Value<String> filePath,
      Value<int> sizeBytes,
      Value<String?> sha256,
      Value<bool> verified,
      Value<DateTime> installedAt,
      Value<DateTime?> lastUsedAt,
      Value<int?> lastLoadMs,
      Value<int?> lastTtftMs,
      Value<double?> lastTokensPerSecond,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$InstalledModelsTableFilterComposer
    extends Composer<_$AppDatabase, $InstalledModelsTable> {
  $$InstalledModelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get verified => $composableBuilder(
    column: $table.verified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastLoadMs => $composableBuilder(
    column: $table.lastLoadMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastTtftMs => $composableBuilder(
    column: $table.lastTtftMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastTokensPerSecond => $composableBuilder(
    column: $table.lastTokensPerSecond,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InstalledModelsTableOrderingComposer
    extends Composer<_$AppDatabase, $InstalledModelsTable> {
  $$InstalledModelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get verified => $composableBuilder(
    column: $table.verified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastLoadMs => $composableBuilder(
    column: $table.lastLoadMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastTtftMs => $composableBuilder(
    column: $table.lastTtftMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastTokensPerSecond => $composableBuilder(
    column: $table.lastTokensPerSecond,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InstalledModelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstalledModelsTable> {
  $$InstalledModelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<bool> get verified =>
      $composableBuilder(column: $table.verified, builder: (column) => column);

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastLoadMs => $composableBuilder(
    column: $table.lastLoadMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastTtftMs => $composableBuilder(
    column: $table.lastTtftMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lastTokensPerSecond => $composableBuilder(
    column: $table.lastTokensPerSecond,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$InstalledModelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstalledModelsTable,
          InstalledModel,
          $$InstalledModelsTableFilterComposer,
          $$InstalledModelsTableOrderingComposer,
          $$InstalledModelsTableAnnotationComposer,
          $$InstalledModelsTableCreateCompanionBuilder,
          $$InstalledModelsTableUpdateCompanionBuilder,
          (
            InstalledModel,
            BaseReferences<
              _$AppDatabase,
              $InstalledModelsTable,
              InstalledModel
            >,
          ),
          InstalledModel,
          PrefetchHooks Function()
        > {
  $$InstalledModelsTableTableManager(
    _$AppDatabase db,
    $InstalledModelsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstalledModelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstalledModelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstalledModelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String?> sha256 = const Value.absent(),
                Value<bool> verified = const Value.absent(),
                Value<DateTime> installedAt = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<int?> lastLoadMs = const Value.absent(),
                Value<int?> lastTtftMs = const Value.absent(),
                Value<double?> lastTokensPerSecond = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstalledModelsCompanion(
                id: id,
                displayName: displayName,
                source: source,
                filePath: filePath,
                sizeBytes: sizeBytes,
                sha256: sha256,
                verified: verified,
                installedAt: installedAt,
                lastUsedAt: lastUsedAt,
                lastLoadMs: lastLoadMs,
                lastTtftMs: lastTtftMs,
                lastTokensPerSecond: lastTokensPerSecond,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                required String source,
                required String filePath,
                required int sizeBytes,
                Value<String?> sha256 = const Value.absent(),
                required bool verified,
                required DateTime installedAt,
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<int?> lastLoadMs = const Value.absent(),
                Value<int?> lastTtftMs = const Value.absent(),
                Value<double?> lastTokensPerSecond = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstalledModelsCompanion.insert(
                id: id,
                displayName: displayName,
                source: source,
                filePath: filePath,
                sizeBytes: sizeBytes,
                sha256: sha256,
                verified: verified,
                installedAt: installedAt,
                lastUsedAt: lastUsedAt,
                lastLoadMs: lastLoadMs,
                lastTtftMs: lastTtftMs,
                lastTokensPerSecond: lastTokensPerSecond,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InstalledModelsTable, InstalledModel>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $InstalledModelsTable,
                    InstalledModel
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InstalledModelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstalledModelsTable,
      InstalledModel,
      $$InstalledModelsTableFilterComposer,
      $$InstalledModelsTableOrderingComposer,
      $$InstalledModelsTableAnnotationComposer,
      $$InstalledModelsTableCreateCompanionBuilder,
      $$InstalledModelsTableUpdateCompanionBuilder,
      (
        InstalledModel,
        BaseReferences<_$AppDatabase, $InstalledModelsTable, InstalledModel>,
      ),
      InstalledModel,
      PrefetchHooks Function()
    >;
typedef $$ContentReportsTableCreateCompanionBuilder =
    ContentReportsCompanion Function({
      required String id,
      required String messageId,
      Value<String?> modelId,
      required String reason,
      required String excerpt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ContentReportsTableUpdateCompanionBuilder =
    ContentReportsCompanion Function({
      Value<String> id,
      Value<String> messageId,
      Value<String?> modelId,
      Value<String> reason,
      Value<String> excerpt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ContentReportsTableFilterComposer
    extends Composer<_$AppDatabase, $ContentReportsTable> {
  $$ContentReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get excerpt => $composableBuilder(
    column: $table.excerpt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContentReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentReportsTable> {
  $$ContentReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get excerpt => $composableBuilder(
    column: $table.excerpt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContentReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentReportsTable> {
  $$ContentReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get excerpt =>
      $composableBuilder(column: $table.excerpt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ContentReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentReportsTable,
          ContentReport,
          $$ContentReportsTableFilterComposer,
          $$ContentReportsTableOrderingComposer,
          $$ContentReportsTableAnnotationComposer,
          $$ContentReportsTableCreateCompanionBuilder,
          $$ContentReportsTableUpdateCompanionBuilder,
          (
            ContentReport,
            BaseReferences<_$AppDatabase, $ContentReportsTable, ContentReport>,
          ),
          ContentReport,
          PrefetchHooks Function()
        > {
  $$ContentReportsTableTableManager(
    _$AppDatabase db,
    $ContentReportsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<String?> modelId = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> excerpt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentReportsCompanion(
                id: id,
                messageId: messageId,
                modelId: modelId,
                reason: reason,
                excerpt: excerpt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String messageId,
                Value<String?> modelId = const Value.absent(),
                required String reason,
                required String excerpt,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ContentReportsCompanion.insert(
                id: id,
                messageId: messageId,
                modelId: modelId,
                reason: reason,
                excerpt: excerpt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContentReportsTable, ContentReport>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ContentReportsTable,
                    ContentReport
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentReportsTable,
      ContentReport,
      $$ContentReportsTableFilterComposer,
      $$ContentReportsTableOrderingComposer,
      $$ContentReportsTableAnnotationComposer,
      $$ContentReportsTableCreateCompanionBuilder,
      $$ContentReportsTableUpdateCompanionBuilder,
      (
        ContentReport,
        BaseReferences<_$AppDatabase, $ContentReportsTable, ContentReport>,
      ),
      ContentReport,
      PrefetchHooks Function()
    >;
typedef $$DocumentsTableCreateCompanionBuilder = DocumentsCompanion Function({
  required String id,
  required String name,
  required String kind,
  required String filePath,
  required int sizeBytes,
  Value<int?> pageCount,
  Value<int> chunkCount,
  Value<int> charCount,
  required String status,
  Value<String?> error,
  required DateTime importedAt,
  Value<DateTime?> indexedAt,
  Value<int?> ocrPages,
  Value<int> rowid,
});
typedef $$DocumentsTableUpdateCompanionBuilder = DocumentsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> kind,
  Value<String> filePath,
  Value<int> sizeBytes,
  Value<int?> pageCount,
  Value<int> chunkCount,
  Value<int> charCount,
  Value<String> status,
  Value<String?> error,
  Value<DateTime> importedAt,
  Value<DateTime?> indexedAt,
  Value<int?> ocrPages,
  Value<int> rowid,
});

final class $$DocumentsTableReferences
    extends BaseReferences<_$AppDatabase, $DocumentsTable, Document> {
  $$DocumentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DocumentChunksTable, List<DocumentChunk>>
  _documentChunksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.documentChunks,
    aliasName: 'documents__id__document_chunks__document_id',
  );

  $$DocumentChunksTableProcessedTableManager get documentChunksRefs {
    final manager = $$DocumentChunksTableTableManager(
      $_db,
      $_db.documentChunks,
    ).filter((f) => f.documentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentChunksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chunkCount => $composableBuilder(
    column: $table.chunkCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get charCount => $composableBuilder(
    column: $table.charCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get indexedAt => $composableBuilder(
    column: $table.indexedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ocrPages => $composableBuilder(
    column: $table.ocrPages,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> documentChunksRefs(
    Expression<bool> Function($$DocumentChunksTableFilterComposer f) f,
  ) {
    final $$DocumentChunksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentChunks,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentChunksTableFilterComposer(
            $db: $db,
            $table: $db.documentChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chunkCount => $composableBuilder(
    column: $table.chunkCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get charCount => $composableBuilder(
    column: $table.charCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get indexedAt => $composableBuilder(
    column: $table.indexedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ocrPages => $composableBuilder(
    column: $table.ocrPages,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<int> get chunkCount => $composableBuilder(
    column: $table.chunkCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get charCount =>
      $composableBuilder(column: $table.charCount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get indexedAt =>
      $composableBuilder(column: $table.indexedAt, builder: (column) => column);

  GeneratedColumn<int> get ocrPages =>
      $composableBuilder(column: $table.ocrPages, builder: (column) => column);

  Expression<T> documentChunksRefs<T extends Object>(
    Expression<T> Function($$DocumentChunksTableAnnotationComposer a) f,
  ) {
    final $$DocumentChunksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentChunks,
      getReferencedColumn: (t) => t.documentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentChunksTableAnnotationComposer(
            $db: $db,
            $table: $db.documentChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentsTable,
          Document,
          $$DocumentsTableFilterComposer,
          $$DocumentsTableOrderingComposer,
          $$DocumentsTableAnnotationComposer,
          $$DocumentsTableCreateCompanionBuilder,
          $$DocumentsTableUpdateCompanionBuilder,
          (Document, $$DocumentsTableReferences),
          Document,
          PrefetchHooks Function({bool documentChunksRefs})
        > {
  $$DocumentsTableTableManager(_$AppDatabase db, $DocumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<int> chunkCount = const Value.absent(),
                Value<int> charCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<DateTime?> indexedAt = const Value.absent(),
                Value<int?> ocrPages = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion(
                id: id,
                name: name,
                kind: kind,
                filePath: filePath,
                sizeBytes: sizeBytes,
                pageCount: pageCount,
                chunkCount: chunkCount,
                charCount: charCount,
                status: status,
                error: error,
                importedAt: importedAt,
                indexedAt: indexedAt,
                ocrPages: ocrPages,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String kind,
                required String filePath,
                required int sizeBytes,
                Value<int?> pageCount = const Value.absent(),
                Value<int> chunkCount = const Value.absent(),
                Value<int> charCount = const Value.absent(),
                required String status,
                Value<String?> error = const Value.absent(),
                required DateTime importedAt,
                Value<DateTime?> indexedAt = const Value.absent(),
                Value<int?> ocrPages = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                filePath: filePath,
                sizeBytes: sizeBytes,
                pageCount: pageCount,
                chunkCount: chunkCount,
                charCount: charCount,
                status: status,
                error: error,
                importedAt: importedAt,
                indexedAt: indexedAt,
                ocrPages: ocrPages,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentsTable, Document>(table),
                  $$DocumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({documentChunksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (documentChunksRefs) db.documentChunks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (documentChunksRefs)
                    await $_getPrefetchedData<
                      Document,
                      $DocumentsTable,
                      DocumentChunk
                    >(
                      currentTable: table,
                      referencedTable: $$DocumentsTableReferences
                          ._documentChunksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DocumentsTableReferences(
                            db,
                            table,
                            p0,
                          ).documentChunksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.documentId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentsTable,
      Document,
      $$DocumentsTableFilterComposer,
      $$DocumentsTableOrderingComposer,
      $$DocumentsTableAnnotationComposer,
      $$DocumentsTableCreateCompanionBuilder,
      $$DocumentsTableUpdateCompanionBuilder,
      (Document, $$DocumentsTableReferences),
      Document,
      PrefetchHooks Function({bool documentChunksRefs})
    >;
typedef $$DocumentChunksTableCreateCompanionBuilder =
    DocumentChunksCompanion Function({
      Value<int> id,
      required String documentId,
      required int ordinal,
      Value<int?> page,
      Value<int?> lineStart,
      Value<int?> lineEnd,
      required String body,
    });
typedef $$DocumentChunksTableUpdateCompanionBuilder =
    DocumentChunksCompanion Function({
      Value<int> id,
      Value<String> documentId,
      Value<int> ordinal,
      Value<int?> page,
      Value<int?> lineStart,
      Value<int?> lineEnd,
      Value<String> body,
    });

final class $$DocumentChunksTableReferences
    extends BaseReferences<_$AppDatabase, $DocumentChunksTable, DocumentChunk> {
  $$DocumentChunksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DocumentsTable _documentIdTable(_$AppDatabase db) =>
      db.documents.createAlias('document_chunks__document_id__documents__id');

  $$DocumentsTableProcessedTableManager get documentId {
    final $_column = $_itemColumn<String>('document_id')!;

    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_documentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChunkEmbeddingsTable, List<ChunkEmbedding>>
  _chunkEmbeddingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.chunkEmbeddings,
    aliasName: 'document_chunks__id__chunk_embeddings__chunk_id',
  );

  $$ChunkEmbeddingsTableProcessedTableManager get chunkEmbeddingsRefs {
    final manager = $$ChunkEmbeddingsTableTableManager(
      $_db,
      $_db.chunkEmbeddings,
    ).filter((f) => f.chunkId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _chunkEmbeddingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DocumentChunksTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentChunksTable> {
  $$DocumentChunksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineStart => $composableBuilder(
    column: $table.lineStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineEnd => $composableBuilder(
    column: $table.lineEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentsTableFilterComposer get documentId {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> chunkEmbeddingsRefs(
    Expression<bool> Function($$ChunkEmbeddingsTableFilterComposer f) f,
  ) {
    final $$ChunkEmbeddingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chunkEmbeddings,
      getReferencedColumn: (t) => t.chunkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChunkEmbeddingsTableFilterComposer(
            $db: $db,
            $table: $db.chunkEmbeddings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentChunksTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentChunksTable> {
  $$DocumentChunksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineStart => $composableBuilder(
    column: $table.lineStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineEnd => $composableBuilder(
    column: $table.lineEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentsTableOrderingComposer get documentId {
    final $$DocumentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableOrderingComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentChunksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentChunksTable> {
  $$DocumentChunksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<int> get lineStart =>
      $composableBuilder(column: $table.lineStart, builder: (column) => column);

  GeneratedColumn<int> get lineEnd =>
      $composableBuilder(column: $table.lineEnd, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  $$DocumentsTableAnnotationComposer get documentId {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.documentId,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> chunkEmbeddingsRefs<T extends Object>(
    Expression<T> Function($$ChunkEmbeddingsTableAnnotationComposer a) f,
  ) {
    final $$ChunkEmbeddingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chunkEmbeddings,
      getReferencedColumn: (t) => t.chunkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChunkEmbeddingsTableAnnotationComposer(
            $db: $db,
            $table: $db.chunkEmbeddings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DocumentChunksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentChunksTable,
          DocumentChunk,
          $$DocumentChunksTableFilterComposer,
          $$DocumentChunksTableOrderingComposer,
          $$DocumentChunksTableAnnotationComposer,
          $$DocumentChunksTableCreateCompanionBuilder,
          $$DocumentChunksTableUpdateCompanionBuilder,
          (DocumentChunk, $$DocumentChunksTableReferences),
          DocumentChunk,
          PrefetchHooks Function({bool documentId, bool chunkEmbeddingsRefs})
        > {
  $$DocumentChunksTableTableManager(
    _$AppDatabase db,
    $DocumentChunksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentChunksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentChunksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentChunksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<int?> page = const Value.absent(),
                Value<int?> lineStart = const Value.absent(),
                Value<int?> lineEnd = const Value.absent(),
                Value<String> body = const Value.absent(),
              }) => DocumentChunksCompanion(
                id: id,
                documentId: documentId,
                ordinal: ordinal,
                page: page,
                lineStart: lineStart,
                lineEnd: lineEnd,
                body: body,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String documentId,
                required int ordinal,
                Value<int?> page = const Value.absent(),
                Value<int?> lineStart = const Value.absent(),
                Value<int?> lineEnd = const Value.absent(),
                required String body,
              }) => DocumentChunksCompanion.insert(
                id: id,
                documentId: documentId,
                ordinal: ordinal,
                page: page,
                lineStart: lineStart,
                lineEnd: lineEnd,
                body: body,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentChunksTable, DocumentChunk>(table),
                  $$DocumentChunksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({documentId = false, chunkEmbeddingsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (chunkEmbeddingsRefs) db.chunkEmbeddings,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (documentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.documentId,
                            referencedTable: $$DocumentChunksTableReferences
                                ._documentIdTable(db),
                            referencedColumn: $$DocumentChunksTableReferences
                                ._documentIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (chunkEmbeddingsRefs)
                        await $_getPrefetchedData<
                          DocumentChunk,
                          $DocumentChunksTable,
                          ChunkEmbedding
                        >(
                          currentTable: table,
                          referencedTable: $$DocumentChunksTableReferences
                              ._chunkEmbeddingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DocumentChunksTableReferences(
                                db,
                                table,
                                p0,
                              ).chunkEmbeddingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.chunkId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DocumentChunksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentChunksTable,
      DocumentChunk,
      $$DocumentChunksTableFilterComposer,
      $$DocumentChunksTableOrderingComposer,
      $$DocumentChunksTableAnnotationComposer,
      $$DocumentChunksTableCreateCompanionBuilder,
      $$DocumentChunksTableUpdateCompanionBuilder,
      (DocumentChunk, $$DocumentChunksTableReferences),
      DocumentChunk,
      PrefetchHooks Function({bool documentId, bool chunkEmbeddingsRefs})
    >;
typedef $$MemoryEntriesTableCreateCompanionBuilder =
    MemoryEntriesCompanion Function({
      required String id,
      required String content,
      Value<bool> enabled,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MemoryEntriesTableUpdateCompanionBuilder =
    MemoryEntriesCompanion Function({
      Value<String> id,
      Value<String> content,
      Value<bool> enabled,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MemoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MemoryEntriesTable> {
  $$MemoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoryEntriesTable> {
  $$MemoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoryEntriesTable> {
  $$MemoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MemoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemoryEntriesTable,
          MemoryEntry,
          $$MemoryEntriesTableFilterComposer,
          $$MemoryEntriesTableOrderingComposer,
          $$MemoryEntriesTableAnnotationComposer,
          $$MemoryEntriesTableCreateCompanionBuilder,
          $$MemoryEntriesTableUpdateCompanionBuilder,
          (
            MemoryEntry,
            BaseReferences<_$AppDatabase, $MemoryEntriesTable, MemoryEntry>,
          ),
          MemoryEntry,
          PrefetchHooks Function()
        > {
  $$MemoryEntriesTableTableManager(_$AppDatabase db, $MemoryEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryEntriesCompanion(
                id: id,
                content: content,
                enabled: enabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String content,
                Value<bool> enabled = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MemoryEntriesCompanion.insert(
                id: id,
                content: content,
                enabled: enabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MemoryEntriesTable, MemoryEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MemoryEntriesTable,
                    MemoryEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemoryEntriesTable,
      MemoryEntry,
      $$MemoryEntriesTableFilterComposer,
      $$MemoryEntriesTableOrderingComposer,
      $$MemoryEntriesTableAnnotationComposer,
      $$MemoryEntriesTableCreateCompanionBuilder,
      $$MemoryEntriesTableUpdateCompanionBuilder,
      (
        MemoryEntry,
        BaseReferences<_$AppDatabase, $MemoryEntriesTable, MemoryEntry>,
      ),
      MemoryEntry,
      PrefetchHooks Function()
    >;
typedef $$ChunkEmbeddingsTableCreateCompanionBuilder =
    ChunkEmbeddingsCompanion Function({
      required int chunkId,
      required String modelId,
      required Uint8List vector,
      Value<int> rowid,
    });
typedef $$ChunkEmbeddingsTableUpdateCompanionBuilder =
    ChunkEmbeddingsCompanion Function({
      Value<int> chunkId,
      Value<String> modelId,
      Value<Uint8List> vector,
      Value<int> rowid,
    });

final class $$ChunkEmbeddingsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ChunkEmbeddingsTable, ChunkEmbedding> {
  $$ChunkEmbeddingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DocumentChunksTable _chunkIdTable(_$AppDatabase db) => db
      .documentChunks
      .createAlias('chunk_embeddings__chunk_id__document_chunks__id');

  $$DocumentChunksTableProcessedTableManager get chunkId {
    final $_column = $_itemColumn<int>('chunk_id')!;

    final manager = $$DocumentChunksTableTableManager(
      $_db,
      $_db.documentChunks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_chunkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChunkEmbeddingsTableFilterComposer
    extends Composer<_$AppDatabase, $ChunkEmbeddingsTable> {
  $$ChunkEmbeddingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnFilters(column),
  );

  $$DocumentChunksTableFilterComposer get chunkId {
    final $$DocumentChunksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chunkId,
      referencedTable: $db.documentChunks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentChunksTableFilterComposer(
            $db: $db,
            $table: $db.documentChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChunkEmbeddingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChunkEmbeddingsTable> {
  $$ChunkEmbeddingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnOrderings(column),
  );

  $$DocumentChunksTableOrderingComposer get chunkId {
    final $$DocumentChunksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chunkId,
      referencedTable: $db.documentChunks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentChunksTableOrderingComposer(
            $db: $db,
            $table: $db.documentChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChunkEmbeddingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChunkEmbeddingsTable> {
  $$ChunkEmbeddingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<Uint8List> get vector =>
      $composableBuilder(column: $table.vector, builder: (column) => column);

  $$DocumentChunksTableAnnotationComposer get chunkId {
    final $$DocumentChunksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.chunkId,
      referencedTable: $db.documentChunks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentChunksTableAnnotationComposer(
            $db: $db,
            $table: $db.documentChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChunkEmbeddingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChunkEmbeddingsTable,
          ChunkEmbedding,
          $$ChunkEmbeddingsTableFilterComposer,
          $$ChunkEmbeddingsTableOrderingComposer,
          $$ChunkEmbeddingsTableAnnotationComposer,
          $$ChunkEmbeddingsTableCreateCompanionBuilder,
          $$ChunkEmbeddingsTableUpdateCompanionBuilder,
          (ChunkEmbedding, $$ChunkEmbeddingsTableReferences),
          ChunkEmbedding,
          PrefetchHooks Function({bool chunkId})
        > {
  $$ChunkEmbeddingsTableTableManager(
    _$AppDatabase db,
    $ChunkEmbeddingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChunkEmbeddingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChunkEmbeddingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChunkEmbeddingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> chunkId = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<Uint8List> vector = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChunkEmbeddingsCompanion(
                chunkId: chunkId,
                modelId: modelId,
                vector: vector,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int chunkId,
                required String modelId,
                required Uint8List vector,
                Value<int> rowid = const Value.absent(),
              }) => ChunkEmbeddingsCompanion.insert(
                chunkId: chunkId,
                modelId: modelId,
                vector: vector,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChunkEmbeddingsTable, ChunkEmbedding>(table),
                  $$ChunkEmbeddingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({chunkId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (chunkId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.chunkId,
                        referencedTable: $$ChunkEmbeddingsTableReferences
                            ._chunkIdTable(db),
                        referencedColumn: $$ChunkEmbeddingsTableReferences
                            ._chunkIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChunkEmbeddingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChunkEmbeddingsTable,
      ChunkEmbedding,
      $$ChunkEmbeddingsTableFilterComposer,
      $$ChunkEmbeddingsTableOrderingComposer,
      $$ChunkEmbeddingsTableAnnotationComposer,
      $$ChunkEmbeddingsTableCreateCompanionBuilder,
      $$ChunkEmbeddingsTableUpdateCompanionBuilder,
      (ChunkEmbedding, $$ChunkEmbeddingsTableReferences),
      ChunkEmbedding,
      PrefetchHooks Function({bool chunkId})
    >;
typedef $$BenchmarkResultsTableCreateCompanionBuilder =
    BenchmarkResultsCompanion Function({
      required String id,
      required String modelId,
      required String modelName,
      required DateTime createdAt,
      required int contextSize,
      required int runs,
      required int loadMs,
      Value<int?> timeToFirstTokenMs,
      required int promptTokens,
      required int completionTokens,
      Value<double?> promptTokensPerSecond,
      Value<double?> generationTokensPerSecond,
      Value<double?> generationMin,
      Value<double?> generationMax,
      Value<int?> rssAfterLoadBytes,
      Value<int?> rssPeakBytes,
      required String device,
      Value<int> rowid,
    });
typedef $$BenchmarkResultsTableUpdateCompanionBuilder =
    BenchmarkResultsCompanion Function({
      Value<String> id,
      Value<String> modelId,
      Value<String> modelName,
      Value<DateTime> createdAt,
      Value<int> contextSize,
      Value<int> runs,
      Value<int> loadMs,
      Value<int?> timeToFirstTokenMs,
      Value<int> promptTokens,
      Value<int> completionTokens,
      Value<double?> promptTokensPerSecond,
      Value<double?> generationTokensPerSecond,
      Value<double?> generationMin,
      Value<double?> generationMax,
      Value<int?> rssAfterLoadBytes,
      Value<int?> rssPeakBytes,
      Value<String> device,
      Value<int> rowid,
    });

class $$BenchmarkResultsTableFilterComposer
    extends Composer<_$AppDatabase, $BenchmarkResultsTable> {
  $$BenchmarkResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contextSize => $composableBuilder(
    column: $table.contextSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get runs => $composableBuilder(
    column: $table.runs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loadMs => $composableBuilder(
    column: $table.loadMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeToFirstTokenMs => $composableBuilder(
    column: $table.timeToFirstTokenMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get promptTokens => $composableBuilder(
    column: $table.promptTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completionTokens => $composableBuilder(
    column: $table.completionTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get promptTokensPerSecond => $composableBuilder(
    column: $table.promptTokensPerSecond,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get generationTokensPerSecond => $composableBuilder(
    column: $table.generationTokensPerSecond,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get generationMin => $composableBuilder(
    column: $table.generationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get generationMax => $composableBuilder(
    column: $table.generationMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rssAfterLoadBytes => $composableBuilder(
    column: $table.rssAfterLoadBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rssPeakBytes => $composableBuilder(
    column: $table.rssPeakBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get device => $composableBuilder(
    column: $table.device,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BenchmarkResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $BenchmarkResultsTable> {
  $$BenchmarkResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contextSize => $composableBuilder(
    column: $table.contextSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get runs => $composableBuilder(
    column: $table.runs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loadMs => $composableBuilder(
    column: $table.loadMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeToFirstTokenMs => $composableBuilder(
    column: $table.timeToFirstTokenMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get promptTokens => $composableBuilder(
    column: $table.promptTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completionTokens => $composableBuilder(
    column: $table.completionTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get promptTokensPerSecond => $composableBuilder(
    column: $table.promptTokensPerSecond,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get generationTokensPerSecond => $composableBuilder(
    column: $table.generationTokensPerSecond,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get generationMin => $composableBuilder(
    column: $table.generationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get generationMax => $composableBuilder(
    column: $table.generationMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rssAfterLoadBytes => $composableBuilder(
    column: $table.rssAfterLoadBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rssPeakBytes => $composableBuilder(
    column: $table.rssPeakBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get device => $composableBuilder(
    column: $table.device,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BenchmarkResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BenchmarkResultsTable> {
  $$BenchmarkResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get contextSize => $composableBuilder(
    column: $table.contextSize,
    builder: (column) => column,
  );

  GeneratedColumn<int> get runs =>
      $composableBuilder(column: $table.runs, builder: (column) => column);

  GeneratedColumn<int> get loadMs =>
      $composableBuilder(column: $table.loadMs, builder: (column) => column);

  GeneratedColumn<int> get timeToFirstTokenMs => $composableBuilder(
    column: $table.timeToFirstTokenMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get promptTokens => $composableBuilder(
    column: $table.promptTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completionTokens => $composableBuilder(
    column: $table.completionTokens,
    builder: (column) => column,
  );

  GeneratedColumn<double> get promptTokensPerSecond => $composableBuilder(
    column: $table.promptTokensPerSecond,
    builder: (column) => column,
  );

  GeneratedColumn<double> get generationTokensPerSecond => $composableBuilder(
    column: $table.generationTokensPerSecond,
    builder: (column) => column,
  );

  GeneratedColumn<double> get generationMin => $composableBuilder(
    column: $table.generationMin,
    builder: (column) => column,
  );

  GeneratedColumn<double> get generationMax => $composableBuilder(
    column: $table.generationMax,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rssAfterLoadBytes => $composableBuilder(
    column: $table.rssAfterLoadBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rssPeakBytes => $composableBuilder(
    column: $table.rssPeakBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get device =>
      $composableBuilder(column: $table.device, builder: (column) => column);
}

class $$BenchmarkResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BenchmarkResultsTable,
          BenchmarkRecord,
          $$BenchmarkResultsTableFilterComposer,
          $$BenchmarkResultsTableOrderingComposer,
          $$BenchmarkResultsTableAnnotationComposer,
          $$BenchmarkResultsTableCreateCompanionBuilder,
          $$BenchmarkResultsTableUpdateCompanionBuilder,
          (
            BenchmarkRecord,
            BaseReferences<
              _$AppDatabase,
              $BenchmarkResultsTable,
              BenchmarkRecord
            >,
          ),
          BenchmarkRecord,
          PrefetchHooks Function()
        > {
  $$BenchmarkResultsTableTableManager(
    _$AppDatabase db,
    $BenchmarkResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BenchmarkResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BenchmarkResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BenchmarkResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> contextSize = const Value.absent(),
                Value<int> runs = const Value.absent(),
                Value<int> loadMs = const Value.absent(),
                Value<int?> timeToFirstTokenMs = const Value.absent(),
                Value<int> promptTokens = const Value.absent(),
                Value<int> completionTokens = const Value.absent(),
                Value<double?> promptTokensPerSecond = const Value.absent(),
                Value<double?> generationTokensPerSecond = const Value.absent(),
                Value<double?> generationMin = const Value.absent(),
                Value<double?> generationMax = const Value.absent(),
                Value<int?> rssAfterLoadBytes = const Value.absent(),
                Value<int?> rssPeakBytes = const Value.absent(),
                Value<String> device = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BenchmarkResultsCompanion(
                id: id,
                modelId: modelId,
                modelName: modelName,
                createdAt: createdAt,
                contextSize: contextSize,
                runs: runs,
                loadMs: loadMs,
                timeToFirstTokenMs: timeToFirstTokenMs,
                promptTokens: promptTokens,
                completionTokens: completionTokens,
                promptTokensPerSecond: promptTokensPerSecond,
                generationTokensPerSecond: generationTokensPerSecond,
                generationMin: generationMin,
                generationMax: generationMax,
                rssAfterLoadBytes: rssAfterLoadBytes,
                rssPeakBytes: rssPeakBytes,
                device: device,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String modelId,
                required String modelName,
                required DateTime createdAt,
                required int contextSize,
                required int runs,
                required int loadMs,
                Value<int?> timeToFirstTokenMs = const Value.absent(),
                required int promptTokens,
                required int completionTokens,
                Value<double?> promptTokensPerSecond = const Value.absent(),
                Value<double?> generationTokensPerSecond = const Value.absent(),
                Value<double?> generationMin = const Value.absent(),
                Value<double?> generationMax = const Value.absent(),
                Value<int?> rssAfterLoadBytes = const Value.absent(),
                Value<int?> rssPeakBytes = const Value.absent(),
                required String device,
                Value<int> rowid = const Value.absent(),
              }) => BenchmarkResultsCompanion.insert(
                id: id,
                modelId: modelId,
                modelName: modelName,
                createdAt: createdAt,
                contextSize: contextSize,
                runs: runs,
                loadMs: loadMs,
                timeToFirstTokenMs: timeToFirstTokenMs,
                promptTokens: promptTokens,
                completionTokens: completionTokens,
                promptTokensPerSecond: promptTokensPerSecond,
                generationTokensPerSecond: generationTokensPerSecond,
                generationMin: generationMin,
                generationMax: generationMax,
                rssAfterLoadBytes: rssAfterLoadBytes,
                rssPeakBytes: rssPeakBytes,
                device: device,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BenchmarkResultsTable, BenchmarkRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BenchmarkResultsTable,
                    BenchmarkRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BenchmarkResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BenchmarkResultsTable,
      BenchmarkRecord,
      $$BenchmarkResultsTableFilterComposer,
      $$BenchmarkResultsTableOrderingComposer,
      $$BenchmarkResultsTableAnnotationComposer,
      $$BenchmarkResultsTableCreateCompanionBuilder,
      $$BenchmarkResultsTableUpdateCompanionBuilder,
      (
        BenchmarkRecord,
        BaseReferences<_$AppDatabase, $BenchmarkResultsTable, BenchmarkRecord>,
      ),
      BenchmarkRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$InstalledModelsTableTableManager get installedModels =>
      $$InstalledModelsTableTableManager(_db, _db.installedModels);
  $$ContentReportsTableTableManager get contentReports =>
      $$ContentReportsTableTableManager(_db, _db.contentReports);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db, _db.documents);
  $$DocumentChunksTableTableManager get documentChunks =>
      $$DocumentChunksTableTableManager(_db, _db.documentChunks);
  $$MemoryEntriesTableTableManager get memoryEntries =>
      $$MemoryEntriesTableTableManager(_db, _db.memoryEntries);
  $$ChunkEmbeddingsTableTableManager get chunkEmbeddings =>
      $$ChunkEmbeddingsTableTableManager(_db, _db.chunkEmbeddings);
  $$BenchmarkResultsTableTableManager get benchmarkResults =>
      $$BenchmarkResultsTableTableManager(_db, _db.benchmarkResults);
}
