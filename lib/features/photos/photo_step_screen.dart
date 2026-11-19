import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/photos/photo_access_views.dart';
import 'package:run4share/features/photos/photo_library.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/icon_tile.dart';

/// Whether run4share already showed the system photo prompt. Android
/// reports "never asked" and "denied" the same way, so this tells the
/// explainer screen apart from the "access is off" one.
const photosAskedPreference = 'photos.asked';

enum _Stage { checking, explain, off, pick }

/// Step 1 of making an image: get photo access, then choose a photo.
class PhotoStepScreen extends ConsumerStatefulWidget {
  const PhotoStepScreen({required this.activityId, super.key});

  final int activityId;

  @override
  ConsumerState<PhotoStepScreen> createState() => _PhotoStepScreenState();
}

class _PhotoStepScreenState extends ConsumerState<PhotoStepScreen> {
  _Stage _stage = _Stage.checking;
  PhotoAccess _access = PhotoAccess.denied;
  late final AppLifecycleListener _lifecycle;

  PhotoLibrary get _library => ref.read(photoLibraryProvider);
  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  void initState() {
    super.initState();
    // Back from the phone's settings: check again.
    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (_stage == _Stage.off) unawaited(_check());
      },
    );
    unawaited(_check());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    // Android: the system picker, no permission screens (Google Play's
    // photo policy). Backing out of it goes back.
    if (_library.usesSystemPicker) {
      await _pickWithSystem();
      return;
    }
    final access = await _library.access();
    final asked = await _db.readPreference(photosAskedPreference) == 'true';
    if (!mounted) return;
    setState(() {
      _access = access;
      _stage = switch (access) {
        PhotoAccess.granted || PhotoAccess.limited => _Stage.pick,
        PhotoAccess.denied => asked ? _Stage.off : _Stage.explain,
      };
    });
  }

  Future<void> _pickWithSystem() async {
    final router = GoRouter.of(context);
    final photoId = await _library.pickWithSystemPicker();
    if (!mounted) return;
    if (photoId == null) {
      router.pop();
    } else {
      unawaited(
        router.pushReplacement(
          AppRoutes.cropPicked(widget.activityId, photoId),
        ),
      );
    }
  }

  Future<void> _ask() async {
    await _db.writePreference(photosAskedPreference, 'true');
    final access = await _library.requestAccess();
    if (!mounted) return;
    setState(() {
      _access = access;
      _stage = access == PhotoAccess.denied ? _Stage.off : _Stage.pick;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final back = IconButton(
      icon: const Icon(AppIcons.back, size: 30),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () => context.pop(),
    );

    return switch (_stage) {
      _Stage.checking => Scaffold(appBar: AppBar(leading: back)),
      _Stage.explain => Scaffold(
          appBar: AppBar(leading: back),
          body: PhotoAccessView(
            icon: AppIcons.image,
            title: l10n.photoAccessTitle,
            body: l10n.photoAccessBody,
            action: l10n.actionContinue,
            onAction: _ask,
            secondary: l10n.actionNotNow,
            onSecondary: () => context.pop(),
          ),
        ),
      _Stage.off => Scaffold(
          appBar: AppBar(leading: back),
          body: PhotoAccessView(
            icon: photoAccessOffIcon,
            highlight: false,
            title: l10n.photoAccessOffTitle,
            body: l10n.photoAccessOffBody,
            action: l10n.actionOpenSettings,
            onAction: _library.openSettings,
            secondary: l10n.actionBackToActivities,
            onSecondary: () => context.go(AppRoutes.activities),
          ),
        ),
      _Stage.pick => _PhotoPicker(
          activityId: widget.activityId,
          limited: _access == PhotoAccess.limited,
          back: back,
        ),
    };
  }
}

class _PhotoPicker extends ConsumerStatefulWidget {
  const _PhotoPicker({
    required this.activityId,
    required this.limited,
    required this.back,
  });

  final int activityId;
  final bool limited;
  final Widget back;

  @override
  ConsumerState<_PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends ConsumerState<_PhotoPicker> {
  static const _pageSize = 60;
  static const _thumbSize = 300;
  static const _maxCached = 400;

  List<PhotoAlbum> _albums = const [];
  PhotoAlbum? _album;
  final _photos = <String>[];
  final _thumbs = <String, Future<Uint8List?>>{};
  int _nextPage = 0;
  bool _loading = true;
  bool _end = false;

  PhotoLibrary get _library => ref.read(photoLibraryProvider);

  @override
  void initState() {
    super.initState();
    unawaited(_loadAlbums());
  }

  Future<void> _loadAlbums() async {
    final albums = await _library.albums();
    if (!mounted) return;
    setState(() {
      _albums = albums;
      _album = albums.isEmpty ? null : albums.first;
    });
    await _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _photos.clear();
      _thumbs.clear();
      _nextPage = 0;
      _end = false;
      _loading = true;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    final album = _album;
    if (album == null) {
      setState(() => _loading = false);
      return;
    }
    if (_end) return;
    final page = _nextPage++;
    final ids = await _library.photos(album, page: page, pageSize: _pageSize);
    if (!mounted || album != _album) return;
    setState(() {
      _photos.addAll(ids);
      _end = ids.length < _pageSize;
      _loading = false;
    });
  }

  Future<Uint8List?> _thumb(String id) {
    if (_thumbs.length > _maxCached) _thumbs.clear();
    return _thumbs[id] ??= _library.thumbnail(id, size: _thumbSize);
  }

  String _albumName(PhotoAlbum album) =>
      album.isAll ? context.l10n.photosRecents : album.name;

  Future<void> _chooseAlbum() async {
    final chosen = await showModalBottomSheet<PhotoAlbum>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final album in _albums)
              ListTile(
                title: Text(_albumName(album)),
                trailing: Text('${album.count}'),
                selected: album.id == _album?.id,
                onTap: () => Navigator.pop(context, album),
              ),
          ],
        ),
      ),
    );
    if (chosen == null || chosen.id == _album?.id) return;
    setState(() => _album = chosen);
    await _reload();
  }

  bool _onScroll(ScrollNotification notification) {
    if (!_loading && !_end && notification.metrics.extentAfter < 800) {
      _loading = true;
      unawaited(_loadMore());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final activity = ref.watch(activityByIdProvider(widget.activityId)).value;
    final album = _album;

    return Scaffold(
      appBar: AppBar(
        leading: widget.back,
        title: album == null
            ? Text(l10n.photosRecents)
            : TextButton(
                onPressed: _albums.length > 1 ? _chooseAlbum : null,
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface,
                  textStyle: theme.appBarTheme.titleTextStyle,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        _albumName(album),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_albums.length > 1) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(AppIcons.down, size: 22),
                    ],
                  ],
                ),
              ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (activity != null) _ActivityLine(activity: activity),
          if (widget.limited)
            _LimitedBanner(
              onManage: () async {
                await _library.manageLimitedAccess();
                await _loadAlbums();
              },
            ),
          Expanded(
            child: _photos.isEmpty
                ? Center(
                    child: _loading
                        ? const CircularProgressIndicator()
                        : Text(
                            l10n.photosEmpty,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: _onScroll,
                    child: GridView.builder(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.paddingOf(context).bottom,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                      ),
                      itemCount: _photos.length,
                      itemBuilder: (context, index) {
                        final id = _photos[index];
                        return _Thumbnail(
                          key: ValueKey(id),
                          bytes: _thumb(id),
                          label: l10n.photoNumber(index + 1),
                          onTap: () => context.push(
                            AppRoutes.crop(widget.activityId, id),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ActivityLine extends ConsumerWidget {
  const _ActivityLine({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final format = ActivityFormat(
      l10n: context.l10n,
      locale: Localizations.localeOf(context).toString(),
      units: ref.watch(unitsProvider),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xs,
        AppSpacing.page,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          IconTile(
            icon: format.icon(sportKindOf(activity.sportType)),
            size: 32,
            background: AppColors.primary95,
            foreground: AppColors.primary40,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: activity.name,
                style: theme.textTheme.titleMedium,
                children: [
                  TextSpan(
                    text: ' · ${context.l10n.photosChooseOne}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitedBanner extends StatelessWidget {
  const _LimitedBanner({required this.onManage});

  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.primaryContainer,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.photosLimited,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: onManage,
            child: Text(context.l10n.actionManage),
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.bytes,
    required this.label,
    required this.onTap,
    super.key,
  });

  final Future<Uint8List?> bytes;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: FutureBuilder<Uint8List?>(
            future: bytes,
            builder: (context, snapshot) {
              final data = snapshot.data;
              if (data == null) return const SizedBox.expand();
              return Image.memory(
                data,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                excludeFromSemantics: true,
              );
            },
          ),
        ),
      ),
    );
  }
}
