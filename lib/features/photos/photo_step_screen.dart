import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/router.dart';
import 'package:run4share/features/photos/photo_library.dart';

/// Step 1 of making an image: the system photo picker opens straight
/// away (no permission, Google Play's photo policy). A chosen photo goes
/// on to the crop step in place of this screen; backing out goes back.
class PhotoStepScreen extends ConsumerStatefulWidget {
  const PhotoStepScreen({required this.activityId, super.key});

  final int activityId;

  @override
  ConsumerState<PhotoStepScreen> createState() => _PhotoStepScreenState();
}

class _PhotoStepScreenState extends ConsumerState<PhotoStepScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_pick()));
  }

  Future<void> _pick() async {
    final router = GoRouter.of(context);
    String? photoId;
    try {
      photoId = await ref.read(photoLibraryProvider).pick();
    } on Object catch (error) {
      debugPrint('Photo picker failed: $error');
    }
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

  // Shown only for the moment before the picker covers it.
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(AppIcons.back, size: 30),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => context.pop(),
          ),
        ),
      );
}
