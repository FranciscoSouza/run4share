// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, Activity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  @override
  late final GeneratedColumnWithTypeConverter<ActivitySource, String> source =
      GeneratedColumn<String>('source', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ActivitySource>($ActivitiesTable.$convertersource);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sportTypeMeta =
      const VerificationMeta('sportType');
  @override
  late final GeneratedColumn<String> sportType = GeneratedColumn<String>(
      'sport_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startLocalMeta =
      const VerificationMeta('startLocal');
  @override
  late final GeneratedColumn<DateTime> startLocal = GeneratedColumn<DateTime>(
      'start_local', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _startUtcMeta =
      const VerificationMeta('startUtc');
  @override
  late final GeneratedColumn<DateTime> startUtc = GeneratedColumn<DateTime>(
      'start_utc', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _distanceMeta =
      const VerificationMeta('distance');
  @override
  late final GeneratedColumn<double> distance = GeneratedColumn<double>(
      'distance', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _movingTimeMeta =
      const VerificationMeta('movingTime');
  @override
  late final GeneratedColumn<int> movingTime = GeneratedColumn<int>(
      'moving_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _elapsedTimeMeta =
      const VerificationMeta('elapsedTime');
  @override
  late final GeneratedColumn<int> elapsedTime = GeneratedColumn<int>(
      'elapsed_time', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _averageSpeedMeta =
      const VerificationMeta('averageSpeed');
  @override
  late final GeneratedColumn<double> averageSpeed = GeneratedColumn<double>(
      'average_speed', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _averageHeartrateMeta =
      const VerificationMeta('averageHeartrate');
  @override
  late final GeneratedColumn<double> averageHeartrate = GeneratedColumn<double>(
      'average_heartrate', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _caloriesMeta =
      const VerificationMeta('calories');
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
      'calories', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _elevationGainMeta =
      const VerificationMeta('elevationGain');
  @override
  late final GeneratedColumn<double> elevationGain = GeneratedColumn<double>(
      'elevation_gain', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        source,
        sourceId,
        name,
        sportType,
        startLocal,
        startUtc,
        distance,
        movingTime,
        elapsedTime,
        averageSpeed,
        averageHeartrate,
        calories,
        elevationGain
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(Insertable<Activity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sport_type')) {
      context.handle(_sportTypeMeta,
          sportType.isAcceptableOrUnknown(data['sport_type']!, _sportTypeMeta));
    } else if (isInserting) {
      context.missing(_sportTypeMeta);
    }
    if (data.containsKey('start_local')) {
      context.handle(
          _startLocalMeta,
          startLocal.isAcceptableOrUnknown(
              data['start_local']!, _startLocalMeta));
    } else if (isInserting) {
      context.missing(_startLocalMeta);
    }
    if (data.containsKey('start_utc')) {
      context.handle(_startUtcMeta,
          startUtc.isAcceptableOrUnknown(data['start_utc']!, _startUtcMeta));
    }
    if (data.containsKey('distance')) {
      context.handle(_distanceMeta,
          distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta));
    }
    if (data.containsKey('moving_time')) {
      context.handle(
          _movingTimeMeta,
          movingTime.isAcceptableOrUnknown(
              data['moving_time']!, _movingTimeMeta));
    } else if (isInserting) {
      context.missing(_movingTimeMeta);
    }
    if (data.containsKey('elapsed_time')) {
      context.handle(
          _elapsedTimeMeta,
          elapsedTime.isAcceptableOrUnknown(
              data['elapsed_time']!, _elapsedTimeMeta));
    }
    if (data.containsKey('average_speed')) {
      context.handle(
          _averageSpeedMeta,
          averageSpeed.isAcceptableOrUnknown(
              data['average_speed']!, _averageSpeedMeta));
    }
    if (data.containsKey('average_heartrate')) {
      context.handle(
          _averageHeartrateMeta,
          averageHeartrate.isAcceptableOrUnknown(
              data['average_heartrate']!, _averageHeartrateMeta));
    }
    if (data.containsKey('calories')) {
      context.handle(_caloriesMeta,
          calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta));
    }
    if (data.containsKey('elevation_gain')) {
      context.handle(
          _elevationGainMeta,
          elevationGain.isAcceptableOrUnknown(
              data['elevation_gain']!, _elevationGainMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {source, sourceId},
      ];
  @override
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      source: $ActivitiesTable.$convertersource.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!),
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sportType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sport_type'])!,
      startLocal: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_local'])!,
      startUtc: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_utc']),
      distance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}distance']),
      movingTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}moving_time'])!,
      elapsedTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}elapsed_time']),
      averageSpeed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}average_speed']),
      averageHeartrate: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}average_heartrate']),
      calories: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}calories']),
      elevationGain: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}elevation_gain']),
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActivitySource, String, String> $convertersource =
      const EnumNameConverter<ActivitySource>(ActivitySource.values);
}

class Activity extends DataClass implements Insertable<Activity> {
  final int id;
  final ActivitySource source;

  /// The source's own ID (Strava activity ID); null for manual ones.
  final String? sourceId;
  final String name;

  /// Strava's sport_type names (Run, Ride, Hike, Walk, WeightTraining...).
  final String sportType;

  /// Wall-clock start time where the activity happened, stored as UTC.
  /// Show its fields as they are; never call toLocal() on it.
  final DateTime startLocal;

  /// The real instant it started, used to page through Strava. Null for
  /// manual activities.
  final DateTime? startUtc;

  /// Metres; null when the activity has no distance.
  final double? distance;

  /// Seconds.
  final int movingTime;
  final int? elapsedTime;

  /// Metres per second.
  final double? averageSpeed;
  final double? averageHeartrate;
  final double? calories;
  final double? elevationGain;
  const Activity(
      {required this.id,
      required this.source,
      this.sourceId,
      required this.name,
      required this.sportType,
      required this.startLocal,
      this.startUtc,
      this.distance,
      required this.movingTime,
      this.elapsedTime,
      this.averageSpeed,
      this.averageHeartrate,
      this.calories,
      this.elevationGain});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['source'] =
          Variable<String>($ActivitiesTable.$convertersource.toSql(source));
    }
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['name'] = Variable<String>(name);
    map['sport_type'] = Variable<String>(sportType);
    map['start_local'] = Variable<DateTime>(startLocal);
    if (!nullToAbsent || startUtc != null) {
      map['start_utc'] = Variable<DateTime>(startUtc);
    }
    if (!nullToAbsent || distance != null) {
      map['distance'] = Variable<double>(distance);
    }
    map['moving_time'] = Variable<int>(movingTime);
    if (!nullToAbsent || elapsedTime != null) {
      map['elapsed_time'] = Variable<int>(elapsedTime);
    }
    if (!nullToAbsent || averageSpeed != null) {
      map['average_speed'] = Variable<double>(averageSpeed);
    }
    if (!nullToAbsent || averageHeartrate != null) {
      map['average_heartrate'] = Variable<double>(averageHeartrate);
    }
    if (!nullToAbsent || calories != null) {
      map['calories'] = Variable<double>(calories);
    }
    if (!nullToAbsent || elevationGain != null) {
      map['elevation_gain'] = Variable<double>(elevationGain);
    }
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      source: Value(source),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      name: Value(name),
      sportType: Value(sportType),
      startLocal: Value(startLocal),
      startUtc: startUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(startUtc),
      distance: distance == null && nullToAbsent
          ? const Value.absent()
          : Value(distance),
      movingTime: Value(movingTime),
      elapsedTime: elapsedTime == null && nullToAbsent
          ? const Value.absent()
          : Value(elapsedTime),
      averageSpeed: averageSpeed == null && nullToAbsent
          ? const Value.absent()
          : Value(averageSpeed),
      averageHeartrate: averageHeartrate == null && nullToAbsent
          ? const Value.absent()
          : Value(averageHeartrate),
      calories: calories == null && nullToAbsent
          ? const Value.absent()
          : Value(calories),
      elevationGain: elevationGain == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationGain),
    );
  }

  factory Activity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activity(
      id: serializer.fromJson<int>(json['id']),
      source: $ActivitiesTable.$convertersource
          .fromJson(serializer.fromJson<String>(json['source'])),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      name: serializer.fromJson<String>(json['name']),
      sportType: serializer.fromJson<String>(json['sportType']),
      startLocal: serializer.fromJson<DateTime>(json['startLocal']),
      startUtc: serializer.fromJson<DateTime?>(json['startUtc']),
      distance: serializer.fromJson<double?>(json['distance']),
      movingTime: serializer.fromJson<int>(json['movingTime']),
      elapsedTime: serializer.fromJson<int?>(json['elapsedTime']),
      averageSpeed: serializer.fromJson<double?>(json['averageSpeed']),
      averageHeartrate: serializer.fromJson<double?>(json['averageHeartrate']),
      calories: serializer.fromJson<double?>(json['calories']),
      elevationGain: serializer.fromJson<double?>(json['elevationGain']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'source': serializer
          .toJson<String>($ActivitiesTable.$convertersource.toJson(source)),
      'sourceId': serializer.toJson<String?>(sourceId),
      'name': serializer.toJson<String>(name),
      'sportType': serializer.toJson<String>(sportType),
      'startLocal': serializer.toJson<DateTime>(startLocal),
      'startUtc': serializer.toJson<DateTime?>(startUtc),
      'distance': serializer.toJson<double?>(distance),
      'movingTime': serializer.toJson<int>(movingTime),
      'elapsedTime': serializer.toJson<int?>(elapsedTime),
      'averageSpeed': serializer.toJson<double?>(averageSpeed),
      'averageHeartrate': serializer.toJson<double?>(averageHeartrate),
      'calories': serializer.toJson<double?>(calories),
      'elevationGain': serializer.toJson<double?>(elevationGain),
    };
  }

  Activity copyWith(
          {int? id,
          ActivitySource? source,
          Value<String?> sourceId = const Value.absent(),
          String? name,
          String? sportType,
          DateTime? startLocal,
          Value<DateTime?> startUtc = const Value.absent(),
          Value<double?> distance = const Value.absent(),
          int? movingTime,
          Value<int?> elapsedTime = const Value.absent(),
          Value<double?> averageSpeed = const Value.absent(),
          Value<double?> averageHeartrate = const Value.absent(),
          Value<double?> calories = const Value.absent(),
          Value<double?> elevationGain = const Value.absent()}) =>
      Activity(
        id: id ?? this.id,
        source: source ?? this.source,
        sourceId: sourceId.present ? sourceId.value : this.sourceId,
        name: name ?? this.name,
        sportType: sportType ?? this.sportType,
        startLocal: startLocal ?? this.startLocal,
        startUtc: startUtc.present ? startUtc.value : this.startUtc,
        distance: distance.present ? distance.value : this.distance,
        movingTime: movingTime ?? this.movingTime,
        elapsedTime: elapsedTime.present ? elapsedTime.value : this.elapsedTime,
        averageSpeed:
            averageSpeed.present ? averageSpeed.value : this.averageSpeed,
        averageHeartrate: averageHeartrate.present
            ? averageHeartrate.value
            : this.averageHeartrate,
        calories: calories.present ? calories.value : this.calories,
        elevationGain:
            elevationGain.present ? elevationGain.value : this.elevationGain,
      );
  Activity copyWithCompanion(ActivitiesCompanion data) {
    return Activity(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      name: data.name.present ? data.name.value : this.name,
      sportType: data.sportType.present ? data.sportType.value : this.sportType,
      startLocal:
          data.startLocal.present ? data.startLocal.value : this.startLocal,
      startUtc: data.startUtc.present ? data.startUtc.value : this.startUtc,
      distance: data.distance.present ? data.distance.value : this.distance,
      movingTime:
          data.movingTime.present ? data.movingTime.value : this.movingTime,
      elapsedTime:
          data.elapsedTime.present ? data.elapsedTime.value : this.elapsedTime,
      averageSpeed: data.averageSpeed.present
          ? data.averageSpeed.value
          : this.averageSpeed,
      averageHeartrate: data.averageHeartrate.present
          ? data.averageHeartrate.value
          : this.averageHeartrate,
      calories: data.calories.present ? data.calories.value : this.calories,
      elevationGain: data.elevationGain.present
          ? data.elevationGain.value
          : this.elevationGain,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activity(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name, ')
          ..write('sportType: $sportType, ')
          ..write('startLocal: $startLocal, ')
          ..write('startUtc: $startUtc, ')
          ..write('distance: $distance, ')
          ..write('movingTime: $movingTime, ')
          ..write('elapsedTime: $elapsedTime, ')
          ..write('averageSpeed: $averageSpeed, ')
          ..write('averageHeartrate: $averageHeartrate, ')
          ..write('calories: $calories, ')
          ..write('elevationGain: $elevationGain')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      source,
      sourceId,
      name,
      sportType,
      startLocal,
      startUtc,
      distance,
      movingTime,
      elapsedTime,
      averageSpeed,
      averageHeartrate,
      calories,
      elevationGain);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.id == this.id &&
          other.source == this.source &&
          other.sourceId == this.sourceId &&
          other.name == this.name &&
          other.sportType == this.sportType &&
          other.startLocal == this.startLocal &&
          other.startUtc == this.startUtc &&
          other.distance == this.distance &&
          other.movingTime == this.movingTime &&
          other.elapsedTime == this.elapsedTime &&
          other.averageSpeed == this.averageSpeed &&
          other.averageHeartrate == this.averageHeartrate &&
          other.calories == this.calories &&
          other.elevationGain == this.elevationGain);
}

