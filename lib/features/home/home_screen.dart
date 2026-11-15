import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/brand.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/strava/strava_api.dart';
import 'package:run4share/features/strava/strava_connection.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/coming_soon.dart';
import 'package:run4share/shared/widgets/app_header.dart';
import 'package:run4share/shared/widgets/buttons.dart';
import 'package:run4share/shared/widgets/grouped_list.dart';
import 'package:run4share/shared/widgets/pills.dart';

/// Activities tab: sources to connect, or the latest activities once
/// Strava is connected.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final connection = ref.watch(stravaConnectionProvider);
    final checking = connection.isLoading && !connection.hasValue;
    final connected = connection.value != null;
    void soon() => showComingSoon(context);
    void connect() => context.push(AppRoutes.connectStrava);

    final list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        AppHeader(
          trailing: checking || connected
              ? null
              : AppPill(
                  label: l10n.homeConnectStrava,
                  icon: AppIcons.link,
                  variant: AppPillVariant.dark,
                  onPressed: connect,
                ),
        ),
        _Heading(l10n.homePopularTemplates, style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.md),
        _TemplateCarousel(onTap: (_) => soon()),
        const SizedBox(height: AppSpacing.xl),
        if (connected)
          ..._activities(context, ref)
        else if (!checking)
          ..._sources(context, connect: connect, soon: soon),
      ],
    );

    return SafeArea(
      bottom: false,
      child: connected
          ? RefreshIndicator(
              onRefresh: () => ref.refresh(stravaActivitiesProvider.future),
              child: list,
            )
          : list,
    );
  }

  List<Widget> _sources(
    BuildContext context, {
    required VoidCallback connect,
    required VoidCallback soon,
  }) {
    final l10n = context.l10n;
    return [
      _Heading(
        l10n.homeBringWorkouts,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: AppSpacing.md),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        child: GroupedListCard(
          children: [
            GroupedListTile(
              icon: AppIcons.link,
              title: Brand.strava,
              subtitle: l10n.sourceStravaSubtitle,
              trailing: AppPill(
                label: l10n.actionConnect,
                variant: AppPillVariant.dark,
                onPressed: connect,
              ),
            ),
            GroupedListTile(
              icon: AppIcons.heart,
              title: Brand.appleHealth,
              subtitle: l10n.sourceOnIphone,
              trailing: AppPill(
                label: l10n.actionConnect,
                variant: AppPillVariant.outlined,
                onPressed: soon,
              ),
            ),
            GroupedListTile(
              icon: AppIcons.pulse,
              title: Brand.healthConnect,
              subtitle: l10n.sourceOnAndroid,
              trailing: AppPill(
                label: l10n.actionConnect,
                variant: AppPillVariant.outlined,
                onPressed: soon,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        child: AppButton(
          label: l10n.homeAddManually,
          icon: AppIcons.plus,
          variant: AppButtonVariant.secondary,
          onPressed: soon,
        ),
      ),
    ];
  }

  List<Widget> _activities(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final activities = ref.watch(stravaActivitiesProvider);
    final format = ActivityFormat(
      l10n: l10n,
      locale: Localizations.localeOf(context).toString(),
      units: ref.watch(unitsProvider),
    );
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return [
      Padding(
        padding: const EdgeInsets.only(left: AppSpacing.page, right: 4),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.homeYourActivities,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
            ),
            IconButton.filledTonal(
              icon: const Icon(AppIcons.plus),
              tooltip: l10n.homeAddManually,
              onPressed: () => showComingSoon(context),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      ...switch (activities) {
        AsyncData(:final value) when value.isEmpty => [
            _Message(text: l10n.homeNoActivities, style: muted),
          ],
        AsyncData(:final value) => [
            for (final activity in value)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  AppSpacing.md,
                ),
                child: format.card(
                  activity,
                  onTap: () => showComingSoon(context),
                ),
              ),
          ],
        AsyncError() => [
            _Message(text: l10n.homeActivitiesError, style: muted),
            Center(
              child: AppPill(
                label: l10n.actionRetry,
                variant: AppPillVariant.tonal,
                onPressed: () => ref.invalidate(stravaActivitiesProvider),
              ),
            ),
          ],
        _ => [
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
      },
    ];
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Text(text, style: style, textAlign: TextAlign.center),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text, {this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Semantics(header: true, child: Text(text, style: style)),
    );
  }
}

/// Placeholder for a popular template until themes exist (phase 4a).
@immutable
class _TemplatePreview {
  const _TemplatePreview(this.name, this.colours);

  final String name;
  final List<Color> colours;
}

const _templates = [
  _TemplatePreview('Story Hero', [Color(0xFF4A9AD8), Color(0xFF3F7A6A)]),
  _TemplatePreview('Top Line', [Color(0xFF6A3F9A), Color(0xFF1A1426)]),
  _TemplatePreview('Left Stack', [Color(0xFF1E3F6E), Color(0xFFB8492F)]),
];

class _TemplateCarousel extends StatelessWidget {
  const _TemplateCarousel({required this.onTap});

  final ValueChanged<String> onTap;

  static const _width = 100.0;
  static const _height = 178.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: _height + 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        itemCount: _templates.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.md - 2),
        itemBuilder: (context, index) {
          final template = _templates[index];
          return SizedBox(
            width: _width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.thumb),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onTap(template.name),
                    child: Ink(
                      width: _width,
                      height: _height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: template.colours,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  template.name,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
