// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta(
    'estimatedMinutes',
  );
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    notes,
    kind,
    estimatedMinutes,
    tags,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
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
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(
          data['estimated_minutes']!,
          _estimatedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
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
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      estimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_minutes'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String title;
  final String? notes;
  final String kind;
  final int? estimatedMinutes;
  final String? tags;
  final int createdAt;
  final int? completedAt;
  const Task({
    required this.id,
    required this.title,
    this.notes,
    required this.kind,
    this.estimatedMinutes,
    this.tags,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || estimatedMinutes != null) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      kind: Value(kind),
      estimatedMinutes: estimatedMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedMinutes),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      kind: serializer.fromJson<String>(json['kind']),
      estimatedMinutes: serializer.fromJson<int?>(json['estimatedMinutes']),
      tags: serializer.fromJson<String?>(json['tags']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'kind': serializer.toJson<String>(kind),
      'estimatedMinutes': serializer.toJson<int?>(estimatedMinutes),
      'tags': serializer.toJson<String?>(tags),
      'createdAt': serializer.toJson<int>(createdAt),
      'completedAt': serializer.toJson<int?>(completedAt),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    Value<String?> notes = const Value.absent(),
    String? kind,
    Value<int?> estimatedMinutes = const Value.absent(),
    Value<String?> tags = const Value.absent(),
    int? createdAt,
    Value<int?> completedAt = const Value.absent(),
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    kind: kind ?? this.kind,
    estimatedMinutes: estimatedMinutes.present
        ? estimatedMinutes.value
        : this.estimatedMinutes,
    tags: tags.present ? tags.value : this.tags,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      kind: data.kind.present ? data.kind.value : this.kind,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      tags: data.tags.present ? data.tags.value : this.tags,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('kind: $kind, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('tags: $tags, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    notes,
    kind,
    estimatedMinutes,
    tags,
    createdAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.kind == this.kind &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.tags == this.tags &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> notes;
  final Value<String> kind;
  final Value<int?> estimatedMinutes;
  final Value<String?> tags;
  final Value<int> createdAt;
  final Value<int?> completedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.kind = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.tags = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String title,
    this.notes = const Value.absent(),
    required String kind,
    this.estimatedMinutes = const Value.absent(),
    this.tags = const Value.absent(),
    required int createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       kind = Value(kind),
       createdAt = Value(createdAt);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<String>? kind,
    Expression<int>? estimatedMinutes,
    Expression<String>? tags,
    Expression<int>? createdAt,
    Expression<int>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (kind != null) 'kind': kind,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (tags != null) 'tags': tags,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? notes,
    Value<String>? kind,
    Value<int?>? estimatedMinutes,
    Value<String?>? tags,
    Value<int>? createdAt,
    Value<int?>? completedAt,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      kind: kind ?? this.kind,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
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
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('kind: $kind, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('tags: $tags, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, Activity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _singleStartMeta = const VerificationMeta(
    'singleStart',
  );
  @override
  late final GeneratedColumn<int> singleStart = GeneratedColumn<int>(
    'single_start',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _singleEndMeta = const VerificationMeta(
    'singleEnd',
  );
  @override
  late final GeneratedColumn<int> singleEnd = GeneratedColumn<int>(
    'single_end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weekdaysMeta = const VerificationMeta(
    'weekdays',
  );
  @override
  late final GeneratedColumn<int> weekdays = GeneratedColumn<int>(
    'weekdays',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstDateMeta = const VerificationMeta(
    'firstDate',
  );
  @override
  late final GeneratedColumn<int> firstDate = GeneratedColumn<int>(
    'first_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startMinutesMeta = const VerificationMeta(
    'startMinutes',
  );
  @override
  late final GeneratedColumn<int> startMinutes = GeneratedColumn<int>(
    'start_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endMinutesMeta = const VerificationMeta(
    'endMinutes',
  );
  @override
  late final GeneratedColumn<int> endMinutes = GeneratedColumn<int>(
    'end_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTypeMeta = const VerificationMeta(
    'endType',
  );
  @override
  late final GeneratedColumn<String> endType = GeneratedColumn<String>(
    'end_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endValueMeta = const VerificationMeta(
    'endValue',
  );
  @override
  late final GeneratedColumn<int> endValue = GeneratedColumn<int>(
    'end_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NULL REFERENCES tasks(id) ON DELETE SET NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    notes,
    color,
    kind,
    singleStart,
    singleEnd,
    weekdays,
    firstDate,
    startMinutes,
    endMinutes,
    endType,
    endValue,
    taskId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Activity> instance, {
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
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('single_start')) {
      context.handle(
        _singleStartMeta,
        singleStart.isAcceptableOrUnknown(
          data['single_start']!,
          _singleStartMeta,
        ),
      );
    }
    if (data.containsKey('single_end')) {
      context.handle(
        _singleEndMeta,
        singleEnd.isAcceptableOrUnknown(data['single_end']!, _singleEndMeta),
      );
    }
    if (data.containsKey('weekdays')) {
      context.handle(
        _weekdaysMeta,
        weekdays.isAcceptableOrUnknown(data['weekdays']!, _weekdaysMeta),
      );
    }
    if (data.containsKey('first_date')) {
      context.handle(
        _firstDateMeta,
        firstDate.isAcceptableOrUnknown(data['first_date']!, _firstDateMeta),
      );
    }
    if (data.containsKey('start_minutes')) {
      context.handle(
        _startMinutesMeta,
        startMinutes.isAcceptableOrUnknown(
          data['start_minutes']!,
          _startMinutesMeta,
        ),
      );
    }
    if (data.containsKey('end_minutes')) {
      context.handle(
        _endMinutesMeta,
        endMinutes.isAcceptableOrUnknown(data['end_minutes']!, _endMinutesMeta),
      );
    }
    if (data.containsKey('end_type')) {
      context.handle(
        _endTypeMeta,
        endType.isAcceptableOrUnknown(data['end_type']!, _endTypeMeta),
      );
    }
    if (data.containsKey('end_value')) {
      context.handle(
        _endValueMeta,
        endValue.isAcceptableOrUnknown(data['end_value']!, _endValueMeta),
      );
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      singleStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}single_start'],
      ),
      singleEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}single_end'],
      ),
      weekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekdays'],
      ),
      firstDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_date'],
      ),
      startMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minutes'],
      ),
      endMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minutes'],
      ),
      endType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_type'],
      ),
      endValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_value'],
      ),
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      ),
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class Activity extends DataClass implements Insertable<Activity> {
  final String id;
  final String title;
  final String? notes;
  final int color;
  final String kind;
  final int? singleStart;
  final int? singleEnd;
  final int? weekdays;
  final int? firstDate;
  final int? startMinutes;
  final int? endMinutes;
  final String? endType;
  final int? endValue;
  final String? taskId;
  const Activity({
    required this.id,
    required this.title,
    this.notes,
    required this.color,
    required this.kind,
    this.singleStart,
    this.singleEnd,
    this.weekdays,
    this.firstDate,
    this.startMinutes,
    this.endMinutes,
    this.endType,
    this.endValue,
    this.taskId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['color'] = Variable<int>(color);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || singleStart != null) {
      map['single_start'] = Variable<int>(singleStart);
    }
    if (!nullToAbsent || singleEnd != null) {
      map['single_end'] = Variable<int>(singleEnd);
    }
    if (!nullToAbsent || weekdays != null) {
      map['weekdays'] = Variable<int>(weekdays);
    }
    if (!nullToAbsent || firstDate != null) {
      map['first_date'] = Variable<int>(firstDate);
    }
    if (!nullToAbsent || startMinutes != null) {
      map['start_minutes'] = Variable<int>(startMinutes);
    }
    if (!nullToAbsent || endMinutes != null) {
      map['end_minutes'] = Variable<int>(endMinutes);
    }
    if (!nullToAbsent || endType != null) {
      map['end_type'] = Variable<String>(endType);
    }
    if (!nullToAbsent || endValue != null) {
      map['end_value'] = Variable<int>(endValue);
    }
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      color: Value(color),
      kind: Value(kind),
      singleStart: singleStart == null && nullToAbsent
          ? const Value.absent()
          : Value(singleStart),
      singleEnd: singleEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(singleEnd),
      weekdays: weekdays == null && nullToAbsent
          ? const Value.absent()
          : Value(weekdays),
      firstDate: firstDate == null && nullToAbsent
          ? const Value.absent()
          : Value(firstDate),
      startMinutes: startMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(startMinutes),
      endMinutes: endMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(endMinutes),
      endType: endType == null && nullToAbsent
          ? const Value.absent()
          : Value(endType),
      endValue: endValue == null && nullToAbsent
          ? const Value.absent()
          : Value(endValue),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
    );
  }

  factory Activity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activity(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      color: serializer.fromJson<int>(json['color']),
      kind: serializer.fromJson<String>(json['kind']),
      singleStart: serializer.fromJson<int?>(json['singleStart']),
      singleEnd: serializer.fromJson<int?>(json['singleEnd']),
      weekdays: serializer.fromJson<int?>(json['weekdays']),
      firstDate: serializer.fromJson<int?>(json['firstDate']),
      startMinutes: serializer.fromJson<int?>(json['startMinutes']),
      endMinutes: serializer.fromJson<int?>(json['endMinutes']),
      endType: serializer.fromJson<String?>(json['endType']),
      endValue: serializer.fromJson<int?>(json['endValue']),
      taskId: serializer.fromJson<String?>(json['taskId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'color': serializer.toJson<int>(color),
      'kind': serializer.toJson<String>(kind),
      'singleStart': serializer.toJson<int?>(singleStart),
      'singleEnd': serializer.toJson<int?>(singleEnd),
      'weekdays': serializer.toJson<int?>(weekdays),
      'firstDate': serializer.toJson<int?>(firstDate),
      'startMinutes': serializer.toJson<int?>(startMinutes),
      'endMinutes': serializer.toJson<int?>(endMinutes),
      'endType': serializer.toJson<String?>(endType),
      'endValue': serializer.toJson<int?>(endValue),
      'taskId': serializer.toJson<String?>(taskId),
    };
  }

  Activity copyWith({
    String? id,
    String? title,
    Value<String?> notes = const Value.absent(),
    int? color,
    String? kind,
    Value<int?> singleStart = const Value.absent(),
    Value<int?> singleEnd = const Value.absent(),
    Value<int?> weekdays = const Value.absent(),
    Value<int?> firstDate = const Value.absent(),
    Value<int?> startMinutes = const Value.absent(),
    Value<int?> endMinutes = const Value.absent(),
    Value<String?> endType = const Value.absent(),
    Value<int?> endValue = const Value.absent(),
    Value<String?> taskId = const Value.absent(),
  }) => Activity(
    id: id ?? this.id,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    color: color ?? this.color,
    kind: kind ?? this.kind,
    singleStart: singleStart.present ? singleStart.value : this.singleStart,
    singleEnd: singleEnd.present ? singleEnd.value : this.singleEnd,
    weekdays: weekdays.present ? weekdays.value : this.weekdays,
    firstDate: firstDate.present ? firstDate.value : this.firstDate,
    startMinutes: startMinutes.present ? startMinutes.value : this.startMinutes,
    endMinutes: endMinutes.present ? endMinutes.value : this.endMinutes,
    endType: endType.present ? endType.value : this.endType,
    endValue: endValue.present ? endValue.value : this.endValue,
    taskId: taskId.present ? taskId.value : this.taskId,
  );
  Activity copyWithCompanion(ActivitiesCompanion data) {
    return Activity(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      color: data.color.present ? data.color.value : this.color,
      kind: data.kind.present ? data.kind.value : this.kind,
      singleStart: data.singleStart.present
          ? data.singleStart.value
          : this.singleStart,
      singleEnd: data.singleEnd.present ? data.singleEnd.value : this.singleEnd,
      weekdays: data.weekdays.present ? data.weekdays.value : this.weekdays,
      firstDate: data.firstDate.present ? data.firstDate.value : this.firstDate,
      startMinutes: data.startMinutes.present
          ? data.startMinutes.value
          : this.startMinutes,
      endMinutes: data.endMinutes.present
          ? data.endMinutes.value
          : this.endMinutes,
      endType: data.endType.present ? data.endType.value : this.endType,
      endValue: data.endValue.present ? data.endValue.value : this.endValue,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activity(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('color: $color, ')
          ..write('kind: $kind, ')
          ..write('singleStart: $singleStart, ')
          ..write('singleEnd: $singleEnd, ')
          ..write('weekdays: $weekdays, ')
          ..write('firstDate: $firstDate, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('endType: $endType, ')
          ..write('endValue: $endValue, ')
          ..write('taskId: $taskId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    notes,
    color,
    kind,
    singleStart,
    singleEnd,
    weekdays,
    firstDate,
    startMinutes,
    endMinutes,
    endType,
    endValue,
    taskId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.color == this.color &&
          other.kind == this.kind &&
          other.singleStart == this.singleStart &&
          other.singleEnd == this.singleEnd &&
          other.weekdays == this.weekdays &&
          other.firstDate == this.firstDate &&
          other.startMinutes == this.startMinutes &&
          other.endMinutes == this.endMinutes &&
          other.endType == this.endType &&
          other.endValue == this.endValue &&
          other.taskId == this.taskId);
}

class ActivitiesCompanion extends UpdateCompanion<Activity> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> notes;
  final Value<int> color;
  final Value<String> kind;
  final Value<int?> singleStart;
  final Value<int?> singleEnd;
  final Value<int?> weekdays;
  final Value<int?> firstDate;
  final Value<int?> startMinutes;
  final Value<int?> endMinutes;
  final Value<String?> endType;
  final Value<int?> endValue;
  final Value<String?> taskId;
  final Value<int> rowid;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.color = const Value.absent(),
    this.kind = const Value.absent(),
    this.singleStart = const Value.absent(),
    this.singleEnd = const Value.absent(),
    this.weekdays = const Value.absent(),
    this.firstDate = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.endMinutes = const Value.absent(),
    this.endType = const Value.absent(),
    this.endValue = const Value.absent(),
    this.taskId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    required String id,
    required String title,
    this.notes = const Value.absent(),
    required int color,
    required String kind,
    this.singleStart = const Value.absent(),
    this.singleEnd = const Value.absent(),
    this.weekdays = const Value.absent(),
    this.firstDate = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.endMinutes = const Value.absent(),
    this.endType = const Value.absent(),
    this.endValue = const Value.absent(),
    this.taskId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       color = Value(color),
       kind = Value(kind);
  static Insertable<Activity> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<int>? color,
    Expression<String>? kind,
    Expression<int>? singleStart,
    Expression<int>? singleEnd,
    Expression<int>? weekdays,
    Expression<int>? firstDate,
    Expression<int>? startMinutes,
    Expression<int>? endMinutes,
    Expression<String>? endType,
    Expression<int>? endValue,
    Expression<String>? taskId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (color != null) 'color': color,
      if (kind != null) 'kind': kind,
      if (singleStart != null) 'single_start': singleStart,
      if (singleEnd != null) 'single_end': singleEnd,
      if (weekdays != null) 'weekdays': weekdays,
      if (firstDate != null) 'first_date': firstDate,
      if (startMinutes != null) 'start_minutes': startMinutes,
      if (endMinutes != null) 'end_minutes': endMinutes,
      if (endType != null) 'end_type': endType,
      if (endValue != null) 'end_value': endValue,
      if (taskId != null) 'task_id': taskId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? notes,
    Value<int>? color,
    Value<String>? kind,
    Value<int?>? singleStart,
    Value<int?>? singleEnd,
    Value<int?>? weekdays,
    Value<int?>? firstDate,
    Value<int?>? startMinutes,
    Value<int?>? endMinutes,
    Value<String?>? endType,
    Value<int?>? endValue,
    Value<String?>? taskId,
    Value<int>? rowid,
  }) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      color: color ?? this.color,
      kind: kind ?? this.kind,
      singleStart: singleStart ?? this.singleStart,
      singleEnd: singleEnd ?? this.singleEnd,
      weekdays: weekdays ?? this.weekdays,
      firstDate: firstDate ?? this.firstDate,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      endType: endType ?? this.endType,
      endValue: endValue ?? this.endValue,
      taskId: taskId ?? this.taskId,
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
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (singleStart.present) {
      map['single_start'] = Variable<int>(singleStart.value);
    }
    if (singleEnd.present) {
      map['single_end'] = Variable<int>(singleEnd.value);
    }
    if (weekdays.present) {
      map['weekdays'] = Variable<int>(weekdays.value);
    }
    if (firstDate.present) {
      map['first_date'] = Variable<int>(firstDate.value);
    }
    if (startMinutes.present) {
      map['start_minutes'] = Variable<int>(startMinutes.value);
    }
    if (endMinutes.present) {
      map['end_minutes'] = Variable<int>(endMinutes.value);
    }
    if (endType.present) {
      map['end_type'] = Variable<String>(endType.value);
    }
    if (endValue.present) {
      map['end_value'] = Variable<int>(endValue.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('color: $color, ')
          ..write('kind: $kind, ')
          ..write('singleStart: $singleStart, ')
          ..write('singleEnd: $singleEnd, ')
          ..write('weekdays: $weekdays, ')
          ..write('firstDate: $firstDate, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('endType: $endType, ')
          ..write('endValue: $endValue, ')
          ..write('taskId: $taskId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityExclusionsTable extends ActivityExclusions
    with TableInfo<$ActivityExclusionsTable, ActivityExclusion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityExclusionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'REFERENCES activities(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _excludedDateMeta = const VerificationMeta(
    'excludedDate',
  );
  @override
  late final GeneratedColumn<int> excludedDate = GeneratedColumn<int>(
    'excluded_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [activityId, excludedDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_exclusions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityExclusion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('excluded_date')) {
      context.handle(
        _excludedDateMeta,
        excludedDate.isAcceptableOrUnknown(
          data['excluded_date']!,
          _excludedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_excludedDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {activityId, excludedDate};
  @override
  ActivityExclusion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityExclusion(
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      )!,
      excludedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}excluded_date'],
      )!,
    );
  }

  @override
  $ActivityExclusionsTable createAlias(String alias) {
    return $ActivityExclusionsTable(attachedDatabase, alias);
  }
}

class ActivityExclusion extends DataClass
    implements Insertable<ActivityExclusion> {
  final String activityId;
  final int excludedDate;
  const ActivityExclusion({
    required this.activityId,
    required this.excludedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['activity_id'] = Variable<String>(activityId);
    map['excluded_date'] = Variable<int>(excludedDate);
    return map;
  }

  ActivityExclusionsCompanion toCompanion(bool nullToAbsent) {
    return ActivityExclusionsCompanion(
      activityId: Value(activityId),
      excludedDate: Value(excludedDate),
    );
  }

  factory ActivityExclusion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityExclusion(
      activityId: serializer.fromJson<String>(json['activityId']),
      excludedDate: serializer.fromJson<int>(json['excludedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'activityId': serializer.toJson<String>(activityId),
      'excludedDate': serializer.toJson<int>(excludedDate),
    };
  }

  ActivityExclusion copyWith({String? activityId, int? excludedDate}) =>
      ActivityExclusion(
        activityId: activityId ?? this.activityId,
        excludedDate: excludedDate ?? this.excludedDate,
      );
  ActivityExclusion copyWithCompanion(ActivityExclusionsCompanion data) {
    return ActivityExclusion(
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      excludedDate: data.excludedDate.present
          ? data.excludedDate.value
          : this.excludedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityExclusion(')
          ..write('activityId: $activityId, ')
          ..write('excludedDate: $excludedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(activityId, excludedDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityExclusion &&
          other.activityId == this.activityId &&
          other.excludedDate == this.excludedDate);
}

class ActivityExclusionsCompanion extends UpdateCompanion<ActivityExclusion> {
  final Value<String> activityId;
  final Value<int> excludedDate;
  final Value<int> rowid;
  const ActivityExclusionsCompanion({
    this.activityId = const Value.absent(),
    this.excludedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityExclusionsCompanion.insert({
    required String activityId,
    required int excludedDate,
    this.rowid = const Value.absent(),
  }) : activityId = Value(activityId),
       excludedDate = Value(excludedDate);
  static Insertable<ActivityExclusion> custom({
    Expression<String>? activityId,
    Expression<int>? excludedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (activityId != null) 'activity_id': activityId,
      if (excludedDate != null) 'excluded_date': excludedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityExclusionsCompanion copyWith({
    Value<String>? activityId,
    Value<int>? excludedDate,
    Value<int>? rowid,
  }) {
    return ActivityExclusionsCompanion(
      activityId: activityId ?? this.activityId,
      excludedDate: excludedDate ?? this.excludedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (excludedDate.present) {
      map['excluded_date'] = Variable<int>(excludedDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityExclusionsCompanion(')
          ..write('activityId: $activityId, ')
          ..write('excludedDate: $excludedDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivitySessionsTable extends ActivitySessions
    with TableInfo<$ActivitySessionsTable, ActivitySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitySessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'REFERENCES activities(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualMinutesMeta = const VerificationMeta(
    'actualMinutes',
  );
  @override
  late final GeneratedColumn<int> actualMinutes = GeneratedColumn<int>(
    'actual_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    activityId,
    date,
    completedAt,
    actualMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivitySession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('actual_minutes')) {
      context.handle(
        _actualMinutesMeta,
        actualMinutes.isAcceptableOrUnknown(
          data['actual_minutes']!,
          _actualMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {activityId, date};
  @override
  ActivitySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivitySession(
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      actualMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_minutes'],
      ),
    );
  }

  @override
  $ActivitySessionsTable createAlias(String alias) {
    return $ActivitySessionsTable(attachedDatabase, alias);
  }
}

class ActivitySession extends DataClass implements Insertable<ActivitySession> {
  final String activityId;
  final int date;
  final int? completedAt;
  final int? actualMinutes;
  const ActivitySession({
    required this.activityId,
    required this.date,
    this.completedAt,
    this.actualMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['activity_id'] = Variable<String>(activityId);
    map['date'] = Variable<int>(date);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    if (!nullToAbsent || actualMinutes != null) {
      map['actual_minutes'] = Variable<int>(actualMinutes);
    }
    return map;
  }

  ActivitySessionsCompanion toCompanion(bool nullToAbsent) {
    return ActivitySessionsCompanion(
      activityId: Value(activityId),
      date: Value(date),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      actualMinutes: actualMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(actualMinutes),
    );
  }

  factory ActivitySession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivitySession(
      activityId: serializer.fromJson<String>(json['activityId']),
      date: serializer.fromJson<int>(json['date']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      actualMinutes: serializer.fromJson<int?>(json['actualMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'activityId': serializer.toJson<String>(activityId),
      'date': serializer.toJson<int>(date),
      'completedAt': serializer.toJson<int?>(completedAt),
      'actualMinutes': serializer.toJson<int?>(actualMinutes),
    };
  }

  ActivitySession copyWith({
    String? activityId,
    int? date,
    Value<int?> completedAt = const Value.absent(),
    Value<int?> actualMinutes = const Value.absent(),
  }) => ActivitySession(
    activityId: activityId ?? this.activityId,
    date: date ?? this.date,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    actualMinutes: actualMinutes.present
        ? actualMinutes.value
        : this.actualMinutes,
  );
  ActivitySession copyWithCompanion(ActivitySessionsCompanion data) {
    return ActivitySession(
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      date: data.date.present ? data.date.value : this.date,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      actualMinutes: data.actualMinutes.present
          ? data.actualMinutes.value
          : this.actualMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivitySession(')
          ..write('activityId: $activityId, ')
          ..write('date: $date, ')
          ..write('completedAt: $completedAt, ')
          ..write('actualMinutes: $actualMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(activityId, date, completedAt, actualMinutes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivitySession &&
          other.activityId == this.activityId &&
          other.date == this.date &&
          other.completedAt == this.completedAt &&
          other.actualMinutes == this.actualMinutes);
}

class ActivitySessionsCompanion extends UpdateCompanion<ActivitySession> {
  final Value<String> activityId;
  final Value<int> date;
  final Value<int?> completedAt;
  final Value<int?> actualMinutes;
  final Value<int> rowid;
  const ActivitySessionsCompanion({
    this.activityId = const Value.absent(),
    this.date = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.actualMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitySessionsCompanion.insert({
    required String activityId,
    required int date,
    this.completedAt = const Value.absent(),
    this.actualMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : activityId = Value(activityId),
       date = Value(date);
  static Insertable<ActivitySession> custom({
    Expression<String>? activityId,
    Expression<int>? date,
    Expression<int>? completedAt,
    Expression<int>? actualMinutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (activityId != null) 'activity_id': activityId,
      if (date != null) 'date': date,
      if (completedAt != null) 'completed_at': completedAt,
      if (actualMinutes != null) 'actual_minutes': actualMinutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitySessionsCompanion copyWith({
    Value<String>? activityId,
    Value<int>? date,
    Value<int?>? completedAt,
    Value<int?>? actualMinutes,
    Value<int>? rowid,
  }) {
    return ActivitySessionsCompanion(
      activityId: activityId ?? this.activityId,
      date: date ?? this.date,
      completedAt: completedAt ?? this.completedAt,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (actualMinutes.present) {
      map['actual_minutes'] = Variable<int>(actualMinutes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitySessionsCompanion(')
          ..write('activityId: $activityId, ')
          ..write('date: $date, ')
          ..write('completedAt: $completedAt, ')
          ..write('actualMinutes: $actualMinutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $ActivityExclusionsTable activityExclusions =
      $ActivityExclusionsTable(this);
  late final $ActivitySessionsTable activitySessions = $ActivitySessionsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasks,
    activities,
    activityExclusions,
    activitySessions,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('activities', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('activity_exclusions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('activity_sessions', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String title,
  Value<String?> notes,
  required String kind,
  Value<int?> estimatedMinutes,
  Value<String?> tags,
  required int createdAt,
  Value<int?> completedAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> notes,
  Value<String> kind,
  Value<int?> estimatedMinutes,
  Value<String?> tags,
  Value<int> createdAt,
  Value<int?> completedAt,
  Value<int> rowid,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ActivitiesTable, List<Activity>>
  _activitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activities,
    aliasName: 'tasks__id__activities__task_id',
  );

  $$ActivitiesTableProcessedTableManager get activitiesRefs {
    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
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

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> activitiesRefs(
    Expression<bool> Function($$ActivitiesTableFilterComposer f) f,
  ) {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
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

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
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

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  Expression<T> activitiesRefs<T extends Object>(
    Expression<T> Function($$ActivitiesTableAnnotationComposer a) f,
  ) {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({bool activitiesRefs})
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> estimatedMinutes = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                notes: notes,
                kind: kind,
                estimatedMinutes: estimatedMinutes,
                tags: tags,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> notes = const Value.absent(),
                required String kind,
                Value<int?> estimatedMinutes = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                required int createdAt,
                Value<int?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                notes: notes,
                kind: kind,
                estimatedMinutes: estimatedMinutes,
                tags: tags,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, Task>(table),
                  $$TasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({activitiesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (activitiesRefs) db.activities],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (activitiesRefs)
                    await $_getPrefetchedDataByColumns<
                      Task,
                      $TasksTable,
                      Activity,
                      $ActivitiesTable
                    >(
                      currentTable: table,
                      referencedTable: $$TasksTableReferences
                          ._activitiesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TasksTableReferences(db, table, p0).activitiesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'task_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({bool activitiesRefs})
    >;
typedef $$ActivitiesTableCreateCompanionBuilder = ActivitiesCompanion Function({
  required String id,
  required String title,
  Value<String?> notes,
  required int color,
  required String kind,
  Value<int?> singleStart,
  Value<int?> singleEnd,
  Value<int?> weekdays,
  Value<int?> firstDate,
  Value<int?> startMinutes,
  Value<int?> endMinutes,
  Value<String?> endType,
  Value<int?> endValue,
  Value<String?> taskId,
  Value<int> rowid,
});
typedef $$ActivitiesTableUpdateCompanionBuilder = ActivitiesCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> notes,
  Value<int> color,
  Value<String> kind,
  Value<int?> singleStart,
  Value<int?> singleEnd,
  Value<int?> weekdays,
  Value<int?> firstDate,
  Value<int?> startMinutes,
  Value<int?> endMinutes,
  Value<String?> endType,
  Value<int?> endValue,
  Value<String?> taskId,
  Value<int> rowid,
});

final class $$ActivitiesTableReferences
    extends BaseReferences<_$AppDatabase, $ActivitiesTable, Activity> {
  $$ActivitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('activities__task_id__tasks__id');

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<String>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ActivityExclusionsTable, List<ActivityExclusion>>
  _activityExclusionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.activityExclusions,
        aliasName: 'activities__id__activity_exclusions__activity_id',
      );

  $$ActivityExclusionsTableProcessedTableManager get activityExclusionsRefs {
    final manager = $$ActivityExclusionsTableTableManager(
      $_db,
      $_db.activityExclusions,
    ).filter((f) => f.activityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _activityExclusionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActivitySessionsTable, List<ActivitySession>>
  _activitySessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activitySessions,
    aliasName: 'activities__id__activity_sessions__activity_id',
  );

  $$ActivitySessionsTableProcessedTableManager get activitySessionsRefs {
    final manager = $$ActivitySessionsTableTableManager(
      $_db,
      $_db.activitySessions,
    ).filter((f) => f.activityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _activitySessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
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

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get singleStart => $composableBuilder(
    column: $table.singleStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get singleEnd => $composableBuilder(
    column: $table.singleEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstDate => $composableBuilder(
    column: $table.firstDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endType => $composableBuilder(
    column: $table.endType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endValue => $composableBuilder(
    column: $table.endValue,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> activityExclusionsRefs(
    Expression<bool> Function($$ActivityExclusionsTableFilterComposer f) f,
  ) {
    final $$ActivityExclusionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activityExclusions,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityExclusionsTableFilterComposer(
            $db: $db,
            $table: $db.activityExclusions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activitySessionsRefs(
    Expression<bool> Function($$ActivitySessionsTableFilterComposer f) f,
  ) {
    final $$ActivitySessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activitySessions,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitySessionsTableFilterComposer(
            $db: $db,
            $table: $db.activitySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
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

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get singleStart => $composableBuilder(
    column: $table.singleStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get singleEnd => $composableBuilder(
    column: $table.singleEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstDate => $composableBuilder(
    column: $table.firstDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endType => $composableBuilder(
    column: $table.endType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endValue => $composableBuilder(
    column: $table.endValue,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
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

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get singleStart => $composableBuilder(
    column: $table.singleStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get singleEnd =>
      $composableBuilder(column: $table.singleEnd, builder: (column) => column);

  GeneratedColumn<int> get weekdays =>
      $composableBuilder(column: $table.weekdays, builder: (column) => column);

  GeneratedColumn<int> get firstDate =>
      $composableBuilder(column: $table.firstDate, builder: (column) => column);

  GeneratedColumn<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endType =>
      $composableBuilder(column: $table.endType, builder: (column) => column);

  GeneratedColumn<int> get endValue =>
      $composableBuilder(column: $table.endValue, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> activityExclusionsRefs<T extends Object>(
    Expression<T> Function($$ActivityExclusionsTableAnnotationComposer a) f,
  ) {
    final $$ActivityExclusionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.activityExclusions,
          getReferencedColumn: (t) => t.activityId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ActivityExclusionsTableAnnotationComposer(
                $db: $db,
                $table: $db.activityExclusions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> activitySessionsRefs<T extends Object>(
    Expression<T> Function($$ActivitySessionsTableAnnotationComposer a) f,
  ) {
    final $$ActivitySessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activitySessions,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitySessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.activitySessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTable,
          Activity,
          $$ActivitiesTableFilterComposer,
          $$ActivitiesTableOrderingComposer,
          $$ActivitiesTableAnnotationComposer,
          $$ActivitiesTableCreateCompanionBuilder,
          $$ActivitiesTableUpdateCompanionBuilder,
          (Activity, $$ActivitiesTableReferences),
          Activity,
          PrefetchHooks Function({
            bool taskId,
            bool activityExclusionsRefs,
            bool activitySessionsRefs,
          })
        > {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> singleStart = const Value.absent(),
                Value<int?> singleEnd = const Value.absent(),
                Value<int?> weekdays = const Value.absent(),
                Value<int?> firstDate = const Value.absent(),
                Value<int?> startMinutes = const Value.absent(),
                Value<int?> endMinutes = const Value.absent(),
                Value<String?> endType = const Value.absent(),
                Value<int?> endValue = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion(
                id: id,
                title: title,
                notes: notes,
                color: color,
                kind: kind,
                singleStart: singleStart,
                singleEnd: singleEnd,
                weekdays: weekdays,
                firstDate: firstDate,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                endType: endType,
                endValue: endValue,
                taskId: taskId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> notes = const Value.absent(),
                required int color,
                required String kind,
                Value<int?> singleStart = const Value.absent(),
                Value<int?> singleEnd = const Value.absent(),
                Value<int?> weekdays = const Value.absent(),
                Value<int?> firstDate = const Value.absent(),
                Value<int?> startMinutes = const Value.absent(),
                Value<int?> endMinutes = const Value.absent(),
                Value<String?> endType = const Value.absent(),
                Value<int?> endValue = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion.insert(
                id: id,
                title: title,
                notes: notes,
                color: color,
                kind: kind,
                singleStart: singleStart,
                singleEnd: singleEnd,
                weekdays: weekdays,
                firstDate: firstDate,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                endType: endType,
                endValue: endValue,
                taskId: taskId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivitiesTable, Activity>(table),
                  $$ActivitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                taskId = false,
                activityExclusionsRefs = false,
                activitySessionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (activityExclusionsRefs) db.activityExclusions,
                    if (activitySessionsRefs) db.activitySessions,
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
                        if (taskId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.taskId,
                            referencedTable: $$ActivitiesTableReferences
                                ._taskIdTable(db),
                            referencedColumn: $$ActivitiesTableReferences
                                ._taskIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (activityExclusionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Activity,
                          $ActivitiesTable,
                          ActivityExclusion,
                          $ActivityExclusionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ActivitiesTableReferences
                              ._activityExclusionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ActivitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).activityExclusionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'activity_id',
                          typedResults: items,
                        ),
                      if (activitySessionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Activity,
                          $ActivitiesTable,
                          ActivitySession,
                          $ActivitySessionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ActivitiesTableReferences
                              ._activitySessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ActivitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).activitySessionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'activity_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTable,
      Activity,
      $$ActivitiesTableFilterComposer,
      $$ActivitiesTableOrderingComposer,
      $$ActivitiesTableAnnotationComposer,
      $$ActivitiesTableCreateCompanionBuilder,
      $$ActivitiesTableUpdateCompanionBuilder,
      (Activity, $$ActivitiesTableReferences),
      Activity,
      PrefetchHooks Function({
        bool taskId,
        bool activityExclusionsRefs,
        bool activitySessionsRefs,
      })
    >;
typedef $$ActivityExclusionsTableCreateCompanionBuilder =
    ActivityExclusionsCompanion Function({
      required String activityId,
      required int excludedDate,
      Value<int> rowid,
    });
typedef $$ActivityExclusionsTableUpdateCompanionBuilder =
    ActivityExclusionsCompanion Function({
      Value<String> activityId,
      Value<int> excludedDate,
      Value<int> rowid,
    });

final class $$ActivityExclusionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ActivityExclusionsTable,
          ActivityExclusion
        > {
  $$ActivityExclusionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ActivitiesTable _activityIdTable(_$AppDatabase db) => db.activities
      .createAlias('activity_exclusions__activity_id__activities__id');

  $$ActivitiesTableProcessedTableManager get activityId {
    final $_column = $_itemColumn<String>('activity_id')!;

    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActivityExclusionsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityExclusionsTable> {
  $$ActivityExclusionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get excludedDate => $composableBuilder(
    column: $table.excludedDate,
    builder: (column) => ColumnFilters(column),
  );

  $$ActivitiesTableFilterComposer get activityId {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityExclusionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityExclusionsTable> {
  $$ActivityExclusionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get excludedDate => $composableBuilder(
    column: $table.excludedDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$ActivitiesTableOrderingComposer get activityId {
    final $$ActivitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableOrderingComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityExclusionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityExclusionsTable> {
  $$ActivityExclusionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get excludedDate => $composableBuilder(
    column: $table.excludedDate,
    builder: (column) => column,
  );

  $$ActivitiesTableAnnotationComposer get activityId {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityExclusionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityExclusionsTable,
          ActivityExclusion,
          $$ActivityExclusionsTableFilterComposer,
          $$ActivityExclusionsTableOrderingComposer,
          $$ActivityExclusionsTableAnnotationComposer,
          $$ActivityExclusionsTableCreateCompanionBuilder,
          $$ActivityExclusionsTableUpdateCompanionBuilder,
          (ActivityExclusion, $$ActivityExclusionsTableReferences),
          ActivityExclusion,
          PrefetchHooks Function({bool activityId})
        > {
  $$ActivityExclusionsTableTableManager(
    _$AppDatabase db,
    $ActivityExclusionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityExclusionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityExclusionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityExclusionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> activityId = const Value.absent(),
                Value<int> excludedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityExclusionsCompanion(
                activityId: activityId,
                excludedDate: excludedDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String activityId,
                required int excludedDate,
                Value<int> rowid = const Value.absent(),
              }) => ActivityExclusionsCompanion.insert(
                activityId: activityId,
                excludedDate: excludedDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivityExclusionsTable, ActivityExclusion>(
                    table,
                  ),
                  $$ActivityExclusionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({activityId = false}) {
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
                    if (activityId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.activityId,
                        referencedTable: $$ActivityExclusionsTableReferences
                            ._activityIdTable(db),
                        referencedColumn: $$ActivityExclusionsTableReferences
                            ._activityIdTable(db)
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

typedef $$ActivityExclusionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityExclusionsTable,
      ActivityExclusion,
      $$ActivityExclusionsTableFilterComposer,
      $$ActivityExclusionsTableOrderingComposer,
      $$ActivityExclusionsTableAnnotationComposer,
      $$ActivityExclusionsTableCreateCompanionBuilder,
      $$ActivityExclusionsTableUpdateCompanionBuilder,
      (ActivityExclusion, $$ActivityExclusionsTableReferences),
      ActivityExclusion,
      PrefetchHooks Function({bool activityId})
    >;
typedef $$ActivitySessionsTableCreateCompanionBuilder =
    ActivitySessionsCompanion Function({
      required String activityId,
      required int date,
      Value<int?> completedAt,
      Value<int?> actualMinutes,
      Value<int> rowid,
    });
typedef $$ActivitySessionsTableUpdateCompanionBuilder =
    ActivitySessionsCompanion Function({
      Value<String> activityId,
      Value<int> date,
      Value<int?> completedAt,
      Value<int?> actualMinutes,
      Value<int> rowid,
    });

final class $$ActivitySessionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ActivitySessionsTable, ActivitySession> {
  $$ActivitySessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ActivitiesTable _activityIdTable(_$AppDatabase db) => db.activities
      .createAlias('activity_sessions__activity_id__activities__id');

  $$ActivitiesTableProcessedTableManager get activityId {
    final $_column = $_itemColumn<String>('activity_id')!;

    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActivitySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitySessionsTable> {
  $$ActivitySessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualMinutes => $composableBuilder(
    column: $table.actualMinutes,
    builder: (column) => ColumnFilters(column),
  );

  $$ActivitiesTableFilterComposer get activityId {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitySessionsTable> {
  $$ActivitySessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualMinutes => $composableBuilder(
    column: $table.actualMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ActivitiesTableOrderingComposer get activityId {
    final $$ActivitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableOrderingComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitySessionsTable> {
  $$ActivitySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualMinutes => $composableBuilder(
    column: $table.actualMinutes,
    builder: (column) => column,
  );

  $$ActivitiesTableAnnotationComposer get activityId {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitySessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitySessionsTable,
          ActivitySession,
          $$ActivitySessionsTableFilterComposer,
          $$ActivitySessionsTableOrderingComposer,
          $$ActivitySessionsTableAnnotationComposer,
          $$ActivitySessionsTableCreateCompanionBuilder,
          $$ActivitySessionsTableUpdateCompanionBuilder,
          (ActivitySession, $$ActivitySessionsTableReferences),
          ActivitySession,
          PrefetchHooks Function({bool activityId})
        > {
  $$ActivitySessionsTableTableManager(
    _$AppDatabase db,
    $ActivitySessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> activityId = const Value.absent(),
                Value<int> date = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int?> actualMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitySessionsCompanion(
                activityId: activityId,
                date: date,
                completedAt: completedAt,
                actualMinutes: actualMinutes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String activityId,
                required int date,
                Value<int?> completedAt = const Value.absent(),
                Value<int?> actualMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitySessionsCompanion.insert(
                activityId: activityId,
                date: date,
                completedAt: completedAt,
                actualMinutes: actualMinutes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivitySessionsTable, ActivitySession>(table),
                  $$ActivitySessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({activityId = false}) {
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
                    if (activityId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.activityId,
                        referencedTable: $$ActivitySessionsTableReferences
                            ._activityIdTable(db),
                        referencedColumn: $$ActivitySessionsTableReferences
                            ._activityIdTable(db)
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

typedef $$ActivitySessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitySessionsTable,
      ActivitySession,
      $$ActivitySessionsTableFilterComposer,
      $$ActivitySessionsTableOrderingComposer,
      $$ActivitySessionsTableAnnotationComposer,
      $$ActivitySessionsTableCreateCompanionBuilder,
      $$ActivitySessionsTableUpdateCompanionBuilder,
      (ActivitySession, $$ActivitySessionsTableReferences),
      ActivitySession,
      PrefetchHooks Function({bool activityId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$ActivityExclusionsTableTableManager get activityExclusions =>
      $$ActivityExclusionsTableTableManager(_db, _db.activityExclusions);
  $$ActivitySessionsTableTableManager get activitySessions =>
      $$ActivitySessionsTableTableManager(_db, _db.activitySessions);
}
