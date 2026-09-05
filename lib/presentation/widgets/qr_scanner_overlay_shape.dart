import 'package:flutter/material.dart';

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 10,
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final left = rect.left + (rect.width - cutOutSize) / 2;
    final top = rect.top + (rect.height - cutOutSize) / 2;

    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, cutOutSize, cutOutSize),
          Radius.circular(borderRadius),
        ),
      );

    canvas.drawPath(
      Path.combine(PathOperation.difference, Path()..addRect(rect), cutoutPath),
      backgroundPaint,
    );

    final cornerPath = Path();
    cornerPath.moveTo(left, top + borderLength);
    cornerPath.lineTo(left, top + borderRadius);
    cornerPath.arcToPoint(
      Offset(left + borderRadius, top),
      radius: Radius.circular(borderRadius),
    );
    cornerPath.lineTo(left + borderLength, top);

    cornerPath.moveTo(left + cutOutSize - borderLength, top);
    cornerPath.lineTo(left + cutOutSize - borderRadius, top);
    cornerPath.arcToPoint(
      Offset(left + cutOutSize, top + borderRadius),
      radius: Radius.circular(borderRadius),
    );
    cornerPath.lineTo(left + cutOutSize, top + borderLength);

    cornerPath.moveTo(left + cutOutSize, top + cutOutSize - borderLength);
    cornerPath.lineTo(left + cutOutSize, top + cutOutSize - borderRadius);
    cornerPath.arcToPoint(
      Offset(left + cutOutSize - borderRadius, top + cutOutSize),
      radius: Radius.circular(borderRadius),
    );
    cornerPath.lineTo(left + cutOutSize - borderLength, top + cutOutSize);

    cornerPath.moveTo(left + borderLength, top + cutOutSize);
    cornerPath.lineTo(left + borderRadius, top + cutOutSize);
    cornerPath.arcToPoint(
      Offset(left, top + cutOutSize - borderRadius),
      radius: Radius.circular(borderRadius),
    );
    cornerPath.lineTo(left, top + cutOutSize - borderLength);

    canvas.drawPath(cornerPath, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
