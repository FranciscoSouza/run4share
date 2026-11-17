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
  static const VerificationMeta _prCountMeta =
      const VerificationMeta('prCount');
  @override
  late final GeneratedColumn<int> prCount = GeneratedColumn<int>(
      'pr_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _raceMeta = const VerificationMeta('race');
  @override
  late final GeneratedColumn<bool> race = GeneratedColumn<bool>(
      'race', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("race" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _polylineMeta =
      const VerificationMeta('polyline');
  @override
  late final GeneratedColumn<String> polyline = GeneratedColumn<String>(
      'polyline', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _gearIdMeta = const VerificationMeta('gearId');
  @override
  late final GeneratedColumn<String> gearId = GeneratedColumn<String>(
      'gear_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _splitsJsonMeta =
      const VerificationMeta('splitsJson');
  @override
  late final GeneratedColumn<String> splitsJson = GeneratedColumn<String>(
      'splits_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _elevationJsonMeta =
      const VerificationMeta('elevationJson');
  @override
  late final GeneratedColumn<String> elevationJson = GeneratedColumn<String>(
      'elevation_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _streamsJsonMeta =
      const VerificationMeta('streamsJson');
  @override
  late final GeneratedColumn<String> streamsJson = GeneratedColumn<String>(
      'streams_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoCountMeta =
      const VerificationMeta('photoCount');
  @override
  late final GeneratedColumn<int> photoCount = GeneratedColumn<int>(
      'photo_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _photosJsonMeta =
      const VerificationMeta('photosJson');
  @override
  late final GeneratedColumn<String> photosJson = GeneratedColumn<String>(
      'photos_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        elevationGain,
        prCount,
        race,
        polyline,
        gearId,
        splitsJson,
        elevationJson,
        streamsJson,
        photoCount,
        photosJson
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
    if (data.containsKey('pr_count')) {
      context.handle(_prCountMeta,
          prCount.isAcceptableOrUnknown(data['pr_count']!, _prCountMeta));
    }
    if (data.containsKey('race')) {
      context.handle(
          _raceMeta, race.isAcceptableOrUnknown(data['race']!, _raceMeta));
    }
    if (data.containsKey('polyline')) {
      context.handle(_polylineMeta,
          polyline.isAcceptableOrUnknown(data['polyline']!, _polylineMeta));
    }
    if (data.containsKey('gear_id')) {
      context.handle(_gearIdMeta,
          gearId.isAcceptableOrUnknown(data['gear_id']!, _gearIdMeta));
    }
    if (data.containsKey('splits_json')) {
      context.handle(
          _splitsJsonMeta,
          splitsJson.isAcceptableOrUnknown(
              data['splits_json']!, _splitsJsonMeta));
    }
    if (data.containsKey('elevation_json')) {
      context.handle(
          _elevationJsonMeta,
          elevationJson.isAcceptableOrUnknown(
              data['elevation_json']!, _elevationJsonMeta));
    }
    if (data.containsKey('streams_json')) {
      context.handle(
          _streamsJsonMeta,
          streamsJson.isAcceptableOrUnknown(
              data['streams_json']!, _streamsJsonMeta));
    }
    if (data.containsKey('photo_count')) {
      context.handle(
          _photoCountMeta,
          photoCount.isAcceptableOrUnknown(
              data['photo_count']!, _photoCountMeta));
    }
    if (data.containsKey('photos_json')) {
      context.handle(
          _photosJsonMeta,
          photosJson.isAcceptableOrUnknown(
              data['photos_json']!, _photosJsonMeta));
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
      prCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pr_count']),
      race: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}race'])!,
      polyline: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}polyline']),
      gearId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gear_id']),
      splitsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}splits_json']),
      elevationJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}elevation_json']),
      streamsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}streams_json']),
      photoCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}photo_count']),
      photosJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photos_json']),
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

  /// Personal records Strava found in it (best efforts); null when not
  /// from Strava.
  final int? prCount;

  /// A race: Strava's "Race" workout type, or the manual form's switch.
  final bool race;

  /// The route, as an encoded polyline (Strava only).
  final String? polyline;

  /// The shoe: a Strava gear ID, or `manual:<name>` for typed ones.
  final String? gearId;

  /// Per-kilometre splits as JSON: [[metres, seconds, climb], ...].
  final String? splitsJson;

  /// Elevation profile as JSON, downsampled: [[metres, altitude], ...].
  final String? elevationJson;

  /// Time series for the charts (`ActivityStreams.toJson`): distance,
  /// altitude, heart rate, speed and pauses. Null until fetched; an
  /// activity without streams stores an empty set so it isn't re-asked.
  final String? streamsJson;

  /// Photos on the activity, per Strava's list (0 or null: none).
  final int? photoCount;

  /// Thumbnails as JSON: {"count": n, "photos": [{"id": ..., "url": ...}]}.
  /// Fetched after a sync; refetched when the count changes.
  final String? photosJson;
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
      this.elevationGain,
      this.prCount,
      required this.race,
      this.polyline,
      this.gearId,
      this.splitsJson,
      this.elevationJson,
      this.streamsJson,
      this.photoCount,
      this.photosJson});
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
    if (!nullToAbsent || prCount != null) {
      map['pr_count'] = Variable<int>(prCount);
    }
    map['race'] = Variable<bool>(race);
    if (!nullToAbsent || polyline != null) {
      map['polyline'] = Variable<String>(polyline);
    }
    if (!nullToAbsent || gearId != null) {
      map['gear_id'] = Variable<String>(gearId);
    }
    if (!nullToAbsent || splitsJson != null) {
      map['splits_json'] = Variable<String>(splitsJson);
    }
    if (!nullToAbsent || elevationJson != null) {
      map['elevation_json'] = Variable<String>(elevationJson);
    }
    if (!nullToAbsent || streamsJson != null) {
      map['streams_json'] = Variable<String>(streamsJson);
    }
    if (!nullToAbsent || photoCount != null) {
      map['photo_count'] = Variable<int>(photoCount);
    }
    if (!nullToAbsent || photosJson != null) {
      map['photos_json'] = Variable<String>(photosJson);
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
      prCount: prCount == null && nullToAbsent
          ? const Value.absent()
          : Value(prCount),
      race: Value(race),
      polyline: polyline == null && nullToAbsent
          ? const Value.absent()
          : Value(polyline),
      gearId:
          gearId == null && nullToAbsent ? const Value.absent() : Value(gearId),
      splitsJson: splitsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(splitsJson),
      elevationJson: elevationJson == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationJson),
      streamsJson: streamsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(streamsJson),
      photoCount: photoCount == null && nullToAbsent
          ? const Value.absent()
          : Value(photoCount),
      photosJson: photosJson == null && nullToAbsent
          ? const Value.absent()
          : Value(photosJson),
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
      prCount: serializer.fromJson<int?>(json['prCount']),
      race: serializer.fromJson<bool>(json['race']),
      polyline: serializer.fromJson<String?>(json['polyline']),
      gearId: serializer.fromJson<String?>(json['gearId']),
      splitsJson: serializer.fromJson<String?>(json['splitsJson']),
      elevationJson: serializer.fromJson<String?>(json['elevationJson']),
      streamsJson: serializer.fromJson<String?>(json['streamsJson']),
      photoCount: serializer.fromJson<int?>(json['photoCount']),
      photosJson: serializer.fromJson<String?>(json['photosJson']),
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
      'prCount': serializer.toJson<int?>(prCount),
      'race': serializer.toJson<bool>(race),
      'polyline': serializer.toJson<String?>(polyline),
      'gearId': serializer.toJson<String?>(gearId),
      'splitsJson': serializer.toJson<String?>(splitsJson),
      'elevationJson': serializer.toJson<String?>(elevationJson),
      'streamsJson': serializer.toJson<String?>(streamsJson),
      'photoCount': serializer.toJson<int?>(photoCount),
      'photosJson': serializer.toJson<String?>(photosJson),
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
          Value<double?> elevationGain = const Value.absent(),
          Value<int?> prCount = const Value.absent(),
          bool? race,
          Value<String?> polyline = const Value.absent(),
          Value<String?> gearId = const Value.absent(),
          Value<String?> splitsJson = const Value.absent(),
          Value<String?> elevationJson = const Value.absent(),
          Value<String?> streamsJson = const Value.absent(),
          Value<int?> photoCount = const Value.absent(),
          Value<String?> photosJson = const Value.absent()}) =>
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
        prCount: prCount.present ? prCount.value : this.prCount,
        race: race ?? this.race,
        polyline: polyline.present ? polyline.value : this.polyline,
        gearId: gearId.present ? gearId.value : this.gearId,
        splitsJson: splitsJson.present ? splitsJson.value : this.splitsJson,
        elevationJson:
            elevationJson.present ? elevationJson.value : this.elevationJson,
        streamsJson: streamsJson.present ? streamsJson.value : this.streamsJson,
        photoCount: photoCount.present ? photoCount.value : this.photoCount,
        photosJson: photosJson.present ? photosJson.value : this.photosJson,
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
      prCount: data.prCount.present ? data.prCount.value : this.prCount,
      race: data.race.present ? data.race.value : this.race,
      polyline: data.polyline.present ? data.polyline.value : this.polyline,
      gearId: data.gearId.present ? data.gearId.value : this.gearId,
      splitsJson:
          data.splitsJson.present ? data.splitsJson.value : this.splitsJson,
      elevationJson: data.elevationJson.present
          ? data.elevationJson.value
          : this.elevationJson,
      streamsJson:
          data.streamsJson.present ? data.streamsJson.value : this.streamsJson,
      photoCount:
          data.photoCount.present ? data.photoCount.value : this.photoCount,
      photosJson:
          data.photosJson.present ? data.photosJson.value : this.photosJson,
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
          ..write('elevationGain: $elevationGain, ')
          ..write('prCount: $prCount, ')
          ..write('race: $race, ')
          ..write('polyline: $polyline, ')
          ..write('gearId: $gearId, ')
          ..write('splitsJson: $splitsJson, ')
          ..write('elevationJson: $elevationJson, ')
          ..write('streamsJson: $streamsJson, ')
          ..write('photoCount: $photoCount, ')
          ..write('photosJson: $photosJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
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
        elevationGain,
        prCount,
        race,
        polyline,
        gearId,
        splitsJson,
        elevationJson,
        streamsJson,
        photoCount,
        photosJson
      ]);
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
          other.elevationGain == this.elevationGain &&
          other.prCount == this.prCount &&
          other.race == this.race &&
          other.polyline == this.polyline &&
          other.gearId == this.gearId &&
          other.splitsJson == this.splitsJson &&
          other.elevationJson == this.elevationJson &&
          other.streamsJson == this.streamsJson &&
          other.photoCount == this.photoCount &&
          other.photosJson == this.photosJson);
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
  final Value<int?> prCount;
  final Value<bool> race;
  final Value<String?> polyline;
  final Value<String?> gearId;
  final Value<String?> splitsJson;
  final Value<String?> elevationJson;
  final Value<String?> streamsJson;
  final Value<int?> photoCount;
  final Value<String?> photosJson;
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
    this.prCount = const Value.absent(),
    this.race = const Value.absent(),
    this.polyline = const Value.absent(),
    this.gearId = const Value.absent(),
    this.splitsJson = const Value.absent(),
    this.elevationJson = const Value.absent(),
    this.streamsJson = const Value.absent(),
    this.photoCount = const Value.absent(),
    this.photosJson = const Value.absent(),
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
    this.prCount = const Value.absent(),
    this.race = const Value.absent(),
    this.polyline = const Value.absent(),
    this.gearId = const Value.absent(),
    this.splitsJson = const Value.absent(),
    this.elevationJson = const Value.absent(),
    this.streamsJson = const Value.absent(),
    this.photoCount = const Value.absent(),
    this.photosJson = const Value.absent(),
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
    Expression<int>? prCount,
    Expression<bool>? race,
    Expression<String>? polyline,
    Expression<String>? gearId,
    Expression<String>? splitsJson,
    Expression<String>? elevationJson,
    Expression<String>? streamsJson,
    Expression<int>? photoCount,
    Expression<String>? photosJson,
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
      if (prCount != null) 'pr_count': prCount,
      if (race != null) 'race': race,
      if (polyline != null) 'polyline': polyline,
      if (gearId != null) 'gear_id': gearId,
      if (splitsJson != null) 'splits_json': splitsJson,
      if (elevationJson != null) 'elevation_json': elevationJson,
      if (streamsJson != null) 'streams_json': streamsJson,
      if (photoCount != null) 'photo_count': photoCount,
      if (photosJson != null) 'photos_json': photosJson,
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
      Value<double?>? elevationGain,
      Value<int?>? prCount,
      Value<bool>? race,
      Value<String?>? polyline,
      Value<String?>? gearId,
      Value<String?>? splitsJson,
      Value<String?>? elevationJson,
      Value<String?>? streamsJson,
      Value<int?>? photoCount,
      Value<String?>? photosJson}) {
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
      prCount: prCount ?? this.prCount,
      race: race ?? this.race,
      polyline: polyline ?? this.polyline,
      gearId: gearId ?? this.gearId,
      splitsJson: splitsJson ?? this.splitsJson,
      elevationJson: elevationJson ?? this.elevationJson,
      streamsJson: streamsJson ?? this.streamsJson,
      photoCount: photoCount ?? this.photoCount,
      photosJson: photosJson ?? this.photosJson,
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
    if (prCount.present) {
      map['pr_count'] = Variable<int>(prCount.value);
    }
    if (race.present) {
      map['race'] = Variable<bool>(race.value);
    }
    if (polyline.present) {
      map['polyline'] = Variable<String>(polyline.value);
    }
    if (gearId.present) {
      map['gear_id'] = Variable<String>(gearId.value);
    }
    if (splitsJson.present) {
      map['splits_json'] = Variable<String>(splitsJson.value);
    }
    if (elevationJson.present) {
      map['elevation_json'] = Variable<String>(elevationJson.value);
    }
    if (streamsJson.present) {
      map['streams_json'] = Variable<String>(streamsJson.value);
    }
    if (photoCount.present) {
      map['photo_count'] = Variable<int>(photoCount.value);
    }
    if (photosJson.present) {
      map['photos_json'] = Variable<String>(photosJson.value);
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
          ..write('elevationGain: $elevationGain, ')
          ..write('prCount: $prCount, ')
          ..write('race: $race, ')
          ..write('polyline: $polyline, ')
          ..write('gearId: $gearId, ')
          ..write('splitsJson: $splitsJson, ')
          ..write('elevationJson: $elevationJson, ')
          ..write('streamsJson: $streamsJson, ')
          ..write('photoCount: $photoCount, ')
          ..write('photosJson: $photosJson')
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

class $CreationsTable extends Creations
    with TableInfo<$CreationsTable, Creation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CreationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _activityIdMeta =
      const VerificationMeta('activityId');
  @override
  late final GeneratedColumn<int> activityId = GeneratedColumn<int>(
      'activity_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _activityNameMeta =
      const VerificationMeta('activityName');
  @override
  late final GeneratedColumn<String> activityName = GeneratedColumn<String>(
      'activity_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
      'format', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stickerOnlyMeta =
      const VerificationMeta('stickerOnly');
  @override
  late final GeneratedColumn<bool> stickerOnly = GeneratedColumn<bool>(
      'sticker_only', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("sticker_only" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _fileNameMeta =
      const VerificationMeta('fileName');
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
      'file_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
      'width', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
      'height', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _settingsMeta =
      const VerificationMeta('settings');
  @override
  late final GeneratedColumn<String> settings = GeneratedColumn<String>(
      'settings', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        activityId,
        activityName,
        createdAt,
        format,
        stickerOnly,
        fileName,
        width,
        height,
        settings
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'creations';
  @override
  VerificationContext validateIntegrity(Insertable<Creation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('activity_id')) {
      context.handle(
          _activityIdMeta,
          activityId.isAcceptableOrUnknown(
              data['activity_id']!, _activityIdMeta));
    }
    if (data.containsKey('activity_name')) {
      context.handle(
          _activityNameMeta,
          activityName.isAcceptableOrUnknown(
              data['activity_name']!, _activityNameMeta));
    } else if (isInserting) {
      context.missing(_activityNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('format')) {
      context.handle(_formatMeta,
          format.isAcceptableOrUnknown(data['format']!, _formatMeta));
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('sticker_only')) {
      context.handle(
          _stickerOnlyMeta,
          stickerOnly.isAcceptableOrUnknown(
              data['sticker_only']!, _stickerOnlyMeta));
    }
    if (data.containsKey('file_name')) {
      context.handle(_fileNameMeta,
          fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
          _widthMeta, width.isAcceptableOrUnknown(data['width']!, _widthMeta));
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta,
          height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('settings')) {
      context.handle(_settingsMeta,
          settings.isAcceptableOrUnknown(data['settings']!, _settingsMeta));
    } else if (isInserting) {
      context.missing(_settingsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Creation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Creation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      activityId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}activity_id']),
      activityName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activity_name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      format: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format'])!,
      stickerOnly: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}sticker_only'])!,
      fileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_name'])!,
      width: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}width'])!,
      height: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height'])!,
      settings: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}settings'])!,
    );
  }

  @override
  $CreationsTable createAlias(String alias) {
    return $CreationsTable(attachedDatabase, alias);
  }
}

class Creation extends DataClass implements Insertable<Creation> {
  final int id;

  /// The activity it was made from; null once that activity is deleted.
  final int? activityId;

  /// Copied so the creation keeps its caption after the activity goes.
  final String activityName;
  final DateTime createdAt;

  /// story, feed or square.
  final String format;

  /// Sticker on a transparent background, without the photo.
  final bool stickerOnly;

  /// File name inside the app's creations folder.
  final String fileName;
  final int width;
  final int height;

  /// The editor settings (photo, crop, theme, sticker, style) as JSON.
  final String settings;
  const Creation(
      {required this.id,
      this.activityId,
      required this.activityName,
      required this.createdAt,
      required this.format,
      required this.stickerOnly,
      required this.fileName,
      required this.width,
      required this.height,
      required this.settings});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || activityId != null) {
      map['activity_id'] = Variable<int>(activityId);
    }
    map['activity_name'] = Variable<String>(activityName);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['format'] = Variable<String>(format);
    map['sticker_only'] = Variable<bool>(stickerOnly);
    map['file_name'] = Variable<String>(fileName);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    map['settings'] = Variable<String>(settings);
    return map;
  }

  CreationsCompanion toCompanion(bool nullToAbsent) {
    return CreationsCompanion(
      id: Value(id),
      activityId: activityId == null && nullToAbsent
          ? const Value.absent()
          : Value(activityId),
      activityName: Value(activityName),
      createdAt: Value(createdAt),
      format: Value(format),
      stickerOnly: Value(stickerOnly),
      fileName: Value(fileName),
      width: Value(width),
      height: Value(height),
      settings: Value(settings),
    );
  }

  factory Creation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Creation(
      id: serializer.fromJson<int>(json['id']),
      activityId: serializer.fromJson<int?>(json['activityId']),
      activityName: serializer.fromJson<String>(json['activityName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      format: serializer.fromJson<String>(json['format']),
      stickerOnly: serializer.fromJson<bool>(json['stickerOnly']),
      fileName: serializer.fromJson<String>(json['fileName']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      settings: serializer.fromJson<String>(json['settings']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'activityId': serializer.toJson<int?>(activityId),
      'activityName': serializer.toJson<String>(activityName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'format': serializer.toJson<String>(format),
      'stickerOnly': serializer.toJson<bool>(stickerOnly),
      'fileName': serializer.toJson<String>(fileName),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'settings': serializer.toJson<String>(settings),
    };
  }

  Creation copyWith(
          {int? id,
          Value<int?> activityId = const Value.absent(),
          String? activityName,
          DateTime? createdAt,
          String? format,
          bool? stickerOnly,
          String? fileName,
          int? width,
          int? height,
          String? settings}) =>
      Creation(
        id: id ?? this.id,
        activityId: activityId.present ? activityId.value : this.activityId,
        activityName: activityName ?? this.activityName,
        createdAt: createdAt ?? this.createdAt,
        format: format ?? this.format,
        stickerOnly: stickerOnly ?? this.stickerOnly,
        fileName: fileName ?? this.fileName,
        width: width ?? this.width,
        height: height ?? this.height,
        settings: settings ?? this.settings,
      );
  Creation copyWithCompanion(CreationsCompanion data) {
    return Creation(
      id: data.id.present ? data.id.value : this.id,
      activityId:
          data.activityId.present ? data.activityId.value : this.activityId,
      activityName: data.activityName.present
          ? data.activityName.value
          : this.activityName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      format: data.format.present ? data.format.value : this.format,
      stickerOnly:
          data.stickerOnly.present ? data.stickerOnly.value : this.stickerOnly,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      settings: data.settings.present ? data.settings.value : this.settings,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Creation(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('activityName: $activityName, ')
          ..write('createdAt: $createdAt, ')
          ..write('format: $format, ')
          ..write('stickerOnly: $stickerOnly, ')
          ..write('fileName: $fileName, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('settings: $settings')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, activityId, activityName, createdAt,
      format, stickerOnly, fileName, width, height, settings);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Creation &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.activityName == this.activityName &&
          other.createdAt == this.createdAt &&
          other.format == this.format &&
          other.stickerOnly == this.stickerOnly &&
          other.fileName == this.fileName &&
          other.width == this.width &&
          other.height == this.height &&
          other.settings == this.settings);
}

class CreationsCompanion extends UpdateCompanion<Creation> {
  final Value<int> id;
  final Value<int?> activityId;
  final Value<String> activityName;
  final Value<DateTime> createdAt;
  final Value<String> format;
  final Value<bool> stickerOnly;
  final Value<String> fileName;
  final Value<int> width;
  final Value<int> height;
  final Value<String> settings;
  const CreationsCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.activityName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.format = const Value.absent(),
    this.stickerOnly = const Value.absent(),
    this.fileName = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.settings = const Value.absent(),
  });
  CreationsCompanion.insert({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    required String activityName,
    required DateTime createdAt,
    required String format,
    this.stickerOnly = const Value.absent(),
    required String fileName,
    required int width,
    required int height,
    required String settings,
  })  : activityName = Value(activityName),
        createdAt = Value(createdAt),
        format = Value(format),
        fileName = Value(fileName),
        width = Value(width),
        height = Value(height),
        settings = Value(settings);
  static Insertable<Creation> custom({
    Expression<int>? id,
    Expression<int>? activityId,
    Expression<String>? activityName,
    Expression<DateTime>? createdAt,
    Expression<String>? format,
    Expression<bool>? stickerOnly,
    Expression<String>? fileName,
    Expression<int>? width,
    Expression<int>? height,
    Expression<String>? settings,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (activityName != null) 'activity_name': activityName,
      if (createdAt != null) 'created_at': createdAt,
      if (format != null) 'format': format,
      if (stickerOnly != null) 'sticker_only': stickerOnly,
      if (fileName != null) 'file_name': fileName,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (settings != null) 'settings': settings,
    });
  }

  CreationsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? activityId,
      Value<String>? activityName,
      Value<DateTime>? createdAt,
      Value<String>? format,
      Value<bool>? stickerOnly,
      Value<String>? fileName,
      Value<int>? width,
      Value<int>? height,
      Value<String>? settings}) {
    return CreationsCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      activityName: activityName ?? this.activityName,
      createdAt: createdAt ?? this.createdAt,
      format: format ?? this.format,
      stickerOnly: stickerOnly ?? this.stickerOnly,
      fileName: fileName ?? this.fileName,
      width: width ?? this.width,
      height: height ?? this.height,
      settings: settings ?? this.settings,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<int>(activityId.value);
    }
    if (activityName.present) {
      map['activity_name'] = Variable<String>(activityName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (stickerOnly.present) {
      map['sticker_only'] = Variable<bool>(stickerOnly.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (settings.present) {
      map['settings'] = Variable<String>(settings.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CreationsCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('activityName: $activityName, ')
          ..write('createdAt: $createdAt, ')
          ..write('format: $format, ')
          ..write('stickerOnly: $stickerOnly, ')
          ..write('fileName: $fileName, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('settings: $settings')
          ..write(')'))
        .toString();
  }
}

class $GearTableTable extends GearTable with TableInfo<$GearTableTable, Gear> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GearTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _distanceMeta =
      const VerificationMeta('distance');
  @override
  late final GeneratedColumn<double> distance = GeneratedColumn<double>(
      'distance', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, distance];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gear';
  @override
  VerificationContext validateIntegrity(Insertable<Gear> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('distance')) {
      context.handle(_distanceMeta,
          distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta));
    } else if (isInserting) {
      context.missing(_distanceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Gear map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Gear(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      distance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}distance'])!,
    );
  }

  @override
  $GearTableTable createAlias(String alias) {
    return $GearTableTable(attachedDatabase, alias);
  }
}

class Gear extends DataClass implements Insertable<Gear> {
  final String id;
  final String name;

  /// Lifetime metres with it, as last known.
  final double distance;
  const Gear({required this.id, required this.name, required this.distance});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['distance'] = Variable<double>(distance);
    return map;
  }

  GearTableCompanion toCompanion(bool nullToAbsent) {
    return GearTableCompanion(
      id: Value(id),
      name: Value(name),
      distance: Value(distance),
    );
  }

  factory Gear.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Gear(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      distance: serializer.fromJson<double>(json['distance']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'distance': serializer.toJson<double>(distance),
    };
  }

  Gear copyWith({String? id, String? name, double? distance}) => Gear(
        id: id ?? this.id,
        name: name ?? this.name,
        distance: distance ?? this.distance,
      );
  Gear copyWithCompanion(GearTableCompanion data) {
    return Gear(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      distance: data.distance.present ? data.distance.value : this.distance,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Gear(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('distance: $distance')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, distance);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Gear &&
          other.id == this.id &&
          other.name == this.name &&
          other.distance == this.distance);
}

class GearTableCompanion extends UpdateCompanion<Gear> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> distance;
  final Value<int> rowid;
  const GearTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.distance = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GearTableCompanion.insert({
    required String id,
    required String name,
    required double distance,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        distance = Value(distance);
  static Insertable<Gear> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? distance,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (distance != null) 'distance': distance,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GearTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<double>? distance,
      Value<int>? rowid}) {
    return GearTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      distance: distance ?? this.distance,
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
    if (distance.present) {
      map['distance'] = Variable<double>(distance.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GearTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('distance: $distance, ')
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
  late final $CreationsTable creations = $CreationsTable(this);
  late final $GearTableTable gearTable = $GearTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [activities, preferences, creations, gearTable];
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
  Value<int?> prCount,
  Value<bool> race,
  Value<String?> polyline,
  Value<String?> gearId,
  Value<String?> splitsJson,
  Value<String?> elevationJson,
  Value<String?> streamsJson,
  Value<int?> photoCount,
  Value<String?> photosJson,
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
  Value<int?> prCount,
  Value<bool> race,
  Value<String?> polyline,
  Value<String?> gearId,
  Value<String?> splitsJson,
  Value<String?> elevationJson,
  Value<String?> streamsJson,
  Value<int?> photoCount,
  Value<String?> photosJson,
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

  ColumnFilters<int> get prCount => $composableBuilder(
      column: $table.prCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get race => $composableBuilder(
      column: $table.race, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get polyline => $composableBuilder(
      column: $table.polyline, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gearId => $composableBuilder(
      column: $table.gearId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get splitsJson => $composableBuilder(
      column: $table.splitsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get elevationJson => $composableBuilder(
      column: $table.elevationJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get streamsJson => $composableBuilder(
      column: $table.streamsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get photoCount => $composableBuilder(
      column: $table.photoCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photosJson => $composableBuilder(
      column: $table.photosJson, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<int> get prCount => $composableBuilder(
      column: $table.prCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get race => $composableBuilder(
      column: $table.race, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get polyline => $composableBuilder(
      column: $table.polyline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gearId => $composableBuilder(
      column: $table.gearId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get splitsJson => $composableBuilder(
      column: $table.splitsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get elevationJson => $composableBuilder(
      column: $table.elevationJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get streamsJson => $composableBuilder(
      column: $table.streamsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get photoCount => $composableBuilder(
      column: $table.photoCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photosJson => $composableBuilder(
      column: $table.photosJson, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<int> get prCount =>
      $composableBuilder(column: $table.prCount, builder: (column) => column);

  GeneratedColumn<bool> get race =>
      $composableBuilder(column: $table.race, builder: (column) => column);

  GeneratedColumn<String> get polyline =>
      $composableBuilder(column: $table.polyline, builder: (column) => column);

  GeneratedColumn<String> get gearId =>
      $composableBuilder(column: $table.gearId, builder: (column) => column);

  GeneratedColumn<String> get splitsJson => $composableBuilder(
      column: $table.splitsJson, builder: (column) => column);

  GeneratedColumn<String> get elevationJson => $composableBuilder(
      column: $table.elevationJson, builder: (column) => column);

  GeneratedColumn<String> get streamsJson => $composableBuilder(
      column: $table.streamsJson, builder: (column) => column);

  GeneratedColumn<int> get photoCount => $composableBuilder(
      column: $table.photoCount, builder: (column) => column);

  GeneratedColumn<String> get photosJson => $composableBuilder(
      column: $table.photosJson, builder: (column) => column);
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
            Value<int?> prCount = const Value.absent(),
            Value<bool> race = const Value.absent(),
            Value<String?> polyline = const Value.absent(),
            Value<String?> gearId = const Value.absent(),
            Value<String?> splitsJson = const Value.absent(),
            Value<String?> elevationJson = const Value.absent(),
            Value<String?> streamsJson = const Value.absent(),
            Value<int?> photoCount = const Value.absent(),
            Value<String?> photosJson = const Value.absent(),
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
            prCount: prCount,
            race: race,
            polyline: polyline,
            gearId: gearId,
            splitsJson: splitsJson,
            elevationJson: elevationJson,
            streamsJson: streamsJson,
            photoCount: photoCount,
            photosJson: photosJson,
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
            Value<int?> prCount = const Value.absent(),
            Value<bool> race = const Value.absent(),
            Value<String?> polyline = const Value.absent(),
            Value<String?> gearId = const Value.absent(),
            Value<String?> splitsJson = const Value.absent(),
            Value<String?> elevationJson = const Value.absent(),
            Value<String?> streamsJson = const Value.absent(),
            Value<int?> photoCount = const Value.absent(),
            Value<String?> photosJson = const Value.absent(),
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
            prCount: prCount,
            race: race,
            polyline: polyline,
            gearId: gearId,
            splitsJson: splitsJson,
            elevationJson: elevationJson,
            streamsJson: streamsJson,
            photoCount: photoCount,
            photosJson: photosJson,
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
typedef $$CreationsTableCreateCompanionBuilder = CreationsCompanion Function({
  Value<int> id,
  Value<int?> activityId,
  required String activityName,
  required DateTime createdAt,
  required String format,
  Value<bool> stickerOnly,
  required String fileName,
  required int width,
  required int height,
  required String settings,
});
typedef $$CreationsTableUpdateCompanionBuilder = CreationsCompanion Function({
  Value<int> id,
  Value<int?> activityId,
  Value<String> activityName,
  Value<DateTime> createdAt,
  Value<String> format,
  Value<bool> stickerOnly,
  Value<String> fileName,
  Value<int> width,
  Value<int> height,
  Value<String> settings,
});

class $$CreationsTableFilterComposer
    extends Composer<_$AppDatabase, $CreationsTable> {
  $$CreationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get activityId => $composableBuilder(
      column: $table.activityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activityName => $composableBuilder(
      column: $table.activityName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get stickerOnly => $composableBuilder(
      column: $table.stickerOnly, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get settings => $composableBuilder(
      column: $table.settings, builder: (column) => ColumnFilters(column));
}

class $$CreationsTableOrderingComposer
    extends Composer<_$AppDatabase, $CreationsTable> {
  $$CreationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get activityId => $composableBuilder(
      column: $table.activityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityName => $composableBuilder(
      column: $table.activityName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get stickerOnly => $composableBuilder(
      column: $table.stickerOnly, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get width => $composableBuilder(
      column: $table.width, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get height => $composableBuilder(
      column: $table.height, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get settings => $composableBuilder(
      column: $table.settings, builder: (column) => ColumnOrderings(column));
}

class $$CreationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CreationsTable> {
  $$CreationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get activityId => $composableBuilder(
      column: $table.activityId, builder: (column) => column);

  GeneratedColumn<String> get activityName => $composableBuilder(
      column: $table.activityName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<bool> get stickerOnly => $composableBuilder(
      column: $table.stickerOnly, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get settings =>
      $composableBuilder(column: $table.settings, builder: (column) => column);
}

class $$CreationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CreationsTable,
    Creation,
    $$CreationsTableFilterComposer,
    $$CreationsTableOrderingComposer,
    $$CreationsTableAnnotationComposer,
    $$CreationsTableCreateCompanionBuilder,
    $$CreationsTableUpdateCompanionBuilder,
    (Creation, BaseReferences<_$AppDatabase, $CreationsTable, Creation>),
    Creation,
    PrefetchHooks Function()> {
  $$CreationsTableTableManager(_$AppDatabase db, $CreationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CreationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CreationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CreationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> activityId = const Value.absent(),
            Value<String> activityName = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> format = const Value.absent(),
            Value<bool> stickerOnly = const Value.absent(),
            Value<String> fileName = const Value.absent(),
            Value<int> width = const Value.absent(),
            Value<int> height = const Value.absent(),
            Value<String> settings = const Value.absent(),
          }) =>
              CreationsCompanion(
            id: id,
            activityId: activityId,
            activityName: activityName,
            createdAt: createdAt,
            format: format,
            stickerOnly: stickerOnly,
            fileName: fileName,
            width: width,
            height: height,
            settings: settings,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> activityId = const Value.absent(),
            required String activityName,
            required DateTime createdAt,
            required String format,
            Value<bool> stickerOnly = const Value.absent(),
            required String fileName,
            required int width,
            required int height,
            required String settings,
          }) =>
              CreationsCompanion.insert(
            id: id,
            activityId: activityId,
            activityName: activityName,
            createdAt: createdAt,
            format: format,
            stickerOnly: stickerOnly,
            fileName: fileName,
            width: width,
            height: height,
            settings: settings,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CreationsTable, Creation>(table),
                    BaseReferences<_$AppDatabase, $CreationsTable, Creation>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CreationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CreationsTable,
    Creation,
    $$CreationsTableFilterComposer,
    $$CreationsTableOrderingComposer,
    $$CreationsTableAnnotationComposer,
    $$CreationsTableCreateCompanionBuilder,
    $$CreationsTableUpdateCompanionBuilder,
    (Creation, BaseReferences<_$AppDatabase, $CreationsTable, Creation>),
    Creation,
    PrefetchHooks Function()>;
typedef $$GearTableTableCreateCompanionBuilder = GearTableCompanion Function({
  required String id,
  required String name,
  required double distance,
  Value<int> rowid,
});
typedef $$GearTableTableUpdateCompanionBuilder = GearTableCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<double> distance,
  Value<int> rowid,
});

class $$GearTableTableFilterComposer
    extends Composer<_$AppDatabase, $GearTableTable> {
  $$GearTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnFilters(column));
}

class $$GearTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GearTableTable> {
  $$GearTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnOrderings(column));
}

class $$GearTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GearTableTable> {
  $$GearTableTableAnnotationComposer({
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

  GeneratedColumn<double> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);
}

class $$GearTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GearTableTable,
    Gear,
    $$GearTableTableFilterComposer,
    $$GearTableTableOrderingComposer,
    $$GearTableTableAnnotationComposer,
    $$GearTableTableCreateCompanionBuilder,
    $$GearTableTableUpdateCompanionBuilder,
    (Gear, BaseReferences<_$AppDatabase, $GearTableTable, Gear>),
    Gear,
    PrefetchHooks Function()> {
  $$GearTableTableTableManager(_$AppDatabase db, $GearTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GearTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GearTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GearTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> distance = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GearTableCompanion(
            id: id,
            name: name,
            distance: distance,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required double distance,
            Value<int> rowid = const Value.absent(),
          }) =>
              GearTableCompanion.insert(
            id: id,
            name: name,
            distance: distance,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$GearTableTable, Gear>(table),
                    BaseReferences<_$AppDatabase, $GearTableTable, Gear>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GearTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GearTableTable,
    Gear,
    $$GearTableTableFilterComposer,
    $$GearTableTableOrderingComposer,
    $$GearTableTableAnnotationComposer,
    $$GearTableTableCreateCompanionBuilder,
    $$GearTableTableUpdateCompanionBuilder,
    (Gear, BaseReferences<_$AppDatabase, $GearTableTable, Gear>),
    Gear,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$PreferencesTableTableManager get preferences =>
      $$PreferencesTableTableManager(_db, _db.preferences);
  $$CreationsTableTableManager get creations =>
      $$CreationsTableTableManager(_db, _db.creations);
  $$GearTableTableTableManager get gearTable =>
      $$GearTableTableTableManager(_db, _db.gearTable);
}
