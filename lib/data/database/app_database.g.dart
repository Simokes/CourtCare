// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TerrainTableTable extends TerrainTable
    with TableInfo<$TerrainTableTable, TerrainTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TerrainTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _numeroMeta = const VerificationMeta('numero');
  @override
  late final GeneratedColumn<int> numero = GeneratedColumn<int>(
      'numero', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
      'statut', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, numero, type, statut];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'terrain_table';
  @override
  VerificationContext validateIntegrity(Insertable<TerrainTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('numero')) {
      context.handle(_numeroMeta,
          numero.isAcceptableOrUnknown(data['numero']!, _numeroMeta));
    } else if (isInserting) {
      context.missing(_numeroMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('statut')) {
      context.handle(_statutMeta,
          statut.isAcceptableOrUnknown(data['statut']!, _statutMeta));
    } else if (isInserting) {
      context.missing(_statutMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TerrainTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TerrainTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      numero: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}numero'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      statut: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}statut'])!,
    );
  }

  @override
  $TerrainTableTable createAlias(String alias) {
    return $TerrainTableTable(attachedDatabase, alias);
  }
}

class TerrainTableData extends DataClass
    implements Insertable<TerrainTableData> {
  final int id;
  final int numero;
  final String type;
  final String statut;
  const TerrainTableData(
      {required this.id,
      required this.numero,
      required this.type,
      required this.statut});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['numero'] = Variable<int>(numero);
    map['type'] = Variable<String>(type);
    map['statut'] = Variable<String>(statut);
    return map;
  }

  TerrainTableCompanion toCompanion(bool nullToAbsent) {
    return TerrainTableCompanion(
      id: Value(id),
      numero: Value(numero),
      type: Value(type),
      statut: Value(statut),
    );
  }

  factory TerrainTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TerrainTableData(
      id: serializer.fromJson<int>(json['id']),
      numero: serializer.fromJson<int>(json['numero']),
      type: serializer.fromJson<String>(json['type']),
      statut: serializer.fromJson<String>(json['statut']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'numero': serializer.toJson<int>(numero),
      'type': serializer.toJson<String>(type),
      'statut': serializer.toJson<String>(statut),
    };
  }

  TerrainTableData copyWith(
          {int? id, int? numero, String? type, String? statut}) =>
      TerrainTableData(
        id: id ?? this.id,
        numero: numero ?? this.numero,
        type: type ?? this.type,
        statut: statut ?? this.statut,
      );
  TerrainTableData copyWithCompanion(TerrainTableCompanion data) {
    return TerrainTableData(
      id: data.id.present ? data.id.value : this.id,
      numero: data.numero.present ? data.numero.value : this.numero,
      type: data.type.present ? data.type.value : this.type,
      statut: data.statut.present ? data.statut.value : this.statut,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TerrainTableData(')
          ..write('id: $id, ')
          ..write('numero: $numero, ')
          ..write('type: $type, ')
          ..write('statut: $statut')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, numero, type, statut);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TerrainTableData &&
          other.id == this.id &&
          other.numero == this.numero &&
          other.type == this.type &&
          other.statut == this.statut);
}

