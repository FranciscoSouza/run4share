import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/brand.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/coming_soon.dart';
import 'package:run4share/shared/widgets/app_header.dart';
import 'package:run4share/shared/widgets/buttons.dart';
import 'package:run4share/shared/widgets/grouped_list.dart';
import 'package:run4share/shared/widgets/pills.dart';

/// Activities tab. Phase 0 shows the "no source connected" layout.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    void soon() => showComingSoon(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          AppHeader(
            trailing: AppPill(
              label: l10n.homeConnectStrava,
              icon: AppIcons.link,
              variant: AppPillVariant.dark,
              onPressed: soon,
            ),
          ),
          _Heading(l10n.homePopularTemplates, style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          _TemplateCarousel(onTap: (_) => soon()),
          const SizedBox(height: AppSpacing.xl),
          _Heading(l10n.homeBringWorkouts, style: textTheme.headlineSmall),
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
                    onPressed: soon,
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
        ],
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
