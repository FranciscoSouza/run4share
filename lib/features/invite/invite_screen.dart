import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/links.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/share/share_actions.dart';
import 'package:run4share/features/templates/template_canvas.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/buttons.dart';

/// "Bring a training partner": the invite message with the app link.
class InviteScreen extends ConsumerWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final link = AppLinks.playStore.toString();
    final message = '${l10n.inviteMessage} $link';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(AppIcons.back, size: 30),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.settingsInvite),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  const ExcludeSemantics(child: _Cards()),
                  const SizedBox(height: AppSpacing.xl),
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.inviteTitle,
                      style: theme.textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.inviteBody,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border:
                          Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.inviteYours.toUpperCase(),
                          style: theme.textTheme.labelSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.inviteMessage,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _LinkBox(link: link),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppButton(
                label: l10n.inviteShare,
                icon: AppIcons.share,
                onPressed: () =>
                    ref.read(shareActionsProvider).shareText(message),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two template previews, fanned out like the design.
class _Cards extends StatelessWidget {
  const _Cards();

  @override
  Widget build(BuildContext context) {
    Widget card(String id, double turn, Offset shift) => Transform.translate(
          offset: shift,
          child: Transform.rotate(
            angle: turn * math.pi / 180,
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.thumb),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.thumb),
                child: TemplateCanvas(
                  template: templateById(id)!,
                  watermark: false,
                ),
              ),
            ),
          ),
        );
    return SizedBox(
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          card('story-hero', -8, const Offset(-50, 6)),
          card('top-line', 6, const Offset(50, -6)),
        ],
      ),
    );
  }
}

/// The link with a copy button; confirms inline for two seconds rather
/// than with a snack bar, which would cover "Share invite link".
class _LinkBox extends StatefulWidget {
  const _LinkBox({required this.link});

  final String link;

  @override
  State<_LinkBox> createState() => _LinkBoxState();
}

class _LinkBoxState extends State<_LinkBox> {
  bool _copied = false;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.link));
    if (!mounted) return;
    setState(() => _copied = true);
    _reset?.cancel();
    _reset = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.button),
        onTap: _copy,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _copied ? l10n.inviteCopied : widget.link,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary40,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                _copied ? AppIcons.check : AppIcons.copy,
                color: AppColors.primary40,
                semanticLabel: _copied ? l10n.inviteCopied : l10n.inviteCopy,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
