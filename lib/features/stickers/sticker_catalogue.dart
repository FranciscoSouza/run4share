import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/stickers/activity_labels.dart';
import 'package:run4share/l10n/l10n.dart';

/// Mood phrases: five moods, three phrases each, in every language.
enum Mood { proud, tired, happy, motivated, funny }

const phrasesPerMood = 3;

String moodName(AppLocalizations l10n, Mood mood) => switch (mood) {
      Mood.proud => l10n.moodProud,
      Mood.tired => l10n.moodTired,
      Mood.happy => l10n.moodHappy,
      Mood.motivated => l10n.moodMotivated,
      Mood.funny => l10n.moodFunny,
    };

/// "proud.0" and the like.
String phraseId(Mood mood, int index) => '${mood.name}.$index';

/// The phrase text for [id], or null if unknown.
String? phraseText(AppLocalizations l10n, String id) => switch (id) {
      'proud.0' => l10n.phraseProud0,
      'proud.1' => l10n.phraseProud1,
      'proud.2' => l10n.phraseProud2,
      'tired.0' => l10n.phraseTired0,
      'tired.1' => l10n.phraseTired1,
      'tired.2' => l10n.phraseTired2,
      'happy.0' => l10n.phraseHappy0,
      'happy.1' => l10n.phraseHappy1,
      'happy.2' => l10n.phraseHappy2,
      'motivated.0' => l10n.phraseMotivated0,
      'motivated.1' => l10n.phraseMotivated1,
      'motivated.2' => l10n.phraseMotivated2,
      'funny.0' => l10n.phraseFunny0,
      'funny.1' => l10n.phraseFunny1,
      'funny.2' => l10n.phraseFunny2,
      _ => null,
    };

/// Stamps and seals. Seals have their text around a ring; stamps are
/// rectangular, like a rubber stamp.
enum StampKind {
  earlyBird(seal: true),
  nightOwl(seal: true),
  rainOrShine(seal: true),
  weekendWarrior(seal: true),
  done(seal: false),
  noExcuses(seal: false);

  const StampKind({required this.seal});

  final bool seal;
}

String stampText(AppLocalizations l10n, StampKind stamp) => switch (stamp) {
      StampKind.earlyBird => l10n.stampEarlyBird,
      StampKind.nightOwl => l10n.stampNightOwl,
      StampKind.rainOrShine => l10n.stampRainOrShine,
      StampKind.weekendWarrior => l10n.stampWeekendWarrior,
      StampKind.done => l10n.stampDone,
      StampKind.noExcuses => l10n.stampNoExcuses,
    };

IconData stampIcon(StampKind stamp) => switch (stamp) {
      StampKind.earlyBird => AppIcons.sunrise,
      StampKind.nightOwl => AppIcons.moon,
      StampKind.rainOrShine => AppIcons.rain,
      StampKind.weekendWarrior => AppIcons.hike,
      StampKind.done => AppIcons.check,
      StampKind.noExcuses => AppIcons.flag,
    };

/// A label as stored in an [ExtraSticker]: "record", "subMark:25"...
String labelValue(ActivityLabel label) =>
    label.mark == null ? label.kind.name : '${label.kind.name}:${label.mark}';

ActivityLabel? labelFromValue(String value) {
  // Only the first colon separates: marks can contain one ("1:45").
  final split = value.indexOf(':');
  final name = split < 0 ? value : value.substring(0, split);
  final kind = LabelKind.values.asNameMap()[name];
  if (kind == null) return null;
  return ActivityLabel(
    kind,
    mark: split < 0 ? null : value.substring(split + 1),
  );
}

String labelText(AppLocalizations l10n, ActivityLabel label) =>
    switch (label.kind) {
      LabelKind.record => l10n.labelRecord,
      LabelKind.longRun => l10n.labelLongRun,
      LabelKind.raceDay => l10n.labelRaceDay,
      LabelKind.subMark => l10n.labelSub(label.mark ?? ''),
    };

IconData labelIcon(LabelKind kind) => switch (kind) {
      LabelKind.record => AppIcons.trophy,
      LabelKind.longRun => AppIcons.route,
      LabelKind.raceDay => AppIcons.flag,
      LabelKind.subMark => AppIcons.timer,
    };

/// The default colour of each kind when the user hasn't picked one.
StickerColour defaultColour(ExtraKind kind) => switch (kind) {
      ExtraKind.label => StickerColour.amber,
      _ => StickerColour.white,
    };
