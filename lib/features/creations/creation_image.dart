import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';
import 'package:run4share/data/creation_repository.dart';
import 'package:run4share/data/database.dart';

/// A creation's image file, at its own aspect ratio. Sticker-only images
/// sit on a dark tile so their transparency reads as such.
class CreationImage extends ConsumerWidget {
  const CreationImage({
    required this.creation,
    this.cacheWidth,
    super.key,
  });

  final Creation creation;

  /// Decode at this width (grid thumbnails) instead of full size.
  final int? cacheWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AspectRatio(
      aspectRatio: creation.width / creation.height,
      child: ColoredBox(
        color: creation.stickerOnly
            ? AppColors.neutral20
            : Theme.of(context).colorScheme.surfaceContainer,
        child: FutureBuilder<File>(
          future: ref.watch(creationRepositoryProvider).file(creation),
          builder: (context, snapshot) {
            final file = snapshot.data;
            if (file == null) return const SizedBox.expand();
            return Image.file(
              file,
              fit: BoxFit.contain,
              cacheWidth: cacheWidth,
              gaplessPlayback: true,
              errorBuilder: (context, error, stack) => const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

/// "Today", "Yesterday" or "10 Nov".
String creationDay(
  DateTime created,
  DateTime now, {
  required String today,
  required String yesterday,
  required String Function(DateTime) date,
}) {
  final day = DateTime(created.year, created.month, created.day);
  final current = DateTime(now.year, now.month, now.day);
  final days = current.difference(day).inDays;
  if (days == 0) return today;
  if (days == 1) return yesterday;
  return date(created);
}
