// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'strava_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StravaSession {
  String get accessToken;
  String get refreshToken;

  /// When [accessToken] expires, in seconds since the epoch (Strava's
  /// `expires_at`).
  int get expiresAt;
  DateTime get connectedAt;
  int? get athleteId;
  String? get athleteName;

  /// What the user allowed on Strava's page; null for sessions from
  /// before scopes were stored.
  List<String>? get scopes;

  /// Create a copy of StravaSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StravaSessionCopyWith<StravaSession> get copyWith =>
      _$StravaSessionCopyWithImpl<StravaSession>(
          this as StravaSession, _$identity);

  /// Serializes this StravaSession to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    final _this = this as StravaSession;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StravaSession &&
            (identical(other.accessToken, _this.accessToken) ||
                other.accessToken == _this.accessToken) &&
            (identical(other.refreshToken, _this.refreshToken) ||
                other.refreshToken == _this.refreshToken) &&
            (identical(other.expiresAt, _this.expiresAt) ||
                other.expiresAt == _this.expiresAt) &&
            (identical(other.connectedAt, _this.connectedAt) ||
                other.connectedAt == _this.connectedAt) &&
            (identical(other.athleteId, _this.athleteId) ||
                other.athleteId == _this.athleteId) &&
            (identical(other.athleteName, _this.athleteName) ||
                other.athleteName == _this.athleteName) &&
            const DeepCollectionEquality().equals(other.scopes, _this.scopes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as StravaSession;
    return Object.hash(
        runtimeType,
        _this.accessToken,
        _this.refreshToken,
        _this.expiresAt,
        _this.connectedAt,
        _this.athleteId,
        _this.athleteName,
        const DeepCollectionEquality().hash(_this.scopes));
  }

  @override
  String toString() {
    final _this = this as StravaSession;
    return 'StravaSession(accessToken: ${_this.accessToken}, refreshToken: ${_this.refreshToken}, expiresAt: ${_this.expiresAt}, connectedAt: ${_this.connectedAt}, athleteId: ${_this.athleteId}, athleteName: ${_this.athleteName}, scopes: ${_this.scopes})';
  }
}

/// @nodoc
abstract mixin class $StravaSessionCopyWith<$Res> {
  factory $StravaSessionCopyWith(
          StravaSession value, $Res Function(StravaSession) _then) =
      _$StravaSessionCopyWithImpl;
  @useResult
  $Res call(
      {String accessToken,
      String refreshToken,
      int expiresAt,
      DateTime connectedAt,
      int? athleteId,
      String? athleteName,
      List<String>? scopes});
}

