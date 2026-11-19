import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:run4share/features/health/route_metrics.dart';

/// Health Connect on this phone.
enum HubStatus {
  available,

  /// Installed but too old.
  updateRequired,

  /// Not installed (Android 13 and older), or not supported at all.
  unavailable,
}

/// One workout read from the phone's health hub.
@immutable
class HubWorkout {
  const HubWorkout({
    required this.id,
    required this.sportType,
    required this.startLocal,
    required this.startUtc,
    required this.movingTime,
    this.distance,
    this.calories,
    this.averageHeartrate,
    this.route = const [],
    this.heartRate = const [],
  });

  /// Health Connect's record ID.
  final String id;

  /// As Strava names sports (Run, Ride, Walk, Hike, Workout...).
  final String sportType;

  /// Wall-clock start where it happened, stored as UTC like Strava's.
  final DateTime startLocal;
  final DateTime startUtc;

  /// Seconds.
  final int movingTime;

  /// Metres.
  final double? distance;
  final double? calories;
  final double? averageHeartrate;
  final List<RoutePoint> route;

  /// Heart-rate readings (time, beats per minute), for the chart.
  final List<(DateTime, double)> heartRate;
}

/// The phone's health hub (Health Connect), behind an interface so tests
/// can fake it. Read only: run4share never writes health data.
abstract interface class HealthHub {
  Future<HubStatus> status();

  /// Opens the store page to install or update Health Connect.
  Future<void> install();

  /// Shows Health Connect's consent screen, then asks for past data.
  /// True when workouts can be read.
  Future<bool> requestAccess();

  Future<bool> hasAccess();

  /// Whether data older than 30 days may be read.
  Future<bool> hasHistory();

  Future<List<HubWorkout>> workouts(DateTime from, DateTime to);

  /// Gives back the permissions (on disconnect).
  Future<void> revoke();
}

/// Strava's sport names for Health Connect's exercise types.
String sportTypeFor(String healthType) {
  final t = healthType.toUpperCase();
  if (t.contains('RUNNING')) return 'Run';
  if (t.contains('BIKING') || t.contains('CYCLING')) return 'Ride';
  if (t.contains('HIKING')) return 'Hike';
  if (t.contains('WALKING')) return 'Walk';
  if (t.contains('SWIMMING')) return 'Swim';
  return 'Workout';
}

class DeviceHealthHub implements HealthHub {
  final Health _health = Health();
  Future<void>? _configured;

  /// What run4share reads, all read-only.
  ///
  /// Steps: the health plugin reads the steps inside every workout it
  /// returns, and without this permission that read fails and the plugin
  /// returns no workouts at all (found 18 Nov 2026). run4share doesn't
  /// use or keep the steps.
  static const List<HealthDataType> _types = [
    HealthDataType.WORKOUT,
    HealthDataType.WORKOUT_ROUTE,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.STEPS,
  ];

  /// Without these the workout list comes back empty, so a phone that
  /// granted only some is treated as not connected and asked again.
  static const List<HealthDataType> _needed = [
    HealthDataType.WORKOUT,
    HealthDataType.STEPS,
  ];

  /// For tests: what's requested, and what must be granted.
  @visibleForTesting
  static List<HealthDataType> get requested => _types;
  @visibleForTesting
  static List<HealthDataType> get needed => _needed;

  static final List<HealthDataAccess> _read = [
    for (final _ in _types) HealthDataAccess.READ,
  ];

  Future<void> _ready() => _configured ??= _health.configure();

  /// Apple Health: always there on iPhone, all history readable, and it
  /// never says whether reading was refused.
  bool get _ios => Platform.isIOS;

  @override
  Future<HubStatus> status() async {
    if (_ios) return HubStatus.available;
    await _ready();
    return switch (await _health.getHealthConnectSdkStatus()) {
      HealthConnectSdkStatus.sdkAvailable => HubStatus.available,
      HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired =>
        HubStatus.updateRequired,
      _ => HubStatus.unavailable,
    };
  }

  @override
  Future<void> install() async {
    await _ready();
    await _health.installHealthConnect();
  }

