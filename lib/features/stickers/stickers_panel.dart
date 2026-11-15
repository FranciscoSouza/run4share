import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/stickers/activity_labels.dart';
import 'package:run4share/features/stickers/extra_sticker_view.dart';
import 'package:run4share/features/stickers/sticker_catalogue.dart';
import 'package:run4share/l10n/l10n.dart';

/// The editor's Stickers picker (Pro): labels this activity earned, its
/// start time, mood phrases, and stamps and seals.
class StickersPanel extends StatefulWidget {
  const StickersPanel({
    required this.activity,
    required this.history,
    required this.isPro,
    required this.onAdd,
    required this.onClose,
    super.key,
  });

  final Activity activity;

  /// Every stored activity, for run4share's own records.
  final List<Activity> history;
  final bool isPro;
  final void Function(ExtraKind kind, String value) onAdd;
  final VoidCallback onClose;

  @override
  State<StickersPanel> createState() => _StickersPanelState();
}

class _StickersPanelState extends State<StickersPanel> {
  Mood _mood = Mood.proud;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final labels = labelsFor(widget.activity, widget.history);
    Widget tile(ExtraKind kind, String value, String name) => _Tile(
          label: name,
          onTap: () => widget.onAdd(kind, value),
          child: ExtraStickerView(
            kind: kind,
            value: value,
            start: widget.activity.startLocal,
          ),
        );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.42,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Text(
                    l10n.editorStickers,
                    style: theme.textTheme.headlineSmall,
                  ),
                  if (!widget.isPro) ...[
                    const SizedBox(width: AppSpacing.sm),
                    const _ProMark(),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: const Icon(AppIcons.down),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
            _Section(title: l10n.stickersForActivity),
            _Row(
              children: [
                for (final label in labels)
                  tile(
                    ExtraKind.label,
                    labelValue(label),
                    labelText(l10n, label),
                  ),
                tile(ExtraKind.time, '', l10n.stickersTime),
              ],
            ),
            _Section(title: l10n.stickersPhrases),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                ),
                children: [
                  for (final mood in Mood.values)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(
                        label: Text(moodName(l10n, mood)),
                        selected: mood == _mood,
                        onSelected: (_) => setState(() => _mood = mood),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var i = 0; i < phrasesPerMood; i++)
              _PhraseRow(
                text: phraseText(l10n, phraseId(_mood, i)) ?? '',
                onTap: () => widget.onAdd(ExtraKind.phrase, phraseId(_mood, i)),
              ),
            _Section(title: l10n.stickersStamps),
            _Row(
              children: [
                for (final stamp in StampKind.values)
                  tile(ExtraKind.stamp, stamp.name, stampText(l10n, stamp)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProMark extends StatelessWidget {
  const _ProMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning60,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'PRO',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.neutral0,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.md,
        AppSpacing.page,
        AppSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        children: [
          for (final child in children)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: child,
            ),
        ],
      ),
    );
  }
}

/// A sticker preview, drawn by the real renderer and scaled down.
class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.onTap, required this.child});

  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColors.neutral20,
        borderRadius: BorderRadius.circular(AppRadius.thumb),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.thumb),
          child: SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: FittedBox(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhraseRow extends StatelessWidget {
  const _PhraseRow({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Icon(AppIcons.plus, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
          ],
        ),
      ),
    );
  }
}
