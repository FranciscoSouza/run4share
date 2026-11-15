import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/app_info.dart';
import 'package:run4share/app/brand.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/strava/strava_connection.dart';
import 'package:run4share/features/strava/strava_models.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/coming_soon.dart';
import 'package:run4share/shared/widgets/grouped_list.dart';
import 'package:run4share/shared/widgets/pills.dart';
import 'package:run4share/shared/widgets/segmented_toggle.dart';

/// Settings, opened from the gear on either tab.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final units = ref.watch(unitsProvider);
    final strava = ref.watch(stravaConnectionProvider).value;
    void soon() => showComingSoon(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(AppIcons.back, size: 30),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.settingsTitle),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          children: [
            SectionLabel(l10n.settingsSectionSources),
            GroupedListCard(
              children: [
                GroupedListTile(
                  icon: AppIcons.link,
                  title: Brand.strava,
                  subtitle: switch (strava) {
                    null => l10n.settingsNotConnected,
                    StravaSession(:final athleteName?) =>
                      l10n.stravaConnectedAs(athleteName),
                    _ => l10n.stravaConnected,
                  },
                  trailing: strava == null
                      ? _connect(
                          l10n,
                          () => context.push(AppRoutes.connectStrava),
                        )
                      : AppPill(
                          label: l10n.actionDisconnect,
                          variant: AppPillVariant.destructive,
                          onPressed: () => _disconnect(context, ref),
                        ),
                ),
                GroupedListTile(
                  icon: AppIcons.heart,
                  title: Brand.appleHealth,
                  subtitle: l10n.settingsNotConnected,
                  trailing: _connect(l10n, soon),
                ),
                GroupedListTile(
                  icon: AppIcons.pulse,
                  title: Brand.healthConnect,
                  subtitle: l10n.settingsAndroidOnly,
                  trailing: _connect(l10n, soon),
                ),
              ],
            ),
            SectionLabel(l10n.settingsSectionPurchase),
            GroupedListCard(
              children: [
                GroupedListTile(
                  icon: AppIcons.star,
                  title: Brand.pro,
                  subtitle: l10n.settingsProSubtitle,
                  trailing: AppPill(label: l10n.actionUnlock, onPressed: soon),
                ),
                GroupedListTile(
                  icon: AppIcons.refresh,
                  title: l10n.settingsRestore,
                  onTap: soon,
                ),
              ],
            ),
            SectionLabel(l10n.settingsSectionPreferences),
            GroupedListCard(
              children: [
                GroupedListTile(
                  icon: AppIcons.ruler,
                  title: l10n.settingsUnits,
                  trailing: SegmentedToggle<Units>(
                    options: [
                      (Units.km, l10n.unitKm),
                      (Units.mi, l10n.unitMi),
                    ],
                    selected: units,
                    onChanged: ref.read(unitsProvider.notifier).select,
                  ),
                ),
                GroupedListTile(
                  icon: AppIcons.globe,
                  title: l10n.settingsLanguage,
                  subtitle: l10n.settingsLanguageSubtitle(l10n.languageName),
                  onTap: soon,
                ),
                GroupedListTile(
                  icon: AppIcons.image,
                  title: l10n.settingsPhotoAccess,
                  subtitle: l10n.settingsPhotoAccessSubtitle,
                  onTap: soon,
                ),
              ],
            ),
            SectionLabel(l10n.settingsSectionAbout),
            GroupedListCard(
              children: [
                GroupedListTile(
                  icon: AppIcons.sparkle,
                  title: l10n.settingsRate,
                  subtitle: l10n.settingsRateSubtitle,
                  onTap: soon,
                ),
                GroupedListTile(
                  icon: AppIcons.invite,
                  title: l10n.settingsInvite,
                  subtitle: l10n.settingsInviteSubtitle,
                  onTap: soon,
                ),
                GroupedListTile(
                  icon: AppIcons.shield,
                  title: l10n.settingsPrivacy,
                  onTap: soon,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                l10n.settingsVersion(AppInfo.version),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _disconnect(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.stravaDisconnected;
    await ref.read(stravaConnectionProvider.notifier).disconnect();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _connect(AppLocalizations l10n, VoidCallback onPressed) => AppPill(
        label: l10n.actionConnect,
        variant: AppPillVariant.tonal,
        onPressed: onPressed,
      );
}