  @override
  Future<bool> requestAccess() async {
    await _ready();
    final granted = await _health.requestAuthorization(
      _types,
      permissions: _read,
    );
    if (granted &&
        !_ios &&
        await _health.isHealthDataHistoryAvailable() &&
        !await _health.isHealthDataHistoryAuthorized()) {
      await _health.requestHealthDataHistoryAuthorization();
    }
    return granted;
  }

  @override
  Future<bool> hasAccess() async {
    // iOS can't tell: a refusal just reads as no workouts.
    if (_ios) return true;
    await _ready();
    return await _health.hasPermissions(
          _needed,
          permissions: [for (final _ in _needed) HealthDataAccess.READ],
        ) ??
        false;
  }

  @override
  Future<bool> hasHistory() async {
    if (_ios) return true;
    await _ready();
    return await _health.isHealthDataHistoryAuthorized();
  }

  @override
  Future<List<HubWorkout>> workouts(DateTime from, DateTime to) async {
    await _ready();
    // A day past "now": a workout logged with a later start today, or
    // saved while the phone's time zone was different, is still read.
    final until = to.add(const Duration(days: 1));
    Future<List<HealthDataPoint>> read(HealthDataType type) async {
      try {
        return await _health.getHealthDataFromTypes(
          types: [type],
          startTime: from,
          endTime: until,
        );
      } on Object catch (error) {
        debugPrint('Health Connect $type failed: $error');
        return const [];
      }
    }

    final sessions = await read(HealthDataType.WORKOUT);
    // What Health Connect gave back, for "my workout doesn't show".
    debugPrint(
      'Health Connect workouts ${from.toUtc()}..${until.toUtc()}: '
      '${sessions.length}',
    );
    for (final p in sessions) {
      debugPrint(
        '  ${p.sourceName} ${p.dateFrom.toUtc()}..${p.dateTo.toUtc()} '
        '${(p.value as WorkoutHealthValue?)?.workoutActivityType.name}',
      );
    }
    if (sessions.isEmpty) return const [];
    final heart = await read(HealthDataType.HEART_RATE);
    final routes = await read(HealthDataType.WORKOUT_ROUTE);

    HubWorkout? convert(HealthDataPoint p) {
      final value = p.value;
      if (value is! WorkoutHealthValue) return null;
      final from = p.dateFrom;
      final to = p.dateTo;
      bool inside(HealthDataPoint q) =>
          !q.dateFrom.isBefore(from) && !q.dateTo.isAfter(to);
      final samples = [
        for (final q in heart.where(inside))
          if (q.value case NumericHealthValue(:final numericValue))
            (q.dateFrom, numericValue.toDouble()),
      ];
      final beats = [for (final (_, bpm) in samples) bpm];
      final route = [
        for (final q in routes.where(
          (q) =>
              q.dateFrom.difference(from).inSeconds.abs() < 60 &&
              q.value is WorkoutRouteHealthValue,
        ))
          for (final l in (q.value as WorkoutRouteHealthValue).locations)
            (
              latitude: l.latitude,
              longitude: l.longitude,
              time: l.timestamp,
              altitude: l.altitude,
            ),
      ];
      final local = from.toLocal();
      return HubWorkout(
        id: p.uuid,
        sportType: sportTypeFor(value.workoutActivityType.name),
        startLocal: DateTime.utc(
          local.year,
          local.month,
          local.day,
          local.hour,
          local.minute,
          local.second,
        ),
        startUtc: from.toUtc(),
        movingTime: to.difference(from).inSeconds,
        distance: value.totalDistance?.toDouble(),
        calories: value.totalEnergyBurned?.toDouble(),
        averageHeartrate:
            beats.isEmpty ? null : beats.reduce((a, b) => a + b) / beats.length,
        route: route,
        heartRate: samples,
      );
    }

    return [
      for (final p in sessions)
        if (convert(p) case final workout?) workout,
    ];
  }

  @override
  Future<void> revoke() async {
    // Apps can't revoke their own Apple Health access; the user can, in
    // the Health app. Disconnecting still removes the local copies.
    if (_ios) return;
    await _ready();
    try {
      await _health.revokePermissions();
    } on Object catch (error) {
      debugPrint('Health Connect revoke failed: $error');
    }
  }
}

final healthHubProvider = Provider<HealthHub>((ref) => DeviceHealthHub());
