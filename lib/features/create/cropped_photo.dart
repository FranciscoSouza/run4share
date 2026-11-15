import 'dart:typed_data';

import 'package:run4share/app/material.dart';

/// Shows the [crop] part (fractions 0–1) of a photo, filling a box of
/// [aspectRatio]. Used by the preview now and the editor later.
class CroppedPhoto extends StatelessWidget {
  const CroppedPhoto({
    required this.bytes,
    required this.crop,
    required this.aspectRatio,
    super.key,
  });

  final Uint8List bytes;
  final Rect crop;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: LayoutBuilder(
        builder: (context, box) {
          final width = box.maxWidth / crop.width;
          final height = box.maxHeight / crop.height;
          return ClipRect(
            child: Stack(
              children: [
                Positioned(
                  left: -crop.left * width,
                  top: -crop.top * height,
                  width: width,
                  height: height,
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