/// @nodoc
class _$StravaSessionCopyWithImpl<$Res>
    implements $StravaSessionCopyWith<$Res> {
  _$StravaSessionCopyWithImpl(this._self, this._then);

  final StravaSession _self;
  final $Res Function(StravaSession) _then;

  /// Create a copy of StravaSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? expiresAt = null,
    Object? connectedAt = null,
    Object? athleteId = freezed,
    Object? athleteName = freezed,
    Object? scopes = freezed,
  }) {
    return _then(StravaSession(
      accessToken: null == accessToken
          ? _self.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _self.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as int,
      connectedAt: null == connectedAt
          ? _self.connectedAt
          : connectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      athleteId: freezed == athleteId
          ? _self.athleteId
          : athleteId // ignore: cast_nullable_to_non_nullable
              as int?,
      athleteName: freezed == athleteName
          ? _self.athleteName
          : athleteName // ignore: cast_nullable_to_non_nullable
              as String?,
      scopes: freezed == scopes
          ? _self.scopes
          : scopes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// Adds pattern-matching-related methods to [StravaSession].
extension StravaSessionPatterns on StravaSession {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_StravaSession value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StravaSession() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_StravaSession value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StravaSession():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_StravaSession value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StravaSession() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String accessToken,
            String refreshToken,
            int expiresAt,
            DateTime connectedAt,
            int? athleteId,
            String? athleteName,
            List<String>? scopes)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StravaSession() when $default != null:
        return $default(
            _that.accessToken,
            _that.refreshToken,
            _that.expiresAt,
            _that.connectedAt,
            _that.athleteId,
            _that.athleteName,
            _that.scopes);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String accessToken,
            String refreshToken,
            int expiresAt,
            DateTime connectedAt,
            int? athleteId,
            String? athleteName,
            List<String>? scopes)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StravaSession():
        return $default(
            _that.accessToken,
            _that.refreshToken,
            _that.expiresAt,
            _that.connectedAt,
            _that.athleteId,
            _that.athleteName,
            _that.scopes);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String accessToken,
            String refreshToken,
            int expiresAt,
            DateTime connectedAt,
            int? athleteId,
            String? athleteName,
            List<String>? scopes)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StravaSession() when $default != null:
        return $default(
            _that.accessToken,
            _that.refreshToken,
            _that.expiresAt,
            _that.connectedAt,
            _that.athleteId,
            _that.athleteName,
            _that.scopes);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _StravaSession extends StravaSession {
  const _StravaSession(
      {required this.accessToken,
      required this.refreshToken,
      required this.expiresAt,
      required this.connectedAt,
      this.athleteId,
      this.athleteName,
      List<String>? scopes})
      : _scopes = scopes,
        super._();
  factory _StravaSession.fromJson(Map<String, dynamic> json) =>
      _$StravaSessionFromJson(json);

  @override
  final String accessToken;
  @override
  final String refreshToken;

  /// When [accessToken] expires, in seconds since the epoch (Strava's
  /// `expires_at`).
  @override
  final int expiresAt;
  @override
  final DateTime connectedAt;
  @override
  final int? athleteId;
  @override
  final String? athleteName;

  /// What the user allowed on Strava's page; null for sessions from
  /// before scopes were stored.
  final List<String>? _scopes;

  /// What the user allowed on Strava's page; null for sessions from
  /// before scopes were stored.
  @override
  List<String>? get scopes {
    final value = _scopes;
    if (value == null) return null;
    if (_scopes is EqualUnmodifiableListView) return _scopes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of StravaSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StravaSessionCopyWith<_StravaSession> get copyWith =>
      __$StravaSessionCopyWithImpl<_StravaSession>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StravaSessionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StravaSession &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.connectedAt, connectedAt) ||
                other.connectedAt == connectedAt) &&
            (identical(other.athleteId, athleteId) ||
                other.athleteId == athleteId) &&
            (identical(other.athleteName, athleteName) ||
                other.athleteName == athleteName) &&
            const DeepCollectionEquality().equals(other.scopes, _scopes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(
        runtimeType,
        accessToken,
        refreshToken,
        expiresAt,
        connectedAt,
        athleteId,
        athleteName,
        const DeepCollectionEquality().hash(_scopes));
  }

  @override
  String toString() {
    return 'StravaSession(accessToken: $accessToken, refreshToken: $refreshToken, expiresAt: $expiresAt, connectedAt: $connectedAt, athleteId: $athleteId, athleteName: $athleteName, scopes: $scopes)';
  }
}

/// @nodoc
abstract mixin class _$StravaSessionCopyWith<$Res>
    implements $StravaSessionCopyWith<$Res> {
  factory _$StravaSessionCopyWith(
          _StravaSession value, $Res Function(_StravaSession) _then) =
      __$StravaSessionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String accessToken,
      String refreshToken,
      int expiresAt,
      DateTime connectedAt,
      int? athleteId,
      String? athleteName,
      List<String>? scopes});
}

