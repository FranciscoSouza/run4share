import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/app/theme/app_text.dart';
import 'package:run4share/app/theme/app_theme.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/pro/pro.dart';
import 'package:run4share/features/pro/pro_store.dart';
import 'package:run4share/features/templates/template_canvas.dart';
import 'package:run4share/l10n/l10n.dart';

/// Preview art for the Pro screen, like the design's three cards.
const _previews = [
  StoryTemplate(
    id: 'pro-poster',
    name: 'Poster',
    themeId: 'poster',
    format: ShareFormat.story,
    colours: [Color(0xFF6B4E7A), Color(0xFFC07A5A), Color(0xFF2A2235)],
  ),
  StoryTemplate(
    id: 'pro-ring',
    name: 'Heart Ring',
    themeId: 'heart-ring',
    format: ShareFormat.story,
    colours: [Color(0xFFBFE0C8), Color(0xFF3E7A52), Color(0xFF1E3B28)],
  ),
  StoryTemplate(
    id: 'pro-weekday',
    name: 'Weekday',
    themeId: 'weekday',
    format: ShareFormat.story,
    colours: [Color(0xFFF2B36B), Color(0xFFD27C45), Color(0xFF7A3E22)],
  ),
];

/// "Unlock everything, once": the one-off Pro purchase.
class ProScreen extends ConsumerStatefulWidget {
  const ProScreen({super.key});

  @override
  ConsumerState<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends ConsumerState<ProScreen> {
  late final Future<ProOffer?> _offer;
  StreamSubscription<ProEvent>? _events;
  bool _busy = false;

  /// Shown above the button (a snack bar would cover it).
  String? _message;

  @override
  void initState() {
    super.initState();
    final store = ref.read(proStoreProvider);
    _offer = store.offer();
    _events = store.events.listen(_onEvent);
  }

  @override
  void dispose() {
    unawaited(_events?.cancel());
    super.dispose();
  }

  void _onEvent(ProEvent event) {
    if (!mounted) return;
    final l10n = context.l10n;
    setState(() {
      _busy = event == ProEvent.pending;
      _message = switch (event) {
        // The screen turns into its "Thanks" state; nothing to add.
        ProEvent.unlocked => null,
        ProEvent.pending => l10n.proPending,
        ProEvent.failed => l10n.proFailed,
        ProEvent.cancelled => null,
      };
    });
  }

  Future<void> _buy() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    await ref.read(proStoreProvider).buy();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPro = ref.watch(isProProvider);

    return Theme(
      data: AppTheme.dark,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(AppIcons.close),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => context.pop(),
              ),
            ),
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      children: [
                        const ExcludeSemantics(child: _Cards()),
                        const SizedBox(height: AppSpacing.xl),
                        const Center(child: _ProBadge()),
                        const SizedBox(height: AppSpacing.md),
                        Semantics(
                          header: true,
                          child: Text(
                            isPro ? l10n.proThanks : l10n.proTitle,
                            style: theme.textTheme.displaySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.proSubtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        // Only what Pro gives today; more as it's built.
                        _Benefit(text: l10n.proBenefitWatermark),
                        _Benefit(text: l10n.proBenefitThemes),
                      ],
                    ),
                  ),
                  if (_message != null && !isPro)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          _message!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: isPro
                        ? _WhiteButton(
                            label: l10n.actionDone,
                            onPressed: () => context.pop(),
                          )
                        : FutureBuilder<ProOffer?>(
                            future: _offer,
                            builder: (context, snapshot) {
                              final offer = snapshot.data;
                              final loading = snapshot.connectionState !=
                                  ConnectionState.done;
                              return _WhiteButton(
                                label: loading
                                    ? '…'
                                    : offer == null
                                        ? l10n.proUnavailable
                                        : l10n.proUnlockFor(offer.price),
                                busy: _busy,
                                onPressed: offer == null || _busy ? null : _buy,
                              );
                            },
                          ),
                  ),
                  if (!isPro)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () =>
                                  ref.read(proStoreProvider).restore(),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    theme.colorScheme.onSurfaceVariant,
                              ),
                              child: Text(l10n.settingsRestore),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () => context.pop(),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    theme.colorScheme.onSurfaceVariant,
                              ),
                              child: Text(l10n.actionNotNow),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Cards extends StatelessWidget {
  const _Cards();

  @override
  Widget build(BuildContext context) {
    Widget card(StoryTemplate template, double turn, double width) =>
        Transform.rotate(
          angle: turn * math.pi / 180,
          child: SizedBox(
            width: width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.thumb),
              child: TemplateCanvas(template: template, watermark: false),
            ),
          ),
        );
    return SizedBox(
      height: 220,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          card(_previews[0], -6, 100),
          const SizedBox(width: AppSpacing.sm),
          card(_previews[1], 0, 116),
          const SizedBox(width: AppSpacing.sm),
          card(_previews[2], 6, 100),
        ],
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  const _ProBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warning60,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AppIcons.star, size: 16, color: AppColors.neutral0),
          const SizedBox(width: 4),
          Text(
            'PRO',
            style: AppText.label.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral0,
            ),
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.warning60,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              AppIcons.check,
              size: 18,
              color: AppColors.neutral0,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

/// The design's white button on the dark Pro screen.
class _WhiteButton extends StatelessWidget {
  const _WhiteButton({
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.neutral100,
        foregroundColor: AppColors.neutral0,
        disabledBackgroundColor: AppColors.neutral20,
        disabledForegroundColor: AppColors.neutral70,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: AppText.button.copyWith(fontSize: 17),
      ),
      child: busy
          ? const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Text(label),
    );
  }
}
