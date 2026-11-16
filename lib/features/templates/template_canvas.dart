import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/sticker_data.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/editor/story_canvas.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/stickers/extra_sticker_view.dart';
import 'package:run4share/features/templates/template_info.dart';
import 'package:run4share/features/templates/template_samples.dart';
import 'package:run4share/l10n/l10n.dart';

/// A template drawn with its sport's sample data on its photo (or
/// gradient), with its extras, through the same canvas as the editor.
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
    final l10n = context.l10n;
    final units = ref.watch(unitsProvider);
    final facts = sampleFactsFor(
      template.sport,
      name: sportName(l10n, template.sport),
      units: units,
    );
    final data = stickerDataFor(
      facts.activity,
      ActivityFormat(
        l10n: l10n,
        locale: Localizations.localeOf(context).toString(),
        units: units,
      ),
    );
    final photo = template.photo;
    return StoryCanvas(
      format: template.format,
      background: photo != null
          ? Image.asset(photo, fit: BoxFit.cover)
          : DecoratedBox(
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
      placement: StickerPlacement(center: template.stickerCenter),
      extras: [
        for (final (i, extra) in template.extras.indexed)
          CanvasItem(
            id: i + 1,
            placement: StickerPlacement(
              center: extra.center,
              scale: extra.scale,
              rotation: extra.rotation,
            ),
            child: ExtraStickerView(
              kind: extra.kind,
              value: extra.value,
              facts: facts,
            ),
          ),
      ],
      watermark: watermark,
    );
  }
}