/// @nodoc
class __$StravaSessionCopyWithImpl<$Res>
    implements _$StravaSessionCopyWith<$Res> {
  __$StravaSessionCopyWithImpl(this._self, this._then);

  final _StravaSession _self;
  final $Res Function(_StravaSession) _then;

  /// Create a copy of StravaSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? expiresAt = null,
    Object? connectedAt = null,
    Object? athleteId = freezed,
    Object? athleteName = freezed,
    Object? scopes = freezed,
  }) {
    return _then(_StravaSession(
      accessToken: null == accessToken
          ? _self.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _self.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as int,
      connectedAt: null == connectedAt
          ? _self.connectedAt
          : connectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      athleteId: freezed == athleteId
          ? _self.athleteId
          : athleteId // ignore: cast_nullable_to_non_nullable
              as int?,
      athleteName: freezed == athleteName
          ? _self.athleteName
          : athleteName // ignore: cast_nullable_to_non_nullable
              as String?,
      scopes: freezed == scopes
          ? _self._scopes
          : scopes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
mixin _$StravaActivity {
  int get id;
  String get name;
  String get sportType;

  /// When it started, in UTC.
  DateTime get startDate;

  /// Wall-clock start time where the activity happened. Strava marks it
  /// with a Z, but it is not UTC: show its fields as they are and never
  /// call toLocal() on it.
  DateTime get startDateLocal;

  /// Metres.
  double get distance;

  /// Seconds.
  int get movingTime;
  int get elapsedTime;

  /// Metres per second.
  double? get averageSpeed;
  double? get averageHeartrate;
  double? get totalElevationGain;

  /// Only in Strava's single-activity detail, not in the list.
  double? get calories;

  /// Personal records Strava found in it.
  int? get prCount;

  /// Strava's workout type: 1 is a run race, 11 a ride race.
  int? get workoutType;

  /// The route as an encoded polyline (map.summary_polyline).
  @JsonKey(readValue: _summaryPolyline)
  String? get polyline;

  /// The shoe or bike used, e.g. "g12345".
  String? get gearId;

  /// Only in the detail: one split per kilometre, and per mile.
  List<StravaSplit> get splitsMetric;
  List<StravaSplit> get splitsStandard;

  /// Create a copy of StravaActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StravaActivityCopyWith<StravaActivity> get copyWith =>
      _$StravaActivityCopyWithImpl<StravaActivity>(
          this as StravaActivity, _$identity);

  /// Serializes this StravaActivity to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    final _this = this as StravaActivity;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StravaActivity &&
            (identical(other.id, _this.id) || other.id == _this.id) &&
            (identical(other.name, _this.name) || other.name == _this.name) &&
            (identical(other.sportType, _this.sportType) ||
                other.sportType == _this.sportType) &&
            (identical(other.startDate, _this.startDate) ||
                other.startDate == _this.startDate) &&
            (identical(other.startDateLocal, _this.startDateLocal) ||
                other.startDateLocal == _this.startDateLocal) &&
            (identical(other.distance, _this.distance) ||
                other.distance == _this.distance) &&
            (identical(other.movingTime, _this.movingTime) ||
                other.movingTime == _this.movingTime) &&
            (identical(other.elapsedTime, _this.elapsedTime) ||
                other.elapsedTime == _this.elapsedTime) &&
            (identical(other.averageSpeed, _this.averageSpeed) ||
                other.averageSpeed == _this.averageSpeed) &&
            (identical(other.averageHeartrate, _this.averageHeartrate) ||
                other.averageHeartrate == _this.averageHeartrate) &&
            (identical(other.totalElevationGain, _this.totalElevationGain) ||
                other.totalElevationGain == _this.totalElevationGain) &&
            (identical(other.calories, _this.calories) ||
                other.calories == _this.calories) &&
            (identical(other.prCount, _this.prCount) ||
                other.prCount == _this.prCount) &&
            (identical(other.workoutType, _this.workoutType) ||
                other.workoutType == _this.workoutType) &&
            (identical(other.polyline, _this.polyline) ||
                other.polyline == _this.polyline) &&
            (identical(other.gearId, _this.gearId) ||
                other.gearId == _this.gearId) &&
            const DeepCollectionEquality()
                .equals(other.splitsMetric, _this.splitsMetric) &&
            const DeepCollectionEquality()
                .equals(other.splitsStandard, _this.splitsStandard));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as StravaActivity;
    return Object.hash(
        runtimeType,
        _this.id,
        _this.name,
        _this.sportType,
        _this.startDate,
        _this.startDateLocal,
        _this.distance,
        _this.movingTime,
        _this.elapsedTime,
        _this.averageSpeed,
        _this.averageHeartrate,
        _this.totalElevationGain,
        _this.calories,
        _this.prCount,
        _this.workoutType,
        _this.polyline,
        _this.gearId,
        const DeepCollectionEquality().hash(_this.splitsMetric),
        const DeepCollectionEquality().hash(_this.splitsStandard));
  }

  @override
  String toString() {
    final _this = this as StravaActivity;
    return 'StravaActivity(id: ${_this.id}, name: ${_this.name}, sportType: ${_this.sportType}, startDate: ${_this.startDate}, startDateLocal: ${_this.startDateLocal}, distance: ${_this.distance}, movingTime: ${_this.movingTime}, elapsedTime: ${_this.elapsedTime}, averageSpeed: ${_this.averageSpeed}, averageHeartrate: ${_this.averageHeartrate}, totalElevationGain: ${_this.totalElevationGain}, calories: ${_this.calories}, prCount: ${_this.prCount}, workoutType: ${_this.workoutType}, polyline: ${_this.polyline}, gearId: ${_this.gearId}, splitsMetric: ${_this.splitsMetric}, splitsStandard: ${_this.splitsStandard})';
  }
}

/// @nodoc
abstract mixin class $StravaActivityCopyWith<$Res> {
  factory $StravaActivityCopyWith(
          StravaActivity value, $Res Function(StravaActivity) _then) =
      _$StravaActivityCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String name,
      String sportType,
      DateTime startDate,
      DateTime startDateLocal,
      double distance,
      int movingTime,
      int elapsedTime,
      double? averageSpeed,
      double? averageHeartrate,
      double? totalElevationGain,
      double? calories,
      int? prCount,
      int? workoutType,
      @JsonKey(readValue: _summaryPolyline) String? polyline,
      String? gearId,
      List<StravaSplit> splitsMetric,
      List<StravaSplit> splitsStandard});
}

