import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/app/theme/app_theme.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/activities/strava_sync.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/create/crop_screen.dart';
import 'package:run4share/features/create/cropped_photo.dart';
import 'package:run4share/features/editor/sticker_data.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/editor/story_canvas.dart';
import 'package:run4share/features/editor/style_panels.dart';
import 'package:run4share/features/editor/theme_messages.dart';
import 'package:run4share/features/photos/photo_library.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/pills.dart';

/// Step 3: the photo with its sticker. Choose a theme, move, size and turn
/// the sticker, then share (phase 5).
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  Future<Uint8List?>? _photo;
  _Panel? _panel = _Panel.themes;
  bool _selected = false;

  StickerTool? get _tool => switch (_panel) {
        _Panel.textColour => StickerTool.textColour,
        _Panel.background => StickerTool.background,
        _ => null,
      };
  bool _detailsRequested = false;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(creationDraftProvider);
    if (draft != null) {
      _photo = ref
          .read(photoLibraryProvider)
          .preview(draft.photoId, maxSide: cropPreviewMaxSide);
    }
  }

  ActivityFormat _format() => ActivityFormat(
        l10n: context.l10n,
        locale: Localizations.localeOf(context).toString(),
        units: ref.watch(unitsProvider),
      );

  void _chooseTheme(StickerTheme theme, StickerData data) {
    final missing = data.missingFor(theme);
    if (missing != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(themeMissingMessage(context.l10n, missing))),
        );
      return;
    }
    ref.read(creationDraftProvider.notifier).setTheme(theme.id, theme.position);
    unawaited(
      ref.read(appDatabaseProvider).writePreference(themePreference, theme.id),
    );
  }

  /// Makes sure the draft's theme can be drawn; else takes the first that
  /// can (e.g. a template theme the activity has no data for).
  void _ensureUsableTheme(CreationDraft draft, StickerData data) {
    final current = themeById(draft.themeId);
    if (current != null && data.supports(current)) return;
    for (final theme in stickerThemes) {
      if (data.supports(theme)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref
                .read(creationDraftProvider.notifier)
                .setTheme(theme.id, theme.position);
          }
        });
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = ref.watch(creationDraftProvider);
    final activity = draft == null
        ? null
        : ref.watch(activityByIdProvider(draft.activityId)).value;

    if (activity != null && !_detailsRequested) {
      _detailsRequested = true;
      unawaited(ref.read(stravaSyncProvider.notifier).fetchDetails(activity));
    }

    final data = activity == null ? null : stickerDataFor(activity, _format());
    if (draft != null && data != null) _ensureUsableTheme(draft, data);

    return Theme(
      data: AppTheme.dark,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(AppIcons.back, size: 30),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.pop(),
              ),
              title: Text(activity?.name ?? ''),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: AppPill(
                    label: l10n.actionShare,
                    icon: AppIcons.share,
                    onPressed: draft == null
                        ? null
                        : () => context.push(AppRoutes.share),
                  ),
                ),
              ],
            ),
            body: draft == null || data == null
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<Uint8List?>(
                    future: _photo,
                    builder: (context, snapshot) {
                      final bytes = snapshot.data;
                      if (bytes == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final background = CroppedPhoto(
                        bytes: bytes,
                        crop: draft.crop,
                        aspectRatio: draft.format.ratio,
                      );
                      return Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.xl,
                                AppSpacing.sm,
                                AppSpacing.xl,
                                AppSpacing.lg,
                              ),
                              child: Center(
                                child: StoryCanvas(
                                  format: draft.format,
                                  background: background,
                                  theme: themeById(draft.themeId),
                                  data: data,
                                  placement: draft.sticker,
                                  style: draft.style,
                                  editable: true,
                                  selected: _selected,
                                  activeTool: _tool,
                                  handleLabels: HandleLabels(
                                    rotate: l10n.editorRotate,
                                    resize: l10n.editorResize,
                                    remove: l10n.editorRemove,
                                    textColour: l10n.editorTextColour,
                                    background: l10n.editorBackground,
                                  ),
                                  onSelect: (selected) => setState(() {
                                    _selected = selected;
                                    // Selecting hides the carousel; leaving
                                    // the sticker closes its style panels.
                                    if (selected && _panel == _Panel.themes) {
                                      _panel = null;
                                    }
                                    if (!selected && _tool != null) {
                                      _panel = null;
                                    }
                                  }),
                                  onTextColour: () => setState(
                                    () => _panel = _panel == _Panel.textColour
                                        ? null
                                        : _Panel.textColour,
                                  ),
                                  onBackground: () => setState(
                                    () => _panel = _panel == _Panel.background
                                        ? null
                                        : _Panel.background,
                                  ),
                                  onPlacement: ref
                                      .read(creationDraftProvider.notifier)
                                      .place,
                                  onRemove: () {
                                    setState(() {
                                      _selected = false;
                                      _panel = null;
                                    });
                                    ref
                                        .read(creationDraftProvider.notifier)
                                        .removeSticker();
                                  },
                                ),
                              ),
                            ),
                          ),
                          _BottomPanel(
                            child: switch (_panel) {
                              _Panel.themes => _ThemeCarousel(
                                  draft: draft,
                                  data: data,
                                  bytes: bytes,
                                  onChoose: (t) => _chooseTheme(t, data),
                                  onClose: () => setState(() => _panel = null),
                                ),
                              _Panel.textColour => TextColourPanel(
                                  selected: draft.style.colour ??
                                      themeById(draft.themeId)?.colour ??
                                      StickerColour.white,
                                  onChoose: ref
                                      .read(creationDraftProvider.notifier)
                                      .setColour,
                                  onClose: () => setState(() => _panel = null),
                                ),
                              _Panel.background => BackgroundPanel(
                                  value: draft.style.background,
                                  onChanged: ref
                                      .read(creationDraftProvider.notifier)
                                      .setBackground,
                                  onClose: () => setState(() => _panel = null),
                                ),
                              null => _Toolbar(
                                  onThemes: () => setState(() {
                                    _panel = _Panel.themes;
                                    _selected = false;
                                  }),
                                ),
                            },
                          ),
                          if (draft.sticker == null)
                            Container(
                              color: theme.colorScheme.surfaceContainer,
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: Text(
                                l10n.editorAddSticker,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}

/// What the bottom of the editor shows; null is the toolbar.
enum _Panel { themes, textColour, background }

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topCenter,
        child: child,
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.onThemes});

  final VoidCallback onThemes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Calories, Quotes, Text and Stickers join after phase 4b.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: InkWell(
          onTap: onThemes,
          borderRadius: BorderRadius.circular(AppRadius.thumb),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.thumb),
                  ),
                  child: const Icon(AppIcons.layers),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.l10n.editorTheme,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeCarousel extends StatelessWidget {
  const _ThemeCarousel({
    required this.draft,
    required this.data,
    required this.bytes,
    required this.onChoose,
    required this.onClose,
  });

  final CreationDraft draft;
  final StickerData data;
  final Uint8List bytes;
  final ValueChanged<StickerTheme> onChoose;
  final VoidCallback onClose;

  static const _tile = 100.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    // Thumbnails are square: the middle square of the chosen crop.
    final square = centreCrop(
      Size(draft.format.ratio, 1),
      ShareFormat.square,
    );
    final thumbCrop = Rect.fromLTWH(
      draft.crop.left + square.left * draft.crop.width,
      draft.crop.top + square.top * draft.crop.height,
      square.width * draft.crop.width,
      square.height * draft.crop.height,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.xl,
            AppSpacing.page,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Text(l10n.editorTheme, style: theme.textTheme.headlineSmall),
              const Spacer(),
              Flexible(
                flex: 3,
                child: Text(
                  l10n.editorThemeCount(stickerThemes.length),
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: _tile + 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            itemCount: stickerThemes.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final t = stickerThemes[index];
              final usable = data.supports(t);
              final selected = t.id == draft.themeId && draft.sticker != null;
              return Semantics(
                button: true,
                selected: selected,
                enabled: usable,
                label: t.name,
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: () => onChoose(t),
                  child: SizedBox(
                    width: _tile + 8,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppRadius.thumb + 3,
                            ),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary60
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: Opacity(
                            opacity: usable ? 1 : 0.35,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppRadius.thumb - 2,
                              ),
                              child: SizedBox.square(
                                dimension: _tile - 4,
                                child: ExcludeSemantics(
                                  child: StoryCanvas(
                                    format: ShareFormat.square,
                                    background: CroppedPhoto(
                                      bytes: bytes,
                                      crop: thumbCrop,
                                      aspectRatio: 1,
                                    ),
                                    theme: usable ? t : null,
                                    data: data,
                                    placement: StickerPlacement(
                                      center: t.position,
                                      scale: 1.25,
                                    ),
                                    style: draft.style,
                                    watermark: false,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          t.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                            color: selected
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        IconButton(
          icon: const Icon(AppIcons.down),
          tooltip: context.l10n.editorHideThemes,
          onPressed: onClose,
        ),
      ],
    );
  }
}
