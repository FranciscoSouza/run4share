import 'package:run4share/app/material.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/l10n/l10n.dart';

/// What each effect is called.
String photoEffectName(AppLocalizations l10n, PhotoEffect effect) =>
    switch (effect) {
      PhotoEffect.none => l10n.effectNone,
      PhotoEffect.blackWhite => l10n.effectBlackWhite,
      PhotoEffect.highContrast => l10n.effectHighContrast,
    };

/// The colour matrix for [effect]; null for none.
ColorFilter? photoEffectFilter(PhotoEffect effect) => switch (effect) {
      PhotoEffect.none => null,
      PhotoEffect.blackWhite => const ColorFilter.matrix(_blackWhite),
      PhotoEffect.highContrast => ColorFilter.matrix(_highContrast),
    };

/// Applies [effect] to [child] (the photo); nothing for none.
Widget withPhotoEffect(PhotoEffect effect, Widget child) =>
    switch (photoEffectFilter(effect)) {
      final filter? => ColorFiltered(colorFilter: filter, child: child),
      null => child,
    };

/// Rec. 709 luminance, the same for each channel.
const _blackWhite = <double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
];

/// Contrast 1.35 around mid-grey, then saturation 1.15: punchier colour
/// and deeper shadows without clipping most photos.
final List<double> _highContrast = () {
  const contrast = 1.35;
  const saturation = 1.15;
  const offset = 128 * (1 - contrast);
  // Saturation matrix (luminance-preserving) times the contrast scale.
  const r = 0.2126 * (1 - saturation);
  const g = 0.7152 * (1 - saturation);
  const b = 0.0722 * (1 - saturation);
  final s = [
    [r + saturation, g, b],
    [r, g + saturation, b],
    [r, g, b + saturation],
  ];
  return <double>[
    for (final row in s) ...[
      for (final v in row) v * contrast,
      0,
      offset,
    ],
    0,
    0,
    0,
    1,
    0,
  ];
}();