/// @nodoc
class _$StravaActivityCopyWithImpl<$Res>
    implements $StravaActivityCopyWith<$Res> {
  _$StravaActivityCopyWithImpl(this._self, this._then);

  final StravaActivity _self;
  final $Res Function(StravaActivity) _then;

  /// Create a copy of StravaActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sportType = null,
    Object? startDate = null,
    Object? startDateLocal = null,
    Object? distance = null,
    Object? movingTime = null,
    Object? elapsedTime = null,
    Object? averageSpeed = freezed,
    Object? averageHeartrate = freezed,
    Object? totalElevationGain = freezed,
    Object? calories = freezed,
    Object? prCount = freezed,
    Object? workoutType = freezed,
    Object? polyline = freezed,
    Object? gearId = freezed,
    Object? splitsMetric = null,
    Object? splitsStandard = null,
  }) {
    return _then(StravaActivity(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sportType: null == sportType
          ? _self.sportType
          : sportType // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _self.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startDateLocal: null == startDateLocal
          ? _self.startDateLocal
          : startDateLocal // ignore: cast_nullable_to_non_nullable
              as DateTime,
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
      movingTime: null == movingTime
          ? _self.movingTime
          : movingTime // ignore: cast_nullable_to_non_nullable
              as int,
      elapsedTime: null == elapsedTime
          ? _self.elapsedTime
          : elapsedTime // ignore: cast_nullable_to_non_nullable
              as int,
      averageSpeed: freezed == averageSpeed
          ? _self.averageSpeed
          : averageSpeed // ignore: cast_nullable_to_non_nullable
              as double?,
      averageHeartrate: freezed == averageHeartrate
          ? _self.averageHeartrate
          : averageHeartrate // ignore: cast_nullable_to_non_nullable
              as double?,
      totalElevationGain: freezed == totalElevationGain
          ? _self.totalElevationGain
          : totalElevationGain // ignore: cast_nullable_to_non_nullable
              as double?,
      calories: freezed == calories
          ? _self.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as double?,
      prCount: freezed == prCount
          ? _self.prCount
          : prCount // ignore: cast_nullable_to_non_nullable
              as int?,
      workoutType: freezed == workoutType
          ? _self.workoutType
          : workoutType // ignore: cast_nullable_to_non_nullable
              as int?,
      polyline: freezed == polyline
          ? _self.polyline
          : polyline // ignore: cast_nullable_to_non_nullable
              as String?,
      gearId: freezed == gearId
          ? _self.gearId
          : gearId // ignore: cast_nullable_to_non_nullable
              as String?,
      splitsMetric: null == splitsMetric
          ? _self.splitsMetric
          : splitsMetric // ignore: cast_nullable_to_non_nullable
              as List<StravaSplit>,
      splitsStandard: null == splitsStandard
          ? _self.splitsStandard
          : splitsStandard // ignore: cast_nullable_to_non_nullable
              as List<StravaSplit>,
    ));
  }
}

