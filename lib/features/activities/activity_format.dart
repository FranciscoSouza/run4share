import 'package:intl/intl.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/brand.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/strava/strava_models.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/activity_card.dart';

enum SportKind { run, ride, hike, walk, other }

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
        _oneDecimal = NumberFormat('0.0', locale);

  final AppLocalizations l10n;
  final Units units;
  final String _locale;
  final NumberFormat _twoDecimals;
  final NumberFormat _oneDecimal;

  static const _metresPerMile = 1609.344;

  double get _metresPerUnit => units == Units.km ? 1000 : _metresPerMile;
  String get distanceUnit => units == Units.km ? 'km' : 'mi';
  String get paceUnit => '/$distanceUnit';
  String get speedUnit => units == Units.km ? 'km/h' : 'mph';

  /// 5.02 (km) or 5,02 in comma locales.
  String distance(double metres) =>
      _twoDecimals.format(metres / _metresPerUnit);

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
    final seconds = (_metresPerUnit / metresPerSecond).round();
    return duration(seconds);
  }

  /// km/h or mph with one decimal.
  String speed(double metresPerSecond) =>
      _oneDecimal.format(metresPerSecond * 3600 / _metresPerUnit);

  /// "Strava · Thu 12 Nov · 12:31".
  String subtitle(String source, DateTime start) {
    final day = DateFormat('EEE d MMM', _locale).format(start);
    final time = DateFormat.Hm(_locale).format(start);
    return '$source · $day · $time';
  }

  IconData icon(SportKind kind) => switch (kind) {
        SportKind.run || SportKind.walk => AppIcons.run,
        SportKind.ride => AppIcons.bike,
        SportKind.hike => AppIcons.hike,
        SportKind.other => AppIcons.pulse,
      };

  /// Distance and time always; pace for foot sports, speed for rides.
  List<ActivityStat> stats(StravaActivity activity) {
    final kind = sportKindOf(activity.sportType);
    final speed = activity.averageSpeed ??
        (activity.movingTime > 0
            ? activity.distance / activity.movingTime
            : 0.0);
    return [
      if (activity.distance > 0)
        ActivityStat(
          label: l10n.statDistance,
          value: distance(activity.distance),
          unit: distanceUnit,
        ),
      ActivityStat(label: l10n.statTime, value: duration(activity.movingTime)),
      if (activity.distance > 0)
        if (kind == SportKind.ride)
          ActivityStat(
            label: l10n.statSpeed,
            value: this.speed(speed),
            unit: speedUnit,
          )
        else if (kind != SportKind.other)
          ActivityStat(
            label: l10n.statPace,
            value: pace(speed),
            unit: paceUnit,
          ),
    ];
  }

  ActivityCard card(StravaActivity activity, {VoidCallback? onTap}) =>
      ActivityCard(
        icon: icon(sportKindOf(activity.sportType)),
        title: activity.name,
        subtitle: subtitle(Brand.strava, activity.startDateLocal),
        stats: stats(activity),
        onTap: onTap,
      );
}
