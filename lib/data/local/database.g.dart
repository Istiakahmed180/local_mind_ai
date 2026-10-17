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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    modelId,
    createdAt,
    updatedAt,
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
  const Conversation({
    required this.id,
    required this.title,
    this.modelId,
    required this.createdAt,
    required this.updatedAt,
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
    };
  }

  Conversation copyWith({
    String? id,
    String? title,
    Value<String?> modelId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Conversation(
    id: id ?? this.id,
    title: title ?? this.title,
    modelId: modelId.present ? modelId.value : this.modelId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('modelId: $modelId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, modelId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == this.id &&
          other.title == this.title &&
          other.modelId == this.modelId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> modelId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.modelId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsCompanion.insert({
    required String id,
    required String title,
    this.modelId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
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
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (modelId != null) 'model_id': modelId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? modelId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ConversationsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      modelId: modelId ?? this.modelId,
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $InstalledModelsTable installedModels = $InstalledModelsTable(
    this,
  );
  late final $ContentReportsTable contentReports = $ContentReportsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    conversations,
    messages,
    installedModels,
    contentReports,
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
  ]);
}

typedef $$ConversationsTableCreateCompanionBuilder =
    ConversationsCompanion Function({
      required String id,
      required String title,
      Value<String?> modelId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ConversationsTableUpdateCompanionBuilder =
    ConversationsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> modelId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
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
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion(
                id: id,
                title: title,
                modelId: modelId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> modelId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion.insert(
                id: id,
                title: title,
                modelId: modelId,
                createdAt: createdAt,
                updatedAt: updatedAt,
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
}
