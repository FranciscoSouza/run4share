import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_text.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/sticker_data.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/editor/sticker_view.dart';
import 'package:run4share/features/editor/story_canvas.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/stickers/extra_sticker_view.dart';
import 'package:run4share/features/templates/template_samples.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/checkerboard.dart';

/// Photos under assets/onboarding/ that exist (see the README there).
/// Add a file name here when its photo is added; pages without one show
/// a flat colour.
const onboardingPhotos = <String>[];

/// Flat stand-ins while a page has no photo.
const List<Color> _flat = [
  AppColors.primary70,
  AppColors.neutral20,
  AppColors.tertiary60,
  AppColors.neutral10,
];

Widget _background(int page) {
  final file = 'page$page.jpg';
  if (onboardingPhotos.contains(file)) {
    return Image.asset('assets/onboarding/$file', fit: BoxFit.cover);
  }
  return ColoredBox(color: _flat[page - 1]);
}

/// One onboarding page's picture (1 to 4), drawn live with the app's own
/// themes and stickers so numbers, units and language follow the user.
/// Pro themes and stickers are drawn regardless of Pro: a preview.
class OnboardingArt extends ConsumerWidget {
  const OnboardingArt({required this.page, super.key});

  final int page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final units = ref.watch(unitsProvider);
    final name = l10n.typeRun;
    final facts = sampleFactsFor(SportKind.run, name: name, units: units);
    final data = stickerDataFor(
      facts.activity,
      ActivityFormat(
        l10n: l10n,
        locale: Localizations.localeOf(context).toString(),
        units: units,
      ),
    );
    final label = switch (page) {
      1 => l10n.onboardingArtLabel1,
      2 => l10n.onboardingArtLabel2,
      3 => l10n.onboardingArtLabel3,
      _ => l10n.onboardingArtLabel4,
    };
    final art = switch (page) {
      3 => _FullAndSticker(data: data),
      _ => _canvas(page, data, facts),
    };
    return Semantics(
      label: label,
      image: true,
      excludeSemantics: true,
      child: art,
    );
  }

  static CanvasItem _extra(
    int id,
    StickerFacts facts,
    ExtraKind kind,
    String value,
    Offset center, {
    double scale = 1,
    double rotation = 0,
  }) =>
      CanvasItem(
        id: id,
        placement: StickerPlacement(
          center: center,
          scale: scale,
          rotation: rotation,
        ),
        child: ExtraStickerView(kind: kind, value: value, facts: facts),
      );

  static Widget _canvas(int page, StickerData data, StickerFacts facts) {
    final (themeId, center, scale, extras) = switch (page) {
      1 => (
          'big-distance',
          const Offset(0.5, 0.74),
          1.0,
          [
            _extra(
              1,
              facts,
              ExtraKind.pace,
              '',
              const Offset(0.5, 0.2),
              scale: 0.9,
            ),
          ],
        ),
      2 => (
          'inline-top',
          const Offset(0.5, 0.8),
          0.95,
          [
            _extra(
              1,
              facts,
              ExtraKind.route,
              'neon',
              const Offset(0.5, 0.36),
              scale: 0.85,
            ),
          ],
        ),
      _ => (
          'receipt',
          const Offset(0.29, 0.63),
          0.8,
          [
            _extra(
              1,
              facts,
              ExtraKind.heartRate,
              '',
              const Offset(0.5, 0.15),
              scale: 0.85,
            ),
            _extra(
              2,
              facts,
              ExtraKind.label,
              'record',
              const Offset(0.76, 0.5),
              scale: 1.2,
              rotation: 0.1,
            ),
          ],
        ),
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: StoryCanvas(
        format: ShareFormat.feed,
        background: _background(page),
        theme: themeById(themeId),
        data: data,
        placement: StickerPlacement(
          center: center,
          scale: scale,
          // The receipt tilts a little, like one dropped on the photo.
          rotation: themeId == 'receipt' ? -0.07 : 0,
        ),
        extras: extras,
        watermark: false,
      ),
    );
  }
}

/// Page 3: the same sticker on the photo, and alone on transparency.
class _FullAndSticker extends StatelessWidget {
  const _FullAndSticker({required this.data});

  final StickerData data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = themeById('vertical-stack')!;
    final caption = AppText.label.copyWith(
      fontSize: 12,
      color: AppColors.neutral80,
    );
    Widget half(Widget child, String text) => Expanded(
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: child,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                text.toUpperCase(),
                style: caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
    return Row(
      children: [
        half(
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: 1080,
              height: 1920,
              child: StoryCanvas(
                format: ShareFormat.story,
                background: _background(3),
                theme: theme,
                data: data,
                placement: const StickerPlacement(
                  center: Offset(0.42, 0.5),
                  scale: 1.9,
                ),
                watermark: false,
              ),
            ),
          ),
          l10n.onboardingFullImage,
        ),
        const SizedBox(width: 12),
        half(
          CustomPaint(
            painter: const Checkerboard(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FittedBox(
                child: StickerView(theme: theme, data: data),
              ),
            ),
          ),
          l10n.onboardingStickerOnly,
        ),
      ],
    );
  }
}
