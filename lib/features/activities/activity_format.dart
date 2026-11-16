import 'package:intl/intl.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/brand.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/activity_card.dart';

enum SportKind { run, ride, hike, walk, workout, other }

SportKind sportKindOf(String sportType) => switch (sportType) {
      'Run' || 'TrailRun' || 'VirtualRun' => SportKind.run,
      'Ride' ||
      'VirtualRide' ||
      'EBikeRide' ||
      'GravelRide' ||
      'MountainBikeRide' ||
      'EMountainBikeRide' ||
      'Velomobile' ||
      'Handcycle' =>
        SportKind.ride,
      'Hike' => SportKind.hike,
      'Walk' => SportKind.walk,
      'Workout' ||
      'WeightTraining' ||
      'Crossfit' ||
      'HighIntensityIntervalTraining' =>
        SportKind.workout,
      _ => SportKind.other,
    };

/// Turns raw activity figures into the text shown on cards, in the user's
/// language and units.
class ActivityFormat {
  ActivityFormat({
    required this.l10n,
    required String locale,
    required this.units,
  })  : _locale = locale,
        _twoDecimals = NumberFormat('0.00', locale),
        _oneDecimal = NumberFormat('0.0', locale),
        _whole = NumberFormat('0', locale);

  final AppLocalizations l10n;
  final Units units;
  final String _locale;
  final NumberFormat _twoDecimals;
  final NumberFormat _oneDecimal;
  final NumberFormat _whole;

  static const metresPerMile = 1609.344;

  double get metresPerUnit => units == Units.km ? 1000 : metresPerMile;
  String get distanceUnit => units == Units.km ? 'km' : 'mi';
  String get paceUnit => '/$distanceUnit';
  String get speedUnit => units == Units.km ? 'km/h' : 'mph';

  /// 5.02 (km) or 5,02 in comma locales.
  String distance(double metres) => _twoDecimals.format(metres / metresPerUnit);

  /// 33:14, or 1:02:05 past an hour.
  String duration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
  }

  /// Minutes and seconds per km or mile, e.g. 6:37.
  String pace(double metresPerSecond) {
    if (metresPerSecond <= 0) return '–';
    return duration((metresPerUnit / metresPerSecond).round());
  }

  /// km/h or mph with one decimal.
  String speed(double metresPerSecond) =>
      _oneDecimal.format(metresPerSecond * 3600 / metresPerUnit);

  /// "Thu 12 Nov · 12:31".
  String when(DateTime start) {
    final day = DateFormat('EEE d MMM', _locale).format(start);
    final time = DateFormat.Hm(_locale).format(start);
    return '$day · $time';
  }

  String sourceName(ActivitySource source) => switch (source) {
        ActivitySource.strava => Brand.strava,
        ActivitySource.manual => l10n.sourceManual,
        ActivitySource.healthConnect => Brand.healthConnect,
      };

  IconData icon(SportKind kind) => switch (kind) {
        SportKind.run => AppIcons.run,
        SportKind.walk => AppIcons.walk,
        SportKind.ride => AppIcons.bike,
        SportKind.hike => AppIcons.hike,
        SportKind.workout => AppIcons.gym,
        SportKind.other => AppIcons.pulse,
      };

  /// With distance: distance, time, then pace (on foot) or speed (rides).
  /// Without: time, then calories or average heart rate if known.
  List<ActivityStat> stats(Activity activity) {
    final kind = sportKindOf(activity.sportType);
    final metres = activity.distance ?? 0;
    final time = ActivityStat(
      label: l10n.statTime,
      value: duration(activity.movingTime),
    );
    if (metres <= 0) {
      return [
        time,
        if (activity.calories case final kcal? when kcal > 0)
          ActivityStat(
            label: l10n.statCalories,
            value: _whole.format(kcal),
            unit: 'kcal',
          )
        else if (activity.averageHeartrate case final bpm? when bpm > 0)
          ActivityStat(
            label: l10n.statHeartRate,
            value: _whole.format(bpm),
            unit: 'bpm',
          ),
      ];
    }
    final speed = activity.averageSpeed ??
        (activity.movingTime > 0 ? metres / activity.movingTime : 0.0);
    return [
      ActivityStat(
        label: l10n.statDistance,
        value: distance(metres),
        unit: distanceUnit,
      ),
      time,
      if (kind == SportKind.ride)
        ActivityStat(
          label: l10n.statSpeed,
          value: this.speed(speed),
          unit: speedUnit,
        )
      else if (kind != SportKind.other && kind != SportKind.workout)
        ActivityStat(label: l10n.statPace, value: pace(speed), unit: paceUnit),
    ];
  }

  ActivityCard card(
    Activity activity, {
    VoidCallback? onTap,
    Widget? trailing,
    Widget? footer,
  }) =>
      ActivityCard(
        icon: icon(sportKindOf(activity.sportType)),
        title: activity.name,
        subtitle:
            '${sourceName(activity.source)} · ${when(activity.startLocal)}',
        stats: stats(activity),
        onTap: onTap,
        trailing: trailing,
        footer: footer,
      );
}
