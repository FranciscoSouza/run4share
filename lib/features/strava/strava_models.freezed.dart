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
                other.athleteName == _this.athleteName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    final _this = this as StravaSession;
    return Object.hash(runtimeType, _this.accessToken, _this.refreshToken,
        _this.expiresAt, _this.connectedAt, _this.athleteId, _this.athleteName);
  }

  @override
  String toString() {
    final _this = this as StravaSession;
    return 'StravaSession(accessToken: ${_this.accessToken}, refreshToken: ${_this.refreshToken}, expiresAt: ${_this.expiresAt}, connectedAt: ${_this.connectedAt}, athleteId: ${_this.athleteId}, athleteName: ${_this.athleteName})';
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
      String? athleteName});
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
    TResult Function(String accessToken, String refreshToken, int expiresAt,
            DateTime connectedAt, int? athleteId, String? athleteName)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StravaSession() when $default != null:
        return $default(_that.accessToken, _that.refreshToken, _that.expiresAt,
            _that.connectedAt, _that.athleteId, _that.athleteName);
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
    TResult Function(String accessToken, String refreshToken, int expiresAt,
            DateTime connectedAt, int? athleteId, String? athleteName)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StravaSession():
        return $default(_that.accessToken, _that.refreshToken, _that.expiresAt,
            _that.connectedAt, _that.athleteId, _that.athleteName);
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
    TResult? Function(String accessToken, String refreshToken, int expiresAt,
            DateTime connectedAt, int? athleteId, String? athleteName)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StravaSession() when $default != null:
        return $default(_that.accessToken, _that.refreshToken, _that.expiresAt,
            _that.connectedAt, _that.athleteId, _that.athleteName);
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
      this.athleteName})
      : super._();
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
                other.athleteName == athleteName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode {
    return Object.hash(runtimeType, accessToken, refreshToken, expiresAt,
        connectedAt, athleteId, athleteName);
  }

  @override
  String toString() {
    return 'StravaSession(accessToken: $accessToken, refreshToken: $refreshToken, expiresAt: $expiresAt, connectedAt: $connectedAt, athleteId: $athleteId, athleteName: $athleteName)';
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
      String? athleteName});
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
                other.totalElevationGain == _this.totalElevationGain));
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
        _this.totalElevationGain);
  }

  @override
  String toString() {
    final _this = this as StravaActivity;
    return 'StravaActivity(id: ${_this.id}, name: ${_this.name}, sportType: ${_this.sportType}, startDate: ${_this.startDate}, startDateLocal: ${_this.startDateLocal}, distance: ${_this.distance}, movingTime: ${_this.movingTime}, elapsedTime: ${_this.elapsedTime}, averageSpeed: ${_this.averageSpeed}, averageHeartrate: ${_this.averageHeartrate}, totalElevationGain: ${_this.totalElevationGain})';
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
      double? totalElevationGain});
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
            double? totalElevationGain)?
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
            _that.totalElevationGain);
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
            double? totalElevationGain)
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
            _that.totalElevationGain);
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
            double? totalElevationGain)?
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
            _that.totalElevationGain);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _StravaActivity implements StravaActivity {
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
      this.totalElevationGain});
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
                other.totalElevationGain == totalElevationGain));
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
        totalElevationGain);
  }

  @override
  String toString() {
    return 'StravaActivity(id: $id, name: $name, sportType: $sportType, startDate: $startDate, startDateLocal: $startDateLocal, distance: $distance, movingTime: $movingTime, elapsedTime: $elapsedTime, averageSpeed: $averageSpeed, averageHeartrate: $averageHeartrate, totalElevationGain: $totalElevationGain)';
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
      double? totalElevationGain});
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
    ));
  }
}

// dart format on