/// Adds pattern-matching-related methods to [StravaActivity].
extension StravaActivityPatterns on StravaActivity {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_StravaActivity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StravaActivity() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_StravaActivity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StravaActivity():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_StravaActivity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StravaActivity() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int id,
            String name,
            String sportType,
            DateTime startDate,
            DateTime startDateLocal,
            double distance,
            int movingTime,
            int elapsedTime,
            double? averageSpeed,
            double? averageHeartrate,
            double? totalElevationGain,
            double? calories,
            int? prCount,
            int? workoutType,
            @JsonKey(readValue: _summaryPolyline) String? polyline,
            String? gearId,
            List<StravaSplit> splitsMetric,
            List<StravaSplit> splitsStandard)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StravaActivity() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.sportType,
            _that.startDate,
            _that.startDateLocal,
            _that.distance,
            _that.movingTime,
            _that.elapsedTime,
            _that.averageSpeed,
            _that.averageHeartrate,
            _that.totalElevationGain,
            _that.calories,
            _that.prCount,
            _that.workoutType,
            _that.polyline,
            _that.gearId,
            _that.splitsMetric,
            _that.splitsStandard);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int id,
            String name,
            String sportType,
            DateTime startDate,
            DateTime startDateLocal,
            double distance,
            int movingTime,
            int elapsedTime,
            double? averageSpeed,
            double? averageHeartrate,
            double? totalElevationGain,
            double? calories,
            int? prCount,
            int? workoutType,
            @JsonKey(readValue: _summaryPolyline) String? polyline,
            String? gearId,
            List<StravaSplit> splitsMetric,
            List<StravaSplit> splitsStandard)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StravaActivity():
        return $default(
            _that.id,
            _that.name,
            _that.sportType,
            _that.startDate,
            _that.startDateLocal,
            _that.distance,
            _that.movingTime,
            _that.elapsedTime,
            _that.averageSpeed,
            _that.averageHeartrate,
            _that.totalElevationGain,
            _that.calories,
            _that.prCount,
            _that.workoutType,
            _that.polyline,
            _that.gearId,
            _that.splitsMetric,
            _that.splitsStandard);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int id,
            String name,
            String sportType,
            DateTime startDate,
            DateTime startDateLocal,
            double distance,
            int movingTime,
            int elapsedTime,
            double? averageSpeed,
            double? averageHeartrate,
            double? totalElevationGain,
            double? calories,
            int? prCount,
            int? workoutType,
            @JsonKey(readValue: _summaryPolyline) String? polyline,
            String? gearId,
            List<StravaSplit> splitsMetric,
            List<StravaSplit> splitsStandard)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StravaActivity() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.sportType,
            _that.startDate,
            _that.startDateLocal,
            _that.distance,
            _that.movingTime,
            _that.elapsedTime,
            _that.averageSpeed,
            _that.averageHeartrate,
            _that.totalElevationGain,
            _that.calories,
            _that.prCount,
            _that.workoutType,
            _that.polyline,
            _that.gearId,
            _that.splitsMetric,
            _that.splitsStandard);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _StravaActivity extends StravaActivity {
  const _StravaActivity(
      {required this.id,
      required this.name,
      required this.sportType,
      required this.startDate,
      required this.startDateLocal,
      this.distance = 0,
      this.movingTime = 0,
      this.elapsedTime = 0,
      this.averageSpeed,
      this.averageHeartrate,
      this.totalElevationGain,
      this.calories,
      this.prCount,
      this.workoutType,
      @JsonKey(readValue: _summaryPolyline) this.polyline,
      this.gearId,
      List<StravaSplit> splitsMetric = const [],
      List<StravaSplit> splitsStandard = const []})
      : _splitsMetric = splitsMetric,
        _splitsStandard = splitsStandard,
        super._();
  factory _StravaActivity.fromJson(Map<String, dynamic> json) =>
      _$StravaActivityFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String sportType;

  /// When it started, in UTC.
  @override
  final DateTime startDate;

  /// Wall-clock start time where the activity happened. Strava marks it
  /// with a Z, but it is not UTC: show its fields as they are and never
  /// call toLocal() on it.
  @override
  final DateTime startDateLocal;

  /// Metres.
  @override
  @JsonKey()
  final double distance;

  /// Seconds.
  @override
  @JsonKey()
  final int movingTime;
  @override
  @JsonKey()
  final int elapsedTime;

  /// Metres per second.
  @override
  final double? averageSpeed;
  @override
  final double? averageHeartrate;
  @override
  final double? totalElevationGain;

  /// Only in Strava's single-activity detail, not in the list.
  @override
  final double? calories;

  /// Personal records Strava found in it.
  @override
  final int? prCount;

  /// Strava's workout type: 1 is a run race, 11 a ride race.
  @override
  final int? workoutType;

  /// The route as an encoded polyline (map.summary_polyline).
  @override
  @JsonKey(readValue: _summaryPolyline)
  final String? polyline;

  /// The shoe or bike used, e.g. "g12345".
  @override
  final String? gearId;

  /// Only in the detail: one split per kilometre, and per mile.
  final List<StravaSplit> _splitsMetric;

  /// Only in the detail: one split per kilometre, and per mile.
  @override
  @JsonKey()
  List<StravaSplit> get splitsMetric {
    if (_splitsMetric is EqualUnmodifiableListView) return _splitsMetric;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_splitsMetric);
  }

  final List<StravaSplit> _splitsStandard;
  @override
  @JsonKey()
  List<StravaSplit> get splitsStandard {
    if (_splitsStandard is EqualUnmodifiableListView) return _splitsStandard;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_splitsStandard);
  }

  /// Create a copy of StravaActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StravaActivityCopyWith<_StravaActivity> get copyWith =>
      __$StravaActivityCopyWithImpl<_StravaActivity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StravaActivityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StravaActivity &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sportType, sportType) ||
                other.sportType == sportType) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.startDateLocal, startDateLocal) ||
                other.startDateLocal == startDateLocal) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.movingTime, movingTime) ||
                other.movingTime == movingTime) &&
            (identical(other.elapsedTime, elapsedTime) ||
                other.elapsedTime == elapsedTime) &&
            (identical(other.averageSpeed, averageSpeed) ||
                other.averageSpeed == averageSpeed) &&
            (identical(other.averageHeartrate, averageHeartrate) ||
                other.averageHeartrate == averageHeartrate) &&
            (identical(other.totalElevationGain, totalElevationGain) ||
                other.totalElevationGain == totalElevationGain) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.prCount, prCount) || other.prCount == prCount) &&
            (identical(other.workoutType, workoutType) ||
                other.workoutType == workoutType) &&
            (identical(other.polyline, polyline) ||
                other.polyline == polyline) &&
            (identical(other.gearId, gearId) || other.gearId == gearId) &&
            const DeepCollectionEquality()
                .equals(other.splitsMetric, _splitsMetric) &&
            const DeepCollectionEquality()
                .equals(other.splitsStandard, _splitsStandard));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(
        runtimeType,
        id,
        name,
        sportType,
        startDate,
        startDateLocal,
        distance,
        movingTime,
        elapsedTime,
        averageSpeed,
        averageHeartrate,
        totalElevationGain,
        calories,
        prCount,
        workoutType,
        polyline,
        gearId,
        const DeepCollectionEquality().hash(_splitsMetric),
        const DeepCollectionEquality().hash(_splitsStandard));
  }

  @override
  String toString() {
    return 'StravaActivity(id: $id, name: $name, sportType: $sportType, startDate: $startDate, startDateLocal: $startDateLocal, distance: $distance, movingTime: $movingTime, elapsedTime: $elapsedTime, averageSpeed: $averageSpeed, averageHeartrate: $averageHeartrate, totalElevationGain: $totalElevationGain, calories: $calories, prCount: $prCount, workoutType: $workoutType, polyline: $polyline, gearId: $gearId, splitsMetric: $splitsMetric, splitsStandard: $splitsStandard)';
  }
}

