// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PlayerTableTable extends PlayerTable
    with TableInfo<$PlayerTableTable, PlayerTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameCountMeta = const VerificationMeta(
    'nameCount',
  );
  @override
  late final GeneratedColumn<int> nameCount = GeneratedColumn<int>(
    'name_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    name,
    nameCount,
    description,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_count')) {
      context.handle(
        _nameCountMeta,
        nameCount.isAcceptableOrUnknown(data['name_count']!, _nameCountMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}name_count'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $PlayerTableTable createAlias(String alias) {
    return $PlayerTableTable(attachedDatabase, alias);
  }
}

class PlayerTableData extends DataClass implements Insertable<PlayerTableData> {
  final String id;
  final DateTime createdAt;
  final String name;
  final int nameCount;
  final String description;
  final bool deleted;
  const PlayerTableData({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.nameCount,
    required this.description,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['name'] = Variable<String>(name);
    map['name_count'] = Variable<int>(nameCount);
    map['description'] = Variable<String>(description);
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  PlayerTableCompanion toCompanion(bool nullToAbsent) {
    return PlayerTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      name: Value(name),
      nameCount: Value(nameCount),
      description: Value(description),
      deleted: Value(deleted),
    );
  }

  factory PlayerTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerTableData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      name: serializer.fromJson<String>(json['name']),
      nameCount: serializer.fromJson<int>(json['nameCount']),
      description: serializer.fromJson<String>(json['description']),
      deleted: serializer.fromJson<bool>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'name': serializer.toJson<String>(name),
      'nameCount': serializer.toJson<int>(nameCount),
      'description': serializer.toJson<String>(description),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  PlayerTableData copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    int? nameCount,
    String? description,
    bool? deleted,
  }) => PlayerTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    name: name ?? this.name,
    nameCount: nameCount ?? this.nameCount,
    description: description ?? this.description,
    deleted: deleted ?? this.deleted,
  );
  PlayerTableData copyWithCompanion(PlayerTableCompanion data) {
    return PlayerTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      name: data.name.present ? data.name.value : this.name,
      nameCount: data.nameCount.present ? data.nameCount.value : this.nameCount,
      description: data.description.present
          ? data.description.value
          : this.description,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('nameCount: $nameCount, ')
          ..write('description: $description, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, name, nameCount, description, deleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.name == this.name &&
          other.nameCount == this.nameCount &&
          other.description == this.description &&
          other.deleted == this.deleted);
}

class PlayerTableCompanion extends UpdateCompanion<PlayerTableData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> name;
  final Value<int> nameCount;
  final Value<String> description;
  final Value<bool> deleted;
  final Value<int> rowid;
  const PlayerTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.name = const Value.absent(),
    this.nameCount = const Value.absent(),
    this.description = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayerTableCompanion.insert({
    required String id,
    required DateTime createdAt,
    required String name,
    this.nameCount = const Value.absent(),
    required String description,
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       name = Value(name),
       description = Value(description);
  static Insertable<PlayerTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? name,
    Expression<int>? nameCount,
    Expression<String>? description,
    Expression<bool>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (name != null) 'name': name,
      if (nameCount != null) 'name_count': nameCount,
      if (description != null) 'description': description,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayerTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<String>? name,
    Value<int>? nameCount,
    Value<String>? description,
    Value<bool>? deleted,
    Value<int>? rowid,
  }) {
    return PlayerTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      nameCount: nameCount ?? this.nameCount,
      description: description ?? this.description,
      deleted: deleted ?? this.deleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameCount.present) {
      map['name_count'] = Variable<int>(nameCount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('nameCount: $nameCount, ')
          ..write('description: $description, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupTableTable extends GroupTable
    with TableInfo<$GroupTableTable, GroupTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, name, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroupTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
    );
  }

  @override
  $GroupTableTable createAlias(String alias) {
    return $GroupTableTable(attachedDatabase, alias);
  }
}

class GroupTableData extends DataClass implements Insertable<GroupTableData> {
  final String id;
  final DateTime createdAt;
  final String name;
  final String description;
  const GroupTableData({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    return map;
  }

  GroupTableCompanion toCompanion(bool nullToAbsent) {
    return GroupTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      name: Value(name),
      description: Value(description),
    );
  }

  factory GroupTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupTableData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
    };
  }

  GroupTableData copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? description,
  }) => GroupTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    name: name ?? this.name,
    description: description ?? this.description,
  );
  GroupTableData copyWithCompanion(GroupTableCompanion data) {
    return GroupTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, name, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.name == this.name &&
          other.description == this.description);
}

class GroupTableCompanion extends UpdateCompanion<GroupTableData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> name;
  final Value<String> description;
  final Value<int> rowid;
  const GroupTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupTableCompanion.insert({
    required String id,
    required DateTime createdAt,
    required String name,
    required String description,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       name = Value(name),
       description = Value(description);
  static Insertable<GroupTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<String>? name,
    Value<String>? description,
    Value<int>? rowid,
  }) {
    return GroupTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameTableTable extends GameTable
    with TableInfo<$GameTableTable, GameTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Ruleset, String> ruleset =
      GeneratedColumn<String>(
        'ruleset',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Ruleset>($GameTableTable.$converterruleset);
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AppColor, String> color =
      GeneratedColumn<String>(
        'color',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AppColor>($GameTableTable.$convertercolor);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    name,
    ruleset,
    description,
    color,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      ruleset: $GameTableTable.$converterruleset.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}ruleset'],
        )!,
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      color: $GameTableTable.$convertercolor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}color'],
        )!,
      ),
    );
  }

  @override
  $GameTableTable createAlias(String alias) {
    return $GameTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Ruleset, String, String> $converterruleset =
      const EnumNameConverter<Ruleset>(Ruleset.values);
  static JsonTypeConverter2<AppColor, String, String> $convertercolor =
      const EnumNameConverter<AppColor>(AppColor.values);
}

class GameTableData extends DataClass implements Insertable<GameTableData> {
  final String id;
  final DateTime createdAt;
  final String name;
  final Ruleset ruleset;
  final String description;
  final AppColor color;
  const GameTableData({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.ruleset,
    required this.description,
    required this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['name'] = Variable<String>(name);
    {
      map['ruleset'] = Variable<String>(
        $GameTableTable.$converterruleset.toSql(ruleset),
      );
    }
    map['description'] = Variable<String>(description);
    {
      map['color'] = Variable<String>(
        $GameTableTable.$convertercolor.toSql(color),
      );
    }
    return map;
  }

  GameTableCompanion toCompanion(bool nullToAbsent) {
    return GameTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      name: Value(name),
      ruleset: Value(ruleset),
      description: Value(description),
      color: Value(color),
    );
  }

  factory GameTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameTableData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      name: serializer.fromJson<String>(json['name']),
      ruleset: $GameTableTable.$converterruleset.fromJson(
        serializer.fromJson<String>(json['ruleset']),
      ),
      description: serializer.fromJson<String>(json['description']),
      color: $GameTableTable.$convertercolor.fromJson(
        serializer.fromJson<String>(json['color']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'name': serializer.toJson<String>(name),
      'ruleset': serializer.toJson<String>(
        $GameTableTable.$converterruleset.toJson(ruleset),
      ),
      'description': serializer.toJson<String>(description),
      'color': serializer.toJson<String>(
        $GameTableTable.$convertercolor.toJson(color),
      ),
    };
  }

  GameTableData copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    Ruleset? ruleset,
    String? description,
    AppColor? color,
  }) => GameTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    name: name ?? this.name,
    ruleset: ruleset ?? this.ruleset,
    description: description ?? this.description,
    color: color ?? this.color,
  );
  GameTableData copyWithCompanion(GameTableCompanion data) {
    return GameTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      name: data.name.present ? data.name.value : this.name,
      ruleset: data.ruleset.present ? data.ruleset.value : this.ruleset,
      description: data.description.present
          ? data.description.value
          : this.description,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('ruleset: $ruleset, ')
          ..write('description: $description, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, name, ruleset, description, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.name == this.name &&
          other.ruleset == this.ruleset &&
          other.description == this.description &&
          other.color == this.color);
}

