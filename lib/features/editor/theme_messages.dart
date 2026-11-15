import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/l10n/l10n.dart';

/// "No heart rate in this activity", for a theme that needs [missing].
String themeMissingMessage(AppLocalizations l10n, Metric missing) =>
    switch (missing) {
      Metric.distance || Metric.rate => l10n.themeNeedsDistance,
      Metric.heartRate => l10n.themeNeedsHeartRate,
      Metric.calories => l10n.themeNeedsCalories,
      Metric.time => l10n.themeNeedsDistance,
    };

/// "distance, time and pace": what a theme shows, for template captions.
String themeMetricNames(AppLocalizations l10n, StickerTheme theme) {
  final names = [
    for (final metric in theme.metrics)
      switch (metric) {
        Metric.distance => l10n.metricDistance,
        Metric.time => l10n.metricTime,
        Metric.rate => l10n.metricPace,
        Metric.heartRate => l10n.metricHeartRate,
        Metric.calories => l10n.metricCalories,
      },
  ];
  return names.join(', ');
}
