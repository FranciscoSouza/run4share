// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strava_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StravaSession _$StravaSessionFromJson(Map<String, dynamic> json) =>
    _StravaSession(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: (json['expires_at'] as num).toInt(),
      connectedAt: DateTime.parse(json['connected_at'] as String),
      athleteId: (json['athlete_id'] as num?)?.toInt(),
      athleteName: json['athlete_name'] as String?,
    );

Map<String, dynamic> _$StravaSessionToJson(_StravaSession instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'expires_at': instance.expiresAt,
      'connected_at': instance.connectedAt.toIso8601String(),
      'athlete_id': instance.athleteId,
      'athlete_name': instance.athleteName,
    };

_StravaActivity _$StravaActivityFromJson(Map<String, dynamic> json) =>
    _StravaActivity(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      sportType: json['sport_type'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      startDateLocal: DateTime.parse(json['start_date_local'] as String),
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      movingTime: (json['moving_time'] as num?)?.toInt() ?? 0,
      elapsedTime: (json['elapsed_time'] as num?)?.toInt() ?? 0,
      averageSpeed: (json['average_speed'] as num?)?.toDouble(),
      averageHeartrate: (json['average_heartrate'] as num?)?.toDouble(),
      totalElevationGain: (json['total_elevation_gain'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$StravaActivityToJson(_StravaActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sport_type': instance.sportType,
      'start_date': instance.startDate.toIso8601String(),
      'start_date_local': instance.startDateLocal.toIso8601String(),
      'distance': instance.distance,
      'moving_time': instance.movingTime,
      'elapsed_time': instance.elapsedTime,
      'average_speed': instance.averageSpeed,
      'average_heartrate': instance.averageHeartrate,
      'total_elevation_gain': instance.totalElevationGain,
    };