/// @nodoc
abstract mixin class _$StravaActivityCopyWith<$Res>
    implements $StravaActivityCopyWith<$Res> {
  factory _$StravaActivityCopyWith(
          _StravaActivity value, $Res Function(_StravaActivity) _then) =
      __$StravaActivityCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String sportType,
      DateTime startDate,
      DateTime startDateLocal,
      double distance,
      int movingTime,
      int elapsedTime,
      double? averageSpeed,
      double? averageHeartrate,
      double? totalElevationGain,
      double? calories,
      int? prCount,
      int? workoutType,
      @JsonKey(readValue: _summaryPolyline) String? polyline,
      String? gearId,
      List<StravaSplit> splitsMetric,
      List<StravaSplit> splitsStandard});
}

/// @nodoc
class __$StravaActivityCopyWithImpl<$Res>
    implements _$StravaActivityCopyWith<$Res> {
  __$StravaActivityCopyWithImpl(this._self, this._then);

  final _StravaActivity _self;
  final $Res Function(_StravaActivity) _then;

  /// Create a copy of StravaActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? sportType = null,
    Object? startDate = null,
    Object? startDateLocal = null,
    Object? distance = null,
    Object? movingTime = null,
    Object? elapsedTime = null,
    Object? averageSpeed = freezed,
    Object? averageHeartrate = freezed,
    Object? totalElevationGain = freezed,
    Object? calories = freezed,
    Object? prCount = freezed,
    Object? workoutType = freezed,
    Object? polyline = freezed,
    Object? gearId = freezed,
    Object? splitsMetric = null,
    Object? splitsStandard = null,
  }) {
    return _then(_StravaActivity(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sportType: null == sportType
          ? _self.sportType
          : sportType // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _self.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startDateLocal: null == startDateLocal
          ? _self.startDateLocal
          : startDateLocal // ignore: cast_nullable_to_non_nullable
              as DateTime,
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
      movingTime: null == movingTime
          ? _self.movingTime
          : movingTime // ignore: cast_nullable_to_non_nullable
              as int,
      elapsedTime: null == elapsedTime
          ? _self.elapsedTime
          : elapsedTime // ignore: cast_nullable_to_non_nullable
              as int,
      averageSpeed: freezed == averageSpeed
          ? _self.averageSpeed
          : averageSpeed // ignore: cast_nullable_to_non_nullable
              as double?,
      averageHeartrate: freezed == averageHeartrate
          ? _self.averageHeartrate
          : averageHeartrate // ignore: cast_nullable_to_non_nullable
              as double?,
      totalElevationGain: freezed == totalElevationGain
          ? _self.totalElevationGain
          : totalElevationGain // ignore: cast_nullable_to_non_nullable
              as double?,
      calories: freezed == calories
          ? _self.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as double?,
      prCount: freezed == prCount
          ? _self.prCount
          : prCount // ignore: cast_nullable_to_non_nullable
              as int?,
      workoutType: freezed == workoutType
          ? _self.workoutType
          : workoutType // ignore: cast_nullable_to_non_nullable
              as int?,
      polyline: freezed == polyline
          ? _self.polyline
          : polyline // ignore: cast_nullable_to_non_nullable
              as String?,
      gearId: freezed == gearId
          ? _self.gearId
          : gearId // ignore: cast_nullable_to_non_nullable
              as String?,
      splitsMetric: null == splitsMetric
          ? _self._splitsMetric
          : splitsMetric // ignore: cast_nullable_to_non_nullable
              as List<StravaSplit>,
      splitsStandard: null == splitsStandard
          ? _self._splitsStandard
          : splitsStandard // ignore: cast_nullable_to_non_nullable
              as List<StravaSplit>,
    ));
  }
}

