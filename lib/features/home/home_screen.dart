import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/brand.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/platform.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/activities/strava_sync.dart';
import 'package:run4share/features/create/creation_draft.dart';
import 'package:run4share/features/health/connect_health.dart';
import 'package:run4share/features/health/health_connect_sync.dart';
import 'package:run4share/features/home/featured_templates.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/strava/strava_connection.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/app_header.dart';
import 'package:run4share/shared/widgets/buttons.dart';
import 'package:run4share/shared/widgets/grouped_list.dart';
import 'package:run4share/shared/widgets/pills.dart';

/// Activities tab: popular templates, then the activity list (synced from
/// Strava and added by hand), or the sources to connect when there is
/// nothing yet.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Start fetching older activities this far from the end of the list.
  static const _loadOlderWithin = 600.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(stravaSyncProvider.notifier).syncIfStale());
        unawaited(ref.read(healthConnectProvider.notifier).syncIfStale());
      }
    });
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical &&
        notification.metrics.extentAfter < _loadOlderWithin) {
      unawaited(ref.read(stravaSyncProvider.notifier).loadOlder());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Sync right after Strava is connected.
    ref.listen(stravaConnectionProvider, (previous, next) {
      if (previous?.value == null && next.value != null) {
        unawaited(ref.read(stravaSyncProvider.notifier).sync());
      }
    });

    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final connection = ref.watch(stravaConnectionProvider);
    final checking = connection.isLoading && !connection.hasValue;
    final stravaConnected = connection.value != null;
    final hub = ref.watch(healthConnectProvider);
    // Any source to sync from: Strava or Health Connect.
    final connected = stravaConnected || hub.connected;
    final activities = ref.watch(activitiesProvider).value;
    final stravaSync = ref.watch(stravaSyncProvider);
    // One status line for both sources.
    final sync = SyncState(
      syncing: stravaSync.syncing || hub.syncing,
      loadingOlder: stravaSync.loadingOlder,
      failed: stravaSync.failed || hub.failed,
      lastSyncedAt: [
        if (stravaSync.lastSyncedAt case final t?) t,
        if (hub.lastSyncedAt case final t?) t,
      ].fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a),
    );
    final hasActivities = activities?.isNotEmpty ?? false;
    void connect() => context.push(AppRoutes.connectStrava);

    final list = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        AppHeader(
          trailing: checking || stravaConnected
              ? null
              : AppPill(
                  label: l10n.homeConnectStrava,
                  icon: AppIcons.link,
                  variant: AppPillVariant.dark,
                  onPressed: connect,
                ),
        ),
        if (sync.syncing) _PullingBanner(text: l10n.homePulling),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: _Heading(
                  l10n.homeTemplatesTitle,
                  style: textTheme.headlineSmall,
                ),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.templates),
                child: Text(l10n.homeSeeAll),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const FeaturedTemplates(),
        const SizedBox(height: AppSpacing.xl),
        if (activities == null || checking)
          const SizedBox.shrink()
        else if (connected || hasActivities) ...[
          _ActivitiesHeader(sync: sync, connected: connected),
          const SizedBox(height: AppSpacing.sm),
          // Apple Health hides a refusal as "no data": say where to look.
          if (hub.connected &&
              hub.empty &&
              ref.read(platformProvider) == TargetPlatform.iOS)
            _Message(text: l10n.hubEmptyApple),
          if (!hasActivities)
            _Message(
              text: sync.syncing
                  ? l10n.homeSyncing
                  : connected
                      ? l10n.homeNoActivities
                      : l10n.homeNoActivitiesYet,
            )
          else
            for (final activity in activities)
              _ActivityTile(activity: activity),
          if (activities.any((a) => a.source == ActivitySource.strava))
            const _PoweredByStrava(),
          if (stravaConnected && sync.loadingOlder)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!stravaConnected || !hub.connected) ...[
            const SizedBox(height: AppSpacing.lg),
            ..._sources(context, connect: connect),
          ],
        ] else
          ..._sources(context, connect: connect, addManually: true),
      ],
    );

    return SafeArea(
      bottom: false,
      child: NotificationListener<ScrollNotification>(
        onNotification: stravaConnected ? _onScroll : null,
        child: connected
            ? RefreshIndicator.noSpinner(
                onRefresh: () => Future.wait([
                  ref.read(stravaSyncProvider.notifier).sync(),
                  ref.read(healthConnectProvider.notifier).sync(),
                ]),
                child: list,
              )
            : list,
      ),
    );
  }

  List<Widget> _sources(
    BuildContext context, {
    required VoidCallback connect,
    bool addManually = false,
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
            if (ref.watch(stravaConnectionProvider).value == null)
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
            // Only the phone's own health source (Apple Health on
            // iPhone, Health Connect on Android).
            if (healthSourceFor(ref.read(platformProvider)) case final source?)
              GroupedListTile(
                icon: source == HealthSource.appleHealth
                    ? AppIcons.heart
                    : AppIcons.pulse,
                title: source == HealthSource.appleHealth
                    ? Brand.appleHealth
                    : Brand.healthConnect,
                subtitle: source == HealthSource.appleHealth
                    ? l10n.sourceOnIphone
                    : l10n.sourceOnAndroid,
                trailing: ref.watch(healthConnectProvider).connected
                    ? Icon(
                        AppIcons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : AppPill(
                        label: l10n.actionConnect,
                        variant: AppPillVariant.outlined,
                        onPressed: () => connectHealthConnect(context, ref),
                      ),
              ),
          ],
        ),
      ),
      if (addManually) ...[
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: AppButton(
            label: l10n.homeAddManually,
            icon: AppIcons.plus,
            variant: AppButtonVariant.secondary,
            onPressed: () => context.push(AppRoutes.newActivity),
          ),
        ),
      ],
    ];
  }
}

