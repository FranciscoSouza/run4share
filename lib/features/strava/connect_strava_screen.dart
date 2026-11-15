import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/brand.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/app/theme/app_text.dart';
import 'package:run4share/features/strava/strava_connection.dart';
import 'package:run4share/features/strava/strava_messages.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/buttons.dart';

/// Explains what run4share reads, then hands over to Strava.
class ConnectStravaScreen extends ConsumerStatefulWidget {
  const ConnectStravaScreen({super.key});

  @override
  ConsumerState<ConnectStravaScreen> createState() =>
      _ConnectStravaScreenState();
}

class _ConnectStravaScreenState extends ConsumerState<ConnectStravaScreen> {
  bool _busy = false;

  Future<void> _connect() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final session =
          await ref.read(stravaConnectionProvider.notifier).connect();
      final name = session.athleteName;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              name == null
                  ? l10n.stravaConnected
                  : l10n.stravaConnectedAs(name),
            ),
          ),
        );
      if (mounted) context.pop();
    } on Object catch (error) {
      final message = stravaFailureMessage(l10n, error);
      if (message != null) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(AppIcons.back, size: 30),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      children: [
                        const _AppTile(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: Icon(AppIcons.link, color: muted),
                        ),
                        const _StravaTile(),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.connectTitle,
                        style: theme.textTheme.displaySmall,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.connectBody,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: muted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _Point(
                      title: l10n.connectReadsActivities,
                      detail: l10n.connectReadsActivitiesDetail,
                    ),
                    _Point(
                      title: l10n.connectReadsProfile,
                      detail: l10n.connectReadsProfileDetail,
                    ),
                    _Point(
                      title: l10n.connectNeverPosts,
                      detail: l10n.connectNeverPostsDetail,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  if (_busy)
                    const SizedBox(
                      height: AppButton.height,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    AppButton(
                      label: l10n.connectContinue,
                      variant: AppButtonVariant.dark,
                      onPressed: _connect,
                    ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.connectFootnote,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _tileSize = 64.0;

class _AppTile extends StatelessWidget {
  const _AppTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _tileSize,
      height: _tileSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(AppRadius.thumb),
      ),
      child: Text.rich(
        TextSpan(
          style: AppText.logo.copyWith(color: AppColors.neutral100),
          children: const [
            TextSpan(text: 'r'),
            TextSpan(
              text: '4',
              style: TextStyle(color: AppColors.primary60),
            ),
            TextSpan(text: 's'),
          ],
        ),
        semanticsLabel: 'run4share',
      ),
    );
  }
}

/// Placeholder until the official Strava brand assets are added.
class _StravaTile extends StatelessWidget {
  const _StravaTile();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: _tileSize,
      height: _tileSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.thumb),
        border: Border.all(color: scheme.outline),
      ),
      child: Text(
        Brand.strava,
        style: AppText.secondary.copyWith(
          fontWeight: FontWeight.w600,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primary95,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              AppIcons.check,
              size: 16,
              color: AppColors.primary30,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                Text(
                  detail,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