/// @nodoc
mixin _$StravaSplit {
  /// Metres actually covered (the last split is often short).
  double get distance;
  int get movingTime;
  double get elevationDifference;

  /// Create a copy of StravaSplit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StravaSplitCopyWith<StravaSplit> get copyWith =>
      _$StravaSplitCopyWithImpl<StravaSplit>(this as StravaSplit, _$identity);

  /// Serializes this StravaSplit to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    final _this = this as StravaSplit;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StravaSplit &&
            (identical(other.distance, _this.distance) ||
                other.distance == _this.distance) &&
            (identical(other.movingTime, _this.movingTime) ||
                other.movingTime == _this.movingTime) &&
            (identical(other.elevationDifference, _this.elevationDifference) ||
                other.elevationDifference == _this.elevationDifference));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as StravaSplit;
    return Object.hash(runtimeType, _this.distance, _this.movingTime,
        _this.elevationDifference);
  }

  @override
  String toString() {
    final _this = this as StravaSplit;
    return 'StravaSplit(distance: ${_this.distance}, movingTime: ${_this.movingTime}, elevationDifference: ${_this.elevationDifference})';
  }
}

/// @nodoc
abstract mixin class $StravaSplitCopyWith<$Res> {
  factory $StravaSplitCopyWith(
          StravaSplit value, $Res Function(StravaSplit) _then) =
      _$StravaSplitCopyWithImpl;
  @useResult
  $Res call({double distance, int movingTime, double elevationDifference});
}

/// @nodoc
class _$StravaSplitCopyWithImpl<$Res> implements $StravaSplitCopyWith<$Res> {
  _$StravaSplitCopyWithImpl(this._self, this._then);

  final StravaSplit _self;
  final $Res Function(StravaSplit) _then;

  /// Create a copy of StravaSplit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? distance = null,
    Object? movingTime = null,
    Object? elevationDifference = null,
  }) {
    return _then(StravaSplit(
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
      movingTime: null == movingTime
          ? _self.movingTime
          : movingTime // ignore: cast_nullable_to_non_nullable
              as int,
      elevationDifference: null == elevationDifference
          ? _self.elevationDifference
          : elevationDifference // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [StravaSplit].
extension StravaSplitPatterns on StravaSplit {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_StravaSplit value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StravaSplit() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_StravaSplit value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StravaSplit():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_StravaSplit value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StravaSplit() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            double distance, int movingTime, double elevationDifference)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StravaSplit() when $default != null:
        return $default(
            _that.distance, _that.movingTime, _that.elevationDifference);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            double distance, int movingTime, double elevationDifference)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StravaSplit():
        return $default(
            _that.distance, _that.movingTime, _that.elevationDifference);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            double distance, int movingTime, double elevationDifference)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StravaSplit() when $default != null:
        return $default(
            _that.distance, _that.movingTime, _that.elevationDifference);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _StravaSplit implements StravaSplit {
  const _StravaSplit(
      {this.distance = 0, this.movingTime = 0, this.elevationDifference = 0});
  factory _StravaSplit.fromJson(Map<String, dynamic> json) =>
      _$StravaSplitFromJson(json);

  /// Metres actually covered (the last split is often short).
  @override
  @JsonKey()
  final double distance;
  @override
  @JsonKey()
  final int movingTime;
  @override
  @JsonKey()
  final double elevationDifference;

  /// Create a copy of StravaSplit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StravaSplitCopyWith<_StravaSplit> get copyWith =>
      __$StravaSplitCopyWithImpl<_StravaSplit>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StravaSplitToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StravaSplit &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.movingTime, movingTime) ||
                other.movingTime == movingTime) &&
            (identical(other.elevationDifference, elevationDifference) ||
                other.elevationDifference == elevationDifference));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(runtimeType, distance, movingTime, elevationDifference);
  }

  @override
  String toString() {
    return 'StravaSplit(distance: $distance, movingTime: $movingTime, elevationDifference: $elevationDifference)';
  }
}