/// Strava's attribution, under lists that show Strava data.
class _PoweredByStrava extends StatelessWidget {
  const _PoweredByStrava();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: Image.asset(
          'assets/strava/powered_by_strava.png',
          width: 148,
          height: 15,
          semanticLabel: 'Powered by Strava',
        ),
      ),
    );
  }
}

class _PullingBanner extends StatelessWidget {
  const _PullingBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colour = Theme.of(context).colorScheme.onPrimaryContainer;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colour,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivitiesHeader extends ConsumerWidget {
  const _ActivitiesHeader({required this.sync, required this.connected});

  final SyncState sync;
  final bool connected;

  String? _status(BuildContext context, DateTime now) {
    final l10n = context.l10n;
    if (!connected) return null;
    if (sync.syncing) return l10n.homeSyncing;
    if (sync.failed) return l10n.homeSyncFailed;
    final last = sync.lastSyncedAt;
    if (last == null) return null;
    final ago = now.difference(last);
    if (ago.inMinutes < 1) return l10n.homeSyncedJustNow;
    if (ago.inHours < 1) return l10n.homeSyncedMinutes(ago.inMinutes);
    if (ago.inDays < 1) return l10n.homeSyncedHours(ago.inHours);
    final locale = Localizations.localeOf(context).toString();
    return l10n.homeSyncedOn(DateFormat('d MMM', locale).format(last));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final status = _status(context, ref.watch(clockProvider)());
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.page, right: 4),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                l10n.homeYourActivities,
                style: theme.textTheme.headlineSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (status != null)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: sync.failed
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          IconButton.filledTonal(
            icon: const Icon(AppIcons.plus),
            tooltip: l10n.homeAddManually,
            onPressed: () => context.push(AppRoutes.newActivity),
          ),
        ],
      ),
    );
  }
}

enum _ActivityAction { edit, delete }

class _ActivityTile extends ConsumerWidget {
  const _ActivityTile({required this.activity});

  final Activity activity;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteActivityTitle),
        content: Text(l10n.deleteActivityBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(activityRepositoryProvider).deleteManual(activity.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.activityDeleted)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final format = ActivityFormat(
      l10n: l10n,
      locale: Localizations.localeOf(context).toString(),
      units: ref.watch(unitsProvider),
    );
    final manual = activity.source == ActivitySource.manual;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.md,
      ),
      child: format.card(
        activity,
        onTap: () {
          ref.read(templateChoiceProvider.notifier).choose(null);
          unawaited(context.push(AppRoutes.choosePhoto(activity.id)));
        },
        trailing: manual
            ? PopupMenuButton<_ActivityAction>(
                icon: const Icon(AppIcons.more),
                tooltip: l10n.activityMenu,
                onSelected: (action) => switch (action) {
                  _ActivityAction.edit => context.push(
                      AppRoutes.editActivity(activity.id),
                    ),
                  _ActivityAction.delete => _delete(context, ref),
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _ActivityAction.edit,
                    child: ListTile(
                      leading: const Icon(AppIcons.edit),
                      title: Text(l10n.actionEdit),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: _ActivityAction.delete,
                    child: ListTile(
                      leading: Icon(
                        AppIcons.trash,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(
                        l10n.actionDelete,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
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
