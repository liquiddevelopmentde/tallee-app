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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
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
  List<GeneratedColumn> get $columns => [id, name, createdAt];
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
  PlayerTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
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
  final String name;
  final DateTime createdAt;
  const PlayerTableData({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlayerTableCompanion toCompanion(bool nullToAbsent) {
    return PlayerTableCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory PlayerTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlayerTableData copyWith({String? id, String? name, DateTime? createdAt}) =>
      PlayerTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  PlayerTableData copyWithCompanion(PlayerTableCompanion data) {
    return PlayerTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class PlayerTableCompanion extends UpdateCompanion<PlayerTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PlayerTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayerTableCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<PlayerTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayerTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PlayerTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
    return (StringBuffer('PlayerTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
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
  List<GeneratedColumn> get $columns => [id, name, createdAt];
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
  GroupTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
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
  final String name;
  final DateTime createdAt;
  const GroupTableData({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GroupTableCompanion toCompanion(bool nullToAbsent) {
    return GroupTableCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory GroupTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GroupTableData copyWith({String? id, String? name, DateTime? createdAt}) =>
      GroupTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  GroupTableData copyWithCompanion(GroupTableCompanion data) {
    return GroupTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class GroupTableCompanion extends UpdateCompanion<GroupTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GroupTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupTableCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<GroupTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return GroupTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
    return (StringBuffer('GroupTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
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
  static const VerificationMeta _winnerIdMeta = const VerificationMeta(
    'winnerId',
  );
  @override
  late final GeneratedColumn<String> winnerId = GeneratedColumn<String>(
    'winner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
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
  List<GeneratedColumn> get $columns => [winnerId, id, name, createdAt];
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
    if (data.containsKey('winner_id')) {
      context.handle(
        _winnerIdMeta,
        winnerId.isAcceptableOrUnknown(data['winner_id']!, _winnerIdMeta),
      );
    }
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
  MatchTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchTableData(
      winnerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}winner_id'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MatchTableTable createAlias(String alias) {
    return $MatchTableTable(attachedDatabase, alias);
  }
}

class MatchTableData extends DataClass implements Insertable<MatchTableData> {
  final String? winnerId;
  final String id;
  final String name;
  final DateTime createdAt;
  const MatchTableData({
    this.winnerId,
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || winnerId != null) {
      map['winner_id'] = Variable<String>(winnerId);
    }
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MatchTableCompanion toCompanion(bool nullToAbsent) {
    return MatchTableCompanion(
      winnerId: winnerId == null && nullToAbsent
          ? const Value.absent()
          : Value(winnerId),
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory MatchTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchTableData(
      winnerId: serializer.fromJson<String?>(json['winnerId']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'winnerId': serializer.toJson<String?>(winnerId),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MatchTableData copyWith({
    Value<String?> winnerId = const Value.absent(),
    String? id,
    String? name,
    DateTime? createdAt,
  }) => MatchTableData(
    winnerId: winnerId.present ? winnerId.value : this.winnerId,
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  MatchTableData copyWithCompanion(MatchTableCompanion data) {
    return MatchTableData(
      winnerId: data.winnerId.present ? data.winnerId.value : this.winnerId,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchTableData(')
          ..write('winnerId: $winnerId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(winnerId, id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchTableData &&
          other.winnerId == this.winnerId &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class MatchTableCompanion extends UpdateCompanion<MatchTableData> {
  final Value<String?> winnerId;
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MatchTableCompanion({
    this.winnerId = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchTableCompanion.insert({
    this.winnerId = const Value.absent(),
    required String id,
    required String name,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<MatchTableData> custom({
    Expression<String>? winnerId,
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (winnerId != null) 'winner_id': winnerId,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchTableCompanion copyWith({
    Value<String?>? winnerId,
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MatchTableCompanion(
      winnerId: winnerId ?? this.winnerId,
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (winnerId.present) {
      map['winner_id'] = Variable<String>(winnerId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
    return (StringBuffer('MatchTableCompanion(')
          ..write('winnerId: $winnerId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
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
  @override
  List<GeneratedColumn> get $columns => [playerId, matchId];
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
  const PlayerMatchTableData({required this.playerId, required this.matchId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['player_id'] = Variable<String>(playerId);
    map['match_id'] = Variable<String>(matchId);
    return map;
  }

  PlayerMatchTableCompanion toCompanion(bool nullToAbsent) {
    return PlayerMatchTableCompanion(
      playerId: Value(playerId),
      matchId: Value(matchId),
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
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playerId': serializer.toJson<String>(playerId),
      'matchId': serializer.toJson<String>(matchId),
    };
  }

  PlayerMatchTableData copyWith({String? playerId, String? matchId}) =>
      PlayerMatchTableData(
        playerId: playerId ?? this.playerId,
        matchId: matchId ?? this.matchId,
      );
  PlayerMatchTableData copyWithCompanion(PlayerMatchTableCompanion data) {
    return PlayerMatchTableData(
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerMatchTableData(')
          ..write('playerId: $playerId, ')
          ..write('matchId: $matchId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playerId, matchId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerMatchTableData &&
          other.playerId == this.playerId &&
          other.matchId == this.matchId);
}

class PlayerMatchTableCompanion extends UpdateCompanion<PlayerMatchTableData> {
  final Value<String> playerId;
  final Value<String> matchId;
  final Value<int> rowid;
  const PlayerMatchTableCompanion({
    this.playerId = const Value.absent(),
    this.matchId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayerMatchTableCompanion.insert({
    required String playerId,
    required String matchId,
    this.rowid = const Value.absent(),
  }) : playerId = Value(playerId),
       matchId = Value(matchId);
  static Insertable<PlayerMatchTableData> custom({
    Expression<String>? playerId,
    Expression<String>? matchId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playerId != null) 'player_id': playerId,
      if (matchId != null) 'match_id': matchId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayerMatchTableCompanion copyWith({
    Value<String>? playerId,
    Value<String>? matchId,
    Value<int>? rowid,
  }) {
    return PlayerMatchTableCompanion(
      playerId: playerId ?? this.playerId,
      matchId: matchId ?? this.matchId,
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
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupMatchTableTable extends GroupMatchTable
    with TableInfo<$GroupMatchTableTable, GroupMatchTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupMatchTableTable(this.attachedDatabase, [this._alias]);
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
  @override
  List<GeneratedColumn> get $columns => [groupId, matchId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_match_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroupMatchTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, matchId};
  @override
  GroupMatchTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupMatchTableData(
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_id'],
      )!,
    );
  }

  @override
  $GroupMatchTableTable createAlias(String alias) {
    return $GroupMatchTableTable(attachedDatabase, alias);
  }
}

class GroupMatchTableData extends DataClass
    implements Insertable<GroupMatchTableData> {
  final String groupId;
  final String matchId;
  const GroupMatchTableData({required this.groupId, required this.matchId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<String>(groupId);
    map['match_id'] = Variable<String>(matchId);
    return map;
  }

  GroupMatchTableCompanion toCompanion(bool nullToAbsent) {
    return GroupMatchTableCompanion(
      groupId: Value(groupId),
      matchId: Value(matchId),
    );
  }

  factory GroupMatchTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupMatchTableData(
      groupId: serializer.fromJson<String>(json['groupId']),
      matchId: serializer.fromJson<String>(json['matchId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<String>(groupId),
      'matchId': serializer.toJson<String>(matchId),
    };
  }

  GroupMatchTableData copyWith({String? groupId, String? matchId}) =>
      GroupMatchTableData(
        groupId: groupId ?? this.groupId,
        matchId: matchId ?? this.matchId,
      );
  GroupMatchTableData copyWithCompanion(GroupMatchTableCompanion data) {
    return GroupMatchTableData(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupMatchTableData(')
          ..write('groupId: $groupId, ')
          ..write('matchId: $matchId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, matchId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMatchTableData &&
          other.groupId == this.groupId &&
          other.matchId == this.matchId);
}

class GroupMatchTableCompanion extends UpdateCompanion<GroupMatchTableData> {
  final Value<String> groupId;
  final Value<String> matchId;
  final Value<int> rowid;
  const GroupMatchTableCompanion({
    this.groupId = const Value.absent(),
    this.matchId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupMatchTableCompanion.insert({
    required String groupId,
    required String matchId,
    this.rowid = const Value.absent(),
  }) : groupId = Value(groupId),
       matchId = Value(matchId);
  static Insertable<GroupMatchTableData> custom({
    Expression<String>? groupId,
    Expression<String>? matchId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (matchId != null) 'match_id': matchId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupMatchTableCompanion copyWith({
    Value<String>? groupId,
    Value<String>? matchId,
    Value<int>? rowid,
  }) {
    return GroupMatchTableCompanion(
      groupId: groupId ?? this.groupId,
      matchId: matchId ?? this.matchId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupMatchTableCompanion(')
          ..write('groupId: $groupId, ')
          ..write('matchId: $matchId, ')
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
  late final $MatchTableTable matchTable = $MatchTableTable(this);
  late final $PlayerGroupTableTable playerGroupTable = $PlayerGroupTableTable(
    this,
  );
  late final $PlayerMatchTableTable playerMatchTable = $PlayerMatchTableTable(
    this,
  );
  late final $GroupMatchTableTable groupMatchTable = $GroupMatchTableTable(
    this,
  );
  late final PlayerDao playerDao = PlayerDao(this as AppDatabase);
  late final GroupDao groupDao = GroupDao(this as AppDatabase);
  late final MatchDao matchDao = MatchDao(this as AppDatabase);
  late final PlayerGroupDao playerGroupDao = PlayerGroupDao(
    this as AppDatabase,
  );
  late final PlayerMatchDao playerMatchDao = PlayerMatchDao(
    this as AppDatabase,
  );
  late final GroupMatchDao groupMatchDao = GroupMatchDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    playerTable,
    groupTable,
    matchTable,
    playerGroupTable,
    playerMatchTable,
    groupMatchTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
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
        'group_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_match_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'match_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('group_match_table', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PlayerTableTableCreateCompanionBuilder =
    PlayerTableCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PlayerTableTableUpdateCompanionBuilder =
    PlayerTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PlayerTableTableReferences
    extends BaseReferences<_$AppDatabase, $PlayerTableTable, PlayerTableData> {
  $$PlayerTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlayerGroupTableTable, List<PlayerGroupTableData>>
  _playerGroupTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playerGroupTable,
    aliasName: $_aliasNameGenerator(
      db.playerTable.id,
      db.playerGroupTable.playerId,
    ),
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
    aliasName: $_aliasNameGenerator(
      db.playerTable.id,
      db.playerMatchTable.playerId,
    ),
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayerTableCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PlayerTableCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
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
              ({playerGroupTableRefs = false, playerMatchTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playerGroupTableRefs) db.playerGroupTable,
                    if (playerMatchTableRefs) db.playerMatchTable,
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
      })
    >;
typedef $$GroupTableTableCreateCompanionBuilder =
    GroupTableCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$GroupTableTableUpdateCompanionBuilder =
    GroupTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$GroupTableTableReferences
    extends BaseReferences<_$AppDatabase, $GroupTableTable, GroupTableData> {
  $$GroupTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlayerGroupTableTable, List<PlayerGroupTableData>>
  _playerGroupTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playerGroupTable,
    aliasName: $_aliasNameGenerator(
      db.groupTable.id,
      db.playerGroupTable.groupId,
    ),
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

  static MultiTypedResultKey<$GroupMatchTableTable, List<GroupMatchTableData>>
  _groupMatchTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupMatchTable,
    aliasName: $_aliasNameGenerator(
      db.groupTable.id,
      db.groupMatchTable.groupId,
    ),
  );

  $$GroupMatchTableTableProcessedTableManager get groupMatchTableRefs {
    final manager = $$GroupMatchTableTableTableManager(
      $_db,
      $_db.groupMatchTable,
    ).filter((f) => f.groupId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _groupMatchTableRefsTable($_db),
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

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

  Expression<bool> groupMatchTableRefs(
    Expression<bool> Function($$GroupMatchTableTableFilterComposer f) f,
  ) {
    final $$GroupMatchTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMatchTable,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMatchTableTableFilterComposer(
            $db: $db,
            $table: $db.groupMatchTable,
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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

  Expression<T> groupMatchTableRefs<T extends Object>(
    Expression<T> Function($$GroupMatchTableTableAnnotationComposer a) f,
  ) {
    final $$GroupMatchTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMatchTable,
      getReferencedColumn: (t) => t.groupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMatchTableTableAnnotationComposer(
            $db: $db,
            $table: $db.groupMatchTable,
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
            bool playerGroupTableRefs,
            bool groupMatchTableRefs,
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
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupTableCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => GroupTableCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
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
              ({playerGroupTableRefs = false, groupMatchTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playerGroupTableRefs) db.playerGroupTable,
                    if (groupMatchTableRefs) db.groupMatchTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
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
                      if (groupMatchTableRefs)
                        await $_getPrefetchedData<
                          GroupTableData,
                          $GroupTableTable,
                          GroupMatchTableData
                        >(
                          currentTable: table,
                          referencedTable: $$GroupTableTableReferences
                              ._groupMatchTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroupTableTableReferences(
                                db,
                                table,
                                p0,
                              ).groupMatchTableRefs,
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
        bool playerGroupTableRefs,
        bool groupMatchTableRefs,
      })
    >;
typedef $$MatchTableTableCreateCompanionBuilder =
    MatchTableCompanion Function({
      Value<String?> winnerId,
      required String id,
      required String name,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MatchTableTableUpdateCompanionBuilder =
    MatchTableCompanion Function({
      Value<String?> winnerId,
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MatchTableTableReferences
    extends BaseReferences<_$AppDatabase, $MatchTableTable, MatchTableData> {
  $$MatchTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlayerMatchTableTable, List<PlayerMatchTableData>>
  _playerMatchTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playerMatchTable,
    aliasName: $_aliasNameGenerator(
      db.matchTable.id,
      db.playerMatchTable.matchId,
    ),
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

  static MultiTypedResultKey<$GroupMatchTableTable, List<GroupMatchTableData>>
  _groupMatchTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groupMatchTable,
    aliasName: $_aliasNameGenerator(
      db.matchTable.id,
      db.groupMatchTable.matchId,
    ),
  );

  $$GroupMatchTableTableProcessedTableManager get groupMatchTableRefs {
    final manager = $$GroupMatchTableTableTableManager(
      $_db,
      $_db.groupMatchTable,
    ).filter((f) => f.matchId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _groupMatchTableRefsTable($_db),
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
  ColumnFilters<String> get winnerId => $composableBuilder(
    column: $table.winnerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

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

  Expression<bool> groupMatchTableRefs(
    Expression<bool> Function($$GroupMatchTableTableFilterComposer f) f,
  ) {
    final $$GroupMatchTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMatchTable,
      getReferencedColumn: (t) => t.matchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMatchTableTableFilterComposer(
            $db: $db,
            $table: $db.groupMatchTable,
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
  ColumnOrderings<String> get winnerId => $composableBuilder(
    column: $table.winnerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
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
  GeneratedColumn<String> get winnerId =>
      $composableBuilder(column: $table.winnerId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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

  Expression<T> groupMatchTableRefs<T extends Object>(
    Expression<T> Function($$GroupMatchTableTableAnnotationComposer a) f,
  ) {
    final $$GroupMatchTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groupMatchTable,
      getReferencedColumn: (t) => t.matchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroupMatchTableTableAnnotationComposer(
            $db: $db,
            $table: $db.groupMatchTable,
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
            bool playerMatchTableRefs,
            bool groupMatchTableRefs,
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
                Value<String?> winnerId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchTableCompanion(
                winnerId: winnerId,
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> winnerId = const Value.absent(),
                required String id,
                required String name,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MatchTableCompanion.insert(
                winnerId: winnerId,
                id: id,
                name: name,
                createdAt: createdAt,
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
              ({playerMatchTableRefs = false, groupMatchTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (playerMatchTableRefs) db.playerMatchTable,
                    if (groupMatchTableRefs) db.groupMatchTable,
                  ],
                  addJoins: null,
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
                      if (groupMatchTableRefs)
                        await $_getPrefetchedData<
                          MatchTableData,
                          $MatchTableTable,
                          GroupMatchTableData
                        >(
                          currentTable: table,
                          referencedTable: $$MatchTableTableReferences
                              ._groupMatchTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MatchTableTableReferences(
                                db,
                                table,
                                p0,
                              ).groupMatchTableRefs,
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
        bool playerMatchTableRefs,
        bool groupMatchTableRefs,
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

  static $PlayerTableTable _playerIdTable(_$AppDatabase db) =>
      db.playerTable.createAlias(
        $_aliasNameGenerator(db.playerGroupTable.playerId, db.playerTable.id),
      );

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

  static $GroupTableTable _groupIdTable(_$AppDatabase db) =>
      db.groupTable.createAlias(
        $_aliasNameGenerator(db.playerGroupTable.groupId, db.groupTable.id),
      );

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
typedef $$PlayerMatchTableTableCreateCompanionBuilder =
    PlayerMatchTableCompanion Function({
      required String playerId,
      required String matchId,
      Value<int> rowid,
    });
typedef $$PlayerMatchTableTableUpdateCompanionBuilder =
    PlayerMatchTableCompanion Function({
      Value<String> playerId,
      Value<String> matchId,
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

  static $PlayerTableTable _playerIdTable(_$AppDatabase db) =>
      db.playerTable.createAlias(
        $_aliasNameGenerator(db.playerMatchTable.playerId, db.playerTable.id),
      );

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
      db.matchTable.createAlias(
        $_aliasNameGenerator(db.playerMatchTable.matchId, db.matchTable.id),
      );

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
          PrefetchHooks Function({bool playerId, bool matchId})
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
                Value<int> rowid = const Value.absent(),
              }) => PlayerMatchTableCompanion(
                playerId: playerId,
                matchId: matchId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playerId,
                required String matchId,
                Value<int> rowid = const Value.absent(),
              }) => PlayerMatchTableCompanion.insert(
                playerId: playerId,
                matchId: matchId,
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
      PrefetchHooks Function({bool playerId, bool matchId})
    >;
typedef $$GroupMatchTableTableCreateCompanionBuilder =
    GroupMatchTableCompanion Function({
      required String groupId,
      required String matchId,
      Value<int> rowid,
    });
typedef $$GroupMatchTableTableUpdateCompanionBuilder =
    GroupMatchTableCompanion Function({
      Value<String> groupId,
      Value<String> matchId,
      Value<int> rowid,
    });

final class $$GroupMatchTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GroupMatchTableTable,
          GroupMatchTableData
        > {
  $$GroupMatchTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GroupTableTable _groupIdTable(_$AppDatabase db) =>
      db.groupTable.createAlias(
        $_aliasNameGenerator(db.groupMatchTable.groupId, db.groupTable.id),
      );

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

  static $MatchTableTable _matchIdTable(_$AppDatabase db) =>
      db.matchTable.createAlias(
        $_aliasNameGenerator(db.groupMatchTable.matchId, db.matchTable.id),
      );

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

class $$GroupMatchTableTableFilterComposer
    extends Composer<_$AppDatabase, $GroupMatchTableTable> {
  $$GroupMatchTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
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

class $$GroupMatchTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupMatchTableTable> {
  $$GroupMatchTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
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

class $$GroupMatchTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupMatchTableTable> {
  $$GroupMatchTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
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

class $$GroupMatchTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupMatchTableTable,
          GroupMatchTableData,
          $$GroupMatchTableTableFilterComposer,
          $$GroupMatchTableTableOrderingComposer,
          $$GroupMatchTableTableAnnotationComposer,
          $$GroupMatchTableTableCreateCompanionBuilder,
          $$GroupMatchTableTableUpdateCompanionBuilder,
          (GroupMatchTableData, $$GroupMatchTableTableReferences),
          GroupMatchTableData,
          PrefetchHooks Function({bool groupId, bool matchId})
        > {
  $$GroupMatchTableTableTableManager(
    _$AppDatabase db,
    $GroupMatchTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupMatchTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupMatchTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupMatchTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> groupId = const Value.absent(),
                Value<String> matchId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupMatchTableCompanion(
                groupId: groupId,
                matchId: matchId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String groupId,
                required String matchId,
                Value<int> rowid = const Value.absent(),
              }) => GroupMatchTableCompanion.insert(
                groupId: groupId,
                matchId: matchId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GroupMatchTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groupId = false, matchId = false}) {
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
                    if (groupId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.groupId,
                                referencedTable:
                                    $$GroupMatchTableTableReferences
                                        ._groupIdTable(db),
                                referencedColumn:
                                    $$GroupMatchTableTableReferences
                                        ._groupIdTable(db)
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
                                    $$GroupMatchTableTableReferences
                                        ._matchIdTable(db),
                                referencedColumn:
                                    $$GroupMatchTableTableReferences
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

typedef $$GroupMatchTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupMatchTableTable,
      GroupMatchTableData,
      $$GroupMatchTableTableFilterComposer,
      $$GroupMatchTableTableOrderingComposer,
      $$GroupMatchTableTableAnnotationComposer,
      $$GroupMatchTableTableCreateCompanionBuilder,
      $$GroupMatchTableTableUpdateCompanionBuilder,
      (GroupMatchTableData, $$GroupMatchTableTableReferences),
      GroupMatchTableData,
      PrefetchHooks Function({bool groupId, bool matchId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayerTableTableTableManager get playerTable =>
      $$PlayerTableTableTableManager(_db, _db.playerTable);
  $$GroupTableTableTableManager get groupTable =>
      $$GroupTableTableTableManager(_db, _db.groupTable);
  $$MatchTableTableTableManager get matchTable =>
      $$MatchTableTableTableManager(_db, _db.matchTable);
  $$PlayerGroupTableTableTableManager get playerGroupTable =>
      $$PlayerGroupTableTableTableManager(_db, _db.playerGroupTable);
  $$PlayerMatchTableTableTableManager get playerMatchTable =>
      $$PlayerMatchTableTableTableManager(_db, _db.playerMatchTable);
  $$GroupMatchTableTableTableManager get groupMatchTable =>
      $$GroupMatchTableTableTableManager(_db, _db.groupMatchTable);
}
