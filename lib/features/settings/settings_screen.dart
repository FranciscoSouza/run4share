import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/app_info.dart';
import 'package:run4share/app/brand.dart';
import 'package:run4share/app/links.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/platform.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/system.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/features/lab/lab.dart';
import 'package:run4share/features/photos/photo_library.dart';
import 'package:run4share/features/pro/pro.dart';
import 'package:run4share/features/pro/pro_store.dart';
import 'package:run4share/features/settings/language.dart';
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
    final stravaDemo = ref.watch(stravaDemoProvider);
    final isPro = ref.watch(isProProvider);
    final pretendPro = ref.watch(pretendProProvider);
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
                if (healthSourceFor(ref.read(platformProvider))
                    case final source?)
                  GroupedListTile(
                    icon: source == HealthSource.appleHealth
                        ? AppIcons.heart
                        : AppIcons.pulse,
                    title: source == HealthSource.appleHealth
                        ? Brand.appleHealth
                        : Brand.healthConnect,
                    subtitle: l10n.settingsNotConnected,
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
                  subtitle: isPro ? l10n.proThanks : l10n.settingsProSubtitle,
                  trailing: isPro
                      ? Icon(AppIcons.check, color: theme.colorScheme.primary)
                      : AppPill(
                          label: l10n.actionUnlock,
                          onPressed: () => context.push(AppRoutes.pro),
                        ),
                ),
                GroupedListTile(
                  icon: AppIcons.refresh,
                  title: l10n.settingsRestore,
                  onTap: () => _restore(context, ref),
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
                  subtitle: ref.watch(languageProvider) == null
                      ? l10n.settingsLanguageSubtitle(l10n.languageName)
                      : l10n.languageName,
                  onTap: () => _chooseLanguage(context, ref),
                ),
                GroupedListTile(
                  icon: AppIcons.image,
                  title: l10n.settingsPhotoAccess,
                  subtitle: l10n.settingsPhotoAccessSubtitle,
                  onTap: ref.read(photoLibraryProvider).openSettings,
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
                  onTap: ref.read(systemActionsProvider).openStoreListing,
                ),
                GroupedListTile(
                  icon: AppIcons.invite,
                  title: l10n.settingsInvite,
                  subtitle: l10n.settingsInviteSubtitle,
                  onTap: () => context.push(AppRoutes.invite),
                ),
                GroupedListTile(
                  icon: AppIcons.shield,
                  title: l10n.settingsPrivacy,
                  onTap: () => ref
                      .read(systemActionsProvider)
                      .openLink(AppLinks.privacyPolicy),
                ),
              ],
            ),
            if (labVisible) ...[
              SectionLabel(l10n.settingsSectionLab),
              GroupedListCard(
                children: [
                  GroupedListTile(
                    icon: AppIcons.flask,
                    title: l10n.labStravaDemo,
                    subtitle: l10n.labStravaDemoSubtitle,
                    onTap: () => _setStravaDemo(ref, enabled: !stravaDemo),
                    trailing: Switch(
                      value: stravaDemo,
                      onChanged: (enabled) =>
                          _setStravaDemo(ref, enabled: enabled),
                    ),
                  ),
                  GroupedListTile(
                    icon: AppIcons.star,
                    title: l10n.labPretendPro,
                    subtitle: l10n.labPretendProSubtitle,
                    onTap: () => ref
                        .read(pretendProProvider.notifier)
                        .setEnabled(enabled: !pretendPro),
                    trailing: Switch(
                      value: pretendPro,
                      onChanged: (enabled) => ref
                          .read(pretendProProvider.notifier)
                          .setEnabled(enabled: enabled),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xs,
                  AppSpacing.sm,
                  AppSpacing.xs,
                  0,
                ),
                child: Text(l10n.labFootnote, style: theme.textTheme.bodySmall),
              ),
            ],
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

  /// The phone's per-app language screen; on phones without one (Android
  /// 12 and older) a list inside run4share.
  Future<void> _chooseLanguage(BuildContext context, WidgetRef ref) async {
    if (await ref.read(systemActionsProvider).openAppLanguage()) return;
    if (!context.mounted) return;
    final l10n = context.l10n;
    final current = ref.read(languageProvider);
    final choice = await showModalBottomSheet<_LanguageChoice>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: RadioGroup<Locale?>(
          groupValue: current,
          onChanged: (locale) =>
              Navigator.pop(context, _LanguageChoice(locale)),
          child: ListView(
            shrinkWrap: true,
            children: [
              RadioListTile<Locale?>(
                value: null,
                title: Text(l10n.languagePhone),
              ),
              for (final locale in AppLocalizations.supportedLocales)
                RadioListTile<Locale?>(
                  value: locale,
                  title: Text(lookupAppLocalizations(locale).languageName),
                ),
            ],
          ),
        ),
      ),
    );
    if (choice != null) {
      await ref.read(languageProvider.notifier).select(choice.locale);
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.proRestoring;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    await ref.read(proStoreProvider).restore();
  }

  Future<void> _setStravaDemo(WidgetRef ref, {required bool enabled}) =>
      ref.read(stravaDemoProvider.notifier).setEnabled(enabled: enabled);

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

/// Wraps the picked locale so "phone language" (null) differs from
/// closing the sheet.
class _LanguageChoice {
  const _LanguageChoice(this.locale);

  final Locale? locale;
}