class GameTableCompanion extends UpdateCompanion<GameTableData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> name;
  final Value<Ruleset> ruleset;
  final Value<String> description;
  final Value<AppColor> color;
  final Value<int> rowid;
  const GameTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.name = const Value.absent(),
    this.ruleset = const Value.absent(),
    this.description = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameTableCompanion.insert({
    required String id,
    required DateTime createdAt,
    required String name,
    required Ruleset ruleset,
    required String description,
    required AppColor color,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       name = Value(name),
       ruleset = Value(ruleset),
       description = Value(description),
       color = Value(color);
  static Insertable<GameTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? name,
    Expression<String>? ruleset,
    Expression<String>? description,
    Expression<String>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (name != null) 'name': name,
      if (ruleset != null) 'ruleset': ruleset,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<String>? name,
    Value<Ruleset>? ruleset,
    Value<String>? description,
    Value<AppColor>? color,
    Value<int>? rowid,
  }) {
    return GameTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      ruleset: ruleset ?? this.ruleset,
      description: description ?? this.description,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (ruleset.present) {
      map['ruleset'] = Variable<String>(
        $GameTableTable.$converterruleset.toSql(ruleset.value),
      );
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(
        $GameTableTable.$convertercolor.toSql(color.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('ruleset: $ruleset, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchTableTable extends MatchTable
    with TableInfo<$MatchTableTable, MatchTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES game_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES group_table (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _isTeamMatchMeta = const VerificationMeta(
    'isTeamMatch',
  );
  @override
  late final GeneratedColumn<bool> isTeamMatch = GeneratedColumn<bool>(
    'is_team_match',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_team_match" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    name,
    gameId,
    groupId,
    isTeamMatch,
    notes,
    endedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'match_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MatchTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('is_team_match')) {
      context.handle(
        _isTeamMatchMeta,
        isTeamMatch.isAcceptableOrUnknown(
          data['is_team_match']!,
          _isTeamMatchMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MatchTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      isTeamMatch: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_team_match'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
    );
  }

  @override
  $MatchTableTable createAlias(String alias) {
    return $MatchTableTable(attachedDatabase, alias);
  }
}

class MatchTableData extends DataClass implements Insertable<MatchTableData> {
  final String id;
  final DateTime createdAt;
  final String name;
  final String gameId;
  final String? groupId;
  final bool isTeamMatch;
  final String notes;
  final DateTime? endedAt;
  const MatchTableData({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.gameId,
    this.groupId,
    required this.isTeamMatch,
    required this.notes,
    this.endedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['name'] = Variable<String>(name);
    map['game_id'] = Variable<String>(gameId);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    map['is_team_match'] = Variable<bool>(isTeamMatch);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    return map;
  }

  MatchTableCompanion toCompanion(bool nullToAbsent) {
    return MatchTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      name: Value(name),
      gameId: Value(gameId),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      isTeamMatch: Value(isTeamMatch),
      notes: Value(notes),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
    );
  }

  factory MatchTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchTableData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      name: serializer.fromJson<String>(json['name']),
      gameId: serializer.fromJson<String>(json['gameId']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      isTeamMatch: serializer.fromJson<bool>(json['isTeamMatch']),
      notes: serializer.fromJson<String>(json['notes']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'name': serializer.toJson<String>(name),
      'gameId': serializer.toJson<String>(gameId),
      'groupId': serializer.toJson<String?>(groupId),
      'isTeamMatch': serializer.toJson<bool>(isTeamMatch),
      'notes': serializer.toJson<String>(notes),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
    };
  }

  MatchTableData copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? gameId,
    Value<String?> groupId = const Value.absent(),
    bool? isTeamMatch,
    String? notes,
    Value<DateTime?> endedAt = const Value.absent(),
  }) => MatchTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    name: name ?? this.name,
    gameId: gameId ?? this.gameId,
    groupId: groupId.present ? groupId.value : this.groupId,
    isTeamMatch: isTeamMatch ?? this.isTeamMatch,
    notes: notes ?? this.notes,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
  );
  MatchTableData copyWithCompanion(MatchTableCompanion data) {
    return MatchTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      name: data.name.present ? data.name.value : this.name,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      isTeamMatch: data.isTeamMatch.present
          ? data.isTeamMatch.value
          : this.isTeamMatch,
      notes: data.notes.present ? data.notes.value : this.notes,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('gameId: $gameId, ')
          ..write('groupId: $groupId, ')
          ..write('isTeamMatch: $isTeamMatch, ')
          ..write('notes: $notes, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    name,
    gameId,
    groupId,
    isTeamMatch,
    notes,
    endedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.name == this.name &&
          other.gameId == this.gameId &&
          other.groupId == this.groupId &&
          other.isTeamMatch == this.isTeamMatch &&
          other.notes == this.notes &&
          other.endedAt == this.endedAt);
}

class MatchTableCompanion extends UpdateCompanion<MatchTableData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> name;
  final Value<String> gameId;
  final Value<String?> groupId;
  final Value<bool> isTeamMatch;
  final Value<String> notes;
  final Value<DateTime?> endedAt;
  final Value<int> rowid;
  const MatchTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.name = const Value.absent(),
    this.gameId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.isTeamMatch = const Value.absent(),
    this.notes = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchTableCompanion.insert({
    required String id,
    required DateTime createdAt,
    required String name,
    required String gameId,
    this.groupId = const Value.absent(),
    this.isTeamMatch = const Value.absent(),
    required String notes,
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       name = Value(name),
       gameId = Value(gameId),
       notes = Value(notes);
  static Insertable<MatchTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? name,
    Expression<String>? gameId,
    Expression<String>? groupId,
    Expression<bool>? isTeamMatch,
    Expression<String>? notes,
    Expression<DateTime>? endedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (name != null) 'name': name,
      if (gameId != null) 'game_id': gameId,
      if (groupId != null) 'group_id': groupId,
      if (isTeamMatch != null) 'is_team_match': isTeamMatch,
      if (notes != null) 'notes': notes,
      if (endedAt != null) 'ended_at': endedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<String>? name,
    Value<String>? gameId,
    Value<String?>? groupId,
    Value<bool>? isTeamMatch,
    Value<String>? notes,
    Value<DateTime?>? endedAt,
    Value<int>? rowid,
  }) {
    return MatchTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      gameId: gameId ?? this.gameId,
      groupId: groupId ?? this.groupId,
      isTeamMatch: isTeamMatch ?? this.isTeamMatch,
      notes: notes ?? this.notes,
      endedAt: endedAt ?? this.endedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (isTeamMatch.present) {
      map['is_team_match'] = Variable<bool>(isTeamMatch.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('gameId: $gameId, ')
          ..write('groupId: $groupId, ')
          ..write('isTeamMatch: $isTeamMatch, ')
          ..write('notes: $notes, ')
          ..write('endedAt: $endedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayerGroupTableTable extends PlayerGroupTable
    with TableInfo<$PlayerGroupTableTable, PlayerGroupTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerGroupTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES player_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES group_table (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [playerId, groupId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_group_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerGroupTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playerId, groupId};
  @override
  PlayerGroupTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerGroupTableData(
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
    );
  }

  @override
  $PlayerGroupTableTable createAlias(String alias) {
    return $PlayerGroupTableTable(attachedDatabase, alias);
  }
}

class PlayerGroupTableData extends DataClass
    implements Insertable<PlayerGroupTableData> {
  final String playerId;
  final String groupId;
  const PlayerGroupTableData({required this.playerId, required this.groupId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['player_id'] = Variable<String>(playerId);
    map['group_id'] = Variable<String>(groupId);
    return map;
  }

  PlayerGroupTableCompanion toCompanion(bool nullToAbsent) {
    return PlayerGroupTableCompanion(
      playerId: Value(playerId),
      groupId: Value(groupId),
    );
  }

  factory PlayerGroupTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerGroupTableData(
      playerId: serializer.fromJson<String>(json['playerId']),
      groupId: serializer.fromJson<String>(json['groupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playerId': serializer.toJson<String>(playerId),
      'groupId': serializer.toJson<String>(groupId),
    };
  }

  PlayerGroupTableData copyWith({String? playerId, String? groupId}) =>
      PlayerGroupTableData(
        playerId: playerId ?? this.playerId,
        groupId: groupId ?? this.groupId,
      );
  PlayerGroupTableData copyWithCompanion(PlayerGroupTableCompanion data) {
    return PlayerGroupTableData(
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerGroupTableData(')
          ..write('playerId: $playerId, ')
          ..write('groupId: $groupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playerId, groupId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerGroupTableData &&
          other.playerId == this.playerId &&
          other.groupId == this.groupId);
}

class PlayerGroupTableCompanion extends UpdateCompanion<PlayerGroupTableData> {
  final Value<String> playerId;
  final Value<String> groupId;
  final Value<int> rowid;
  const PlayerGroupTableCompanion({
    this.playerId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayerGroupTableCompanion.insert({
    required String playerId,
    required String groupId,
    this.rowid = const Value.absent(),
  }) : playerId = Value(playerId),
       groupId = Value(groupId);
  static Insertable<PlayerGroupTableData> custom({
    Expression<String>? playerId,
    Expression<String>? groupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playerId != null) 'player_id': playerId,
      if (groupId != null) 'group_id': groupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayerGroupTableCompanion copyWith({
    Value<String>? playerId,
    Value<String>? groupId,
    Value<int>? rowid,
  }) {
    return PlayerGroupTableCompanion(
      playerId: playerId ?? this.playerId,
      groupId: groupId ?? this.groupId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerGroupTableCompanion(')
          ..write('playerId: $playerId, ')
          ..write('groupId: $groupId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeamTableTable extends TeamTable
    with TableInfo<$TeamTableTable, TeamTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AppColor, String> color =
      GeneratedColumn<String>(
        'color',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(AppColor.blue.name),
      ).withConverter<AppColor>($TeamTableTable.$convertercolor);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, name, color, score];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'team_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeamTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeamTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeamTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: $TeamTableTable.$convertercolor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}color'],
        )!,
      ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      ),
    );
  }

  @override
  $TeamTableTable createAlias(String alias) {
    return $TeamTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AppColor, String, String> $convertercolor =
      const EnumNameConverter<AppColor>(AppColor.values);
}

class TeamTableData extends DataClass implements Insertable<TeamTableData> {
  final String id;
  final DateTime createdAt;
  final String name;
  final AppColor color;
  final int? score;
  const TeamTableData({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.color,
    this.score,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['name'] = Variable<String>(name);
    {
      map['color'] = Variable<String>(
        $TeamTableTable.$convertercolor.toSql(color),
      );
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    return map;
  }

  TeamTableCompanion toCompanion(bool nullToAbsent) {
    return TeamTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      name: Value(name),
      color: Value(color),
      score: score == null && nullToAbsent
          ? const Value.absent()
          : Value(score),
    );
  }

  factory TeamTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeamTableData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      name: serializer.fromJson<String>(json['name']),
      color: $TeamTableTable.$convertercolor.fromJson(
        serializer.fromJson<String>(json['color']),
      ),
      score: serializer.fromJson<int?>(json['score']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(
        $TeamTableTable.$convertercolor.toJson(color),
      ),
      'score': serializer.toJson<int?>(score),
    };
  }

  TeamTableData copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    AppColor? color,
    Value<int?> score = const Value.absent(),
  }) => TeamTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    name: name ?? this.name,
    color: color ?? this.color,
    score: score.present ? score.value : this.score,
  );
  TeamTableData copyWithCompanion(TeamTableCompanion data) {
    return TeamTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      score: data.score.present ? data.score.value : this.score,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeamTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, name, color, score);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeamTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.name == this.name &&
          other.color == this.color &&
          other.score == this.score);
}

class TeamTableCompanion extends UpdateCompanion<TeamTableData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> name;
  final Value<AppColor> color;
  final Value<int?> score;
  final Value<int> rowid;
  const TeamTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.score = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamTableCompanion.insert({
    required String id,
    required DateTime createdAt,
    required String name,
    this.color = const Value.absent(),
    this.score = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       name = Value(name);
  static Insertable<TeamTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? name,
    Expression<String>? color,
    Expression<int>? score,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (score != null) 'score': score,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<String>? name,
    Value<AppColor>? color,
    Value<int?>? score,
    Value<int>? rowid,
  }) {
    return TeamTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      color: color ?? this.color,
      score: score ?? this.score,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(
        $TeamTableTable.$convertercolor.toSql(color.value),
      );
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('score: $score, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayerMatchTableTable extends PlayerMatchTable
    with TableInfo<$PlayerMatchTableTable, PlayerMatchTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerMatchTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES player_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
    'match_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES match_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES team_table (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [playerId, matchId, teamId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_match_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerMatchTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playerId, matchId};
  @override
  PlayerMatchTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerMatchTableData(
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_id'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      ),
    );
  }

  @override
  $PlayerMatchTableTable createAlias(String alias) {
    return $PlayerMatchTableTable(attachedDatabase, alias);
  }
}

class PlayerMatchTableData extends DataClass
    implements Insertable<PlayerMatchTableData> {
  final String playerId;
  final String matchId;
  final String? teamId;
  const PlayerMatchTableData({
    required this.playerId,
    required this.matchId,
    this.teamId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['player_id'] = Variable<String>(playerId);
    map['match_id'] = Variable<String>(matchId);
    if (!nullToAbsent || teamId != null) {
      map['team_id'] = Variable<String>(teamId);
    }
    return map;
  }

  PlayerMatchTableCompanion toCompanion(bool nullToAbsent) {
    return PlayerMatchTableCompanion(
      playerId: Value(playerId),
      matchId: Value(matchId),
      teamId: teamId == null && nullToAbsent
          ? const Value.absent()
          : Value(teamId),
    );
  }

  factory PlayerMatchTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerMatchTableData(
      playerId: serializer.fromJson<String>(json['playerId']),
      matchId: serializer.fromJson<String>(json['matchId']),
      teamId: serializer.fromJson<String?>(json['teamId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playerId': serializer.toJson<String>(playerId),
      'matchId': serializer.toJson<String>(matchId),
      'teamId': serializer.toJson<String?>(teamId),
    };
  }

  PlayerMatchTableData copyWith({
    String? playerId,
    String? matchId,
    Value<String?> teamId = const Value.absent(),
  }) => PlayerMatchTableData(
    playerId: playerId ?? this.playerId,
    matchId: matchId ?? this.matchId,
    teamId: teamId.present ? teamId.value : this.teamId,
  );
  PlayerMatchTableData copyWithCompanion(PlayerMatchTableCompanion data) {
    return PlayerMatchTableData(
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerMatchTableData(')
          ..write('playerId: $playerId, ')
          ..write('matchId: $matchId, ')
          ..write('teamId: $teamId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playerId, matchId, teamId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerMatchTableData &&
          other.playerId == this.playerId &&
          other.matchId == this.matchId &&
          other.teamId == this.teamId);
}

class PlayerMatchTableCompanion extends UpdateCompanion<PlayerMatchTableData> {
  final Value<String> playerId;
  final Value<String> matchId;
  final Value<String?> teamId;
  final Value<int> rowid;
  const PlayerMatchTableCompanion({
    this.playerId = const Value.absent(),
    this.matchId = const Value.absent(),
    this.teamId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayerMatchTableCompanion.insert({
    required String playerId,
    required String matchId,
    this.teamId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : playerId = Value(playerId),
       matchId = Value(matchId);
  static Insertable<PlayerMatchTableData> custom({
    Expression<String>? playerId,
    Expression<String>? matchId,
    Expression<String>? teamId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playerId != null) 'player_id': playerId,
      if (matchId != null) 'match_id': matchId,
      if (teamId != null) 'team_id': teamId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayerMatchTableCompanion copyWith({
    Value<String>? playerId,
    Value<String>? matchId,
    Value<String?>? teamId,
    Value<int>? rowid,
  }) {
    return PlayerMatchTableCompanion(
      playerId: playerId ?? this.playerId,
      matchId: matchId ?? this.matchId,
      teamId: teamId ?? this.teamId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerMatchTableCompanion(')
          ..write('playerId: $playerId, ')
          ..write('matchId: $matchId, ')
          ..write('teamId: $teamId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScoreEntryTableTable extends ScoreEntryTable
    with TableInfo<$ScoreEntryTableTable, ScoreEntryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScoreEntryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES player_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
    'match_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES match_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roundNumberMeta = const VerificationMeta(
    'roundNumber',
  );
  @override
  late final GeneratedColumn<int> roundNumber = GeneratedColumn<int>(
    'round_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changeMeta = const VerificationMeta('change');
  @override
  late final GeneratedColumn<int> change = GeneratedColumn<int>(
    'change',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    playerId,
    matchId,
    roundNumber,
    score,
    change,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'score_entry_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScoreEntryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('round_number')) {
      context.handle(
        _roundNumberMeta,
        roundNumber.isAcceptableOrUnknown(
          data['round_number']!,
          _roundNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_roundNumberMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('change')) {
      context.handle(
        _changeMeta,
        change.isAcceptableOrUnknown(data['change']!, _changeMeta),
      );
    } else if (isInserting) {
      context.missing(_changeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playerId, matchId, roundNumber};
  @override
  ScoreEntryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScoreEntryTableData(
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_id'],
      )!,
      roundNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round_number'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      change: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}change'],
      )!,
    );
  }

  @override
  $ScoreEntryTableTable createAlias(String alias) {
    return $ScoreEntryTableTable(attachedDatabase, alias);
  }
}

class ScoreEntryTableData extends DataClass
    implements Insertable<ScoreEntryTableData> {
  final String playerId;
  final String matchId;
  final int roundNumber;
  final int score;
  final int change;
  const ScoreEntryTableData({
    required this.playerId,
    required this.matchId,
    required this.roundNumber,
    required this.score,
    required this.change,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['player_id'] = Variable<String>(playerId);
    map['match_id'] = Variable<String>(matchId);
    map['round_number'] = Variable<int>(roundNumber);
    map['score'] = Variable<int>(score);
    map['change'] = Variable<int>(change);
    return map;
  }

  ScoreEntryTableCompanion toCompanion(bool nullToAbsent) {
    return ScoreEntryTableCompanion(
      playerId: Value(playerId),
      matchId: Value(matchId),
      roundNumber: Value(roundNumber),
      score: Value(score),
      change: Value(change),
    );
  }

  factory ScoreEntryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScoreEntryTableData(
      playerId: serializer.fromJson<String>(json['playerId']),
      matchId: serializer.fromJson<String>(json['matchId']),
      roundNumber: serializer.fromJson<int>(json['roundNumber']),
      score: serializer.fromJson<int>(json['score']),
      change: serializer.fromJson<int>(json['change']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playerId': serializer.toJson<String>(playerId),
      'matchId': serializer.toJson<String>(matchId),
      'roundNumber': serializer.toJson<int>(roundNumber),
      'score': serializer.toJson<int>(score),
      'change': serializer.toJson<int>(change),
    };
  }

  ScoreEntryTableData copyWith({
    String? playerId,
    String? matchId,
    int? roundNumber,
    int? score,
    int? change,
  }) => ScoreEntryTableData(
    playerId: playerId ?? this.playerId,
    matchId: matchId ?? this.matchId,
    roundNumber: roundNumber ?? this.roundNumber,
    score: score ?? this.score,
    change: change ?? this.change,
  );
  ScoreEntryTableData copyWithCompanion(ScoreEntryTableCompanion data) {
    return ScoreEntryTableData(
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      roundNumber: data.roundNumber.present
          ? data.roundNumber.value
          : this.roundNumber,
      score: data.score.present ? data.score.value : this.score,
      change: data.change.present ? data.change.value : this.change,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScoreEntryTableData(')
          ..write('playerId: $playerId, ')
          ..write('matchId: $matchId, ')
          ..write('roundNumber: $roundNumber, ')
          ..write('score: $score, ')
          ..write('change: $change')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(playerId, matchId, roundNumber, score, change);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScoreEntryTableData &&
          other.playerId == this.playerId &&
          other.matchId == this.matchId &&
          other.roundNumber == this.roundNumber &&
          other.score == this.score &&
          other.change == this.change);
}

class ScoreEntryTableCompanion extends UpdateCompanion<ScoreEntryTableData> {
  final Value<String> playerId;
  final Value<String> matchId;
  final Value<int> roundNumber;
  final Value<int> score;
  final Value<int> change;
  final Value<int> rowid;
  const ScoreEntryTableCompanion({
    this.playerId = const Value.absent(),
    this.matchId = const Value.absent(),
    this.roundNumber = const Value.absent(),
    this.score = const Value.absent(),
    this.change = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScoreEntryTableCompanion.insert({
    required String playerId,
    required String matchId,
    required int roundNumber,
    required int score,
    required int change,
    this.rowid = const Value.absent(),
  }) : playerId = Value(playerId),
       matchId = Value(matchId),
       roundNumber = Value(roundNumber),
       score = Value(score),
       change = Value(change);
  static Insertable<ScoreEntryTableData> custom({
    Expression<String>? playerId,
    Expression<String>? matchId,
    Expression<int>? roundNumber,
    Expression<int>? score,
    Expression<int>? change,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playerId != null) 'player_id': playerId,
      if (matchId != null) 'match_id': matchId,
      if (roundNumber != null) 'round_number': roundNumber,
      if (score != null) 'score': score,
      if (change != null) 'change': change,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScoreEntryTableCompanion copyWith({
    Value<String>? playerId,
    Value<String>? matchId,
    Value<int>? roundNumber,
    Value<int>? score,
    Value<int>? change,
    Value<int>? rowid,
  }) {
    return ScoreEntryTableCompanion(
      playerId: playerId ?? this.playerId,
      matchId: matchId ?? this.matchId,
      roundNumber: roundNumber ?? this.roundNumber,
      score: score ?? this.score,
      change: change ?? this.change,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (roundNumber.present) {
      map['round_number'] = Variable<int>(roundNumber.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (change.present) {
      map['change'] = Variable<int>(change.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScoreEntryTableCompanion(')
          ..write('playerId: $playerId, ')
          ..write('matchId: $matchId, ')
          ..write('roundNumber: $roundNumber, ')
          ..write('score: $score, ')
          ..write('change: $change, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StatisticTableTable extends StatisticTable
    with TableInfo<$StatisticTableTable, StatisticTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatisticTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  late final GeneratedColumnWithTypeConverter<StatisticType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<StatisticType>($StatisticTableTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<Timeframe, String> timeframe =
      GeneratedColumn<String>(
        'timeframe',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Timeframe>($StatisticTableTable.$convertertimeframe);
  @override
  late final GeneratedColumnWithTypeConverter<AppColor, String> color =
      GeneratedColumn<String>(
        'color',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AppColor>($StatisticTableTable.$convertercolor);
  static const VerificationMeta _displayCountMeta = const VerificationMeta(
    'displayCount',
  );
  @override
  late final GeneratedColumn<int> displayCount = GeneratedColumn<int>(
    'display_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _isFavouriteMeta = const VerificationMeta(
    'isFavourite',
  );
  @override
  late final GeneratedColumn<bool> isFavourite = GeneratedColumn<bool>(
    'is_favourite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favourite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    type,
    timeframe,
    color,
    displayCount,
    isFavourite,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'statistic_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatisticTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('display_count')) {
      context.handle(
        _displayCountMeta,
        displayCount.isAcceptableOrUnknown(
          data['display_count']!,
          _displayCountMeta,
        ),
      );
    }
    if (data.containsKey('is_favourite')) {
      context.handle(
        _isFavouriteMeta,
        isFavourite.isAcceptableOrUnknown(
          data['is_favourite']!,
          _isFavouriteMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StatisticTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatisticTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      type: $StatisticTableTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      timeframe: $StatisticTableTable.$convertertimeframe.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}timeframe'],
        )!,
      ),
      color: $StatisticTableTable.$convertercolor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}color'],
        )!,
      ),
      displayCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_count'],
      )!,
      isFavourite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favourite'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $StatisticTableTable createAlias(String alias) {
    return $StatisticTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<StatisticType, String, String> $convertertype =
      const EnumNameConverter<StatisticType>(StatisticType.values);
  static JsonTypeConverter2<Timeframe, String, String> $convertertimeframe =
      const EnumNameConverter<Timeframe>(Timeframe.values);
  static JsonTypeConverter2<AppColor, String, String> $convertercolor =
      const EnumNameConverter<AppColor>(AppColor.values);
}

class StatisticTableData extends DataClass
    implements Insertable<StatisticTableData> {
  final String id;
  final DateTime createdAt;
  final StatisticType type;
  final Timeframe timeframe;
  final AppColor color;
  final int displayCount;
  final bool isFavourite;
  final int position;
  const StatisticTableData({
    required this.id,
    required this.createdAt,
    required this.type,
    required this.timeframe,
    required this.color,
    required this.displayCount,
    required this.isFavourite,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    {
      map['type'] = Variable<String>(
        $StatisticTableTable.$convertertype.toSql(type),
      );
    }
    {
      map['timeframe'] = Variable<String>(
        $StatisticTableTable.$convertertimeframe.toSql(timeframe),
      );
    }
    {
      map['color'] = Variable<String>(
        $StatisticTableTable.$convertercolor.toSql(color),
      );
    }
    map['display_count'] = Variable<int>(displayCount);
    map['is_favourite'] = Variable<bool>(isFavourite);
    map['position'] = Variable<int>(position);
    return map;
  }

  StatisticTableCompanion toCompanion(bool nullToAbsent) {
    return StatisticTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      type: Value(type),
      timeframe: Value(timeframe),
      color: Value(color),
      displayCount: Value(displayCount),
      isFavourite: Value(isFavourite),
      position: Value(position),
    );
  }

  factory StatisticTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatisticTableData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      type: $StatisticTableTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      timeframe: $StatisticTableTable.$convertertimeframe.fromJson(
        serializer.fromJson<String>(json['timeframe']),
      ),
      color: $StatisticTableTable.$convertercolor.fromJson(
        serializer.fromJson<String>(json['color']),
      ),
      displayCount: serializer.fromJson<int>(json['displayCount']),
      isFavourite: serializer.fromJson<bool>(json['isFavourite']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'type': serializer.toJson<String>(
        $StatisticTableTable.$convertertype.toJson(type),
      ),
      'timeframe': serializer.toJson<String>(
        $StatisticTableTable.$convertertimeframe.toJson(timeframe),
      ),
      'color': serializer.toJson<String>(
        $StatisticTableTable.$convertercolor.toJson(color),
      ),
      'displayCount': serializer.toJson<int>(displayCount),
      'isFavourite': serializer.toJson<bool>(isFavourite),
      'position': serializer.toJson<int>(position),
    };
  }

  StatisticTableData copyWith({
    String? id,
    DateTime? createdAt,
    StatisticType? type,
    Timeframe? timeframe,
    AppColor? color,
    int? displayCount,
    bool? isFavourite,
    int? position,
  }) => StatisticTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    type: type ?? this.type,
    timeframe: timeframe ?? this.timeframe,
    color: color ?? this.color,
    displayCount: displayCount ?? this.displayCount,
    isFavourite: isFavourite ?? this.isFavourite,
    position: position ?? this.position,
  );
  StatisticTableData copyWithCompanion(StatisticTableCompanion data) {
    return StatisticTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      type: data.type.present ? data.type.value : this.type,
      timeframe: data.timeframe.present ? data.timeframe.value : this.timeframe,
      color: data.color.present ? data.color.value : this.color,
      displayCount: data.displayCount.present
          ? data.displayCount.value
          : this.displayCount,
      isFavourite: data.isFavourite.present
          ? data.isFavourite.value
          : this.isFavourite,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatisticTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('type: $type, ')
          ..write('timeframe: $timeframe, ')
          ..write('color: $color, ')
          ..write('displayCount: $displayCount, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    type,
    timeframe,
    color,
    displayCount,
    isFavourite,
    position,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatisticTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.type == this.type &&
          other.timeframe == this.timeframe &&
          other.color == this.color &&
          other.displayCount == this.displayCount &&
          other.isFavourite == this.isFavourite &&
          other.position == this.position);
}

class StatisticTableCompanion extends UpdateCompanion<StatisticTableData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<StatisticType> type;
  final Value<Timeframe> timeframe;
  final Value<AppColor> color;
  final Value<int> displayCount;
  final Value<bool> isFavourite;
  final Value<int> position;
  final Value<int> rowid;
  const StatisticTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.type = const Value.absent(),
    this.timeframe = const Value.absent(),
    this.color = const Value.absent(),
    this.displayCount = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StatisticTableCompanion.insert({
    required String id,
    required DateTime createdAt,
    required StatisticType type,
    required Timeframe timeframe,
    required AppColor color,
    this.displayCount = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       type = Value(type),
       timeframe = Value(timeframe),
       color = Value(color);
  static Insertable<StatisticTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? type,
    Expression<String>? timeframe,
    Expression<String>? color,
    Expression<int>? displayCount,
    Expression<bool>? isFavourite,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (type != null) 'type': type,
      if (timeframe != null) 'timeframe': timeframe,
      if (color != null) 'color': color,
      if (displayCount != null) 'display_count': displayCount,
      if (isFavourite != null) 'is_favourite': isFavourite,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StatisticTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<StatisticType>? type,
    Value<Timeframe>? timeframe,
    Value<AppColor>? color,
    Value<int>? displayCount,
    Value<bool>? isFavourite,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return StatisticTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      timeframe: timeframe ?? this.timeframe,
      color: color ?? this.color,
      displayCount: displayCount ?? this.displayCount,
      isFavourite: isFavourite ?? this.isFavourite,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $StatisticTableTable.$convertertype.toSql(type.value),
      );
    }
    if (timeframe.present) {
      map['timeframe'] = Variable<String>(
        $StatisticTableTable.$convertertimeframe.toSql(timeframe.value),
      );
    }
    if (color.present) {
      map['color'] = Variable<String>(
        $StatisticTableTable.$convertercolor.toSql(color.value),
      );
    }
    if (displayCount.present) {
      map['display_count'] = Variable<int>(displayCount.value);
    }
    if (isFavourite.present) {
      map['is_favourite'] = Variable<bool>(isFavourite.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatisticTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('type: $type, ')
          ..write('timeframe: $timeframe, ')
          ..write('color: $color, ')
          ..write('displayCount: $displayCount, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StatisticScopeTableTable extends StatisticScopeTable
    with TableInfo<$StatisticScopeTableTable, StatisticScopeTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatisticScopeTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _statisticIdMeta = const VerificationMeta(
    'statisticId',
  );
  @override
  late final GeneratedColumn<String> statisticId = GeneratedColumn<String>(
    'statistic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES statistic_table (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<StatisticScope, String> scope =
      GeneratedColumn<String>(
        'scope',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<StatisticScope>(
        $StatisticScopeTableTable.$converterscope,
      );
  @override
  List<GeneratedColumn> get $columns => [statisticId, scope];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'statistic_scope_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatisticScopeTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('statistic_id')) {
      context.handle(
        _statisticIdMeta,
        statisticId.isAcceptableOrUnknown(
          data['statistic_id']!,
          _statisticIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_statisticIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {statisticId, scope};
  @override
  StatisticScopeTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatisticScopeTableData(
      statisticId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}statistic_id'],
      )!,
      scope: $StatisticScopeTableTable.$converterscope.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}scope'],
        )!,
      ),
    );
  }

  @override
  $StatisticScopeTableTable createAlias(String alias) {
    return $StatisticScopeTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<StatisticScope, String, String> $converterscope =
      const EnumNameConverter<StatisticScope>(StatisticScope.values);
}

class StatisticScopeTableData extends DataClass
    implements Insertable<StatisticScopeTableData> {
  final String statisticId;
  final StatisticScope scope;
  const StatisticScopeTableData({
    required this.statisticId,
    required this.scope,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['statistic_id'] = Variable<String>(statisticId);
    {
      map['scope'] = Variable<String>(
        $StatisticScopeTableTable.$converterscope.toSql(scope),
      );
    }
    return map;
  }

  StatisticScopeTableCompanion toCompanion(bool nullToAbsent) {
    return StatisticScopeTableCompanion(
      statisticId: Value(statisticId),
      scope: Value(scope),
    );
  }

  factory StatisticScopeTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatisticScopeTableData(
      statisticId: serializer.fromJson<String>(json['statisticId']),
      scope: $StatisticScopeTableTable.$converterscope.fromJson(
        serializer.fromJson<String>(json['scope']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'statisticId': serializer.toJson<String>(statisticId),
      'scope': serializer.toJson<String>(
        $StatisticScopeTableTable.$converterscope.toJson(scope),
      ),
    };
  }

  StatisticScopeTableData copyWith({
    String? statisticId,
    StatisticScope? scope,
  }) => StatisticScopeTableData(
    statisticId: statisticId ?? this.statisticId,
    scope: scope ?? this.scope,
  );
  StatisticScopeTableData copyWithCompanion(StatisticScopeTableCompanion data) {
    return StatisticScopeTableData(
      statisticId: data.statisticId.present
          ? data.statisticId.value
          : this.statisticId,
      scope: data.scope.present ? data.scope.value : this.scope,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatisticScopeTableData(')
          ..write('statisticId: $statisticId, ')
          ..write('scope: $scope')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(statisticId, scope);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatisticScopeTableData &&
          other.statisticId == this.statisticId &&
          other.scope == this.scope);
}

class StatisticScopeTableCompanion
    extends UpdateCompanion<StatisticScopeTableData> {
  final Value<String> statisticId;
  final Value<StatisticScope> scope;
  final Value<int> rowid;
  const StatisticScopeTableCompanion({
    this.statisticId = const Value.absent(),
    this.scope = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StatisticScopeTableCompanion.insert({
    required String statisticId,
    required StatisticScope scope,
    this.rowid = const Value.absent(),
  }) : statisticId = Value(statisticId),
       scope = Value(scope);
  static Insertable<StatisticScopeTableData> custom({
    Expression<String>? statisticId,
    Expression<String>? scope,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (statisticId != null) 'statistic_id': statisticId,
      if (scope != null) 'scope': scope,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StatisticScopeTableCompanion copyWith({
    Value<String>? statisticId,
    Value<StatisticScope>? scope,
    Value<int>? rowid,
  }) {
    return StatisticScopeTableCompanion(
      statisticId: statisticId ?? this.statisticId,
      scope: scope ?? this.scope,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (statisticId.present) {
      map['statistic_id'] = Variable<String>(statisticId.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(
        $StatisticScopeTableTable.$converterscope.toSql(scope.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatisticScopeTableCompanion(')
          ..write('statisticId: $statisticId, ')
          ..write('scope: $scope, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StatisticGameTableTable extends StatisticGameTable
    with TableInfo<$StatisticGameTableTable, StatisticGameTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatisticGameTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _statisticIdMeta = const VerificationMeta(
    'statisticId',
  );
  @override
  late final GeneratedColumn<String> statisticId = GeneratedColumn<String>(
    'statistic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES statistic_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES game_table (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [statisticId, gameId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'statistic_game_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatisticGameTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('statistic_id')) {
      context.handle(
        _statisticIdMeta,
        statisticId.isAcceptableOrUnknown(
          data['statistic_id']!,
          _statisticIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_statisticIdMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {statisticId, gameId};
  @override
  StatisticGameTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatisticGameTableData(
      statisticId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}statistic_id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
    );
  }

  @override
  $StatisticGameTableTable createAlias(String alias) {
    return $StatisticGameTableTable(attachedDatabase, alias);
  }
}

class StatisticGameTableData extends DataClass
    implements Insertable<StatisticGameTableData> {
  final String statisticId;
  final String gameId;
  const StatisticGameTableData({
    required this.statisticId,
    required this.gameId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['statistic_id'] = Variable<String>(statisticId);
    map['game_id'] = Variable<String>(gameId);
    return map;
  }

  StatisticGameTableCompanion toCompanion(bool nullToAbsent) {
    return StatisticGameTableCompanion(
      statisticId: Value(statisticId),
      gameId: Value(gameId),
    );
  }

  factory StatisticGameTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatisticGameTableData(
      statisticId: serializer.fromJson<String>(json['statisticId']),
      gameId: serializer.fromJson<String>(json['gameId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'statisticId': serializer.toJson<String>(statisticId),
      'gameId': serializer.toJson<String>(gameId),
    };
  }

  StatisticGameTableData copyWith({String? statisticId, String? gameId}) =>
      StatisticGameTableData(
        statisticId: statisticId ?? this.statisticId,
        gameId: gameId ?? this.gameId,
      );
  StatisticGameTableData copyWithCompanion(StatisticGameTableCompanion data) {
    return StatisticGameTableData(
      statisticId: data.statisticId.present
          ? data.statisticId.value
          : this.statisticId,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatisticGameTableData(')
          ..write('statisticId: $statisticId, ')
          ..write('gameId: $gameId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(statisticId, gameId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatisticGameTableData &&
          other.statisticId == this.statisticId &&
          other.gameId == this.gameId);
}

class StatisticGameTableCompanion
    extends UpdateCompanion<StatisticGameTableData> {
  final Value<String> statisticId;
  final Value<String> gameId;
  final Value<int> rowid;
  const StatisticGameTableCompanion({
    this.statisticId = const Value.absent(),
    this.gameId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StatisticGameTableCompanion.insert({
    required String statisticId,
    required String gameId,
    this.rowid = const Value.absent(),
  }) : statisticId = Value(statisticId),
       gameId = Value(gameId);
  static Insertable<StatisticGameTableData> custom({
    Expression<String>? statisticId,
    Expression<String>? gameId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (statisticId != null) 'statistic_id': statisticId,
      if (gameId != null) 'game_id': gameId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StatisticGameTableCompanion copyWith({
    Value<String>? statisticId,
    Value<String>? gameId,
    Value<int>? rowid,
  }) {
    return StatisticGameTableCompanion(
      statisticId: statisticId ?? this.statisticId,
      gameId: gameId ?? this.gameId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (statisticId.present) {
      map['statistic_id'] = Variable<String>(statisticId.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatisticGameTableCompanion(')
          ..write('statisticId: $statisticId, ')
          ..write('gameId: $gameId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StatisticGroupTableTable extends StatisticGroupTable
    with TableInfo<$StatisticGroupTableTable, StatisticGroupTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatisticGroupTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _statisticIdMeta = const VerificationMeta(
    'statisticId',
  );
  @override
  late final GeneratedColumn<String> statisticId = GeneratedColumn<String>(
    'statistic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES statistic_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES group_table (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [statisticId, groupId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'statistic_group_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatisticGroupTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('statistic_id')) {
      context.handle(
        _statisticIdMeta,
        statisticId.isAcceptableOrUnknown(
          data['statistic_id']!,
          _statisticIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_statisticIdMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {statisticId, groupId};
  @override
  StatisticGroupTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatisticGroupTableData(
      statisticId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}statistic_id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
    );
  }

  @override
  $StatisticGroupTableTable createAlias(String alias) {
    return $StatisticGroupTableTable(attachedDatabase, alias);
  }
}

class StatisticGroupTableData extends DataClass
    implements Insertable<StatisticGroupTableData> {
  final String statisticId;
  final String groupId;
  const StatisticGroupTableData({
    required this.statisticId,
    required this.groupId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['statistic_id'] = Variable<String>(statisticId);
    map['group_id'] = Variable<String>(groupId);
    return map;
  }

  StatisticGroupTableCompanion toCompanion(bool nullToAbsent) {
    return StatisticGroupTableCompanion(
      statisticId: Value(statisticId),
      groupId: Value(groupId),
    );
  }

  factory StatisticGroupTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatisticGroupTableData(
      statisticId: serializer.fromJson<String>(json['statisticId']),
      groupId: serializer.fromJson<String>(json['groupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'statisticId': serializer.toJson<String>(statisticId),
      'groupId': serializer.toJson<String>(groupId),
    };
  }

  StatisticGroupTableData copyWith({String? statisticId, String? groupId}) =>
      StatisticGroupTableData(
        statisticId: statisticId ?? this.statisticId,
        groupId: groupId ?? this.groupId,
      );
  StatisticGroupTableData copyWithCompanion(StatisticGroupTableCompanion data) {
    return StatisticGroupTableData(
      statisticId: data.statisticId.present
          ? data.statisticId.value
          : this.statisticId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatisticGroupTableData(')
          ..write('statisticId: $statisticId, ')
          ..write('groupId: $groupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(statisticId, groupId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatisticGroupTableData &&
          other.statisticId == this.statisticId &&
          other.groupId == this.groupId);
}

class StatisticGroupTableCompanion
    extends UpdateCompanion<StatisticGroupTableData> {
  final Value<String> statisticId;
  final Value<String> groupId;
  final Value<int> rowid;
  const StatisticGroupTableCompanion({
    this.statisticId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StatisticGroupTableCompanion.insert({
    required String statisticId,
    required String groupId,
    this.rowid = const Value.absent(),
  }) : statisticId = Value(statisticId),
       groupId = Value(groupId);
  static Insertable<StatisticGroupTableData> custom({
    Expression<String>? statisticId,
    Expression<String>? groupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (statisticId != null) 'statistic_id': statisticId,
      if (groupId != null) 'group_id': groupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StatisticGroupTableCompanion copyWith({
    Value<String>? statisticId,
    Value<String>? groupId,
    Value<int>? rowid,
  }) {
    return StatisticGroupTableCompanion(
      statisticId: statisticId ?? this.statisticId,
      groupId: groupId ?? this.groupId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (statisticId.present) {
      map['statistic_id'] = Variable<String>(statisticId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatisticGroupTableCompanion(')
          ..write('statisticId: $statisticId, ')
          ..write('groupId: $groupId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayerTableTable playerTable = $PlayerTableTable(this);
  late final $GroupTableTable groupTable = $GroupTableTable(this);
  late final $GameTableTable gameTable = $GameTableTable(this);
  late final $MatchTableTable matchTable = $MatchTableTable(this);
  late final $PlayerGroupTableTable playerGroupTable = $PlayerGroupTableTable(
    this,
  );
  late final $TeamTableTable teamTable = $TeamTableTable(this);
  late final $PlayerMatchTableTable playerMatchTable = $PlayerMatchTableTable(
    this,
  );
  late final $ScoreEntryTableTable scoreEntryTable = $ScoreEntryTableTable(
    this,
  );
  late final $StatisticTableTable statisticTable = $StatisticTableTable(this);
  late final $StatisticScopeTableTable statisticScopeTable =
      $StatisticScopeTableTable(this);
  late final $StatisticGameTableTable statisticGameTable =
      $StatisticGameTableTable(this);
  late final $StatisticGroupTableTable statisticGroupTable =
      $StatisticGroupTableTable(this);
  late final PlayerDao playerDao = PlayerDao(this as AppDatabase);
  late final GroupDao groupDao = GroupDao(this as AppDatabase);
  late final MatchDao matchDao = MatchDao(this as AppDatabase);
  late final PlayerGroupDao playerGroupDao = PlayerGroupDao(
    this as AppDatabase,
  );
  late final PlayerMatchDao playerMatchDao = PlayerMatchDao(
    this as AppDatabase,
  );
  late final GameDao gameDao = GameDao(this as AppDatabase);
  late final ScoreEntryDao scoreEntryDao = ScoreEntryDao(this as AppDatabase);
  late final TeamDao teamDao = TeamDao(this as AppDatabase);
  late final StatisticDao statisticDao = StatisticDao(this as AppDatabase);
  late final StatisticScopeDao statisticScopeDao = StatisticScopeDao(
    this as AppDatabase,
  );
  late final StatisticGameDao statisticGameDao = StatisticGameDao(
    this as AppDatabase,
  );
  late final StatisticGroupDao statisticGroupDao = StatisticGroupDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    playerTable,
    groupTable,
    gameTable,
    matchTable,
    playerGroupTable,
    teamTable,
    playerMatchTable,
    scoreEntryTable,
    statisticTable,
    statisticScopeTable,
    statisticGameTable,
    statisticGroupTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'game_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('match_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'group_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('match_table', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'player_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('player_group_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'group_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('player_group_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'player_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('player_match_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'match_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('player_match_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'team_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('player_match_table', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'player_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('score_entry_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'match_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('score_entry_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'statistic_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('statistic_scope_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'statistic_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('statistic_game_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'game_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('statistic_game_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'statistic_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('statistic_group_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'group_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('statistic_group_table', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PlayerTableTableCreateCompanionBuilder =
    PlayerTableCompanion Function({
      required String id,
      required DateTime createdAt,
      required String name,
      Value<int> nameCount,
      required String description,
      Value<bool> deleted,
      Value<int> rowid,
    });
typedef $$PlayerTableTableUpdateCompanionBuilder =
    PlayerTableCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<String> name,
      Value<int> nameCount,
      Value<String> description,
      Value<bool> deleted,
      Value<int> rowid,
    });

final class $$PlayerTableTableReferences
    extends BaseReferences<_$AppDatabase, $PlayerTableTable, PlayerTableData> {
  $$PlayerTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlayerGroupTableTable, List<PlayerGroupTableData>>
  _playerGroupTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playerGroupTable,
    aliasName: 'player_table__id__player_group_table__player_id',
  );

  $$PlayerGroupTableTableProcessedTableManager get playerGroupTableRefs {
    final manager = $$PlayerGroupTableTableTableManager(
      $_db,
      $_db.playerGroupTable,
    ).filter((f) => f.playerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playerGroupTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlayerMatchTableTable, List<PlayerMatchTableData>>
  _playerMatchTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playerMatchTable,
    aliasName: 'player_table__id__player_match_table__player_id',
  );

  $$PlayerMatchTableTableProcessedTableManager get playerMatchTableRefs {
    final manager = $$PlayerMatchTableTableTableManager(
      $_db,
      $_db.playerMatchTable,
    ).filter((f) => f.playerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playerMatchTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScoreEntryTableTable, List<ScoreEntryTableData>>
  _scoreEntryTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scoreEntryTable,
    aliasName: 'player_table__id__score_entry_table__player_id',
  );

  $$ScoreEntryTableTableProcessedTableManager get scoreEntryTableRefs {
    final manager = $$ScoreEntryTableTableTableManager(
      $_db,
      $_db.scoreEntryTable,
    ).filter((f) => f.playerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _scoreEntryTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlayerTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerTableTable> {
  $$PlayerTableTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nameCount => $composableBuilder(
    column: $table.nameCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playerGroupTableRefs(
    Expression<bool> Function($$PlayerGroupTableTableFilterComposer f) f,
  ) {
    final $$PlayerGroupTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playerGroupTable,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerGroupTableTableFilterComposer(
            $db: $db,
            $table: $db.playerGroupTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> playerMatchTableRefs(
    Expression<bool> Function($$PlayerMatchTableTableFilterComposer f) f,
  ) {
    final $$PlayerMatchTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playerMatchTable,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerMatchTableTableFilterComposer(
            $db: $db,
            $table: $db.playerMatchTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scoreEntryTableRefs(
    Expression<bool> Function($$ScoreEntryTableTableFilterComposer f) f,
  ) {
    final $$ScoreEntryTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scoreEntryTable,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScoreEntryTableTableFilterComposer(
            $db: $db,
            $table: $db.scoreEntryTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlayerTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerTableTable> {
  $$PlayerTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nameCount => $composableBuilder(
    column: $table.nameCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayerTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerTableTable> {
  $$PlayerTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get nameCount =>
      $composableBuilder(column: $table.nameCount, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  Expression<T> playerGroupTableRefs<T extends Object>(
    Expression<T> Function($$PlayerGroupTableTableAnnotationComposer a) f,
  ) {
    final $$PlayerGroupTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playerGroupTable,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerGroupTableTableAnnotationComposer(
            $db: $db,
            $table: $db.playerGroupTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> playerMatchTableRefs<T extends Object>(
    Expression<T> Function($$PlayerMatchTableTableAnnotationComposer a) f,
  ) {
    final $$PlayerMatchTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playerMatchTable,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerMatchTableTableAnnotationComposer(
            $db: $db,
            $table: $db.playerMatchTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> scoreEntryTableRefs<T extends Object>(
    Expression<T> Function($$ScoreEntryTableTableAnnotationComposer a) f,
  ) {
    final $$ScoreEntryTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scoreEntryTable,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScoreEntryTableTableAnnotationComposer(
            $db: $db,
            $table: $db.scoreEntryTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlayerTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerTableTable,
          PlayerTableData,
          $$PlayerTableTableFilterComposer,
          $$PlayerTableTableOrderingComposer,
          $$PlayerTableTableAnnotationComposer,
          $$PlayerTableTableCreateCompanionBuilder,
          $$PlayerTableTableUpdateCompanionBuilder,
          (PlayerTableData, $$PlayerTableTableReferences),
          PlayerTableData,
          PrefetchHooks Function({
            bool playerGroupTableRefs,
            bool playerMatchTableRefs,
            bool scoreEntryTableRefs,
          })
        > {
  $$PlayerTableTableTableManager(_$AppDatabase db, $PlayerTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> nameCount = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayerTableCompanion(
                id: id,
                createdAt: createdAt,
                name: name,
                nameCount: nameCount,
                description: description,
                deleted: deleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required String name,
                Value<int> nameCount = const Value.absent(),
                required String description,
                Value<bool> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayerTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                name: name,
                nameCount: nameCount,
                description: description,
                deleted: deleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlayerTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                playerGroupTableRefs = false,
                playerMatchTableRefs = false,
                scoreEntryTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playerGroupTableRefs) db.playerGroupTable,
                    if (playerMatchTableRefs) db.playerMatchTable,
                    if (scoreEntryTableRefs) db.scoreEntryTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playerGroupTableRefs)
                        await $_getPrefetchedData<
                          PlayerTableData,
                          $PlayerTableTable,
                          PlayerGroupTableData
                        >(
                          currentTable: table,
                          referencedTable: $$PlayerTableTableReferences
                              ._playerGroupTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlayerTableTableReferences(
                                db,
                                table,
                                p0,
                              ).playerGroupTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.playerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (playerMatchTableRefs)
                        await $_getPrefetchedData<
                          PlayerTableData,
                          $PlayerTableTable,
                          PlayerMatchTableData
                        >(
                          currentTable: table,
                          referencedTable: $$PlayerTableTableReferences
                              ._playerMatchTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlayerTableTableReferences(
                                db,
                                table,
                                p0,
                              ).playerMatchTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.playerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scoreEntryTableRefs)
                        await $_getPrefetchedData<
                          PlayerTableData,
                          $PlayerTableTable,
                          ScoreEntryTableData
                        >(
                          currentTable: table,
                          referencedTable: $$PlayerTableTableReferences
                              ._scoreEntryTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlayerTableTableReferences(
                                db,
                                table,
                                p0,
                              ).scoreEntryTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.playerId == item.id,
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

typedef $$PlayerTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerTableTable,
      PlayerTableData,
      $$PlayerTableTableFilterComposer,
      $$PlayerTableTableOrderingComposer,
      $$PlayerTableTableAnnotationComposer,
      $$PlayerTableTableCreateCompanionBuilder,
      $$PlayerTableTableUpdateCompanionBuilder,
      (PlayerTableData, $$PlayerTableTableReferences),
      PlayerTableData,
      PrefetchHooks Function({
        bool playerGroupTableRefs,
        bool playerMatchTableRefs,
        bool scoreEntryTableRefs,
      })
    >;
typedef $$GroupTableTableCreateCompanionBuilder =
    GroupTableCompanion Function({
      required String id,
      required DateTime createdAt,
      required String name,
      required String description,
      Value<int> rowid,
    });
typedef $$GroupTableTableUpdateCompanionBuilder =
    GroupTableCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<String> name,
      Value<String> description,
      Value<int> rowid,
    });

final class $$GroupTableTableReferences
    extends BaseReferences<_$AppDatabase, $GroupTableTable, GroupTableData> {
  $$GroupTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MatchTableTable, List<MatchTableData>>
  _matchTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.matchTable,
    aliasName: 'group_table__id__match_table__group_id',
  );

  $$MatchTableTableProcessedTableManager get matchTableRefs {
    final manager = $$MatchTableTableTableManager(
      $_db,
      $_db.matchTable,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_matchTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlayerGroupTableTable, List<PlayerGroupTableData>>
  _playerGroupTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playerGroupTable,
    aliasName: 'group_table__id__player_group_table__group_id',
  );

  $$PlayerGroupTableTableProcessedTableManager get playerGroupTableRefs {
    final manager = $$PlayerGroupTableTableTableManager(
      $_db,
      $_db.playerGroupTable,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playerGroupTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StatisticGroupTableTable,
    List<StatisticGroupTableData>
  >
  _statisticGroupTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.statisticGroupTable,
        aliasName: 'group_table__id__statistic_group_table__group_id',
      );

  $$StatisticGroupTableTableProcessedTableManager get statisticGroupTableRefs {
    final manager = $$StatisticGroupTableTableTableManager(
      $_db,
      $_db.statisticGroupTable,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _statisticGroupTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GroupTableTableFilterComposer
    extends Composer<_$AppDatabase, $GroupTableTable> {
  $$GroupTableTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> matchTableRefs(
    Expression<bool> Function($$MatchTableTableFilterComposer f) f,
  ) {
    final $$MatchTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matchTable,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchTableTableFilterComposer(
            $db: $db,
            $table: $db.matchTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> playerGroupTableRefs(
    Expression<bool> Function($$PlayerGroupTableTableFilterComposer f) f,
  ) {
    final $$PlayerGroupTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playerGroupTable,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerGroupTableTableFilterComposer(
            $db: $db,
            $table: $db.playerGroupTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> statisticGroupTableRefs(
    Expression<bool> Function($$StatisticGroupTableTableFilterComposer f) f,
  ) {
    final $$StatisticGroupTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.statisticGroupTable,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatisticGroupTableTableFilterComposer(
            $db: $db,
            $table: $db.statisticGroupTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroupTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupTableTable> {
  $$GroupTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroupTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupTableTable> {
  $$GroupTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  Expression<T> matchTableRefs<T extends Object>(
    Expression<T> Function($$MatchTableTableAnnotationComposer a) f,
  ) {
    final $$MatchTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matchTable,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchTableTableAnnotationComposer(
            $db: $db,
            $table: $db.matchTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> playerGroupTableRefs<T extends Object>(
    Expression<T> Function($$PlayerGroupTableTableAnnotationComposer a) f,
  ) {
    final $$PlayerGroupTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playerGroupTable,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerGroupTableTableAnnotationComposer(
            $db: $db,
            $table: $db.playerGroupTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> statisticGroupTableRefs<T extends Object>(
    Expression<T> Function($$StatisticGroupTableTableAnnotationComposer a) f,
  ) {
    final $$StatisticGroupTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.statisticGroupTable,
          getReferencedColumn: (t) => t.groupId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StatisticGroupTableTableAnnotationComposer(
                $db: $db,
                $table: $db.statisticGroupTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GroupTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupTableTable,
          GroupTableData,
          $$GroupTableTableFilterComposer,
          $$GroupTableTableOrderingComposer,
          $$GroupTableTableAnnotationComposer,
          $$GroupTableTableCreateCompanionBuilder,
          $$GroupTableTableUpdateCompanionBuilder,
          (GroupTableData, $$GroupTableTableReferences),
          GroupTableData,
          PrefetchHooks Function({
            bool matchTableRefs,
            bool playerGroupTableRefs,
            bool statisticGroupTableRefs,
          })
        > {
  $$GroupTableTableTableManager(_$AppDatabase db, $GroupTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupTableCompanion(
                id: id,
                createdAt: createdAt,
                name: name,
                description: description,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required String name,
                required String description,
                Value<int> rowid = const Value.absent(),
              }) => GroupTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                name: name,
                description: description,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GroupTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                matchTableRefs = false,
                playerGroupTableRefs = false,
                statisticGroupTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (matchTableRefs) db.matchTable,
                    if (playerGroupTableRefs) db.playerGroupTable,
                    if (statisticGroupTableRefs) db.statisticGroupTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (matchTableRefs)
                        await $_getPrefetchedData<
                          GroupTableData,
                          $GroupTableTable,
                          MatchTableData
                        >(
                          currentTable: table,
                          referencedTable: $$GroupTableTableReferences
                              ._matchTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupTableTableReferences(
                                db,
                                table,
                                p0,
                              ).matchTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (playerGroupTableRefs)
                        await $_getPrefetchedData<
                          GroupTableData,
                          $GroupTableTable,
                          PlayerGroupTableData
                        >(
                          currentTable: table,
                          referencedTable: $$GroupTableTableReferences
                              ._playerGroupTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupTableTableReferences(
                                db,
                                table,
                                p0,
                              ).playerGroupTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (statisticGroupTableRefs)
                        await $_getPrefetchedData<
                          GroupTableData,
                          $GroupTableTable,
                          StatisticGroupTableData
                        >(
                          currentTable: table,
                          referencedTable: $$GroupTableTableReferences
                              ._statisticGroupTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupTableTableReferences(
                                db,
                                table,
                                p0,
                              ).statisticGroupTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.groupId == item.id,
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

typedef $$GroupTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupTableTable,
      GroupTableData,
      $$GroupTableTableFilterComposer,
      $$GroupTableTableOrderingComposer,
      $$GroupTableTableAnnotationComposer,
      $$GroupTableTableCreateCompanionBuilder,
      $$GroupTableTableUpdateCompanionBuilder,
      (GroupTableData, $$GroupTableTableReferences),
      GroupTableData,
      PrefetchHooks Function({
        bool matchTableRefs,
        bool playerGroupTableRefs,
        bool statisticGroupTableRefs,
      })
    >;
typedef $$GameTableTableCreateCompanionBuilder =
    GameTableCompanion Function({
      required String id,
      required DateTime createdAt,
      required String name,
      required Ruleset ruleset,
      required String description,
      required AppColor color,
      Value<int> rowid,
    });
typedef $$GameTableTableUpdateCompanionBuilder =
    GameTableCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<String> name,
      Value<Ruleset> ruleset,
      Value<String> description,
      Value<AppColor> color,
      Value<int> rowid,
    });

final class $$GameTableTableReferences
    extends BaseReferences<_$AppDatabase, $GameTableTable, GameTableData> {
  $$GameTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MatchTableTable, List<MatchTableData>>
  _matchTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.matchTable,
    aliasName: 'game_table__id__match_table__game_id',
  );

  $$MatchTableTableProcessedTableManager get matchTableRefs {
    final manager = $$MatchTableTableTableManager(
      $_db,
      $_db.matchTable,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_matchTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StatisticGameTableTable,
    List<StatisticGameTableData>
  >
  _statisticGameTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.statisticGameTable,
        aliasName: 'game_table__id__statistic_game_table__game_id',
      );

  $$StatisticGameTableTableProcessedTableManager get statisticGameTableRefs {
    final manager = $$StatisticGameTableTableTableManager(
      $_db,
      $_db.statisticGameTable,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _statisticGameTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GameTableTableFilterComposer
    extends Composer<_$AppDatabase, $GameTableTable> {
  $$GameTableTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Ruleset, Ruleset, String> get ruleset =>
      $composableBuilder(
        column: $table.ruleset,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AppColor, AppColor, String> get color =>
      $composableBuilder(
        column: $table.color,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> matchTableRefs(
    Expression<bool> Function($$MatchTableTableFilterComposer f) f,
  ) {
    final $$MatchTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matchTable,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchTableTableFilterComposer(
            $db: $db,
            $table: $db.matchTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> statisticGameTableRefs(
    Expression<bool> Function($$StatisticGameTableTableFilterComposer f) f,
  ) {
    final $$StatisticGameTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.statisticGameTable,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatisticGameTableTableFilterComposer(
            $db: $db,
            $table: $db.statisticGameTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GameTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GameTableTable> {
  $$GameTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleset => $composableBuilder(
    column: $table.ruleset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameTableTable> {
  $$GameTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Ruleset, String> get ruleset =>
      $composableBuilder(column: $table.ruleset, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AppColor, String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  Expression<T> matchTableRefs<T extends Object>(
    Expression<T> Function($$MatchTableTableAnnotationComposer a) f,
  ) {
    final $$MatchTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matchTable,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchTableTableAnnotationComposer(
            $db: $db,
            $table: $db.matchTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> statisticGameTableRefs<T extends Object>(
    Expression<T> Function($$StatisticGameTableTableAnnotationComposer a) f,
  ) {
    final $$StatisticGameTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.statisticGameTable,
          getReferencedColumn: (t) => t.gameId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StatisticGameTableTableAnnotationComposer(
                $db: $db,
                $table: $db.statisticGameTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GameTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameTableTable,
          GameTableData,
          $$GameTableTableFilterComposer,
          $$GameTableTableOrderingComposer,
          $$GameTableTableAnnotationComposer,
          $$GameTableTableCreateCompanionBuilder,
          $$GameTableTableUpdateCompanionBuilder,
          (GameTableData, $$GameTableTableReferences),
          GameTableData,
          PrefetchHooks Function({
            bool matchTableRefs,
            bool statisticGameTableRefs,
          })
        > {
  $$GameTableTableTableManager(_$AppDatabase db, $GameTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<Ruleset> ruleset = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<AppColor> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameTableCompanion(
                id: id,
                createdAt: createdAt,
                name: name,
                ruleset: ruleset,
                description: description,
                color: color,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required String name,
                required Ruleset ruleset,
                required String description,
                required AppColor color,
                Value<int> rowid = const Value.absent(),
              }) => GameTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                name: name,
                ruleset: ruleset,
                description: description,
                color: color,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GameTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({matchTableRefs = false, statisticGameTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (matchTableRefs) db.matchTable,
                    if (statisticGameTableRefs) db.statisticGameTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (matchTableRefs)
                        await $_getPrefetchedData<
                          GameTableData,
                          $GameTableTable,
                          MatchTableData
                        >(
                          currentTable: table,
                          referencedTable: $$GameTableTableReferences
                              ._matchTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GameTableTableReferences(
                                db,
                                table,
                                p0,
                              ).matchTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (statisticGameTableRefs)
                        await $_getPrefetchedData<
                          GameTableData,
                          $GameTableTable,
                          StatisticGameTableData
                        >(
                          currentTable: table,
                          referencedTable: $$GameTableTableReferences
                              ._statisticGameTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GameTableTableReferences(
                                db,
                                table,
                                p0,
                              ).statisticGameTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.id,
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

typedef $$GameTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameTableTable,
      GameTableData,
      $$GameTableTableFilterComposer,
      $$GameTableTableOrderingComposer,
      $$GameTableTableAnnotationComposer,
      $$GameTableTableCreateCompanionBuilder,
      $$GameTableTableUpdateCompanionBuilder,
      (GameTableData, $$GameTableTableReferences),
      GameTableData,
      PrefetchHooks Function({bool matchTableRefs, bool statisticGameTableRefs})
    >;
typedef $$MatchTableTableCreateCompanionBuilder =
    MatchTableCompanion Function({
      required String id,
      required DateTime createdAt,
      required String name,
      required String gameId,
      Value<String?> groupId,
      Value<bool> isTeamMatch,
      required String notes,
      Value<DateTime?> endedAt,
      Value<int> rowid,
    });
typedef $$MatchTableTableUpdateCompanionBuilder =
    MatchTableCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<String> name,
      Value<String> gameId,
      Value<String?> groupId,
      Value<bool> isTeamMatch,
      Value<String> notes,
      Value<DateTime?> endedAt,
      Value<int> rowid,
    });

final class $$MatchTableTableReferences
    extends BaseReferences<_$AppDatabase, $MatchTableTable, MatchTableData> {
  $$MatchTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GameTableTable _gameIdTable(_$AppDatabase db) =>
      db.gameTable.createAlias('match_table__game_id__game_table__id');

  $$GameTableTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GameTableTableTableManager(
      $_db,
      $_db.gameTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GroupTableTable _groupIdTable(_$AppDatabase db) =>
      db.groupTable.createAlias('match_table__group_id__group_table__id');

  $$GroupTableTableProcessedTableManager? get groupId {
    final $_column = $_itemColumn<String>('group_id');
    if ($_column == null) return null;
    final manager = $$GroupTableTableTableManager(
      $_db,
      $_db.groupTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PlayerMatchTableTable, List<PlayerMatchTableData>>
  _playerMatchTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playerMatchTable,
    aliasName: 'match_table__id__player_match_table__match_id',
  );

  $$PlayerMatchTableTableProcessedTableManager get playerMatchTableRefs {
    final manager = $$PlayerMatchTableTableTableManager(
      $_db,
      $_db.playerMatchTable,
    ).filter((f) => f.matchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playerMatchTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScoreEntryTableTable, List<ScoreEntryTableData>>
  _scoreEntryTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scoreEntryTable,
    aliasName: 'match_table__id__score_entry_table__match_id',
  );

  $$ScoreEntryTableTableProcessedTableManager get scoreEntryTableRefs {
    final manager = $$ScoreEntryTableTableTableManager(
      $_db,
      $_db.scoreEntryTable,
    ).filter((f) => f.matchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _scoreEntryTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MatchTableTableFilterComposer
    extends Composer<_$AppDatabase, $MatchTableTable> {
  $$MatchTableTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTeamMatch => $composableBuilder(
    column: $table.isTeamMatch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GameTableTableFilterComposer get gameId {
    final $$GameTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.gameTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameTableTableFilterComposer(
            $db: $db,
            $table: $db.gameTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupTableTableFilterComposer get groupId {
    final $$GroupTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupTableTableFilterComposer(
            $db: $db,
            $table: $db.groupTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> playerMatchTableRefs(
    Expression<bool> Function($$PlayerMatchTableTableFilterComposer f) f,
  ) {
    final $$PlayerMatchTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playerMatchTable,
      getReferencedColumn: (t) => t.matchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerMatchTableTableFilterComposer(
            $db: $db,
            $table: $db.playerMatchTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scoreEntryTableRefs(
    Expression<bool> Function($$ScoreEntryTableTableFilterComposer f) f,
  ) {
    final $$ScoreEntryTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scoreEntryTable,
      getReferencedColumn: (t) => t.matchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScoreEntryTableTableFilterComposer(
            $db: $db,
            $table: $db.scoreEntryTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MatchTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchTableTable> {
  $$MatchTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTeamMatch => $composableBuilder(
    column: $table.isTeamMatch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GameTableTableOrderingComposer get gameId {
    final $$GameTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.gameTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameTableTableOrderingComposer(
            $db: $db,
            $table: $db.gameTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupTableTableOrderingComposer get groupId {
    final $$GroupTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupTableTableOrderingComposer(
            $db: $db,
            $table: $db.groupTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MatchTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchTableTable> {
  $$MatchTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isTeamMatch => $composableBuilder(
    column: $table.isTeamMatch,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  $$GameTableTableAnnotationComposer get gameId {
    final $$GameTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.gameTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameTableTableAnnotationComposer(
            $db: $db,
            $table: $db.gameTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupTableTableAnnotationComposer get groupId {
    final $$GroupTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupTableTableAnnotationComposer(
            $db: $db,
            $table: $db.groupTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> playerMatchTableRefs<T extends Object>(
    Expression<T> Function($$PlayerMatchTableTableAnnotationComposer a) f,
  ) {
    final $$PlayerMatchTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playerMatchTable,
      getReferencedColumn: (t) => t.matchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerMatchTableTableAnnotationComposer(
            $db: $db,
            $table: $db.playerMatchTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> scoreEntryTableRefs<T extends Object>(
    Expression<T> Function($$ScoreEntryTableTableAnnotationComposer a) f,
  ) {
    final $$ScoreEntryTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scoreEntryTable,
      getReferencedColumn: (t) => t.matchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScoreEntryTableTableAnnotationComposer(
            $db: $db,
            $table: $db.scoreEntryTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MatchTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MatchTableTable,
          MatchTableData,
          $$MatchTableTableFilterComposer,
          $$MatchTableTableOrderingComposer,
          $$MatchTableTableAnnotationComposer,
          $$MatchTableTableCreateCompanionBuilder,
          $$MatchTableTableUpdateCompanionBuilder,
          (MatchTableData, $$MatchTableTableReferences),
          MatchTableData,
          PrefetchHooks Function({
            bool gameId,
            bool groupId,
            bool playerMatchTableRefs,
            bool scoreEntryTableRefs,
          })
        > {
  $$MatchTableTableTableManager(_$AppDatabase db, $MatchTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<bool> isTeamMatch = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchTableCompanion(
                id: id,
                createdAt: createdAt,
                name: name,
                gameId: gameId,
                groupId: groupId,
                isTeamMatch: isTeamMatch,
                notes: notes,
                endedAt: endedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required String name,
                required String gameId,
                Value<String?> groupId = const Value.absent(),
                Value<bool> isTeamMatch = const Value.absent(),
                required String notes,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                name: name,
                gameId: gameId,
                groupId: groupId,
                isTeamMatch: isTeamMatch,
                notes: notes,
                endedAt: endedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MatchTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gameId = false,
                groupId = false,
                playerMatchTableRefs = false,
                scoreEntryTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playerMatchTableRefs) db.playerMatchTable,
                    if (scoreEntryTableRefs) db.scoreEntryTable,
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
                        if (gameId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gameId,
                                    referencedTable: $$MatchTableTableReferences
                                        ._gameIdTable(db),
                                    referencedColumn:
                                        $$MatchTableTableReferences
                                            ._gameIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (groupId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.groupId,
                                    referencedTable: $$MatchTableTableReferences
                                        ._groupIdTable(db),
                                    referencedColumn:
                                        $$MatchTableTableReferences
                                            ._groupIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (playerMatchTableRefs)
                        await $_getPrefetchedData<
                          MatchTableData,
                          $MatchTableTable,
                          PlayerMatchTableData
                        >(
                          currentTable: table,
                          referencedTable: $$MatchTableTableReferences
                              ._playerMatchTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MatchTableTableReferences(
                                db,
                                table,
                                p0,
                              ).playerMatchTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.matchId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scoreEntryTableRefs)
                        await $_getPrefetchedData<
                          MatchTableData,
                          $MatchTableTable,
                          ScoreEntryTableData
                        >(
                          currentTable: table,
                          referencedTable: $$MatchTableTableReferences
                              ._scoreEntryTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MatchTableTableReferences(
                                db,
                                table,
                                p0,
                              ).scoreEntryTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.matchId == item.id,
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

typedef $$MatchTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MatchTableTable,
      MatchTableData,
      $$MatchTableTableFilterComposer,
      $$MatchTableTableOrderingComposer,
      $$MatchTableTableAnnotationComposer,
      $$MatchTableTableCreateCompanionBuilder,
      $$MatchTableTableUpdateCompanionBuilder,
      (MatchTableData, $$MatchTableTableReferences),
      MatchTableData,
      PrefetchHooks Function({
        bool gameId,
        bool groupId,
        bool playerMatchTableRefs,
        bool scoreEntryTableRefs,
      })
    >;
typedef $$PlayerGroupTableTableCreateCompanionBuilder =
    PlayerGroupTableCompanion Function({
      required String playerId,
      required String groupId,
      Value<int> rowid,
    });
typedef $$PlayerGroupTableTableUpdateCompanionBuilder =
    PlayerGroupTableCompanion Function({
      Value<String> playerId,
      Value<String> groupId,
      Value<int> rowid,
    });

final class $$PlayerGroupTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlayerGroupTableTable,
          PlayerGroupTableData
        > {
  $$PlayerGroupTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlayerTableTable _playerIdTable(_$AppDatabase db) => db.playerTable
      .createAlias('player_group_table__player_id__player_table__id');

  $$PlayerTableTableProcessedTableManager get playerId {
    final $_column = $_itemColumn<String>('player_id')!;

    final manager = $$PlayerTableTableTableManager(
      $_db,
      $_db.playerTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GroupTableTable _groupIdTable(_$AppDatabase db) => db.groupTable
      .createAlias('player_group_table__group_id__group_table__id');

  $$GroupTableTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$GroupTableTableTableManager(
      $_db,
      $_db.groupTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlayerGroupTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerGroupTableTable> {
  $$PlayerGroupTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PlayerTableTableFilterComposer get playerId {
    final $$PlayerTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.playerTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerTableTableFilterComposer(
            $db: $db,
            $table: $db.playerTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupTableTableFilterComposer get groupId {
    final $$GroupTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupTableTableFilterComposer(
            $db: $db,
            $table: $db.groupTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayerGroupTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerGroupTableTable> {
  $$PlayerGroupTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PlayerTableTableOrderingComposer get playerId {
    final $$PlayerTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.playerTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerTableTableOrderingComposer(
            $db: $db,
            $table: $db.playerTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupTableTableOrderingComposer get groupId {
    final $$GroupTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupTableTableOrderingComposer(
            $db: $db,
            $table: $db.groupTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayerGroupTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerGroupTableTable> {
  $$PlayerGroupTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PlayerTableTableAnnotationComposer get playerId {
    final $$PlayerTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.playerTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerTableTableAnnotationComposer(
            $db: $db,
            $table: $db.playerTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupTableTableAnnotationComposer get groupId {
    final $$GroupTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupTableTableAnnotationComposer(
            $db: $db,
            $table: $db.groupTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayerGroupTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerGroupTableTable,
          PlayerGroupTableData,
          $$PlayerGroupTableTableFilterComposer,
          $$PlayerGroupTableTableOrderingComposer,
          $$PlayerGroupTableTableAnnotationComposer,
          $$PlayerGroupTableTableCreateCompanionBuilder,
          $$PlayerGroupTableTableUpdateCompanionBuilder,
          (PlayerGroupTableData, $$PlayerGroupTableTableReferences),
          PlayerGroupTableData,
          PrefetchHooks Function({bool playerId, bool groupId})
        > {
  $$PlayerGroupTableTableTableManager(
    _$AppDatabase db,
    $PlayerGroupTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerGroupTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerGroupTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerGroupTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> playerId = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayerGroupTableCompanion(
                playerId: playerId,
                groupId: groupId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playerId,
                required String groupId,
                Value<int> rowid = const Value.absent(),
              }) => PlayerGroupTableCompanion.insert(
                playerId: playerId,
                groupId: groupId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlayerGroupTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playerId = false, groupId = false}) {
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
                    if (playerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playerId,
                                referencedTable:
                                    $$PlayerGroupTableTableReferences
                                        ._playerIdTable(db),
                                referencedColumn:
                                    $$PlayerGroupTableTableReferences
                                        ._playerIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (groupId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.groupId,
                                referencedTable:
                                    $$PlayerGroupTableTableReferences
                                        ._groupIdTable(db),
                                referencedColumn:
                                    $$PlayerGroupTableTableReferences
                                        ._groupIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$PlayerGroupTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerGroupTableTable,
      PlayerGroupTableData,
      $$PlayerGroupTableTableFilterComposer,
      $$PlayerGroupTableTableOrderingComposer,
      $$PlayerGroupTableTableAnnotationComposer,
      $$PlayerGroupTableTableCreateCompanionBuilder,
      $$PlayerGroupTableTableUpdateCompanionBuilder,
      (PlayerGroupTableData, $$PlayerGroupTableTableReferences),
      PlayerGroupTableData,
      PrefetchHooks Function({bool playerId, bool groupId})
    >;
typedef $$TeamTableTableCreateCompanionBuilder =
    TeamTableCompanion Function({
      required String id,
      required DateTime createdAt,
      required String name,
      Value<AppColor> color,
      Value<int?> score,
      Value<int> rowid,
    });
typedef $$TeamTableTableUpdateCompanionBuilder =
    TeamTableCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<String> name,
      Value<AppColor> color,
      Value<int?> score,
      Value<int> rowid,
    });

final class $$TeamTableTableReferences
    extends BaseReferences<_$AppDatabase, $TeamTableTable, TeamTableData> {
  $$TeamTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlayerMatchTableTable, List<PlayerMatchTableData>>
  _playerMatchTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playerMatchTable,
    aliasName: 'team_table__id__player_match_table__team_id',
  );

  $$PlayerMatchTableTableProcessedTableManager get playerMatchTableRefs {
    final manager = $$PlayerMatchTableTableTableManager(
      $_db,
      $_db.playerMatchTable,
    ).filter((f) => f.teamId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playerMatchTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TeamTableTableFilterComposer
    extends Composer<_$AppDatabase, $TeamTableTable> {
  $$TeamTableTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AppColor, AppColor, String> get color =>
      $composableBuilder(
        column: $table.color,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playerMatchTableRefs(
    Expression<bool> Function($$PlayerMatchTableTableFilterComposer f) f,
  ) {
    final $$PlayerMatchTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playerMatchTable,
      getReferencedColumn: (t) => t.teamId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerMatchTableTableFilterComposer(
            $db: $db,
            $table: $db.playerMatchTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TeamTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamTableTable> {
  $$TeamTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeamTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamTableTable> {
  $$TeamTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AppColor, String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  Expression<T> playerMatchTableRefs<T extends Object>(
    Expression<T> Function($$PlayerMatchTableTableAnnotationComposer a) f,
  ) {
    final $$PlayerMatchTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playerMatchTable,
      getReferencedColumn: (t) => t.teamId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerMatchTableTableAnnotationComposer(
            $db: $db,
            $table: $db.playerMatchTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TeamTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeamTableTable,
          TeamTableData,
          $$TeamTableTableFilterComposer,
          $$TeamTableTableOrderingComposer,
          $$TeamTableTableAnnotationComposer,
          $$TeamTableTableCreateCompanionBuilder,
          $$TeamTableTableUpdateCompanionBuilder,
          (TeamTableData, $$TeamTableTableReferences),
          TeamTableData,
          PrefetchHooks Function({bool playerMatchTableRefs})
        > {
  $$TeamTableTableTableManager(_$AppDatabase db, $TeamTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<AppColor> color = const Value.absent(),
                Value<int?> score = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamTableCompanion(
                id: id,
                createdAt: createdAt,
                name: name,
                color: color,
                score: score,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required String name,
                Value<AppColor> color = const Value.absent(),
                Value<int?> score = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                name: name,
                color: color,
                score: score,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TeamTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playerMatchTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playerMatchTableRefs) db.playerMatchTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playerMatchTableRefs)
                    await $_getPrefetchedData<
                      TeamTableData,
                      $TeamTableTable,
                      PlayerMatchTableData
                    >(
                      currentTable: table,
                      referencedTable: $$TeamTableTableReferences
                          ._playerMatchTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TeamTableTableReferences(
                            db,
                            table,
                            p0,
                          ).playerMatchTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.teamId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TeamTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeamTableTable,
      TeamTableData,
      $$TeamTableTableFilterComposer,
      $$TeamTableTableOrderingComposer,
      $$TeamTableTableAnnotationComposer,
      $$TeamTableTableCreateCompanionBuilder,
      $$TeamTableTableUpdateCompanionBuilder,
      (TeamTableData, $$TeamTableTableReferences),
      TeamTableData,
      PrefetchHooks Function({bool playerMatchTableRefs})
    >;
typedef $$PlayerMatchTableTableCreateCompanionBuilder =
    PlayerMatchTableCompanion Function({
      required String playerId,
      required String matchId,
      Value<String?> teamId,
      Value<int> rowid,
    });
typedef $$PlayerMatchTableTableUpdateCompanionBuilder =
    PlayerMatchTableCompanion Function({
      Value<String> playerId,
      Value<String> matchId,
      Value<String?> teamId,
      Value<int> rowid,
    });

final class $$PlayerMatchTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlayerMatchTableTable,
          PlayerMatchTableData
        > {
  $$PlayerMatchTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlayerTableTable _playerIdTable(_$AppDatabase db) => db.playerTable
      .createAlias('player_match_table__player_id__player_table__id');

  $$PlayerTableTableProcessedTableManager get playerId {
    final $_column = $_itemColumn<String>('player_id')!;

    final manager = $$PlayerTableTableTableManager(
      $_db,
      $_db.playerTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MatchTableTable _matchIdTable(_$AppDatabase db) => db.matchTable
      .createAlias('player_match_table__match_id__match_table__id');

  $$MatchTableTableProcessedTableManager get matchId {
    final $_column = $_itemColumn<String>('match_id')!;

    final manager = $$MatchTableTableTableManager(
      $_db,
      $_db.matchTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_matchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TeamTableTable _teamIdTable(_$AppDatabase db) =>
      db.teamTable.createAlias('player_match_table__team_id__team_table__id');

  $$TeamTableTableProcessedTableManager? get teamId {
    final $_column = $_itemColumn<String>('team_id');
    if ($_column == null) return null;
    final manager = $$TeamTableTableTableManager(
      $_db,
      $_db.teamTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_teamIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlayerMatchTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerMatchTableTable> {
  $$PlayerMatchTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PlayerTableTableFilterComposer get playerId {
    final $$PlayerTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.playerTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerTableTableFilterComposer(
            $db: $db,
            $table: $db.playerTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MatchTableTableFilterComposer get matchId {
    final $$MatchTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.matchTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchTableTableFilterComposer(
            $db: $db,
            $table: $db.matchTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TeamTableTableFilterComposer get teamId {
    final $$TeamTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teamId,
      referencedTable: $db.teamTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamTableTableFilterComposer(
            $db: $db,
            $table: $db.teamTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayerMatchTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerMatchTableTable> {
  $$PlayerMatchTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PlayerTableTableOrderingComposer get playerId {
    final $$PlayerTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.playerTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerTableTableOrderingComposer(
            $db: $db,
            $table: $db.playerTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MatchTableTableOrderingComposer get matchId {
    final $$MatchTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.matchTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchTableTableOrderingComposer(
            $db: $db,
            $table: $db.matchTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TeamTableTableOrderingComposer get teamId {
    final $$TeamTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teamId,
      referencedTable: $db.teamTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamTableTableOrderingComposer(
            $db: $db,
            $table: $db.teamTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayerMatchTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerMatchTableTable> {
  $$PlayerMatchTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PlayerTableTableAnnotationComposer get playerId {
    final $$PlayerTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.playerTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerTableTableAnnotationComposer(
            $db: $db,
            $table: $db.playerTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MatchTableTableAnnotationComposer get matchId {
    final $$MatchTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.matchTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchTableTableAnnotationComposer(
            $db: $db,
            $table: $db.matchTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TeamTableTableAnnotationComposer get teamId {
    final $$TeamTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teamId,
      referencedTable: $db.teamTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeamTableTableAnnotationComposer(
            $db: $db,
            $table: $db.teamTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayerMatchTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerMatchTableTable,
          PlayerMatchTableData,
          $$PlayerMatchTableTableFilterComposer,
          $$PlayerMatchTableTableOrderingComposer,
          $$PlayerMatchTableTableAnnotationComposer,
          $$PlayerMatchTableTableCreateCompanionBuilder,
          $$PlayerMatchTableTableUpdateCompanionBuilder,
          (PlayerMatchTableData, $$PlayerMatchTableTableReferences),
          PlayerMatchTableData,
          PrefetchHooks Function({bool playerId, bool matchId, bool teamId})
        > {
  $$PlayerMatchTableTableTableManager(
    _$AppDatabase db,
    $PlayerMatchTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerMatchTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerMatchTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerMatchTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> playerId = const Value.absent(),
                Value<String> matchId = const Value.absent(),
                Value<String?> teamId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayerMatchTableCompanion(
                playerId: playerId,
                matchId: matchId,
                teamId: teamId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playerId,
                required String matchId,
                Value<String?> teamId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayerMatchTableCompanion.insert(
                playerId: playerId,
                matchId: matchId,
                teamId: teamId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlayerMatchTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({playerId = false, matchId = false, teamId = false}) {
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
                        if (playerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.playerId,
                                    referencedTable:
                                        $$PlayerMatchTableTableReferences
                                            ._playerIdTable(db),
                                    referencedColumn:
                                        $$PlayerMatchTableTableReferences
                                            ._playerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (matchId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.matchId,
                                    referencedTable:
                                        $$PlayerMatchTableTableReferences
                                            ._matchIdTable(db),
                                    referencedColumn:
                                        $$PlayerMatchTableTableReferences
                                            ._matchIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (teamId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.teamId,
                                    referencedTable:
                                        $$PlayerMatchTableTableReferences
                                            ._teamIdTable(db),
                                    referencedColumn:
                                        $$PlayerMatchTableTableReferences
                                            ._teamIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$PlayerMatchTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerMatchTableTable,
      PlayerMatchTableData,
      $$PlayerMatchTableTableFilterComposer,
      $$PlayerMatchTableTableOrderingComposer,
      $$PlayerMatchTableTableAnnotationComposer,
      $$PlayerMatchTableTableCreateCompanionBuilder,
      $$PlayerMatchTableTableUpdateCompanionBuilder,
      (PlayerMatchTableData, $$PlayerMatchTableTableReferences),
      PlayerMatchTableData,
      PrefetchHooks Function({bool playerId, bool matchId, bool teamId})
    >;
typedef $$ScoreEntryTableTableCreateCompanionBuilder =
    ScoreEntryTableCompanion Function({
      required String playerId,
      required String matchId,
      required int roundNumber,
      required int score,
      required int change,
      Value<int> rowid,
    });
typedef $$ScoreEntryTableTableUpdateCompanionBuilder =
    ScoreEntryTableCompanion Function({
      Value<String> playerId,
      Value<String> matchId,
      Value<int> roundNumber,
      Value<int> score,
      Value<int> change,
      Value<int> rowid,
    });

final class $$ScoreEntryTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ScoreEntryTableTable,
          ScoreEntryTableData
        > {
  $$ScoreEntryTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlayerTableTable _playerIdTable(_$AppDatabase db) => db.playerTable
      .createAlias('score_entry_table__player_id__player_table__id');

  $$PlayerTableTableProcessedTableManager get playerId {
    final $_column = $_itemColumn<String>('player_id')!;

    final manager = $$PlayerTableTableTableManager(
      $_db,
      $_db.playerTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MatchTableTable _matchIdTable(_$AppDatabase db) =>
      db.matchTable.createAlias('score_entry_table__match_id__match_table__id');

  $$MatchTableTableProcessedTableManager get matchId {
    final $_column = $_itemColumn<String>('match_id')!;

    final manager = $$MatchTableTableTableManager(
      $_db,
      $_db.matchTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_matchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScoreEntryTableTableFilterComposer
    extends Composer<_$AppDatabase, $ScoreEntryTableTable> {
  $$ScoreEntryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get roundNumber => $composableBuilder(
    column: $table.roundNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get change => $composableBuilder(
    column: $table.change,
    builder: (column) => ColumnFilters(column),
  );

  $$PlayerTableTableFilterComposer get playerId {
    final $$PlayerTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.playerTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerTableTableFilterComposer(
            $db: $db,
            $table: $db.playerTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MatchTableTableFilterComposer get matchId {
    final $$MatchTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.matchTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchTableTableFilterComposer(
            $db: $db,
            $table: $db.matchTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScoreEntryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ScoreEntryTableTable> {
  $$ScoreEntryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get roundNumber => $composableBuilder(
    column: $table.roundNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get change => $composableBuilder(
    column: $table.change,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlayerTableTableOrderingComposer get playerId {
    final $$PlayerTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.playerTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerTableTableOrderingComposer(
            $db: $db,
            $table: $db.playerTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MatchTableTableOrderingComposer get matchId {
    final $$MatchTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.matchTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchTableTableOrderingComposer(
            $db: $db,
            $table: $db.matchTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScoreEntryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScoreEntryTableTable> {
  $$ScoreEntryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get roundNumber => $composableBuilder(
    column: $table.roundNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get change =>
      $composableBuilder(column: $table.change, builder: (column) => column);

  $$PlayerTableTableAnnotationComposer get playerId {
    final $$PlayerTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.playerTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerTableTableAnnotationComposer(
            $db: $db,
            $table: $db.playerTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MatchTableTableAnnotationComposer get matchId {
    final $$MatchTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.matchTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchTableTableAnnotationComposer(
            $db: $db,
            $table: $db.matchTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScoreEntryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScoreEntryTableTable,
          ScoreEntryTableData,
          $$ScoreEntryTableTableFilterComposer,
          $$ScoreEntryTableTableOrderingComposer,
          $$ScoreEntryTableTableAnnotationComposer,
          $$ScoreEntryTableTableCreateCompanionBuilder,
          $$ScoreEntryTableTableUpdateCompanionBuilder,
          (ScoreEntryTableData, $$ScoreEntryTableTableReferences),
          ScoreEntryTableData,
          PrefetchHooks Function({bool playerId, bool matchId})
        > {
  $$ScoreEntryTableTableTableManager(
    _$AppDatabase db,
    $ScoreEntryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScoreEntryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScoreEntryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScoreEntryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> playerId = const Value.absent(),
                Value<String> matchId = const Value.absent(),
                Value<int> roundNumber = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> change = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScoreEntryTableCompanion(
                playerId: playerId,
                matchId: matchId,
                roundNumber: roundNumber,
                score: score,
                change: change,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playerId,
                required String matchId,
                required int roundNumber,
                required int score,
                required int change,
                Value<int> rowid = const Value.absent(),
              }) => ScoreEntryTableCompanion.insert(
                playerId: playerId,
                matchId: matchId,
                roundNumber: roundNumber,
                score: score,
                change: change,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScoreEntryTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playerId = false, matchId = false}) {
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
                    if (playerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playerId,
                                referencedTable:
                                    $$ScoreEntryTableTableReferences
                                        ._playerIdTable(db),
                                referencedColumn:
                                    $$ScoreEntryTableTableReferences
                                        ._playerIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (matchId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.matchId,
                                referencedTable:
                                    $$ScoreEntryTableTableReferences
                                        ._matchIdTable(db),
                                referencedColumn:
                                    $$ScoreEntryTableTableReferences
                                        ._matchIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$ScoreEntryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScoreEntryTableTable,
      ScoreEntryTableData,
      $$ScoreEntryTableTableFilterComposer,
      $$ScoreEntryTableTableOrderingComposer,
      $$ScoreEntryTableTableAnnotationComposer,
      $$ScoreEntryTableTableCreateCompanionBuilder,
      $$ScoreEntryTableTableUpdateCompanionBuilder,
      (ScoreEntryTableData, $$ScoreEntryTableTableReferences),
      ScoreEntryTableData,
      PrefetchHooks Function({bool playerId, bool matchId})
    >;
typedef $$StatisticTableTableCreateCompanionBuilder =
    StatisticTableCompanion Function({
      required String id,
      required DateTime createdAt,
      required StatisticType type,
      required Timeframe timeframe,
      required AppColor color,
      Value<int> displayCount,
      Value<bool> isFavourite,
      Value<int> position,
      Value<int> rowid,
    });
typedef $$StatisticTableTableUpdateCompanionBuilder =
    StatisticTableCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<StatisticType> type,
      Value<Timeframe> timeframe,
      Value<AppColor> color,
      Value<int> displayCount,
      Value<bool> isFavourite,
      Value<int> position,
      Value<int> rowid,
    });

final class $$StatisticTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StatisticTableTable,
          StatisticTableData
        > {
  $$StatisticTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $StatisticScopeTableTable,
    List<StatisticScopeTableData>
  >
  _statisticScopeTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.statisticScopeTable,
        aliasName: 'statistic_table__id__statistic_scope_table__statistic_id',
      );

  $$StatisticScopeTableTableProcessedTableManager get statisticScopeTableRefs {
    final manager = $$StatisticScopeTableTableTableManager(
      $_db,
      $_db.statisticScopeTable,
    ).filter((f) => f.statisticId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _statisticScopeTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StatisticGameTableTable,
    List<StatisticGameTableData>
  >
  _statisticGameTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.statisticGameTable,
        aliasName: 'statistic_table__id__statistic_game_table__statistic_id',
      );

  $$StatisticGameTableTableProcessedTableManager get statisticGameTableRefs {
    final manager = $$StatisticGameTableTableTableManager(
      $_db,
      $_db.statisticGameTable,
    ).filter((f) => f.statisticId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _statisticGameTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StatisticGroupTableTable,
    List<StatisticGroupTableData>
  >
  _statisticGroupTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.statisticGroupTable,
        aliasName: 'statistic_table__id__statistic_group_table__statistic_id',
      );

  $$StatisticGroupTableTableProcessedTableManager get statisticGroupTableRefs {
    final manager = $$StatisticGroupTableTableTableManager(
      $_db,
      $_db.statisticGroupTable,
    ).filter((f) => f.statisticId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _statisticGroupTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StatisticTableTableFilterComposer
    extends Composer<_$AppDatabase, $StatisticTableTable> {
  $$StatisticTableTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StatisticType, StatisticType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Timeframe, Timeframe, String> get timeframe =>
      $composableBuilder(
        column: $table.timeframe,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<AppColor, AppColor, String> get color =>
      $composableBuilder(
        column: $table.color,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get displayCount => $composableBuilder(
    column: $table.displayCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> statisticScopeTableRefs(
    Expression<bool> Function($$StatisticScopeTableTableFilterComposer f) f,
  ) {
    final $$StatisticScopeTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.statisticScopeTable,
      getReferencedColumn: (t) => t.statisticId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatisticScopeTableTableFilterComposer(
            $db: $db,
            $table: $db.statisticScopeTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> statisticGameTableRefs(
    Expression<bool> Function($$StatisticGameTableTableFilterComposer f) f,
  ) {
    final $$StatisticGameTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.statisticGameTable,
      getReferencedColumn: (t) => t.statisticId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatisticGameTableTableFilterComposer(
            $db: $db,
            $table: $db.statisticGameTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> statisticGroupTableRefs(
    Expression<bool> Function($$StatisticGroupTableTableFilterComposer f) f,
  ) {
    final $$StatisticGroupTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.statisticGroupTable,
      getReferencedColumn: (t) => t.statisticId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatisticGroupTableTableFilterComposer(
            $db: $db,
            $table: $db.statisticGroupTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StatisticTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StatisticTableTable> {
  $$StatisticTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeframe => $composableBuilder(
    column: $table.timeframe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayCount => $composableBuilder(
    column: $table.displayCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StatisticTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatisticTableTable> {
  $$StatisticTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<StatisticType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Timeframe, String> get timeframe =>
      $composableBuilder(column: $table.timeframe, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AppColor, String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get displayCount => $composableBuilder(
    column: $table.displayCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  Expression<T> statisticScopeTableRefs<T extends Object>(
    Expression<T> Function($$StatisticScopeTableTableAnnotationComposer a) f,
  ) {
    final $$StatisticScopeTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.statisticScopeTable,
          getReferencedColumn: (t) => t.statisticId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StatisticScopeTableTableAnnotationComposer(
                $db: $db,
                $table: $db.statisticScopeTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> statisticGameTableRefs<T extends Object>(
    Expression<T> Function($$StatisticGameTableTableAnnotationComposer a) f,
  ) {
    final $$StatisticGameTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.statisticGameTable,
          getReferencedColumn: (t) => t.statisticId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StatisticGameTableTableAnnotationComposer(
                $db: $db,
                $table: $db.statisticGameTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> statisticGroupTableRefs<T extends Object>(
    Expression<T> Function($$StatisticGroupTableTableAnnotationComposer a) f,
  ) {
    final $$StatisticGroupTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.statisticGroupTable,
          getReferencedColumn: (t) => t.statisticId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StatisticGroupTableTableAnnotationComposer(
                $db: $db,
                $table: $db.statisticGroupTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StatisticTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StatisticTableTable,
          StatisticTableData,
          $$StatisticTableTableFilterComposer,
          $$StatisticTableTableOrderingComposer,
          $$StatisticTableTableAnnotationComposer,
          $$StatisticTableTableCreateCompanionBuilder,
          $$StatisticTableTableUpdateCompanionBuilder,
          (StatisticTableData, $$StatisticTableTableReferences),
          StatisticTableData,
          PrefetchHooks Function({
            bool statisticScopeTableRefs,
            bool statisticGameTableRefs,
            bool statisticGroupTableRefs,
          })
        > {
  $$StatisticTableTableTableManager(
    _$AppDatabase db,
    $StatisticTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatisticTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatisticTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatisticTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<StatisticType> type = const Value.absent(),
                Value<Timeframe> timeframe = const Value.absent(),
                Value<AppColor> color = const Value.absent(),
                Value<int> displayCount = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StatisticTableCompanion(
                id: id,
                createdAt: createdAt,
                type: type,
                timeframe: timeframe,
                color: color,
                displayCount: displayCount,
                isFavourite: isFavourite,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required StatisticType type,
                required Timeframe timeframe,
                required AppColor color,
                Value<int> displayCount = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StatisticTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                type: type,
                timeframe: timeframe,
                color: color,
                displayCount: displayCount,
                isFavourite: isFavourite,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StatisticTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                statisticScopeTableRefs = false,
                statisticGameTableRefs = false,
                statisticGroupTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (statisticScopeTableRefs) db.statisticScopeTable,
                    if (statisticGameTableRefs) db.statisticGameTable,
                    if (statisticGroupTableRefs) db.statisticGroupTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (statisticScopeTableRefs)
                        await $_getPrefetchedData<
                          StatisticTableData,
                          $StatisticTableTable,
                          StatisticScopeTableData
                        >(
                          currentTable: table,
                          referencedTable: $$StatisticTableTableReferences
                              ._statisticScopeTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StatisticTableTableReferences(
                                db,
                                table,
                                p0,
                              ).statisticScopeTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.statisticId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (statisticGameTableRefs)
                        await $_getPrefetchedData<
                          StatisticTableData,
                          $StatisticTableTable,
                          StatisticGameTableData
                        >(
                          currentTable: table,
                          referencedTable: $$StatisticTableTableReferences
                              ._statisticGameTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StatisticTableTableReferences(
                                db,
                                table,
                                p0,
                              ).statisticGameTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.statisticId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (statisticGroupTableRefs)
                        await $_getPrefetchedData<
                          StatisticTableData,
                          $StatisticTableTable,
                          StatisticGroupTableData
                        >(
                          currentTable: table,
                          referencedTable: $$StatisticTableTableReferences
                              ._statisticGroupTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StatisticTableTableReferences(
                                db,
                                table,
                                p0,
                              ).statisticGroupTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.statisticId == item.id,
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

typedef $$StatisticTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StatisticTableTable,
      StatisticTableData,
      $$StatisticTableTableFilterComposer,
      $$StatisticTableTableOrderingComposer,
      $$StatisticTableTableAnnotationComposer,
      $$StatisticTableTableCreateCompanionBuilder,
      $$StatisticTableTableUpdateCompanionBuilder,
      (StatisticTableData, $$StatisticTableTableReferences),
      StatisticTableData,
      PrefetchHooks Function({
        bool statisticScopeTableRefs,
        bool statisticGameTableRefs,
        bool statisticGroupTableRefs,
      })
    >;
typedef $$StatisticScopeTableTableCreateCompanionBuilder =
    StatisticScopeTableCompanion Function({
      required String statisticId,
      required StatisticScope scope,
      Value<int> rowid,
    });
typedef $$StatisticScopeTableTableUpdateCompanionBuilder =
    StatisticScopeTableCompanion Function({
      Value<String> statisticId,
      Value<StatisticScope> scope,
      Value<int> rowid,
    });

final class $$StatisticScopeTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StatisticScopeTableTable,
          StatisticScopeTableData
        > {
  $$StatisticScopeTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StatisticTableTable _statisticIdTable(_$AppDatabase db) => db
      .statisticTable
      .createAlias('statistic_scope_table__statistic_id__statistic_table__id');

  $$StatisticTableTableProcessedTableManager get statisticId {
    final $_column = $_itemColumn<String>('statistic_id')!;

    final manager = $$StatisticTableTableTableManager(
      $_db,
      $_db.statisticTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_statisticIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StatisticScopeTableTableFilterComposer
    extends Composer<_$AppDatabase, $StatisticScopeTableTable> {
  $$StatisticScopeTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<StatisticScope, StatisticScope, String>
  get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$StatisticTableTableFilterComposer get statisticId {
    final $$StatisticTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.statisticId,
      referencedTable: $db.statisticTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatisticTableTableFilterComposer(
            $db: $db,
            $table: $db.statisticTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatisticScopeTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StatisticScopeTableTable> {
  $$StatisticScopeTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  $$StatisticTableTableOrderingComposer get statisticId {
    final $$StatisticTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.statisticId,
      referencedTable: $db.statisticTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatisticTableTableOrderingComposer(
            $db: $db,
            $table: $db.statisticTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatisticScopeTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatisticScopeTableTable> {
  $$StatisticScopeTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<StatisticScope, String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  $$StatisticTableTableAnnotationComposer get statisticId {
    final $$StatisticTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.statisticId,
      referencedTable: $db.statisticTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatisticTableTableAnnotationComposer(
            $db: $db,
            $table: $db.statisticTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatisticScopeTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StatisticScopeTableTable,
          StatisticScopeTableData,
          $$StatisticScopeTableTableFilterComposer,
          $$StatisticScopeTableTableOrderingComposer,
          $$StatisticScopeTableTableAnnotationComposer,
          $$StatisticScopeTableTableCreateCompanionBuilder,
          $$StatisticScopeTableTableUpdateCompanionBuilder,
          (StatisticScopeTableData, $$StatisticScopeTableTableReferences),
          StatisticScopeTableData,
          PrefetchHooks Function({bool statisticId})
        > {
  $$StatisticScopeTableTableTableManager(
    _$AppDatabase db,
    $StatisticScopeTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatisticScopeTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatisticScopeTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StatisticScopeTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> statisticId = const Value.absent(),
                Value<StatisticScope> scope = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StatisticScopeTableCompanion(
                statisticId: statisticId,
                scope: scope,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String statisticId,
                required StatisticScope scope,
                Value<int> rowid = const Value.absent(),
              }) => StatisticScopeTableCompanion.insert(
                statisticId: statisticId,
                scope: scope,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StatisticScopeTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({statisticId = false}) {
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
                    if (statisticId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.statisticId,
                                referencedTable:
                                    $$StatisticScopeTableTableReferences
                                        ._statisticIdTable(db),
                                referencedColumn:
                                    $$StatisticScopeTableTableReferences
                                        ._statisticIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$StatisticScopeTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StatisticScopeTableTable,
      StatisticScopeTableData,
      $$StatisticScopeTableTableFilterComposer,
      $$StatisticScopeTableTableOrderingComposer,
      $$StatisticScopeTableTableAnnotationComposer,
      $$StatisticScopeTableTableCreateCompanionBuilder,
      $$StatisticScopeTableTableUpdateCompanionBuilder,
      (StatisticScopeTableData, $$StatisticScopeTableTableReferences),
      StatisticScopeTableData,
      PrefetchHooks Function({bool statisticId})
    >;
typedef $$StatisticGameTableTableCreateCompanionBuilder =
    StatisticGameTableCompanion Function({
      required String statisticId,
      required String gameId,
      Value<int> rowid,
    });
typedef $$StatisticGameTableTableUpdateCompanionBuilder =
    StatisticGameTableCompanion Function({
      Value<String> statisticId,
      Value<String> gameId,
      Value<int> rowid,
    });

final class $$StatisticGameTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StatisticGameTableTable,
          StatisticGameTableData
        > {
  $$StatisticGameTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StatisticTableTable _statisticIdTable(_$AppDatabase db) => db
      .statisticTable
      .createAlias('statistic_game_table__statistic_id__statistic_table__id');

  $$StatisticTableTableProcessedTableManager get statisticId {
    final $_column = $_itemColumn<String>('statistic_id')!;

    final manager = $$StatisticTableTableTableManager(
      $_db,
      $_db.statisticTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_statisticIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GameTableTable _gameIdTable(_$AppDatabase db) =>
      db.gameTable.createAlias('statistic_game_table__game_id__game_table__id');

  $$GameTableTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GameTableTableTableManager(
      $_db,
      $_db.gameTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StatisticGameTableTableFilterComposer
    extends Composer<_$AppDatabase, $StatisticGameTableTable> {
  $$StatisticGameTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StatisticTableTableFilterComposer get statisticId {
    final $$StatisticTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.statisticId,
      referencedTable: $db.statisticTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatisticTableTableFilterComposer(
            $db: $db,
            $table: $db.statisticTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GameTableTableFilterComposer get gameId {
    final $$GameTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.gameTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameTableTableFilterComposer(
            $db: $db,
            $table: $db.gameTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatisticGameTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StatisticGameTableTable> {
  $$StatisticGameTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StatisticTableTableOrderingComposer get statisticId {
    final $$StatisticTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.statisticId,
      referencedTable: $db.statisticTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatisticTableTableOrderingComposer(
            $db: $db,
            $table: $db.statisticTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GameTableTableOrderingComposer get gameId {
    final $$GameTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.gameTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameTableTableOrderingComposer(
            $db: $db,
            $table: $db.gameTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatisticGameTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatisticGameTableTable> {
  $$StatisticGameTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StatisticTableTableAnnotationComposer get statisticId {
    final $$StatisticTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.statisticId,
      referencedTable: $db.statisticTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatisticTableTableAnnotationComposer(
            $db: $db,
            $table: $db.statisticTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GameTableTableAnnotationComposer get gameId {
    final $$GameTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.gameTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameTableTableAnnotationComposer(
            $db: $db,
            $table: $db.gameTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatisticGameTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StatisticGameTableTable,
          StatisticGameTableData,
          $$StatisticGameTableTableFilterComposer,
          $$StatisticGameTableTableOrderingComposer,
          $$StatisticGameTableTableAnnotationComposer,
          $$StatisticGameTableTableCreateCompanionBuilder,
          $$StatisticGameTableTableUpdateCompanionBuilder,
          (StatisticGameTableData, $$StatisticGameTableTableReferences),
          StatisticGameTableData,
          PrefetchHooks Function({bool statisticId, bool gameId})
        > {
  $$StatisticGameTableTableTableManager(
    _$AppDatabase db,
    $StatisticGameTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatisticGameTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatisticGameTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatisticGameTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> statisticId = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StatisticGameTableCompanion(
                statisticId: statisticId,
                gameId: gameId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String statisticId,
                required String gameId,
                Value<int> rowid = const Value.absent(),
              }) => StatisticGameTableCompanion.insert(
                statisticId: statisticId,
                gameId: gameId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StatisticGameTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({statisticId = false, gameId = false}) {
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
                    if (statisticId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.statisticId,
                                referencedTable:
                                    $$StatisticGameTableTableReferences
                                        ._statisticIdTable(db),
                                referencedColumn:
                                    $$StatisticGameTableTableReferences
                                        ._statisticIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (gameId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.gameId,
                                referencedTable:
                                    $$StatisticGameTableTableReferences
                                        ._gameIdTable(db),
                                referencedColumn:
                                    $$StatisticGameTableTableReferences
                                        ._gameIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$StatisticGameTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StatisticGameTableTable,
      StatisticGameTableData,
      $$StatisticGameTableTableFilterComposer,
      $$StatisticGameTableTableOrderingComposer,
      $$StatisticGameTableTableAnnotationComposer,
      $$StatisticGameTableTableCreateCompanionBuilder,
      $$StatisticGameTableTableUpdateCompanionBuilder,
      (StatisticGameTableData, $$StatisticGameTableTableReferences),
      StatisticGameTableData,
      PrefetchHooks Function({bool statisticId, bool gameId})
    >;
typedef $$StatisticGroupTableTableCreateCompanionBuilder =
    StatisticGroupTableCompanion Function({
      required String statisticId,
      required String groupId,
      Value<int> rowid,
    });
typedef $$StatisticGroupTableTableUpdateCompanionBuilder =
    StatisticGroupTableCompanion Function({
      Value<String> statisticId,
      Value<String> groupId,
      Value<int> rowid,
    });

final class $$StatisticGroupTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StatisticGroupTableTable,
          StatisticGroupTableData
        > {
  $$StatisticGroupTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StatisticTableTable _statisticIdTable(_$AppDatabase db) => db
      .statisticTable
      .createAlias('statistic_group_table__statistic_id__statistic_table__id');

  $$StatisticTableTableProcessedTableManager get statisticId {
    final $_column = $_itemColumn<String>('statistic_id')!;

    final manager = $$StatisticTableTableTableManager(
      $_db,
      $_db.statisticTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_statisticIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GroupTableTable _groupIdTable(_$AppDatabase db) => db.groupTable
      .createAlias('statistic_group_table__group_id__group_table__id');

  $$GroupTableTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager = $$GroupTableTableTableManager(
      $_db,
      $_db.groupTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StatisticGroupTableTableFilterComposer
    extends Composer<_$AppDatabase, $StatisticGroupTableTable> {
  $$StatisticGroupTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StatisticTableTableFilterComposer get statisticId {
    final $$StatisticTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.statisticId,
      referencedTable: $db.statisticTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatisticTableTableFilterComposer(
            $db: $db,
            $table: $db.statisticTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupTableTableFilterComposer get groupId {
    final $$GroupTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupTableTableFilterComposer(
            $db: $db,
            $table: $db.groupTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatisticGroupTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StatisticGroupTableTable> {
  $$StatisticGroupTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StatisticTableTableOrderingComposer get statisticId {
    final $$StatisticTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.statisticId,
      referencedTable: $db.statisticTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatisticTableTableOrderingComposer(
            $db: $db,
            $table: $db.statisticTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupTableTableOrderingComposer get groupId {
    final $$GroupTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupTableTableOrderingComposer(
            $db: $db,
            $table: $db.groupTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatisticGroupTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatisticGroupTableTable> {
  $$StatisticGroupTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$StatisticTableTableAnnotationComposer get statisticId {
    final $$StatisticTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.statisticId,
      referencedTable: $db.statisticTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StatisticTableTableAnnotationComposer(
            $db: $db,
            $table: $db.statisticTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GroupTableTableAnnotationComposer get groupId {
    final $$GroupTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.groupId,
      referencedTable: $db.groupTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupTableTableAnnotationComposer(
            $db: $db,
            $table: $db.groupTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StatisticGroupTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StatisticGroupTableTable,
          StatisticGroupTableData,
          $$StatisticGroupTableTableFilterComposer,
          $$StatisticGroupTableTableOrderingComposer,
          $$StatisticGroupTableTableAnnotationComposer,
          $$StatisticGroupTableTableCreateCompanionBuilder,
          $$StatisticGroupTableTableUpdateCompanionBuilder,
          (StatisticGroupTableData, $$StatisticGroupTableTableReferences),
          StatisticGroupTableData,
          PrefetchHooks Function({bool statisticId, bool groupId})
        > {
  $$StatisticGroupTableTableTableManager(
    _$AppDatabase db,
    $StatisticGroupTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatisticGroupTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatisticGroupTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StatisticGroupTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> statisticId = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StatisticGroupTableCompanion(
                statisticId: statisticId,
                groupId: groupId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String statisticId,
                required String groupId,
                Value<int> rowid = const Value.absent(),
              }) => StatisticGroupTableCompanion.insert(
                statisticId: statisticId,
                groupId: groupId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StatisticGroupTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({statisticId = false, groupId = false}) {
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
                    if (statisticId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.statisticId,
                                referencedTable:
                                    $$StatisticGroupTableTableReferences
                                        ._statisticIdTable(db),
                                referencedColumn:
                                    $$StatisticGroupTableTableReferences
                                        ._statisticIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (groupId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.groupId,
                                referencedTable:
                                    $$StatisticGroupTableTableReferences
                                        ._groupIdTable(db),
                                referencedColumn:
                                    $$StatisticGroupTableTableReferences
                                        ._groupIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$StatisticGroupTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StatisticGroupTableTable,
      StatisticGroupTableData,
      $$StatisticGroupTableTableFilterComposer,
      $$StatisticGroupTableTableOrderingComposer,
      $$StatisticGroupTableTableAnnotationComposer,
      $$StatisticGroupTableTableCreateCompanionBuilder,
      $$StatisticGroupTableTableUpdateCompanionBuilder,
      (StatisticGroupTableData, $$StatisticGroupTableTableReferences),
      StatisticGroupTableData,
      PrefetchHooks Function({bool statisticId, bool groupId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayerTableTableTableManager get playerTable =>
      $$PlayerTableTableTableManager(_db, _db.playerTable);
  $$GroupTableTableTableManager get groupTable =>
      $$GroupTableTableTableManager(_db, _db.groupTable);
  $$GameTableTableTableManager get gameTable =>
      $$GameTableTableTableManager(_db, _db.gameTable);
  $$MatchTableTableTableManager get matchTable =>
      $$MatchTableTableTableManager(_db, _db.matchTable);
  $$PlayerGroupTableTableTableManager get playerGroupTable =>
      $$PlayerGroupTableTableTableManager(_db, _db.playerGroupTable);
  $$TeamTableTableTableManager get teamTable =>
      $$TeamTableTableTableManager(_db, _db.teamTable);
  $$PlayerMatchTableTableTableManager get playerMatchTable =>
      $$PlayerMatchTableTableTableManager(_db, _db.playerMatchTable);
  $$ScoreEntryTableTableTableManager get scoreEntryTable =>
      $$ScoreEntryTableTableTableManager(_db, _db.scoreEntryTable);
  $$StatisticTableTableTableManager get statisticTable =>
      $$StatisticTableTableTableManager(_db, _db.statisticTable);
  $$StatisticScopeTableTableTableManager get statisticScopeTable =>
      $$StatisticScopeTableTableTableManager(_db, _db.statisticScopeTable);
  $$StatisticGameTableTableTableManager get statisticGameTable =>
      $$StatisticGameTableTableTableManager(_db, _db.statisticGameTable);
  $$StatisticGroupTableTableTableManager get statisticGroupTable =>
      $$StatisticGroupTableTableTableManager(_db, _db.statisticGroupTable);
}