/// @nodoc
abstract mixin class _$StravaSplitCopyWith<$Res>
    implements $StravaSplitCopyWith<$Res> {
  factory _$StravaSplitCopyWith(
          _StravaSplit value, $Res Function(_StravaSplit) _then) =
      __$StravaSplitCopyWithImpl;
  @override
  @useResult
  $Res call({double distance, int movingTime, double elevationDifference});
}

/// @nodoc
class __$StravaSplitCopyWithImpl<$Res> implements _$StravaSplitCopyWith<$Res> {
  __$StravaSplitCopyWithImpl(this._self, this._then);

  final _StravaSplit _self;
  final $Res Function(_StravaSplit) _then;

  /// Create a copy of StravaSplit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? distance = null,
    Object? movingTime = null,
    Object? elevationDifference = null,
  }) {
    return _then(_StravaSplit(
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
      movingTime: null == movingTime
          ? _self.movingTime
          : movingTime // ignore: cast_nullable_to_non_nullable
              as int,
      elevationDifference: null == elevationDifference
          ? _self.elevationDifference
          : elevationDifference // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
mixin _$StravaGear {
  String get id;
  String get name;

  /// Lifetime metres Strava has recorded with it.
  double get distance;

  /// Create a copy of StravaGear
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StravaGearCopyWith<StravaGear> get copyWith =>
      _$StravaGearCopyWithImpl<StravaGear>(this as StravaGear, _$identity);

  /// Serializes this StravaGear to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    final _this = this as StravaGear;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StravaGear &&
            (identical(other.id, _this.id) || other.id == _this.id) &&
            (identical(other.name, _this.name) || other.name == _this.name) &&
            (identical(other.distance, _this.distance) ||
                other.distance == _this.distance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as StravaGear;
    return Object.hash(runtimeType, _this.id, _this.name, _this.distance);
  }

  @override
  String toString() {
    final _this = this as StravaGear;
    return 'StravaGear(id: ${_this.id}, name: ${_this.name}, distance: ${_this.distance})';
  }
}

/// @nodoc
abstract mixin class $StravaGearCopyWith<$Res> {
  factory $StravaGearCopyWith(
          StravaGear value, $Res Function(StravaGear) _then) =
      _$StravaGearCopyWithImpl;
  @useResult
  $Res call({String id, String name, double distance});
}

/// @nodoc
class _$StravaGearCopyWithImpl<$Res> implements $StravaGearCopyWith<$Res> {
  _$StravaGearCopyWithImpl(this._self, this._then);

  final StravaGear _self;
  final $Res Function(StravaGear) _then;

  /// Create a copy of StravaGear
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? distance = null,
  }) {
    return _then(StravaGear(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [StravaGear].
extension StravaGearPatterns on StravaGear {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_StravaGear value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StravaGear() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_StravaGear value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StravaGear():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_StravaGear value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StravaGear() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String id, String name, double distance)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StravaGear() when $default != null:
        return $default(_that.id, _that.name, _that.distance);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String id, String name, double distance) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StravaGear():
        return $default(_that.id, _that.name, _that.distance);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String id, String name, double distance)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StravaGear() when $default != null:
        return $default(_that.id, _that.name, _that.distance);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _StravaGear implements StravaGear {
  const _StravaGear({required this.id, required this.name, this.distance = 0});
  factory _StravaGear.fromJson(Map<String, dynamic> json) =>
      _$StravaGearFromJson(json);

  @override
  final String id;
  @override
  final String name;

  /// Lifetime metres Strava has recorded with it.
  @override
  @JsonKey()
  final double distance;

  /// Create a copy of StravaGear
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StravaGearCopyWith<_StravaGear> get copyWith =>
      __$StravaGearCopyWithImpl<_StravaGear>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StravaGearToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StravaGear &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.distance, distance) ||
                other.distance == distance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(runtimeType, id, name, distance);
  }

  @override
  String toString() {
    return 'StravaGear(id: $id, name: $name, distance: $distance)';
  }
}

/// @nodoc
abstract mixin class _$StravaGearCopyWith<$Res>
    implements $StravaGearCopyWith<$Res> {
  factory _$StravaGearCopyWith(
          _StravaGear value, $Res Function(_StravaGear) _then) =
      __$StravaGearCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String name, double distance});
}

/// @nodoc
class __$StravaGearCopyWithImpl<$Res> implements _$StravaGearCopyWith<$Res> {
  __$StravaGearCopyWithImpl(this._self, this._then);

  final _StravaGear _self;
  final $Res Function(_StravaGear) _then;

  /// Create a copy of StravaGear
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? distance = null,
  }) {
    return _then(_StravaGear(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      distance: null == distance
          ? _self.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

// dart format on