class ActivitiesCompanion extends UpdateCompanion<Activity> {
  final Value<int> id;
  final Value<ActivitySource> source;
  final Value<String?> sourceId;
  final Value<String> name;
  final Value<String> sportType;
  final Value<DateTime> startLocal;
  final Value<DateTime?> startUtc;
  final Value<double?> distance;
  final Value<int> movingTime;
  final Value<int?> elapsedTime;
  final Value<double?> averageSpeed;
  final Value<double?> averageHeartrate;
  final Value<double?> calories;
  final Value<double?> elevationGain;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.name = const Value.absent(),
    this.sportType = const Value.absent(),
    this.startLocal = const Value.absent(),
    this.startUtc = const Value.absent(),
    this.distance = const Value.absent(),
    this.movingTime = const Value.absent(),
    this.elapsedTime = const Value.absent(),
    this.averageSpeed = const Value.absent(),
    this.averageHeartrate = const Value.absent(),
    this.calories = const Value.absent(),
    this.elevationGain = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    this.id = const Value.absent(),
    required ActivitySource source,
    this.sourceId = const Value.absent(),
    required String name,
    required String sportType,
    required DateTime startLocal,
    this.startUtc = const Value.absent(),
    this.distance = const Value.absent(),
    required int movingTime,
    this.elapsedTime = const Value.absent(),
    this.averageSpeed = const Value.absent(),
    this.averageHeartrate = const Value.absent(),
    this.calories = const Value.absent(),
    this.elevationGain = const Value.absent(),
  })  : source = Value(source),
        name = Value(name),
        sportType = Value(sportType),
        startLocal = Value(startLocal),
        movingTime = Value(movingTime);
  static Insertable<Activity> custom({
    Expression<int>? id,
    Expression<String>? source,
    Expression<String>? sourceId,
    Expression<String>? name,
    Expression<String>? sportType,
    Expression<DateTime>? startLocal,
    Expression<DateTime>? startUtc,
    Expression<double>? distance,
    Expression<int>? movingTime,
    Expression<int>? elapsedTime,
    Expression<double>? averageSpeed,
    Expression<double>? averageHeartrate,
    Expression<double>? calories,
    Expression<double>? elevationGain,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (sourceId != null) 'source_id': sourceId,
      if (name != null) 'name': name,
      if (sportType != null) 'sport_type': sportType,
      if (startLocal != null) 'start_local': startLocal,
      if (startUtc != null) 'start_utc': startUtc,
      if (distance != null) 'distance': distance,
      if (movingTime != null) 'moving_time': movingTime,
      if (elapsedTime != null) 'elapsed_time': elapsedTime,
      if (averageSpeed != null) 'average_speed': averageSpeed,
      if (averageHeartrate != null) 'average_heartrate': averageHeartrate,
      if (calories != null) 'calories': calories,
      if (elevationGain != null) 'elevation_gain': elevationGain,
    });
  }

  ActivitiesCompanion copyWith(
      {Value<int>? id,
      Value<ActivitySource>? source,
      Value<String?>? sourceId,
      Value<String>? name,
      Value<String>? sportType,
      Value<DateTime>? startLocal,
      Value<DateTime?>? startUtc,
      Value<double?>? distance,
      Value<int>? movingTime,
      Value<int?>? elapsedTime,
      Value<double?>? averageSpeed,
      Value<double?>? averageHeartrate,
      Value<double?>? calories,
      Value<double?>? elevationGain}) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      name: name ?? this.name,
      sportType: sportType ?? this.sportType,
      startLocal: startLocal ?? this.startLocal,
      startUtc: startUtc ?? this.startUtc,
      distance: distance ?? this.distance,
      movingTime: movingTime ?? this.movingTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      averageHeartrate: averageHeartrate ?? this.averageHeartrate,
      calories: calories ?? this.calories,
      elevationGain: elevationGain ?? this.elevationGain,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
          $ActivitiesTable.$convertersource.toSql(source.value));
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sportType.present) {
      map['sport_type'] = Variable<String>(sportType.value);
    }
    if (startLocal.present) {
      map['start_local'] = Variable<DateTime>(startLocal.value);
    }
    if (startUtc.present) {
      map['start_utc'] = Variable<DateTime>(startUtc.value);
    }
    if (distance.present) {
      map['distance'] = Variable<double>(distance.value);
    }
    if (movingTime.present) {
      map['moving_time'] = Variable<int>(movingTime.value);
    }
    if (elapsedTime.present) {
      map['elapsed_time'] = Variable<int>(elapsedTime.value);
    }
    if (averageSpeed.present) {
      map['average_speed'] = Variable<double>(averageSpeed.value);
    }
    if (averageHeartrate.present) {
      map['average_heartrate'] = Variable<double>(averageHeartrate.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (elevationGain.present) {
      map['elevation_gain'] = Variable<double>(elevationGain.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('name: $name, ')
          ..write('sportType: $sportType, ')
          ..write('startLocal: $startLocal, ')
          ..write('startUtc: $startUtc, ')
          ..write('distance: $distance, ')
          ..write('movingTime: $movingTime, ')
          ..write('elapsedTime: $elapsedTime, ')
          ..write('averageSpeed: $averageSpeed, ')
          ..write('averageHeartrate: $averageHeartrate, ')
          ..write('calories: $calories, ')
          ..write('elevationGain: $elevationGain')
          ..write(')'))
        .toString();
  }
}

class $PreferencesTable extends Preferences
    with TableInfo<$PreferencesTable, Preference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferences';
  @override
  VerificationContext validateIntegrity(Insertable<Preference> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Preference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Preference(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $PreferencesTable createAlias(String alias) {
    return $PreferencesTable(attachedDatabase, alias);
  }
}

class Preference extends DataClass implements Insertable<Preference> {
  final String key;
  final String value;
  const Preference({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  PreferencesCompanion toCompanion(bool nullToAbsent) {
    return PreferencesCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory Preference.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Preference(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Preference copyWith({String? key, String? value}) => Preference(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  Preference copyWithCompanion(PreferencesCompanion data) {
    return Preference(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Preference(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Preference &&
          other.key == this.key &&
          other.value == this.value);
}

class PreferencesCompanion extends UpdateCompanion<Preference> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const PreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferencesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<Preference> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferencesCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return PreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $PreferencesTable preferences = $PreferencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [activities, preferences];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ActivitiesTableCreateCompanionBuilder = ActivitiesCompanion Function({
  Value<int> id,
  required ActivitySource source,
  Value<String?> sourceId,
  required String name,
  required String sportType,
  required DateTime startLocal,
  Value<DateTime?> startUtc,
  Value<double?> distance,
  required int movingTime,
  Value<int?> elapsedTime,
  Value<double?> averageSpeed,
  Value<double?> averageHeartrate,
  Value<double?> calories,
  Value<double?> elevationGain,
});
typedef $$ActivitiesTableUpdateCompanionBuilder = ActivitiesCompanion Function({
  Value<int> id,
  Value<ActivitySource> source,
  Value<String?> sourceId,
  Value<String> name,
  Value<String> sportType,
  Value<DateTime> startLocal,
  Value<DateTime?> startUtc,
  Value<double?> distance,
  Value<int> movingTime,
  Value<int?> elapsedTime,
  Value<double?> averageSpeed,
  Value<double?> averageHeartrate,
  Value<double?> calories,
  Value<double?> elevationGain,
});

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ActivitySource, ActivitySource, String>
      get source => $composableBuilder(
          column: $table.source,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sportType => $composableBuilder(
      column: $table.sportType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startLocal => $composableBuilder(
      column: $table.startLocal, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startUtc => $composableBuilder(
      column: $table.startUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get movingTime => $composableBuilder(
      column: $table.movingTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get elapsedTime => $composableBuilder(
      column: $table.elapsedTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get averageSpeed => $composableBuilder(
      column: $table.averageSpeed, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get averageHeartrate => $composableBuilder(
      column: $table.averageHeartrate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get elevationGain => $composableBuilder(
      column: $table.elevationGain, builder: (column) => ColumnFilters(column));
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
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sportType => $composableBuilder(
      column: $table.sportType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startLocal => $composableBuilder(
      column: $table.startLocal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startUtc => $composableBuilder(
      column: $table.startUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get movingTime => $composableBuilder(
      column: $table.movingTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get elapsedTime => $composableBuilder(
      column: $table.elapsedTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get averageSpeed => $composableBuilder(
      column: $table.averageSpeed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get averageHeartrate => $composableBuilder(
      column: $table.averageHeartrate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get calories => $composableBuilder(
      column: $table.calories, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get elevationGain => $composableBuilder(
      column: $table.elevationGain,
      builder: (column) => ColumnOrderings(column));
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivitySource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sportType =>
      $composableBuilder(column: $table.sportType, builder: (column) => column);

  GeneratedColumn<DateTime> get startLocal => $composableBuilder(
      column: $table.startLocal, builder: (column) => column);

  GeneratedColumn<DateTime> get startUtc =>
      $composableBuilder(column: $table.startUtc, builder: (column) => column);

  GeneratedColumn<double> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);

  GeneratedColumn<int> get movingTime => $composableBuilder(
      column: $table.movingTime, builder: (column) => column);

  GeneratedColumn<int> get elapsedTime => $composableBuilder(
      column: $table.elapsedTime, builder: (column) => column);

  GeneratedColumn<double> get averageSpeed => $composableBuilder(
      column: $table.averageSpeed, builder: (column) => column);

  GeneratedColumn<double> get averageHeartrate => $composableBuilder(
      column: $table.averageHeartrate, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get elevationGain => $composableBuilder(
      column: $table.elevationGain, builder: (column) => column);
}

class $$ActivitiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivitiesTable,
    Activity,
    $$ActivitiesTableFilterComposer,
    $$ActivitiesTableOrderingComposer,
    $$ActivitiesTableAnnotationComposer,
    $$ActivitiesTableCreateCompanionBuilder,
    $$ActivitiesTableUpdateCompanionBuilder,
    (Activity, BaseReferences<_$AppDatabase, $ActivitiesTable, Activity>),
    Activity,
    PrefetchHooks Function()> {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<ActivitySource> source = const Value.absent(),
            Value<String?> sourceId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> sportType = const Value.absent(),
            Value<DateTime> startLocal = const Value.absent(),
            Value<DateTime?> startUtc = const Value.absent(),
            Value<double?> distance = const Value.absent(),
            Value<int> movingTime = const Value.absent(),
            Value<int?> elapsedTime = const Value.absent(),
            Value<double?> averageSpeed = const Value.absent(),
            Value<double?> averageHeartrate = const Value.absent(),
            Value<double?> calories = const Value.absent(),
            Value<double?> elevationGain = const Value.absent(),
          }) =>
              ActivitiesCompanion(
            id: id,
            source: source,
            sourceId: sourceId,
            name: name,
            sportType: sportType,
            startLocal: startLocal,
            startUtc: startUtc,
            distance: distance,
            movingTime: movingTime,
            elapsedTime: elapsedTime,
            averageSpeed: averageSpeed,
            averageHeartrate: averageHeartrate,
            calories: calories,
            elevationGain: elevationGain,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required ActivitySource source,
            Value<String?> sourceId = const Value.absent(),
            required String name,
            required String sportType,
            required DateTime startLocal,
            Value<DateTime?> startUtc = const Value.absent(),
            Value<double?> distance = const Value.absent(),
            required int movingTime,
            Value<int?> elapsedTime = const Value.absent(),
            Value<double?> averageSpeed = const Value.absent(),
            Value<double?> averageHeartrate = const Value.absent(),
            Value<double?> calories = const Value.absent(),
            Value<double?> elevationGain = const Value.absent(),
          }) =>
              ActivitiesCompanion.insert(
            id: id,
            source: source,
            sourceId: sourceId,
            name: name,
            sportType: sportType,
            startLocal: startLocal,
            startUtc: startUtc,
            distance: distance,
            movingTime: movingTime,
            elapsedTime: elapsedTime,
            averageSpeed: averageSpeed,
            averageHeartrate: averageHeartrate,
            calories: calories,
            elevationGain: elevationGain,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ActivitiesTable, Activity>(table),
                    BaseReferences<_$AppDatabase, $ActivitiesTable, Activity>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ActivitiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ActivitiesTable,
    Activity,
    $$ActivitiesTableFilterComposer,
    $$ActivitiesTableOrderingComposer,
    $$ActivitiesTableAnnotationComposer,
    $$ActivitiesTableCreateCompanionBuilder,
    $$ActivitiesTableUpdateCompanionBuilder,
    (Activity, BaseReferences<_$AppDatabase, $ActivitiesTable, Activity>),
    Activity,
    PrefetchHooks Function()>;
typedef $$PreferencesTableCreateCompanionBuilder = PreferencesCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$PreferencesTableUpdateCompanionBuilder = PreferencesCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$PreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$PreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$PreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$PreferencesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PreferencesTable,
    Preference,
    $$PreferencesTableFilterComposer,
    $$PreferencesTableOrderingComposer,
    $$PreferencesTableAnnotationComposer,
    $$PreferencesTableCreateCompanionBuilder,
    $$PreferencesTableUpdateCompanionBuilder,
    (Preference, BaseReferences<_$AppDatabase, $PreferencesTable, Preference>),
    Preference,
    PrefetchHooks Function()> {
  $$PreferencesTableTableManager(_$AppDatabase db, $PreferencesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PreferencesCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              PreferencesCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PreferencesTable, Preference>(table),
                    BaseReferences<_$AppDatabase, $PreferencesTable,
                        Preference>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PreferencesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PreferencesTable,
    Preference,
    $$PreferencesTableFilterComposer,
    $$PreferencesTableOrderingComposer,
    $$PreferencesTableAnnotationComposer,
    $$PreferencesTableCreateCompanionBuilder,
    $$PreferencesTableUpdateCompanionBuilder,
    (Preference, BaseReferences<_$AppDatabase, $PreferencesTable, Preference>),
    Preference,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$PreferencesTableTableManager get preferences =>
      $$PreferencesTableTableManager(_db, _db.preferences);
}
