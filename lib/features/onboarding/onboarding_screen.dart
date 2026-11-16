import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/brand.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/platform.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_text.dart';
import 'package:run4share/app/theme/app_theme.dart';
import 'package:run4share/features/onboarding/onboarding.dart';
import 'package:run4share/features/onboarding/onboarding_art.dart';
import 'package:run4share/features/pro/pro_store.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/logo.dart';
import 'package:run4share/shared/widgets/pro_badge.dart';

const _pageCount = 4;

/// The four-page introduction: first launch, or from Settings ([replay]).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({this.replay = false, super.key});

  /// Opened from Settings: finishing goes back there, not Home.
  final bool replay;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  var _page = 0;

  /// The store's price for "See what's in Pro"; null shows no price.
  late final Future<ProOffer?> _offer;

  @override
  void initState() {
    super.initState();
    _offer = ref.read(proStoreProvider).offer().catchError((Object _) => null);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(page);
    } else {
      _pages.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _finish({bool seePro = false}) async {
    final router = GoRouter.of(context);
    await ref.read(onboardingDoneProvider.notifier).complete();
    if (widget.replay) {
      router.pop();
    } else {
      router.go(AppRoutes.activities);
    }
    if (seePro) await router.push(AppRoutes.pro);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final last = _page == _pageCount - 1;
    return Theme(
      data: AppTheme.dark,
      child: PopScope(
        canPop: _page == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _page > 0) _goTo(_page - 1);
        },
        child: Scaffold(
          backgroundColor: AppColors.neutral0,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 12, 0),
                  child: SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        const AppLogo(
                          fontSize: 24,
                          color: AppColors.neutral100,
                        ),
                        const Spacer(),
                        if (last)
                          const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: ProBadge(),
                          )
                        else
                          TextButton(
                            onPressed: _finish,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.neutral80,
                            ),
                            child: Text(
                              l10n.onboardingSkip,
                              style: AppText.button,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pages,
                    onPageChanged: (page) => setState(() => _page = page),
                    children: [
                      for (var i = 1; i <= _pageCount; i++) _Page(page: i),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Dots(page: _page),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary50,
                            foregroundColor: AppColors.neutral100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: AppText.button.copyWith(fontSize: 17),
                          ),
                          onPressed: last ? _finish : () => _goTo(_page + 1),
                          child: Text(
                            last ? l10n.onboardingStart : l10n.onboardingNext,
                          ),
                        ),
                      ),
                      if (last)
                        FutureBuilder<ProOffer?>(
                          future: _offer,
                          builder: (context, snapshot) => TextButton(
                            onPressed: () => _finish(seePro: true),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.neutral90,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: Text(
                              switch (snapshot.data) {
                                final offer? =>
                                  l10n.onboardingSeeProPrice(offer.price),
                                null => l10n.onboardingSeePro,
                              },
                              style: AppText.button,
                            ),
                          ),
                        ),
                    ],
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

/// Art on top (4:5, at most about half the height), then title and body.
/// The text scrolls rather than ever running under the bottom bar.
class _Page extends ConsumerWidget {
  const _Page({required this.page});

  final int page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final (title, body) = switch (page) {
      1 => (l10n.onboardingTitle1, l10n.onboardingBody1),
      2 => (l10n.onboardingTitle2, l10n.onboardingBody2),
      3 => (l10n.onboardingTitle3, l10n.onboardingBody3),
      _ => (l10n.onboardingTitle4, l10n.onboardingBody4),
    };
    final health = healthSourceFor(ref.watch(platformProvider));
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - 48;
        final height = (constraints.maxHeight * 0.48)
            .clamp(240.0, 420.0)
            .clamp(0.0, width / 0.8);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: SizedBox(
                  height: height,
                  width: height * 0.8,
                  child: OnboardingArt(page: page),
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: AppText.onboardingTitle.copyWith(
                          color: AppColors.neutral100,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        body,
                        style: AppText.onboardingBody.copyWith(
                          color: AppColors.neutral70,
                        ),
                      ),
                      if (page == 2) ...[
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            const _Chip(Brand.strava),
                            if (health != null)
                              _Chip(
                                health == HealthSource.appleHealth
                                    ? Brand.appleHealth
                                    : Brand.healthConnect,
                              ),
                            _Chip(l10n.onboardingByHand),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A source name in a pill: text only (no logos, per Strava's rules).
class _Chip extends StatelessWidget {
  const _Chip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.neutral10,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.neutral20),
        ),
        child: Text(
          text,
          style: AppText.secondary.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral90,
          ),
        ),
      );
}

class _Dots extends StatelessWidget {
  const _Dots({required this.page});

  final int page;

  @override
  Widget build(BuildContext context) => Semantics(
        label: context.l10n.onboardingPageOf(page + 1, _pageCount),
        excludeSemantics: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _pageCount; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == page ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == page ? AppColors.primary50 : AppColors.neutral20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      );
}
