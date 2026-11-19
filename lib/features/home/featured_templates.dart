import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/app/theme/app_text.dart';
import 'package:run4share/features/editor/sticker_theme.dart';
import 'package:run4share/features/pro/pro.dart';
import 'package:run4share/features/templates/template_canvas.dart';
import 'package:run4share/features/templates/template_info.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/pro_badge.dart';

/// Home's featured templates: one card centred, its neighbours peeking,
/// looping, advancing by itself every 5 s; under it the centred template's
/// name, what it shows, page dots and "Use this template".
class FeaturedTemplates extends ConsumerStatefulWidget {
  const FeaturedTemplates({super.key});

  /// Time between automatic advances.
  static const advanceEvery = Duration(seconds: 5);

  /// Quiet time after the user touches the carousel.
  static const pauseAfterTouch = Duration(seconds: 10);

  @override
  ConsumerState<FeaturedTemplates> createState() => _FeaturedTemplatesState();
}

class _FeaturedTemplatesState extends ConsumerState<FeaturedTemplates>
    with WidgetsBindingObserver {
  static const _gap = 12.0;

  /// Far enough from 0 that it never runs out either way.
  static const _loops = 1000;

  final List<StoryTemplate> _templates = featuredTemplates;
  PageController? _pages;
  double _fraction = 0;
  late int _index = _templates.length * _loops;
  Timer? _timer;

  /// Running after a touch; auto-advance restarts when it fires.
  Timer? _quiet;
  bool _resumed = true;

  /// Set while the timer turns the page, so it isn't announced.
  bool _auto = false;

  StoryTemplate get _current => _templates[_index % _templates.length];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startAdvancing();
  }

  void _startAdvancing() {
    _timer?.cancel();
    _timer = Timer.periodic(FeaturedTemplates.advanceEvery, (_) => _tick());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The first photos, so the carousel doesn't flash on first swipe.
    for (final t in _templates.take(3)) {
      if (t.photo case final photo?) {
        unawaited(precacheImage(AssetImage(photo), context));
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      _resumed = state == AppLifecycleState.resumed;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _quiet?.cancel();
    _pages?.dispose();
    super.dispose();
  }

  /// Off with animations disabled or a screen reader, while Home isn't on
  /// screen or the app isn't in front, and for a while after a touch.
  bool get _mayAdvance {
    if (!mounted || !_resumed) return false;
    final media = MediaQuery.of(context);
    if (media.disableAnimations || media.accessibleNavigation) return false;
    if (!TickerMode.valuesOf(context).enabled) return false;
    return ModalRoute.of(context)?.isCurrent ?? true;
  }

  void _tick() {
    final pages = _pages;
    if (pages == null || !pages.hasClients || !_mayAdvance) return;
    _auto = true;
    unawaited(
      pages
          .animateToPage(
            _index + 1,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOutCubic,
          )
          .whenComplete(() => _auto = false),
    );
  }

  /// Stops advancing, then starts again 10 s after the last touch.
  void _touched() {
    _timer?.cancel();
    _quiet?.cancel();
    _quiet = Timer(FeaturedTemplates.pauseAfterTouch, () {
      if (mounted) _startAdvancing();
    });
  }

  void _pageChanged(int index) {
    setState(() => _index = index);
    if (!_auto) {
      final l10n = context.l10n;
      unawaited(
        SemanticsService.sendAnnouncement(
          View.of(context),
          l10n.homeTemplateOf(
            index % _templates.length + 1,
            _templates.length,
          ),
          Directionality.of(context),
        ),
      );
    }
  }

  PageController _controllerFor(double fraction) {
    if (_pages == null || (fraction - _fraction).abs() > 0.001) {
      final old = _pages;
      _pages = PageController(
        viewportFraction: fraction,
        initialPage: _index,
      );
      _fraction = fraction;
      if (old != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      }
    }
    return _pages!;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPro = ref.watch(isProProvider);
    final current = _current;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Compact (Francisco, 18 Nov 2026): about a third of the width, so
        // the activities show under it.
        final card = (width * 0.34).clamp(120.0, 160.0);
        final pages = _controllerFor(math.min(1, (card + _gap) / width));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Listener(
              onPointerDown: (_) => _touched(),
              child: SizedBox(
                height: card * 16 / 9,
                child: PageView.builder(
                  controller: pages,
                  onPageChanged: _pageChanged,
                  itemBuilder: (context, i) => AnimatedBuilder(
                    animation: pages,
                    builder: (context, child) {
                      final page =
                          pages.hasClients && pages.position.haveDimensions
                              ? pages.page ?? _index.toDouble()
                              : _index.toDouble();
                      final away = (i - page).abs().clamp(0.0, 1.0);
                      return Center(
                        child: Transform.scale(
                          scale: 1 - 0.18 * away,
                          child: Opacity(
                            opacity: 1 - 0.15 * away,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: _Card(
                      template: _templates[i % _templates.length],
                      width: card,
                      isPro: isPro,
                      onTap: () {
                        if (i == _index) {
                          unawaited(
                            context.push(
                              AppRoutes.template(
                                _templates[i % _templates.length].id,
                              ),
                            ),
                          );
                        } else {
                          pages.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: _Dots(
                count: _templates.length,
                active: _index % _templates.length,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          current.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.section.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          templateWhat(l10n, current, isPro: isPro),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body.copyWith(
                            fontSize: 13,
                            color: AppColors.neutral40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                    ),
                    onPressed: () =>
                        useTemplate(context, current, isPro: isPro),
                    child: Text(l10n.templateUse),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.template,
    required this.width,
    required this.isPro,
    required this.onTap,
  });

  final StoryTemplate template;
  final double width;
  final bool isPro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: '${template.name}, ${templateWhat(l10n, template, isPro: isPro)}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: width * 16 / 9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2E000000),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                TemplateCanvas(template: template, watermark: false),
                if (templateLocked(template, isPro: isPro))
                  const Positioned(top: 10, right: 10, child: ProBadge()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One dot per template: the active one a short bar.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < count; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(left: 6),
                width: i == active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color:
                      i == active ? AppColors.primary50 : AppColors.neutral80,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      );
}
