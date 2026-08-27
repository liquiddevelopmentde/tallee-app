import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tallee/core/custom_theme.dart';

class CountdownPainter extends CustomPainter {
  final double progress;
  final Color color;

  CountdownPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = ui.StrokeCap.round;

    final path = ui.Path();

    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    const double radius = CustomTheme.standardBorderRadius - 2;

    path.addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(radius)));

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final extractPath = metric.extractPath(0, metric.length * progress);

    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(CountdownPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