class TerrainTableCompanion extends UpdateCompanion<TerrainTableData> {
  final Value<int> id;
  final Value<int> numero;
  final Value<String> type;
  final Value<String> statut;
  const TerrainTableCompanion({
    this.id = const Value.absent(),
    this.numero = const Value.absent(),
    this.type = const Value.absent(),
    this.statut = const Value.absent(),
  });
  TerrainTableCompanion.insert({
    this.id = const Value.absent(),
    required int numero,
    required String type,
    required String statut,
  })  : numero = Value(numero),
        type = Value(type),
        statut = Value(statut);
  static Insertable<TerrainTableData> custom({
    Expression<int>? id,
    Expression<int>? numero,
    Expression<String>? type,
    Expression<String>? statut,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (numero != null) 'numero': numero,
      if (type != null) 'type': type,
      if (statut != null) 'statut': statut,
    });
  }

  TerrainTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? numero,
      Value<String>? type,
      Value<String>? statut}) {
    return TerrainTableCompanion(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      type: type ?? this.type,
      statut: statut ?? this.statut,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (numero.present) {
      map['numero'] = Variable<int>(numero.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TerrainTableCompanion(')
          ..write('id: $id, ')
          ..write('numero: $numero, ')
          ..write('type: $type, ')
          ..write('statut: $statut')
          ..write(')'))
        .toString();
  }
}

class $MaintenancesTable extends Maintenances
    with TableInfo<$MaintenancesTable, MaintenanceEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaintenancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _terrainIdMeta =
      const VerificationMeta('terrainId');
  @override
  late final GeneratedColumn<int> terrainId = GeneratedColumn<int>(
      'terrain_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _commentaireMeta =
      const VerificationMeta('commentaire');
  @override
  late final GeneratedColumn<String> commentaire = GeneratedColumn<String>(
      'commentaire', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sacsTerreUtilisesMeta =
      const VerificationMeta('sacsTerreUtilises');
  @override
  late final GeneratedColumn<int> sacsTerreUtilises = GeneratedColumn<int>(
      'sacs_terre_utilises', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _sacsSableUtilisesMeta =
      const VerificationMeta('sacsSableUtilises');
  @override
  late final GeneratedColumn<int> sacsSableUtilises = GeneratedColumn<int>(
      'sacs_sable_utilises', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        terrainId,
        type,
        commentaire,
        date,
        sacsTerreUtilises,
        sacsSableUtilises
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maintenances';
  @override
  VerificationContext validateIntegrity(Insertable<MaintenanceEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('terrain_id')) {
      context.handle(_terrainIdMeta,
          terrainId.isAcceptableOrUnknown(data['terrain_id']!, _terrainIdMeta));
    } else if (isInserting) {
      context.missing(_terrainIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('commentaire')) {
      context.handle(
          _commentaireMeta,
          commentaire.isAcceptableOrUnknown(
              data['commentaire']!, _commentaireMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('sacs_terre_utilises')) {
      context.handle(
          _sacsTerreUtilisesMeta,
          sacsTerreUtilises.isAcceptableOrUnknown(
              data['sacs_terre_utilises']!, _sacsTerreUtilisesMeta));
    }
    if (data.containsKey('sacs_sable_utilises')) {
      context.handle(
          _sacsSableUtilisesMeta,
          sacsSableUtilises.isAcceptableOrUnknown(
              data['sacs_sable_utilises']!, _sacsSableUtilisesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaintenanceEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaintenanceEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      terrainId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}terrain_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      commentaire: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}commentaire']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      sacsTerreUtilises: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}sacs_terre_utilises'])!,
      sacsSableUtilises: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}sacs_sable_utilises'])!,
    );
  }

  @override
  $MaintenancesTable createAlias(String alias) {
    return $MaintenancesTable(attachedDatabase, alias);
  }
}

class MaintenanceEntity extends DataClass
    implements Insertable<MaintenanceEntity> {
  final int id;
  final int terrainId;
  final String type;
  final String? commentaire;
  final DateTime date;
  final int sacsTerreUtilises;
  final int sacsSableUtilises;
  const MaintenanceEntity(
      {required this.id,
      required this.terrainId,
      required this.type,
      this.commentaire,
      required this.date,
      required this.sacsTerreUtilises,
      required this.sacsSableUtilises});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['terrain_id'] = Variable<int>(terrainId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || commentaire != null) {
      map['commentaire'] = Variable<String>(commentaire);
    }
    map['date'] = Variable<DateTime>(date);
    map['sacs_terre_utilises'] = Variable<int>(sacsTerreUtilises);
    map['sacs_sable_utilises'] = Variable<int>(sacsSableUtilises);
    return map;
  }

  MaintenancesCompanion toCompanion(bool nullToAbsent) {
    return MaintenancesCompanion(
      id: Value(id),
      terrainId: Value(terrainId),
      type: Value(type),
      commentaire: commentaire == null && nullToAbsent
          ? const Value.absent()
          : Value(commentaire),
      date: Value(date),
      sacsTerreUtilises: Value(sacsTerreUtilises),
      sacsSableUtilises: Value(sacsSableUtilises),
    );
  }

  factory MaintenanceEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaintenanceEntity(
      id: serializer.fromJson<int>(json['id']),
      terrainId: serializer.fromJson<int>(json['terrainId']),
      type: serializer.fromJson<String>(json['type']),
      commentaire: serializer.fromJson<String?>(json['commentaire']),
      date: serializer.fromJson<DateTime>(json['date']),
      sacsTerreUtilises: serializer.fromJson<int>(json['sacsTerreUtilises']),
      sacsSableUtilises: serializer.fromJson<int>(json['sacsSableUtilises']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'terrainId': serializer.toJson<int>(terrainId),
      'type': serializer.toJson<String>(type),
      'commentaire': serializer.toJson<String?>(commentaire),
      'date': serializer.toJson<DateTime>(date),
      'sacsTerreUtilises': serializer.toJson<int>(sacsTerreUtilises),
      'sacsSableUtilises': serializer.toJson<int>(sacsSableUtilises),
    };
  }

  MaintenanceEntity copyWith(
          {int? id,
          int? terrainId,
          String? type,
          Value<String?> commentaire = const Value.absent(),
          DateTime? date,
          int? sacsTerreUtilises,
          int? sacsSableUtilises}) =>
      MaintenanceEntity(
        id: id ?? this.id,
        terrainId: terrainId ?? this.terrainId,
        type: type ?? this.type,
        commentaire: commentaire.present ? commentaire.value : this.commentaire,
        date: date ?? this.date,
        sacsTerreUtilises: sacsTerreUtilises ?? this.sacsTerreUtilises,
        sacsSableUtilises: sacsSableUtilises ?? this.sacsSableUtilises,
      );
  MaintenanceEntity copyWithCompanion(MaintenancesCompanion data) {
    return MaintenanceEntity(
      id: data.id.present ? data.id.value : this.id,
      terrainId: data.terrainId.present ? data.terrainId.value : this.terrainId,
      type: data.type.present ? data.type.value : this.type,
      commentaire:
          data.commentaire.present ? data.commentaire.value : this.commentaire,
      date: data.date.present ? data.date.value : this.date,
      sacsTerreUtilises: data.sacsTerreUtilises.present
          ? data.sacsTerreUtilises.value
          : this.sacsTerreUtilises,
      sacsSableUtilises: data.sacsSableUtilises.present
          ? data.sacsSableUtilises.value
          : this.sacsSableUtilises,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceEntity(')
          ..write('id: $id, ')
          ..write('terrainId: $terrainId, ')
          ..write('type: $type, ')
          ..write('commentaire: $commentaire, ')
          ..write('date: $date, ')
          ..write('sacsTerreUtilises: $sacsTerreUtilises, ')
          ..write('sacsSableUtilises: $sacsSableUtilises')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, terrainId, type, commentaire, date,
      sacsTerreUtilises, sacsSableUtilises);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaintenanceEntity &&
          other.id == this.id &&
          other.terrainId == this.terrainId &&
          other.type == this.type &&
          other.commentaire == this.commentaire &&
          other.date == this.date &&
          other.sacsTerreUtilises == this.sacsTerreUtilises &&
          other.sacsSableUtilises == this.sacsSableUtilises);
}

class MaintenancesCompanion extends UpdateCompanion<MaintenanceEntity> {
  final Value<int> id;
  final Value<int> terrainId;
  final Value<String> type;
  final Value<String?> commentaire;
  final Value<DateTime> date;
  final Value<int> sacsTerreUtilises;
  final Value<int> sacsSableUtilises;
  const MaintenancesCompanion({
    this.id = const Value.absent(),
    this.terrainId = const Value.absent(),
    this.type = const Value.absent(),
    this.commentaire = const Value.absent(),
    this.date = const Value.absent(),
    this.sacsTerreUtilises = const Value.absent(),
    this.sacsSableUtilises = const Value.absent(),
  });
  MaintenancesCompanion.insert({
    this.id = const Value.absent(),
    required int terrainId,
    required String type,
    this.commentaire = const Value.absent(),
    required DateTime date,
    this.sacsTerreUtilises = const Value.absent(),
    this.sacsSableUtilises = const Value.absent(),
  })  : terrainId = Value(terrainId),
        type = Value(type),
        date = Value(date);
  static Insertable<MaintenanceEntity> custom({
    Expression<int>? id,
    Expression<int>? terrainId,
    Expression<String>? type,
    Expression<String>? commentaire,
    Expression<DateTime>? date,
    Expression<int>? sacsTerreUtilises,
    Expression<int>? sacsSableUtilises,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (terrainId != null) 'terrain_id': terrainId,
      if (type != null) 'type': type,
      if (commentaire != null) 'commentaire': commentaire,
      if (date != null) 'date': date,
      if (sacsTerreUtilises != null) 'sacs_terre_utilises': sacsTerreUtilises,
      if (sacsSableUtilises != null) 'sacs_sable_utilises': sacsSableUtilises,
    });
  }

  MaintenancesCompanion copyWith(
      {Value<int>? id,
      Value<int>? terrainId,
      Value<String>? type,
      Value<String?>? commentaire,
      Value<DateTime>? date,
      Value<int>? sacsTerreUtilises,
      Value<int>? sacsSableUtilises}) {
    return MaintenancesCompanion(
      id: id ?? this.id,
      terrainId: terrainId ?? this.terrainId,
      type: type ?? this.type,
      commentaire: commentaire ?? this.commentaire,
      date: date ?? this.date,
      sacsTerreUtilises: sacsTerreUtilises ?? this.sacsTerreUtilises,
      sacsSableUtilises: sacsSableUtilises ?? this.sacsSableUtilises,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (terrainId.present) {
      map['terrain_id'] = Variable<int>(terrainId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (commentaire.present) {
      map['commentaire'] = Variable<String>(commentaire.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (sacsTerreUtilises.present) {
      map['sacs_terre_utilises'] = Variable<int>(sacsTerreUtilises.value);
    }
    if (sacsSableUtilises.present) {
      map['sacs_sable_utilises'] = Variable<int>(sacsSableUtilises.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaintenancesCompanion(')
          ..write('id: $id, ')
          ..write('terrainId: $terrainId, ')
          ..write('type: $type, ')
          ..write('commentaire: $commentaire, ')
          ..write('date: $date, ')
          ..write('sacsTerreUtilises: $sacsTerreUtilises, ')
          ..write('sacsSableUtilises: $sacsSableUtilises')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TerrainTableTable terrainTable = $TerrainTableTable(this);
  late final $MaintenancesTable maintenances = $MaintenancesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [terrainTable, maintenances];
}

typedef $$TerrainTableTableCreateCompanionBuilder = TerrainTableCompanion
    Function({
  Value<int> id,
  required int numero,
  required String type,
  required String statut,
});
typedef $$TerrainTableTableUpdateCompanionBuilder = TerrainTableCompanion
    Function({
  Value<int> id,
  Value<int> numero,
  Value<String> type,
  Value<String> statut,
});

class $$TerrainTableTableFilterComposer
    extends Composer<_$AppDatabase, $TerrainTableTable> {
  $$TerrainTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numero => $composableBuilder(
      column: $table.numero, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnFilters(column));
}

class $$TerrainTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TerrainTableTable> {
  $$TerrainTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numero => $composableBuilder(
      column: $table.numero, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statut => $composableBuilder(
      column: $table.statut, builder: (column) => ColumnOrderings(column));
}

class $$TerrainTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TerrainTableTable> {
  $$TerrainTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get numero =>
      $composableBuilder(column: $table.numero, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);
}

class $$TerrainTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TerrainTableTable,
    TerrainTableData,
    $$TerrainTableTableFilterComposer,
    $$TerrainTableTableOrderingComposer,
    $$TerrainTableTableAnnotationComposer,
    $$TerrainTableTableCreateCompanionBuilder,
    $$TerrainTableTableUpdateCompanionBuilder,
    (
      TerrainTableData,
      BaseReferences<_$AppDatabase, $TerrainTableTable, TerrainTableData>
    ),
    TerrainTableData,
    PrefetchHooks Function()> {
  $$TerrainTableTableTableManager(_$AppDatabase db, $TerrainTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TerrainTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TerrainTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TerrainTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> numero = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> statut = const Value.absent(),
          }) =>
              TerrainTableCompanion(
            id: id,
            numero: numero,
            type: type,
            statut: statut,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int numero,
            required String type,
            required String statut,
          }) =>
              TerrainTableCompanion.insert(
            id: id,
            numero: numero,
            type: type,
            statut: statut,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TerrainTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TerrainTableTable,
    TerrainTableData,
    $$TerrainTableTableFilterComposer,
    $$TerrainTableTableOrderingComposer,
    $$TerrainTableTableAnnotationComposer,
    $$TerrainTableTableCreateCompanionBuilder,
    $$TerrainTableTableUpdateCompanionBuilder,
    (
      TerrainTableData,
      BaseReferences<_$AppDatabase, $TerrainTableTable, TerrainTableData>
    ),
    TerrainTableData,
    PrefetchHooks Function()>;
typedef $$MaintenancesTableCreateCompanionBuilder = MaintenancesCompanion
    Function({
  Value<int> id,
  required int terrainId,
  required String type,
  Value<String?> commentaire,
  required DateTime date,
  Value<int> sacsTerreUtilises,
  Value<int> sacsSableUtilises,
});
typedef $$MaintenancesTableUpdateCompanionBuilder = MaintenancesCompanion
    Function({
  Value<int> id,
  Value<int> terrainId,
  Value<String> type,
  Value<String?> commentaire,
  Value<DateTime> date,
  Value<int> sacsTerreUtilises,
  Value<int> sacsSableUtilises,
});

class $$MaintenancesTableFilterComposer
    extends Composer<_$AppDatabase, $MaintenancesTable> {
  $$MaintenancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get terrainId => $composableBuilder(
      column: $table.terrainId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commentaire => $composableBuilder(
      column: $table.commentaire, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sacsTerreUtilises => $composableBuilder(
      column: $table.sacsTerreUtilises,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sacsSableUtilises => $composableBuilder(
      column: $table.sacsSableUtilises,
      builder: (column) => ColumnFilters(column));
}

class $$MaintenancesTableOrderingComposer
    extends Composer<_$AppDatabase, $MaintenancesTable> {
  $$MaintenancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get terrainId => $composableBuilder(
      column: $table.terrainId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commentaire => $composableBuilder(
      column: $table.commentaire, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sacsTerreUtilises => $composableBuilder(
      column: $table.sacsTerreUtilises,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sacsSableUtilises => $composableBuilder(
      column: $table.sacsSableUtilises,
      builder: (column) => ColumnOrderings(column));
}

class $$MaintenancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaintenancesTable> {
  $$MaintenancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get terrainId =>
      $composableBuilder(column: $table.terrainId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get commentaire => $composableBuilder(
      column: $table.commentaire, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get sacsTerreUtilises => $composableBuilder(
      column: $table.sacsTerreUtilises, builder: (column) => column);

  GeneratedColumn<int> get sacsSableUtilises => $composableBuilder(
      column: $table.sacsSableUtilises, builder: (column) => column);
}

class $$MaintenancesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MaintenancesTable,
    MaintenanceEntity,
    $$MaintenancesTableFilterComposer,
    $$MaintenancesTableOrderingComposer,
    $$MaintenancesTableAnnotationComposer,
    $$MaintenancesTableCreateCompanionBuilder,
    $$MaintenancesTableUpdateCompanionBuilder,
    (
      MaintenanceEntity,
      BaseReferences<_$AppDatabase, $MaintenancesTable, MaintenanceEntity>
    ),
    MaintenanceEntity,
    PrefetchHooks Function()> {
  $$MaintenancesTableTableManager(_$AppDatabase db, $MaintenancesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaintenancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaintenancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaintenancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> terrainId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> commentaire = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int> sacsTerreUtilises = const Value.absent(),
            Value<int> sacsSableUtilises = const Value.absent(),
          }) =>
              MaintenancesCompanion(
            id: id,
            terrainId: terrainId,
            type: type,
            commentaire: commentaire,
            date: date,
            sacsTerreUtilises: sacsTerreUtilises,
            sacsSableUtilises: sacsSableUtilises,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int terrainId,
            required String type,
            Value<String?> commentaire = const Value.absent(),
            required DateTime date,
            Value<int> sacsTerreUtilises = const Value.absent(),
            Value<int> sacsSableUtilises = const Value.absent(),
          }) =>
              MaintenancesCompanion.insert(
            id: id,
            terrainId: terrainId,
            type: type,
            commentaire: commentaire,
            date: date,
            sacsTerreUtilises: sacsTerreUtilises,
            sacsSableUtilises: sacsSableUtilises,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MaintenancesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MaintenancesTable,
    MaintenanceEntity,
    $$MaintenancesTableFilterComposer,
    $$MaintenancesTableOrderingComposer,
    $$MaintenancesTableAnnotationComposer,
    $$MaintenancesTableCreateCompanionBuilder,
    $$MaintenancesTableUpdateCompanionBuilder,
    (
      MaintenanceEntity,
      BaseReferences<_$AppDatabase, $MaintenancesTable, MaintenanceEntity>
    ),
    MaintenanceEntity,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TerrainTableTableTableManager get terrainTable =>
      $$TerrainTableTableTableManager(_db, _db.terrainTable);
  $$MaintenancesTableTableManager get maintenances =>
      $$MaintenancesTableTableManager(_db, _db.maintenances);
}
