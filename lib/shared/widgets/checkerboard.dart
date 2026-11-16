import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_colors.dart';

/// The grey checks that mean "transparent", behind sticker-only images.
class Checkerboard extends CustomPainter {
  const Checkerboard();

  @override
  void paint(Canvas canvas, Size size) {
    const cell = 12.0;
    final a = Paint()..color = AppColors.neutral20;
    final b = Paint()..color = AppColors.neutral10;
    for (var y = 0.0; y < size.height; y += cell) {
      for (var x = 0.0; x < size.width; x += cell) {
        final odd = ((x / cell).floor() + (y / cell).floor()).isOdd;
        canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), odd ? a : b);
      }
    }
  }

  @override
  bool shouldRepaint(Checkerboard oldDelegate) => false;
}
