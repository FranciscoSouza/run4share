import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/data/database.dart';

/// Output formats, chosen before editing.
enum ShareFormat {
  story(9, 16),
  feed(4, 5),
  square(1, 1);

  const ShareFormat(this.width, this.height);

  final int width;
  final int height;

  /// Width over height.
  double get ratio => width / height;
}

const formatPreference = 'creation.format';

/// The last sticker theme used, offered first next time.
const themePreference = 'creation.theme';

/// The image being made: which activity, which photo, which part of it.
///
/// The crop is kept as a fraction of the photo (0–1 on both axes), not as
/// cropped pixels, so later steps can use the full-resolution original.
@immutable
class CreationDraft {
  const CreationDraft({
    required this.activityId,
    required this.photoId,
    required this.format,
    required this.crop,
    required this.themeId,
    this.sticker,
  });

  final int activityId;
  final String photoId;
  final ShareFormat format;

  /// Part of the photo to use, as fractions of its width and height.
  final Rect crop;

  /// The sticker theme.
  final String themeId;

  /// Where the sticker sits; null when the user removed it.
  final StickerPlacement? sticker;

  CreationDraft copyWith({
    String? themeId,
    StickerPlacement? sticker,
    bool removeSticker = false,
  }) =>
      CreationDraft(
        activityId: activityId,
        photoId: photoId,
        format: format,
        crop: crop,
        themeId: themeId ?? this.themeId,
        sticker: removeSticker ? null : sticker ?? this.sticker,
      );
}

/// The sticker's centre (fractions of the canvas), size and turn.
@immutable
class StickerPlacement {
  const StickerPlacement({
    required this.center,
    this.scale = 1,
    this.rotation = 0,
  });

  final Offset center;

  /// 1 is the theme's designed size.
  final double scale;

  /// Radians, clockwise.
  final double rotation;

  static const minScale = 0.3;
  static const maxScale = 3.0;

  StickerPlacement copyWith({
    Offset? center,
    double? scale,
    double? rotation,
  }) =>
      StickerPlacement(
        center: center ?? this.center,
        scale: scale ?? this.scale,
        rotation: rotation ?? this.rotation,
      );

  @override
  bool operator ==(Object other) =>
      other is StickerPlacement &&
      other.center == center &&
      other.scale == scale &&
      other.rotation == rotation;

  @override
  int get hashCode => Object.hash(center, scale, rotation);
}

/// The largest centred crop of a [photoSize] photo in [format].
Rect centreCrop(Size photoSize, ShareFormat format) {
  final photoRatio = photoSize.width / photoSize.height;
  if (photoRatio > format.ratio) {
    final w = format.ratio / photoRatio;
    return Rect.fromLTWH((1 - w) / 2, 0, w, 1);
  }
  final h = photoRatio / format.ratio;
  return Rect.fromLTWH(0, (1 - h) / 2, 1, h);
}

/// The crop as fractions of the photo, from the crop frame and the photo's
/// on-screen rectangle (both in the same coordinates).
Rect fractionalCrop({required Rect frame, required Rect photo}) {
  final rect = Rect.fromLTWH(
    (frame.left - photo.left) / photo.width,
    (frame.top - photo.top) / photo.height,
    frame.width / photo.width,
    frame.height / photo.height,
  );
  return rect.intersect(const Rect.fromLTWH(0, 0, 1, 1));
}

/// The draft in progress; null outside the creation flow.
final creationDraftProvider =
    NotifierProvider<CreationDraftNotifier, CreationDraft?>(
  CreationDraftNotifier.new,
);

class CreationDraftNotifier extends Notifier<CreationDraft?> {
  @override
  CreationDraft? build() => null;

  // A plain method keeps the call site readable: draft.set(...).
  // ignore: use_setters_to_change_properties
  void set(CreationDraft draft) => state = draft;

  void clear() => state = null;

  /// Switches theme; the sticker comes back at the theme's own position.
  void setTheme(String themeId, Offset position) {
    final draft = state;
    if (draft == null) return;
    state = draft.copyWith(
      themeId: themeId,
      sticker: StickerPlacement(center: position),
    );
  }

  void place(StickerPlacement placement) {
    final draft = state;
    if (draft != null) state = draft.copyWith(sticker: placement);
  }

  void removeSticker() {
    final draft = state;
    if (draft != null) state = draft.copyWith(removeSticker: true);
  }
}

/// The Popular template being followed, if any: its format and theme are
/// used by the crop and editor steps.
final templateChoiceProvider =
    NotifierProvider<TemplateChoiceNotifier, String?>(
  TemplateChoiceNotifier.new,
);

class TemplateChoiceNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  // A method reads better at call sites: choice.choose(id).
  // ignore: use_setters_to_change_properties
  void choose(String? templateId) => state = templateId;
}

/// The last format chosen, offered first next time (Story when unset).
Future<ShareFormat> lastFormat(AppDatabase db) async =>
    ShareFormat.values.asNameMap()[await db.readPreference(
      formatPreference,
    )] ??
    ShareFormat.story;
