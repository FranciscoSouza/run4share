import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/sticker_data.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/editor/story_canvas.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/l10n/l10n.dart';

/// A template drawn with sample data on its sample art, through the same
/// canvas as the editor.
class TemplateCanvas extends ConsumerWidget {
  const TemplateCanvas({
    required this.template,
    this.watermark = true,
    super.key,
  });

  final StoryTemplate template;
  final bool watermark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = stickerDataFor(
      sampleActivity,
      ActivityFormat(
        l10n: context.l10n,
        locale: Localizations.localeOf(context).toString(),
        units: ref.watch(unitsProvider),
      ),
    );
    return StoryCanvas(
      format: template.format,
      background: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: template.colours,
          ),
        ),
      ),
      theme: template.theme,
      data: data,
      placement: StickerPlacement(center: template.theme.position),
      watermark: watermark,
    );
  }
}
