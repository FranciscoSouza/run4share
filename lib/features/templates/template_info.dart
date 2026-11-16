import 'package:go_router/go_router.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/stickers/activity_labels.dart';
import 'package:run4share/features/stickers/extra_sticker_view.dart';
import 'package:run4share/features/stickers/sticker_catalogue.dart';
import 'package:run4share/l10n/l10n.dart';

/// "Run", "Ride"... as the activity forms name them.
String sportName(AppLocalizations l10n, SportKind sport) => switch (sport) {
      SportKind.run => l10n.typeRun,
      SportKind.ride => l10n.typeRide,
      SportKind.hike => l10n.typeHike,
      SportKind.walk => l10n.typeWalk,
      SportKind.workout || SportKind.other => l10n.typeWorkout,
    };

/// What an extra is called, as the Your data / Stickers panels say it.
String extraName(AppLocalizations l10n, TemplateExtra extra) =>
    switch (extra.kind) {
      ExtraKind.pace => l10n.chartPace,
      ExtraKind.heartRate => l10n.chartHeartRate,
      ExtraKind.elevation => l10n.chartElevation,
      ExtraKind.splits => l10n.chartSplits,
      ExtraKind.route => l10n.stickerRoute,
      ExtraKind.label => switch (labelFromValue(extra.value)) {
          final label? => labelText(l10n, label),
          null => extra.value,
        },
      ExtraKind.shoe => l10n.stickersYourData,
      ExtraKind.time => l10n.stickersTime,
      ExtraKind.phrase || ExtraKind.stamp => l10n.editorStickers,
    };

/// "Hike · Elevation · Pro": sport, first extra, and Pro while locked.
String templateWhat(
  AppLocalizations l10n,
  StoryTemplate template, {
  required bool isPro,
}) =>
    [
      sportName(l10n, template.sport),
      if (template.extras.isNotEmpty) extraName(l10n, template.extras.first),
      if (template.pro && !isPro) 'Pro',
    ].join(' · ');

/// Whether [template] needs Pro that isn't there.
bool templateLocked(StoryTemplate template, {required bool isPro}) =>
    template.pro && !isPro;

/// "Use this template": Pro without Pro → the Pro screen, else choosing
/// an activity. One rule for Home and the preview.
void useTemplate(
  BuildContext context,
  StoryTemplate template, {
  required bool isPro,
}) =>
    context.push(
      templateLocked(template, isPro: isPro)
          ? AppRoutes.pro
          : AppRoutes.templateActivity(template.id),
    );

/// The template's extras as draft stickers, keeping only those [facts]
/// can draw; the names of the ones left out come back for the note.
(List<ExtraSticker>, List<String>) templateExtrasFor(
  StoryTemplate template,
  StickerFacts facts, {
  required List<Activity> history,
  required AppLocalizations l10n,
}) {
  final kept = <ExtraSticker>[];
  final missing = <String>[];
  for (final extra in template.extras) {
    final has = switch (extra.kind) {
      ExtraKind.pace => facts.charts.pace != null,
      ExtraKind.heartRate => facts.charts.heartRate != null,
      ExtraKind.elevation => facts.charts.elevation != null,
      ExtraKind.route => facts.activity.polyline != null,
      ExtraKind.splits => facts.activity.splitsJson != null,
      ExtraKind.shoe => facts.gear != null,
      ExtraKind.label => labelsFor(facts.activity, history)
          .any((l) => labelValue(l) == extra.value),
      ExtraKind.time || ExtraKind.phrase || ExtraKind.stamp => true,
    };
    if (has) {
      kept.add(
        ExtraSticker(
          id: kept.length + 1,
          kind: extra.kind,
          value: extra.value,
          placement: StickerPlacement(
            center: extra.center,
            scale: extra.scale,
            rotation: extra.rotation,
          ),
        ),
      );
    } else {
      missing.add(extraName(l10n, extra));
    }
  }
  return (kept, missing);
}

/// Whether the draft has something only Pro may export: a Pro theme or
/// any extra sticker (all extras are Pro stickers).
bool draftNeedsPro(CreationDraft draft) =>
    (themeById(draft.themeId)?.pro ?? false) || draft.extras.isNotEmpty;
